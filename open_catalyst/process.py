import json
from pathlib import Path

for dir in Path(__file__).parent.glob('results/*'):
    with open(dir/'mlperf.log') as f:
        for line in f:
            obj = json.loads(line.removeprefix(':::MLLOG '))
            t = int(obj['time_ms'])
            match obj['key']:
                case 'run_start':
                    start = t
                case 'run_stop':
                    stop = t
    print(dir.name.split('-')[-1], stop - start)
