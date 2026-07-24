"""
Utility functions for loading configs and instructions.
"""

import json
from pathlib import Path
from typing import List, Optional

from .instruction import Instruction, parse_instruction

def load_config(config_path: Path) -> dict:
    with open(config_path, encoding='utf-8') as f:
        return json.load(f)

def load_instructions(input_path: Path, config: dict) -> List[Instruction]:
    instructions = []
    inst_id = 1
    
    if isinstance(input_path, str):
        input_path = Path(input_path)
        
    if input_path.suffix == ".json":
        with open(input_path, encoding="utf-8") as f:
            data = json.load(f)  # fixed: was json.open
            # Expecting a list of instruction strings
            for line in data:
                instr = parse_instruction(line, inst_id, config)
                if instr:
                    instructions.append(instr)
                    inst_id += 1
    else:
        # Text file
        with open(input_path, encoding="utf-8") as f:
            for line in f:
                instr = parse_instruction(line, inst_id, config)
                if instr:
                    instructions.append(instr)
                    inst_id += 1
        
    return instructions

def print_cycle_table(data):
    """pretty prints for data that comes later"""
    print(data)