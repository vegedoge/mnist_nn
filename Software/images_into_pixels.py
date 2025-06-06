import struct
import numpy as np

# Load MNIST image file
def read_images(path):
    with open(path, 'rb') as f:
        magic, num, rows, cols = struct.unpack(">IIII", f.read(16))
        data = np.frombuffer(f.read(), dtype=np.uint8)
        return data.reshape(num, rows * cols)

# Load MNIST label file
def read_labels(path):
    with open(path, 'rb') as f:
        magic, num = struct.unpack(">II", f.read(8))
        labels = np.frombuffer(f.read(), dtype=np.uint8)
        return labels

# Read and process the first 10 test samples
images = read_images("t10k-images.idx3-ubyte")[:1000]
labels = read_labels("t10k-labels.idx1-ubyte")[:1000]

# Binarize (threshold at 128)
images_bin = (images > 128).astype(np.uint8)

# Save to .mem for Verilog
with open("mnist_test_1000.mem", "w") as f:
    for img in images_bin:
        for bit in img:
            f.write(f"{bit}\n")

# Save labels
with open("mnist_test_1000_labels.mem", "w") as f:
    for label in labels:
        f.write(f"{label}\n")

print("✅ Generated: mnist_test_1000.mem and mnist_test_1000_labels.mem")
