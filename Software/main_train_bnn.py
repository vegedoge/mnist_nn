#!/usr/bin/env python3
"""
main_bnn_mnist.py

Trains a binary neural network on MNIST using optional hyperparameter optimization.

Run without HPO:
    python3 main_bnn_mnist.py

Run with hyperparameter optimization:
    python3 main_bnn_mnist.py --search

Add --plot to visualize correct and incorrect predictions.
Add --dump to export model weights and test images in hex.
"""


# ----------------------------
# 1) Imports and Setup
# ----------------------------
import os
import argparse
import time
import random
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader, random_split
import matplotlib.pyplot as plt
import numpy as np

# ----------------------------
# 2) Binary Layers and Model
# ----------------------------
class BinarizeF(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input):
        return input.sign()
    @staticmethod
    def backward(ctx, grad_output):
        return grad_output    

# Binary Convolutional Layer (weights and activations binary)
class BinaryConv2d(nn.Conv2d):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, bias=False, **kwargs)

    def forward(self, input):
        # binary_weight = self.weight.sign()
        binary_weight = BinarizeF.apply(self.weight)
        # binary_input = input.sign()
        binary_input = BinarizeF.apply(input)
        return F.conv2d(binary_input, binary_weight, None, self.stride,
                        self.padding, self.dilation, self.groups)

# Weight-Binarized Convolution (only weights binary)
class WeightBinaryConv2d(nn.Conv2d):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, bias=False, **kwargs)
    def forward(self, input):
        # binary_weight = self.weight.sign()
        binary_weight = BinarizeF.apply(self.weight)
        return F.conv2d(input, binary_weight, None, self.stride,
                        self.padding, self.dilation, self.groups)

# Binary Fully Connected Layer
class BinaryLinear(nn.Linear):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, bias=False, **kwargs)
    def forward(self, input):
        # binary_weight = self.weight.sign()
        binary_weight = BinarizeF.apply(self.weight)
        # binary_input = input.sign()
        binary_input = BinarizeF.apply(input)
        return F.linear(binary_input, binary_weight, None)

# Selective Binarized Neural Network Model
class BNN(nn.Module):
    def __init__(self):
        super(BNN, self).__init__()
        # First layer: weight-binarized convolution (input real, weights ±1)
        self.conv1 = WeightBinaryConv2d(1, 8, kernel_size=3, padding=0)
        self.pool1 = nn.MaxPool2d(2)
        # Second layer: binary convolution (weights and activations ±1)
        self.conv2 = BinaryConv2d(8, 16, kernel_size=3, padding=0)
        self.pool2 = nn.MaxPool2d(2)
        # Final layer: real-valued fully connected
        self.fc = BinaryLinear(16 * 5 * 5, 10)

    def forward(self, x):
        # Conv1: input real, weights binarized
        x = self.conv1(x)
        # x = Binarize(x)
        x = BinarizeF.apply(x)
        x = self.pool1(x)
        # Binarize activation for next binary layer
        # x = Binarize(x)
        # Conv2: binary weights and activations
        x = self.conv2(x)
        x = self.pool2(x)
        # Flatten and final real-valued FC
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x




# ----------------------------
# 3) Training and Evaluation
# ----------------------------
def train(model, device, train_loader, optimizer, epoch):
    model.train()
    criterion = nn.CrossEntropyLoss()
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        loss.backward()
        optimizer.step()
        if batch_idx % 100 == 0:
            print(f'Train Epoch: {epoch} [{batch_idx * len(data)}/{len(train_loader.dataset)}'
                  f' ({100. * batch_idx / len(train_loader):.0f}%)]\tLoss: {loss.item():.6f}')


def test(model, device, test_loader):
    model.eval()
    criterion = nn.CrossEntropyLoss(reduction='sum')
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += criterion(output, target).item()
            pred = output.argmax(dim=1, keepdim=True)
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)
    accuracy = 100. * correct / len(test_loader.dataset)
    print(f'\nTest set: Average loss: {test_loss:.4f}, Accuracy: {correct}/{len(test_loader.dataset)}'
          f' ({accuracy:.2f}%)\n')
    return test_loss, accuracy


# ----------------------------
# 4) Dumping Functions
# ----------------------------
def dump_weights(model, out_dir="weights"):
    os.makedirs(out_dir, exist_ok=True)
    # Conv1
    os.makedirs("weights/conv1", exist_ok=True)
    w1 = model.conv1.weight.data.sign().cpu().numpy()
    for o in range(w1.shape[0]):
        with open(f"{out_dir}/conv1/weight_ch{o+1}.txt", 'w') as f:
            for bit in w1[o].flatten():
                f.write(f"{1 if bit>0 else 0}\n")
    # Conv2
    os.makedirs("weights/conv2", exist_ok=True)
    w2 = model.conv2.weight.data.sign().cpu().numpy()
    for o in range(w2.shape[0]):
        with open(f"{out_dir}/conv2/weight_ch{o+1}.txt", 'w') as f:
            for bit in w2[o].flatten():
                f.write(f"{1 if bit>0 else 0}\n")
    # FC
    os.makedirs("weights/fc", exist_ok=True)
    w3 = model.fc.weight.data.sign().cpu().numpy()
    for o in range(w3.shape[0]):
        with open(f"{out_dir}/fc/weight_ch{o+1}.txt", 'w') as f:
            for val in w3[o].flatten():
                # f.write(f"{val:.6f}\n")
                f.write(f"{1 if val>0 else 0}\n")
    print(f"Weights dumped to '{out_dir}/'")


def dump_test_images_hex_linewise(test_loader, img_file="test_images_hex.txt", label_file="test_labels.txt"):
    with open(img_file, 'w') as img_f, open(label_file, 'w') as lbl_f:
        for data, targets in test_loader:
            # imgs = data
            imgs = data.clamp(0, 255).to(torch.uint8)  # [0, 255]
            for img, label in zip(imgs, targets):
                flat = img.view(-1).tolist()
                hex_line = ' '.join(f"{val:02X}" for val in flat)  # 2-digit hex
                img_f.write(hex_line + '\n')
                lbl_f.write(f"{label.item()}\n")
    print(f"Images dumped to '{img_file}', labels to '{label_file}'")

# ----------------------------
# 5) Hyperparameter Search
# ----------------------------
def hyperparam_search(device, train_set, val_set):
    from itertools import product

    best_acc, best_cfg = 0, (64, 'Adam', 0.001)
    configs = list(product([32, 64, 128], ['SGD', 'Adam'], [1e-4, 1e-3, 1e-2]))

    for bs, opt, lr in configs:
        print(f"Testing config: BS={bs}, OPT={opt}, LR={lr}")
        model = BNN().to(device)

        if opt == 'SGD':
            optimizer = optim.SGD(model.parameters(), lr=lr)
        else:
            optimizer = optim.Adam(model.parameters(), lr=lr)

        train_loader = DataLoader(train_set, batch_size=bs, shuffle=True)
        val_loader = DataLoader(val_set, batch_size=bs)

        # Train for 5 epochs
        for epoch in range(1, 6):
            train(model, device, train_loader, optimizer, epoch)

        # Evaluate on validation set
        _, acc = test(model, device, val_loader)

        if acc > best_acc:
            best_acc = acc
            best_cfg = (bs, opt, lr)
            print(f"New best config: {best_cfg} -> {best_acc:.2f}%")

    return best_cfg


# ----------------------------
# 6) Visualization
# ----------------------------
def plot_predictions(model, test_loader, device):
    correct, wrong = [], []
    model.eval()
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            preds = output.argmax(1)
            for img, pred, label in zip(data, preds, target):
                (correct if pred == label else wrong).append((img.cpu(), pred.item(), label.item()))
                if len(correct) >= 3 and len(wrong) >= 2:
                    break
            if len(correct) >= 3 and len(wrong) >= 2:
                break

    fig, axs = plt.subplots(1, 5, figsize=(12, 3))
    for ax, (img, pred, label) in zip(axs, correct + wrong):
        ax.imshow(img.squeeze(), cmap='gray')
        ax.set_title(f"Pred: {pred}\nTrue: {label}")
        ax.axis('off')
    plt.tight_layout()
    plt.show()


# ----------------------------
# 7) Main
# ----------------------------
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--search', action='store_true', help="Enable hyperparameter search")
    parser.add_argument('--plot', action='store_true', help="Plot example predictions")
    parser.add_argument('--dump', action='store_true', help="Dump weights and images")
    args = parser.parse_args()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Lambda(lambda x: x * 255.0),
    ])

    train_dataset = datasets.MNIST('./data', train=True, download=True, transform=transform)
    test_dataset = datasets.MNIST('./data', train=False, transform=transform)
    train_size = int(0.9 * len(train_dataset))
    val_size = len(train_dataset) - train_size
    train_set, val_set = random_split(train_dataset, [train_size, val_size])

    if args.search:
        bs, opt_name, lr = hyperparam_search(device, train_set, val_set)
    else:
        bs, opt_name, lr = 128, 'Adam', 0.001

    print(f"Using config: BS={bs}, OPT={opt_name}, LR={lr}")
    # train_val_set = torch.utils.data.ConcatDataset([train_set, val_set])
    train_loader = DataLoader(train_set, batch_size=bs, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=1000, shuffle=False)

    # train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
    # test_loader = DataLoader(test_dataset, batch_size=1000, shuffle=False)

    model = BNN().to(device)
    optimizer = getattr(optim, opt_name)(model.parameters(), lr=lr)
    # optimizer = optim.Adam(model.parameters(), lr=0.001)

    # criterion = nn.CrossEntropyLoss()

    epochs = 10
    for epoch in range(1, epochs + 1):
        train(model, device, train_loader, optimizer, epoch)
        test(model, device, test_loader)

    torch.save(model.state_dict(), "bnn_model.pth")
    print("Model saved as bnn_model.pth")

    dump_weights(model)

    if args.dump:
        dump_test_images_hex_linewise(test_loader)

    if args.plot:
        plot_predictions(model, test_loader, device)


if __name__ == "__main__":
    main()