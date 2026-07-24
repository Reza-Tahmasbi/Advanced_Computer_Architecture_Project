# src/api.py
import json
import io
from contextlib import redirect_stdout
from typing import List, Dict, Any
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from .instruction import Instruction, parse_instruction
from .scoreboard import Scoreboard
from .tomasulo import Tomasulo

app = FastAPI(title="Dynamic Scheduling Simulator API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class RunSimulationRequest(BaseModel):
    mode: str
    instructions: List[str]
    config: Dict[str, Any]

# ==================== IMPROVED HAZARD ANALYSIS ====================
def analyze_hazards(instructions: List[Instruction], mode: str) -> List[Dict[str, Any]]:
    hazards = []
    instr_strings = {}

    for instr in instructions:
        full = instr.op
        if instr.dest: full += f" {instr.dest}"
        if instr.src1: full += f" {instr.src1}"
        if instr.src2: full += f" {instr.src2}"
        instr_strings[instr.id] = full

    for i, instr in enumerate(instructions):
        # ----- RAW -----
        for src in [instr.src1, instr.src2]:
            if not src or not src.startswith('R'):
                continue
            for j in range(i-1, -1, -1):
                if instructions[j].dest == src:
                    hazards.append({
                        'type': 'RAW',
                        'instruction': f"I{instr.id}",
                        'full_instruction': f"I{instr.id}: {instr_strings[instr.id]}",
                        'depends_on': f"I{instructions[j].id}",
                        'full_depends_on': f"I{instructions[j].id}: {instr_strings[instructions[j].id]}",
                        'register': src,
                        'cycle': getattr(instr, 'issue_cycle', 0) or 0,
                    })
                    break

        # ----- WAW (FULL DETECTION - all previous writers) -----
        if instr.dest and instr.dest.startswith('R'):
            for j in range(i-1, -1, -1):
                if instructions[j].dest == instr.dest:
                    hazards.append({
                        'type': 'WAW',
                        'instruction': f"I{instr.id}",
                        'full_instruction': f"I{instr.id}: {instr_strings[instr.id]}",
                        'depends_on': f"I{instructions[j].id}",
                        'full_depends_on': f"I{instructions[j].id}: {instr_strings[instructions[j].id]}",
                        'register': instr.dest,
                        'cycle': getattr(instr, 'issue_cycle', 0) or 0,
                    })
                    # NO break → reports ALL previous writers (including transitive)

        # ----- WAR (Scoreboard only) -----
        if mode.lower() == 'scoreboard':
            for src in [instr.src1, instr.src2]:
                if not src or not src.startswith('R'):
                    continue
                read_cycle = getattr(instr, 'read_operands_cycle', None)
                if read_cycle is None:
                    continue
                for j in range(i+1, len(instructions)):
                    later = instructions[j]
                    if later.dest == src:
                        later_wb = getattr(later, 'writeback_cycle', None)
                        if later_wb is not None and later_wb < read_cycle:
                            hazards.append({
                                'type': 'WAR',
                                'instruction': f"I{instr.id}",
                                'full_instruction': f"I{instr.id}: {instr_strings[instr.id]}",
                                'depends_on': f"I{later.id}",
                                'full_depends_on': f"I{later.id}: {instr_strings[later.id]}",
                                'register': src,
                                'cycle': read_cycle,
                            })
                        break

    # Deduplicate
    seen = set()
    unique = []
    for h in hazards:
        key = (h['type'], h['instruction'], h['depends_on'], h['register'])
        if key not in seen:
            seen.add(key)
            unique.append(h)

    return unique


# ==================== REST OF THE FILE (unchanged) ====================
def run_simulator(mode: str, instructions: List[str], config: Dict[str, Any]) -> Dict[str, Any]:
    instr_objects = []
    for idx, line in enumerate(instructions, start=1):
        instr = parse_instruction(line, idx, config)
        if instr:
            instr_objects.append(instr)

    if not instr_objects:
        raise ValueError("No valid instructions provided.")

    if mode.lower() == "scoreboard":
        backend = Scoreboard(config, instr_objects)
    elif mode.lower() == "tomasulo":
        backend = Tomasulo(config, instr_objects)
    else:
        raise ValueError(f"Unknown mode: {mode}")

    f = io.StringIO()
    with redirect_stdout(f):
        backend.run()

    output_text = f.getvalue()
    logs = output_text.splitlines()

    timing = []
    for instr in instr_objects:
        full_instr = instr.op
        if instr.dest: full_instr += f" {instr.dest}"
        if instr.src1: full_instr += f" {instr.src1}"
        if instr.src2: full_instr += f" {instr.src2}"
        timing.append({
            "id": instr.id,
            "op": instr.op,
            "full_instruction": full_instr,
            "issue": getattr(instr, 'issue_cycle', None),
            "read_operands": getattr(instr, 'read_operands_cycle', None),
            "exec_start": getattr(instr, 'exec_start_cycle', None),
            "writeback": getattr(instr, 'writeback_cycle', None),
        })

    total_cycles = backend.get_total_cycles()
    state_history = backend.get_state_history()
    hazards = analyze_hazards(instr_objects, mode)

    return {
        "total_cycles": total_cycles,
        "timing_table": timing,
        "logs": logs,
        "cycle_states": state_history,
        "hazards": hazards,
    }


@app.post("/run_simulation")
async def run_simulation(request: RunSimulationRequest):
    try:
        result = run_simulator(request.mode, request.instructions, request.config)
        return JSONResponse(content=result)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/")
async def root():
    return {"message": "Dynamic Scheduling Simulator API is running."}