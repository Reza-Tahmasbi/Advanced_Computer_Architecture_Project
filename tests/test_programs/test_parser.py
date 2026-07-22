from src.utils import load_config, load_instructions

config = load_config('configs/config.json')
instrs = load_instructions('tests/test_programs/example.txt', config)

for i in instrs:
    print(i)
