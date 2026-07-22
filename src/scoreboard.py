from typing import List, Optional, Dict
from .instruction import Instruction

class Scoreboard:
    def __init__(self, config: dict, instructions: List[Instruction]):
        self.config = config
        self.instructions = instructions
        self.cycle = 0
        self.instruction_status: Dict[int, str] = {}
        self.fu_status: Dict[str, Dict] = {}
        self.register_result: Dict[str, Optional[str]] = {reg: None for reg in config.get("registers", [])}
        
        self._init_fu_status()
        for instr in instructions:
            self.instruction_status[instr.id] = "Not Issued"

    def _init_fu_status(self):
        for fu_type, info in self.config.get("functional_units", {}).items():
            for i in range(info.get("count", 1)):
                name = f"{fu_type}{i}"
                self.fu_status[name] = {"busy": False, "op": None, "fi": None, "fj": None, "fk": None}

    def run(self):
        while not self._is_finished():
            self.cycle += 1
            self._issue_stage()
            self._read_operands_stage()
            self._execute_stage()
            self._writeback_stage()
            if self.cycle > 200:
                print("Safety limit reached")
                break
            self.print_state(self.cycle)
        self._update_instruction_cycles()
        print(f"Scoreboard simulation finished in {self.cycle} cycles.")
        self.print_timing_table()

    def _issue_stage(self):
        for instr in self.instructions:
            if instr.issue_cycle is not None:
                continue
            fu_name = self._find_free_fu(instr.fu_type)
            if fu_name and self._no_waw_hazard(instr):
                instr.issue_cycle = self.cycle
                self.instruction_status[instr.id] = "Issued"
                self._update_fu_on_issue(fu_name, instr)
                print(f"Issued I{instr.id}: {instr.op} at cycle {self.cycle}")
                break

    def _read_operands_stage(self):
        for instr in self.instructions:
            if instr.issue_cycle is None or instr.read_operands_cycle is not None:
                continue
            if self.cycle <= instr.issue_cycle:
                continue
            ready = True
            for src in [instr.src1, instr.src2]:
                if src and src.startswith('R') and self.register_result.get(src):
                    ready = False
                    break
            if ready:
                instr.read_operands_cycle = self.cycle
                print(f"  RO I{instr.id} at {self.cycle}")

    def _execute_stage(self):
        for instr in self.instructions:
            if instr.read_operands_cycle is None or instr.exec_start_cycle is not None:
                continue
            if self.cycle >= instr.read_operands_cycle:
                instr.exec_start_cycle = self.cycle
                print(f"  EX start I{instr.id} at {self.cycle}")

    def _writeback_stage(self):
        for instr in self.instructions:
            if instr.exec_start_cycle is None or instr.writeback_cycle is not None:
                continue
            if self.cycle >= instr.exec_start_cycle + instr.latency - 1:
                instr.writeback_cycle = self.cycle
                # Free FU
                for status in self.fu_status.values():
                    if status["fi"] == instr.dest:
                        status["busy"] = False
                        self.register_result[instr.dest] = None
                        print(f"  WB I{instr.id} at {self.cycle}")
                        break

    def _is_finished(self):
        return all(i.writeback_cycle is not None for i in self.instructions)

    def _update_instruction_cycles(self):
        for instr in self.instructions:
            if instr.issue_cycle is None:
                continue
            if instr.exec_start_cycle is None:
                instr.exec_start_cycle = instr.issue_cycle + 1
            if instr.writeback_cycle is None:
                instr.writeback_cycle = instr.exec_start_cycle + instr.latency

    # Helper methods (same as before)
    def _find_free_fu(self, fu_type):
        for name, status in self.fu_status.items():
            if name.startswith(fu_type) and not status["busy"]:
                return name
        return None

    def _no_waw_hazard(self, instr):
        if instr.dest and self.register_result.get(instr.dest):
            return False
        return True

    def _update_fu_on_issue(self, fu_name, instr):
        status = self.fu_status[fu_name]
        status["busy"] = True
        status["op"] = instr.op
        status["fi"] = instr.dest
        status["fj"] = instr.src1
        status["fk"] = instr.src2
        if instr.dest:
            self.register_result[instr.dest] = fu_name

    def get_total_cycles(self):
        return self.cycle

    def generate_report(self, output_dir=None):
        print(f"\n=== SCOREBOARD REPORT ===")
        print(f"Total cycles: {self.cycle}")
        for instr in self.instructions:
            print(instr)
            
    
    def print_timing_table(self):
        print("\n=== SCOREBOARD TIMING TABLE ===")
        print(f"{'ID':<4} {'Op':<8} {'Issue':<6} {'RO':<6} {'EX':<8} {'WB':<6}")
        for instr in self.instructions:
            issue = instr.issue_cycle if instr.issue_cycle is not None else '-'
            ro = getattr(instr, 'read_operands_cycle', None) or '-'
            ex = instr.exec_start_cycle if instr.exec_start_cycle is not None else '-'
            wb = instr.writeback_cycle if instr.writeback_cycle is not None else '-'
            print(f"I{instr.id:<3} {instr.op:<8} {issue:<6} {ro:<6} {ex:<8} {wb:<6}")
            
    def print_state(self, cycle):
        print(f"\n--- Cycle {cycle} (Scoreboard) ---")
        print("Instruction Status:")
        for instr in self.instructions:
            stage = "Issued" if instr.issue_cycle else "Not Issued"
            print(f"  I{instr.id} {instr.op}: {stage}")
        print("FU Status:", {name: status["busy"] for name, status in self.fu_status.items()})