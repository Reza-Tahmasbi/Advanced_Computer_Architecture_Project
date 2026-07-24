"""
Main simulator orchestrator with command‑line argument support.
"""

import argparse
from pathlib import Path
from typing import List

from .instruction import Instruction
from .utils import load_config, load_instructions
from .scoreboard import Scoreboard
from .tomasulo import Tomasulo


class Simulator:
    def __init__(self, config: dict, instructions: List[Instruction], mode: str = "scoreboard"):
        self.config = config
        self.instructions = instructions
        self.mode = mode.lower()
        self.cycle = 0
        self.backend = None
        
        if self.mode == "scoreboard":
            self.backend = Scoreboard(config, instructions)
        elif self.mode == "tomasulo":
            self.backend = Tomasulo(config, instructions)
        else:
            raise ValueError(f"Unknown mode: {self.mode}")
        
    def run(self):
        """Run the full simulation."""
        print(f"Starting {self.mode.upper()} simulation with {len(self.instructions)} instructions...")
        self.backend.run()
        print(f"Simulation completed in {self.backend.get_total_cycles()} cycles.")
        
    def generate_reports(self):
        print("\n" + "="*50)
        print("SIMULATION COMPLETE")
        print("="*50)
        self.backend.print_timing_table()
        print(f"\nTotal Cycles ({self.mode.upper()}): {self.backend.get_total_cycles()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Dynamic Instruction Scheduling Simulator")
    parser.add_argument("--mode", type=str, default="scoreboard",
                        choices=["scoreboard", "tomasulo"],
                        help="Scheduling mode (scoreboard or tomasulo)")
    parser.add_argument("--input", type=str, required=True,
                        help="Path to input instruction file")
    parser.add_argument("--config", type=str, default="configs/config.json",
                        help="Path to configuration file")
    args = parser.parse_args()

    config = load_config(args.config)
    instrs = load_instructions(args.input, config)
    
    sim = Simulator(config, instrs, mode=args.mode)
    sim.run()