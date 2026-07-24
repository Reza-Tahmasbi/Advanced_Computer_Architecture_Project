"""
Tomasulo's algorithm implementation.
"""

from typing import List, Dict, Optional
from .instruction import Instruction

class ReservationStation:
    def __init__(self, name: str):
        self.name = name
        self.busy = False
        self.op = None
        self.vj = None
        self.vk = None
        self.qj = None
        self.qk = None
        self.dest = None
        self.remaining_cycles = 0
        self.instr_id = None

class Tomasulo:
    def __init__(self, config: dict, instructions: List[Instruction]):
        self.config = config
        self.instructions = instructions
        self.cycle = 0
        self.rs = {
            "ALU": [ReservationStation(f"ALU{i}") for i in range(3)],
            "MULT": [ReservationStation(f"MULT{i}") for i in range(2)],
            "LOAD_STORE": [ReservationStation(f"LS{i}") for i in range(2)]
        }
        self.register_tags = {reg: None for reg in config.get("registers", [])}
        self.register_values = {reg: 0 for reg in config.get("registers", [])}
        self._state_history: List[Dict] = []  # NEW

    def run(self):
        print("Starting Tomasulo simulation...")
        while not self._is_finished():
            self.cycle += 1
            self._issue_stage()
            self._execute_stage()
            self._write_result_stage()
            if self.cycle > 200:
                print("Safety limit reached")
                break
            self.print_state(self.cycle)
            # NEW: capture state after each cycle
            self._state_history.append(self._get_state_snapshot())
        for instr in self.instructions:
            if getattr(instr, 'writeback_cycle', None) is None:
                instr.writeback_cycle = self.cycle
        print(f"Tomasulo simulation finished in {self.cycle} cycles.")
        self.print_timing_table()

    def _get_state_snapshot(self) -> Dict:
        rs_snap = {}
        for fu_type, stations in self.rs.items():
            for rs in stations:
                if rs.busy:
                    rs_snap[rs.name] = {
                        "op": rs.op,
                        "busy": rs.busy,
                        "qj": rs.qj,
                        "qk": rs.qk,
                        "vj": rs.vj,
                        "vk": rs.vk,
                        "remaining": rs.remaining_cycles
                    }
                else:
                    rs_snap[rs.name] = {"busy": False}
        return {
            "cycle": self.cycle,
            "reservation_stations": rs_snap,
            "register_tags": self.register_tags.copy()
        }

    def get_state_history(self) -> List[Dict]:
        return self._state_history

    def _is_finished(self):
        return all(getattr(i, 'writeback_cycle', None) is not None for i in self.instructions)

    def _issue_stage(self):
        for instr in self.instructions:
            if getattr(instr, 'issue_cycle', None) is not None:
                continue
            rs_list = self.rs.get(instr.fu_type, [])
            for rs in rs_list:
                if not rs.busy:
                    rs.busy = True
                    rs.op = instr.op
                    rs.dest = instr.dest
                    rs.instr_id = instr.id
                    instr.issue_cycle = self.cycle
                    print(f"Issued I{instr.id} to {rs.name} at cycle {self.cycle}")
                    self._set_rs_operands(rs, instr)
                    if instr.dest:
                        self.register_tags[instr.dest] = rs.name
                    break
            else:
                continue
            break

    def _set_rs_operands(self, rs, instr):
        for src_field, q_field, v_field in [(instr.src1, 'qj', 'vj'), (instr.src2, 'qk', 'vk')]:
            if src_field and src_field.startswith('R'):
                tag = self.register_tags.get(src_field)
                if tag:
                    setattr(rs, q_field, tag)
                    setattr(rs, v_field, None)
                else:
                    setattr(rs, q_field, None)
                    setattr(rs, v_field, 0)
            else:
                setattr(rs, q_field, None)
                setattr(rs, v_field, 0)

    def _execute_stage(self):
        for stations in self.rs.values():
            for rs in stations:
                if rs.busy and rs.remaining_cycles == 0 and rs.qj is None and rs.qk is None:
                    instr = next((i for i in self.instructions if i.id == rs.instr_id), None)
                    if instr and getattr(instr, 'exec_start_cycle', None) is None:
                        instr.exec_start_cycle = self.cycle
                        rs.remaining_cycles = instr.latency
                if rs.remaining_cycles > 0:
                    rs.remaining_cycles -= 1

    def _write_result_stage(self):
        for stations in self.rs.values():
            for rs in stations:
                if rs.busy and rs.remaining_cycles == 0:
                    instr = next((i for i in self.instructions if i.id == rs.instr_id), None)
                    if instr and getattr(instr, 'writeback_cycle', None) is None:
                        instr.writeback_cycle = self.cycle
                        rs.busy = False
                        print(f"  CDB WB I{instr.id} ({instr.op}) at cycle {self.cycle}")
                        if instr.dest:
                            self.register_tags[instr.dest] = None
                            self._broadcast_to_waiting_rs(instr.dest, rs.name)
                        break

    def _broadcast_to_waiting_rs(self, reg, tag):
        for stations in self.rs.values():
            for rs in stations:
                if rs.qj == tag or rs.qj == reg:
                    rs.qj = None
                    rs.vj = 0
                if rs.qk == tag or rs.qk == reg:
                    rs.qk = None
                    rs.vk = 0

    def get_total_cycles(self):
        return self.cycle

    def generate_report(self, output_dir=None):
        print("\n=== TOMASULO REPORT ===")
        print(f"Total cycles: {self.cycle}")
        for instr in self.instructions:
            print(instr)

    def print_timing_table(self):
        print("\n=== FINAL TIMING TABLE ===")
        print(f"{'ID':<4} {'Op':<8} {'Issue':<6} {'RO':<6} {'EX':<8} {'WB':<6}")
        for instr in self.instructions:
            issue = instr.issue_cycle if hasattr(instr, 'issue_cycle') and instr.issue_cycle is not None else '-'
            ro = getattr(instr, 'read_operands_cycle', None) or '-'
            ex = instr.exec_start_cycle if hasattr(instr, 'exec_start_cycle') and instr.exec_start_cycle is not None else '-'
            wb = instr.writeback_cycle if hasattr(instr, 'writeback_cycle') and instr.writeback_cycle is not None else '-'
            print(f"I{instr.id:<3} {instr.op:<8} {issue:<6} {ro:<6} {ex:<8} {wb:<6}")

    def print_state(self, cycle):
        print(f"\n--- Cycle {cycle} (Tomasulo) ---")
        print("Reservation Stations:")
        for fu_type, stations in self.rs.items():
            for rs in stations:
                if rs.busy:
                    vj_str = rs.vj if rs.vj is not None else '-'
                    vk_str = rs.vk if rs.vk is not None else '-'
                    print(f"  {rs.name}: {rs.op} busy={rs.busy} qj={rs.qj} qk={rs.qk} vj={vj_str} vk={vk_str} rem={rs.remaining_cycles}")
        print("Register Tags:", self.register_tags)