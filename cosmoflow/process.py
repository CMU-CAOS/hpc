import csv
from pathlib import Path

for dir in Path(__file__).parent.glob('output/*'):
    with open(dir/'history.csv', newline='') as f:
        reader = csv.DictReader(f)
        time = sum(float(row['time']) for row in reader)
    print(dir.name, time)
