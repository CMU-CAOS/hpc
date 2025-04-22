import csv
from pathlib import Path
import statistics

for file in Path('reports').glob('1_cuda_gpu_trace.csv'):
    with open(file, newline='') as f:
        reader = csv.DictReader(f)
        durations = [int(row['Duration (ns)'])
                     for row in reader if row['GrdX']]
        p = statistics.quantiles(durations, n=100)[-1]
    print(file.stem.split('_')[0], p)
