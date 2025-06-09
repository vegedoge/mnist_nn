import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
import os

# # Binarization function with Straight-Through Estimator
# def Binarize(input):
#     return input.sign()

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

# Training and Evaluation

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


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Lambda(lambda x: x * 255.0),
    # transforms.Normalize((0.1307,), (0.3081,)),
    # transforms.Lambda(lambda x: torch.sign(x))
])

train_dataset = datasets.MNIST('./data', train=True, download=True, transform=transform)
test_dataset = datasets.MNIST('./data', train=False, transform=transform)
train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=1000, shuffle=False)

model = BNN().to(device)
optimizer = optim.Adam(model.parameters(), lr=0.001)

epochs = 5
for epoch in range(1, epochs + 1):
    train(model, device, train_loader, optimizer, epoch)
    test(model, device, test_loader)

torch.save(model.state_dict(), 'bnn_selective.pth')
print('Model saved as bnn_selective.pth')
dump_weights(model)
# dump_test_images_hex_linewise(test_loader)