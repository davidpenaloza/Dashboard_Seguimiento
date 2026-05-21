#!/usr/bin/env python3
import glob
import json
import sys

paths = sorted(glob.glob('Dashboard_Seguimiento_Soporte_DAA.Report/definition/pages/*/visuals/*/visual.json'))
violations = []
for p in paths:
    with open(p, encoding='utf-8') as f:
        data = json.load(f)
    if 'objects' in data:
        violations.append(p)

if violations:
    print('ERROR: visual.json con propiedad root no válida "objects":')
    for v in violations:
        print(f'- {v}')
    sys.exit(1)

print(f'OK: {len(paths)} visuales sin propiedad root "objects".')
