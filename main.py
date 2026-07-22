"""
Entry point for the Dynamic Instruction Scheduling Simulator.
"""

import argparse
from pathlib import Path
from src.utils import load_config, load_instructions
from src.simulator import Simulator

def main():
    parser = argparse.ArgumentParser(description="ACA Project #2 - Scoreboard & Tomasulo Simulator")
    parser.add_argument("--mode", choices=["scoreboard", "tomasulo"], default="scoreboard", help="Execution mode")
    parser.add_argument("--input", type=str, default="tests/test_programs/example.txt", help="Input program file")
    parser.add_argument("--config", type=str, default="configs/config.json", help="Config file")
    args = parser.parse_args()

    config = load_config(Path(args.config))
    instructions = load_instructions(Path(args.input), config)

    print(f"Loaded {len(instructions)} instructions.")

    sim = Simulator(config, instructions, mode=args.mode)
    sim.run()
    sim.generate_reports()

if __name__ == "__main__":
    main()