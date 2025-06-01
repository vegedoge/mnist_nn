import torch
from main import TinyBinCNN
import numpy as np
import os

# Load model and weights
model = TinyBinCNN()
state_dict = torch.load('tiny_bincnn_final.pth', map_location='cpu')
model.load_state_dict(state_dict)

def save_binary_mem_file(tensor, filename):
    """Save a binarized tensor as a .mem file with 0/1 values."""
    arr = tensor.detach().cpu().numpy().flatten()
    arr_bin = ((arr > 0).astype(np.uint8))  # Convert +1 → 1, -1/0 → 0

    with open(filename, 'w') as f:
        for bit in arr_bin:
            f.write(f"{bit:01b}\n")  # 1 bit per line

# Create output dir
output_dir = 'vivado_bin_files'
os.makedirs(output_dir, exist_ok=True)

# Save each weight as binary
for name, param in state_dict.items():
    if 'weight' in name:
        fname = os.path.join(output_dir, f"{name.replace('.', '_')}.mem")
        print(f"Saving {fname}")
        save_binary_mem_file(param, fname)
