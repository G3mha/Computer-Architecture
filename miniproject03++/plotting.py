import pandas as pd
import matplotlib.pyplot as plt
import os

base_dir = './'  # Adjust if needed
folders = {
    'sine': 'Sine',
    'tri': 'Triangle',
    'sqr': 'Square'
}
frequencies = ['1k', '2k', '5k', '10k']

for folder, label in folders.items():
    fig, axs = plt.subplots(len(frequencies), 1, figsize=(10, 8), sharex=True)
    fig.suptitle(f"{label} Waveforms", fontsize=14)

    for i, freq in enumerate(frequencies):
        file_path = os.path.join(base_dir, folder, f"{freq}.csv")

        # Extract Start/Increment from second row
        with open(file_path, 'r') as f:
            header = f.readline().strip().split(',')
            values = f.readline().strip().split(',')

        try:
            start = float(values[header.index("Start")])
            increment = float(values[header.index("Increment")])
        except Exception as e:
            print(f"Failed to parse start/increment from {file_path}: {e}")
            start = 0
            increment = 1e-6

        # Load data
        df = pd.read_csv(file_path, skiprows=2, usecols=[0, 1], header=None, names=["X", "CH2"])
        df["X"] = pd.to_numeric(df["X"], errors='coerce')
        df["CH2"] = pd.to_numeric(df["CH2"], errors='coerce')
        df.dropna(subset=["X", "CH2"], inplace=True)

        # Time and voltage
        time = start + df["X"] * increment
        voltage = df["CH2"]

        axs[i].plot(time, voltage)
        axs[i].set_ylabel(f"{freq} (V)")
        axs[i].set_title(f"{freq}Hz", fontsize=10)
        axs[i].grid(True)

    axs[-1].set_xlabel("Time (s)")
    plt.tight_layout(rect=[0, 0, 1, 0.95])  # Leave space for title
    plt.savefig(f"{folder}_subplots.png")
    plt.show()
