import os
import yaml
import copy
root = 'configs/examples'
dirs = os.listdir(root)

cfg_dict = {}
for config in dirs:
    p = os.path.join(root, config)
    data = yaml.safe_load(open(p, 'r'))
    cfg_dict[data['merge_method']] = data

o_dict = {}
for name, data in cfg_dict.items():
    o_dict[name] = []
    if data['merge_method'] in ['breadcrumbs', 'dare_linear', 'ties']:
        for d in range(1, 10, 2):
            d = d/10
            r = round(1 - d, 1)
            _data = copy.deepcopy(data)
            _data['models'][0]['parameters']['density'] = d
            o_dict[name].append(_data)
    if data['merge_method'] == 'linear':
        for d in range(1, 10, 2):
            d = d/10
            r = round(1 - d, 1)
            _data = copy.deepcopy(data)
            _data['models'][0]['parameters']['weight'] = d
            _data['models'][1]['parameters']['weight'] = r
            o_dict[name].append(_data)
    if data['merge_method'] == 'della_linear':
        for d in range(1, 10, 2):
            d = d/10
            r = round(1 - d, 1)
            _data = copy.deepcopy(data)
            _data['models'][0]['parameters']['density'] = d
            _data['parameters']['epsilon'] = 0.05 if d < 0.2 or d > 0.8 else 0.2
            o_dict[name].append(_data)
    
for name, data_list in o_dict.items():
    for i, data in enumerate(data_list):
        yaml.safe_dump(data, open(f'configs/llama_{name}_{i*2+1}.yaml', 'w'), sort_keys=True)

llama_configs = [f for f in os.listdir('configs') if f.endswith('.yaml') and f.startswith('llama')]
for f in llama_configs:
    p = os.path.join('configs', f)
    text = open(p, 'r').read()
    text = text.replace('Llama3-8B', 'Qwen2.5-14B')
    open(p.replace('llama', 'qwen'), 'w').write(text)

for f in llama_configs:
    p = os.path.join('configs', f)
    text = open(p, 'r').read()
    text = text.replace('I-Llama3-8B', 'I-Phi4')
    text = text.replace('R1-Llama3-8B', 'R-Phi4')
    open(p.replace('llama', 'phi'), 'w').write(text)