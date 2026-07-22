"""
Instruction class and parser.
"""

from dataclasses import dataclass
from typing import Optional

@dataclass
class Instruction:
    """
    Instruction class.
    """
    id: int
    op: str # Operation type, such as ADD, SUB, MUL, DIV, LOAD, or STORE.
    fu_type: str    # Required functional unit type
    latency: int    # Number of cycles required for execution.
    dest: Optional[str] = None  # Destination register
    src1: Optional[str] = None  # Source operands or registers
    src2: Optional[str] = None  # Source operands or registers
    
    # For simulation tracking
    issue_cycle: Optional[int] = None
    read_operands_cycle: Optional[int] = None
    exec_start_cycle: Optional[int] = None
    exec_end_cycle: Optional[int] = None
    writeback_cycle: Optional[int] = None
    remaining_exec_cycles: Optional[int] = None
    
    
def parse_instruction(line: str, inst_id: int, config: dict) -> Optional[Instruction]:
    """Parse one line of assembly-like instruction.

    Args:
        line (str): _description_
        inst_id (int): _description_
        config (dict): _description_

    Returns:
        Optional[Instruction]: _description_
    """
    line = line.strip()
    if not line or line.startswith('#'):
        return None
    
    segments = line.split()
    op = segments[0].upper()
    
    dest = None
    src1 = None
    src2 = None
    
    if op == "LOAD":
        dest = segments[1] 
        src1 = segments[2] # e.g. 0(R2)
    elif op == "STORE":
        src1 = segments[1] # value to store
        src2 = segments[2] # address e.g. 4(R2)
    elif len(segments) == 4: # ADD/SUB/MUL Rdest Rsrc1 Rsrc2
        dest = segments[1]
        src1 = segments[2]
        src2 = segments[3]
    else:
        # handle other class if needed
        pass
    
    # determine the functional unit
    # div must be added here as well.
    if op in ["ADD", "SUB"]:
        fu_type = "ALU"
    elif op == "MUL":
        fu_type = "MULT"
    elif op in ["LOAD", "STORE"]:
        fu_type = "LOAD_STORE"
    else:
        fu_type = "ALU"
        
    latency = config.get("functional_units", {}).get(fu_type,{}).get("latency", 2)
    
    return Instruction(
        id = inst_id,
        op = op,
        dest=dest,
        src1=src1,
        src2=src2,
        fu_type=fu_type,
        latency=latency,
    )