#!/usr/bin/env python3
"""
tiny_bincnn_mnist_hpo.py

Defines functions for optional hyperparameter search and standard training.
Implements a 70/12/18 train/val/test split, hyperparameter search on train/val (if enabled),
and final training on train+val with test evaluation.
Run with --search to enable HPO, otherwise uses default best hyperparameters.

Run without HPO (Hyperparameter Search):
python3 main.py

With HPO (Hyperparameter Search):
python3 main.py --search

Add --plot to visualize 5 examples (3 correct, 2 incorrect).
"""

import sys
import time
import argparse
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, random_split
from torchvision import datasets, transforms
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
import numpy as np

# helper print that flushes
def flush_print(*args, **kwargs):
    print(*args, **kwargs, flush=True)

class NormalizeAndBinarize(object):
    def __call__(self, tensor):
        tensor = (tensor - 0.1307) / 0.3081
        return (tensor > 0).float()  # Adjust threshold if needed
    
def binarize_model_weights(model):
    for name, module in model.named_modules():
        if isinstance(module, (BinaryConv2d, BinaryLinear)):
            weight = module.conv.weight if hasattr(module, 'conv') else module.fc.weight
            bin_weight = weight.data.sign()
            weight.data.copy_(bin_weight)


# ----------------------------
# 1) Custom binary layers
# ----------------------------
class BinaryActivation(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x): return x.sign()
    @staticmethod
    def backward(ctx, grad_output): return grad_output

class BinaryConv2d(nn.Module):
    def __init__(self, in_ch, out_ch, k, stride=1, padding=0):
        super().__init__()
        self.conv = nn.Conv2d(in_ch, out_ch, k, stride=stride, padding=padding, bias=False)
        self.register_buffer('weight_org', self.conv.weight.data.clone())
    def forward(self, x):
        self.weight_org.copy_(self.conv.weight.data)
        self.conv.weight.data.copy_(self.conv.weight.data.sign())
        out = self.conv(x)
        self.conv.weight.data.copy_(self.weight_org)
        return out

class BinaryLinear(nn.Module):
    def __init__(self, in_features, out_features):
        super().__init__()
        self.fc = nn.Linear(in_features, out_features, bias=False)
        self.register_buffer('weight_org', self.fc.weight.data.clone())
    def forward(self, x):
        self.weight_org.copy_(self.fc.weight.data)
        self.fc.weight.data.copy_(self.fc.weight.data.sign())
        out = self.fc(x)
        self.fc.weight.data.copy_(self.weight_org)
        return out

# ----------------------------
# 2) Model definition
# ----------------------------
class TinyBinCNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.act = BinaryActivation.apply
        self.conv1 = BinaryConv2d(1, 8, 3, padding=1)
        self.bn1   = nn.BatchNorm2d(8)
        self.conv2 = BinaryConv2d(8, 16, 3, padding=1)
        self.bn2   = nn.BatchNorm2d(16)
        self.pool  = nn.MaxPool2d(2,2)
        self.fc    = BinaryLinear(7*7*16, 10)
    def forward(self, x):
        x = self.act(self.bn1(self.conv1(x)))
        x = self.pool(x)
        x = self.act(self.bn2(self.conv2(x)))
        x = self.pool(x)
        x = x.view(x.size(0), -1)
        return self.fc(x)

# ----------------------------
# 3) Train & Eval
# ----------------------------
def train_one_epoch(model, loader, optimizer, criterion, device):
    model.train()
    total_loss = 0.0
    for data, target in loader:
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        logits = model(data)
        loss = criterion(logits, target)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    return total_loss / len(loader)


def evaluate(model, loader, criterion, device):
    model.eval()
    total_loss, correct = 0.0, 0
    with torch.no_grad():
        for data, target in loader:
            data, target = data.to(device), target.to(device)
            logits = model(data)
            total_loss += criterion(logits, target).item()
            correct += logits.argmax(dim=1).eq(target).sum().item()
    return total_loss / len(loader), correct / len(loader.dataset)

# ----------------------------
# 4) Hyperparameter search
# ----------------------------
def hyperparam_search(device, train_ds, val_ds, prune_thresh=0.55):
    from itertools import product
    import random, time

    flush_print("Starting full-grid hyperparameter search (5 epochs + pruning)...")
    start = time.time()

    batch_sizes = [32, 64, 128, 256, 512]
    optimizers  = ['SGD', 'Adam', 'RMSprop']
    lrs         = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2, 0.1, 1]
    epochs      = 10
    criterion   = nn.CrossEntropyLoss()

    all_cfgs = list(product(batch_sizes, optimizers, lrs))
    random.shuffle(all_cfgs)

    best_acc, best_cfg = 0.0, (128, 'Adam', 1e-3)
    for idx, (bs, opt_name, lr) in enumerate(all_cfgs, 1):
        flush_print(f"Config {idx}/{len(all_cfgs)}: BS={bs}, OPT={opt_name}, LR={lr}")
        tr_loader  = DataLoader(train_ds, batch_size=bs, shuffle=True)
        val_loader = DataLoader(val_ds,   batch_size=bs)

        model = TinyBinCNN().to(device)
        if opt_name == 'SGD':
            optimizer = optim.SGD(model.parameters(), lr=lr, momentum=0.9)
        elif opt_name == 'RMSprop':
            optimizer = optim.RMSprop(model.parameters(), lr=lr)
        else:
            optimizer = optim.Adam(model.parameters(), lr=lr)

        binarize_model_weights(model)
        flush_print("Weights permanently binarized for evaluation.")

        pruned = False
        for e in range(1, epochs+1):
            tr_loss = train_one_epoch(model, tr_loader, optimizer, criterion, device)
            val_loss, val_acc = evaluate(model, val_loader, criterion, device)
            flush_print(f" Ep{e} tr_loss={tr_loss:.3f} val_acc={val_acc:.3f}")
            if e >= 3 and val_acc < prune_thresh:
                flush_print(f" Pruned at epoch {e} (val_acc {val_acc:.3f} < {prune_thresh})")
                pruned = True
                break

        if not pruned and val_acc > best_acc:
            best_acc, best_cfg = val_acc, (bs, opt_name, lr)
            flush_print(f" New best: {best_cfg} -> acc={best_acc:.3f}")

    elapsed = (time.time() - start) / 60
    flush_print(f"Grid search done in {elapsed:.1f}m, best={best_cfg} acc={best_acc:.3f}")
    return best_cfg

# ----------------------------
# 5) Visualization: plot 5 examples with 2 wrong
# ----------------------------
def plot_five_examples(model, test_set, device, n_correct=3, n_wrong=2):
    loader = DataLoader(test_set, batch_size=1, shuffle=False)
    correct_imgs, correct_labels, correct_preds = [], [], []
    wrong_imgs, wrong_labels, wrong_preds = [], [], []

    model.eval()
    with torch.no_grad():
        for img, label in loader:
            img = img.to(device)
            pred = model(img).argmax(dim=1).cpu().item()
            true = label.item()
            if pred == true and len(correct_imgs) < n_correct:
                correct_imgs.append(img.cpu())
                correct_labels.append(true)
                correct_preds.append(pred)
            elif pred != true and len(wrong_imgs) < n_wrong:
                wrong_imgs.append(img.cpu())
                wrong_labels.append(true)
                wrong_preds.append(pred)
            if len(correct_imgs) == n_correct and len(wrong_imgs) == n_wrong:
                break

    images = correct_imgs + wrong_imgs
    trues = correct_labels + wrong_labels
    preds = correct_preds + wrong_preds

    fig, axes = plt.subplots(1, len(images), figsize=(2*len(images), 2))
    for i, ax in enumerate(axes):
        ax.imshow(images[i].squeeze(), cmap='gray')
        ax.set_title(f"True label:{trues[i]} Predicted label:{preds[i]}")
        ax.axis('off')
    plt.tight_layout()
    plt.show()

# ----------------------------
# 6) Main
# ----------------------------
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--search', action='store_true', help='Enable hyperparameter search')
    parser.add_argument('--plot',   action='store_true', help='Show example predictions')
    args = parser.parse_args()

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    transform = transforms.Compose([
        transforms.ToTensor(),
        NormalizeAndBinarize()
    ])
    full_train = datasets.MNIST('data', train=True, download=True, transform=transform)
    test_set   = datasets.MNIST('data', train=False, transform=transform)

    n = len(full_train)
    n_train = int(0.80 * n)
    n_val   = int(0.20 * n)
    train_ds, val_ds, _ = random_split(full_train, [n_train, n_val, n - n_train - n_val])
    flush_print("Step 1: Data split into train/val/test")

    if args.search:
        best_bs, best_opt, best_lr = hyperparam_search(device, train_ds, val_ds)
    else:
        best_bs, best_opt, best_lr = 64, 'RMSprop', 5e-3
    flush_print(f"Step 2: Hyperparameters -> BS={best_bs}, OPT={best_opt}, LR={best_lr}")

    train_loader = DataLoader(train_ds, batch_size=best_bs, shuffle=True)
    test_loader  = DataLoader(test_set, batch_size=best_bs)

    model = TinyBinCNN().to(device)
    if best_opt == 'SGD':
        optimizer = optim.SGD(model.parameters(), lr=best_lr, momentum=0.9)
    elif best_opt == 'RMSprop':
        optimizer = optim.RMSprop(model.parameters(), lr=best_lr)
    else:
        optimizer = optim.Adam(model.parameters(), lr=best_lr)
    criterion = nn.CrossEntropyLoss()

    #Binarize Weights
    binarize_model_weights(model)
    flush_print("Weights permanently binarized for evaluation.")


    flush_print("Step 3: Starting final training")
    for epoch in range(1, 11):
        tr_loss = train_one_epoch(model, train_loader, optimizer, criterion, device)
        flush_print(f"Epoch {epoch:2d} | Train Loss: {tr_loss:.4f}")

    te_loss, te_acc = evaluate(model, test_loader, criterion, device)
    flush_print(f"Final Test Loss: {te_loss:.4f} | Final Test Acc: {te_acc:.4f}")
    flush_print("Step 4: Completed evaluation on test set.")

    torch.save(model.state_dict(), 'tiny_bincnn_final.pth')
    flush_print("Saved final model to tiny_bincnn_final.pth")

    if args.plot:
        plot_five_examples(model, test_set, device)

    return 0

if __name__ == '__main__':
    main()
