# 🚀 ACA Dynamic Instruction Scheduling Simulator

> An interactive educational simulator for visualizing and comparing **Scoreboard** and **Tomasulo's Algorithm** in modern processors.

Developed for the **Advanced Computer Architecture** course at **Amirkabir University of Technology**.

---

## 📖 Overview

The **ACA Dynamic Instruction Scheduling Simulator** is a cycle-accurate educational tool designed to help students understand how dynamic instruction scheduling works inside modern CPUs.

The simulator supports two of the most important scheduling algorithms:

- **Scoreboard**
  - Centralized hazard detection
  - No register renaming
  - WAR/WAW hazards cause stalls

- **Tomasulo's Algorithm**
  - Distributed reservation stations
  - Register renaming
  - Common Data Bus (CDB)
  - Eliminates WAR and WAW hazards

The project provides a modern graphical interface that allows users to create custom instruction sequences, configure processor resources, execute simulations cycle-by-cycle, and visualize every stage of execution.

---

# ✨ Features

## 📂 Scenario Management

- Create custom instruction scheduling scenarios
- Configure functional units and execution latencies
- Built-in educational examples
- Save, edit, duplicate, and delete scenarios
- Import / Export scenarios (`.aca`)

---

## 📊 Simulation Visualization

### Gantt Chart

Visual timeline showing:

- Issue
- Read Operands
- Execute
- Write Back
- Waiting/Stall periods

---

### Timing Table

Cycle-accurate execution table including:

| Column | Description |
|---------|-------------|
| Issue | Instruction issue cycle |
| RO | Read operands |
| EX | Execute |
| WB | Write back |

---

### Hazards Analysis

Automatically detects:

- ✅ RAW (Read After Write)
- ✅ WAR (Write After Read)
- ✅ WAW (Write After Write)

with detailed information about dependent instructions.

---

### Performance Dashboard

Displays:

- Total execution cycles
- Number of instructions
- Average instruction latency
- IPC / Issue rate
- Functional unit utilization

---

### Instruction Statistics

Pie chart showing instruction distribution by type:

- LOAD
- STORE
- ADD
- SUB
- MUL
- DIV

---

### Tomasulo Visualization

When Tomasulo mode is selected, the simulator additionally displays:

- Reservation Stations
- Register Status Table
- Register Tags
- Common Data Bus (CDB) activity

---

### Simulation Log

Cycle-by-cycle textual execution log showing:

- Instruction issued
- Operand reads
- Execution start/end
- Write-back events
- Hazard detection
- Functional unit allocation

---

### Animated CPU Clock

A synchronized CPU clock updates every simulation cycle to provide an intuitive visualization of processor timing.

---

# 🎮 Interactive Controls

The simulator supports both automatic and manual execution.

### Controls

- ▶ Play
- ⏸ Pause
- ⏭ Step Forward
- ⏮ Step Backward
- 🎚 Cycle Slider
- ⚡ Clock Speed Control

Users can jump to any simulation cycle or replay the execution from any point.

---

# ⚖ Supported Scheduling Algorithms

| Feature | Scoreboard | Tomasulo |
|----------|------------|-----------|
| Dynamic Scheduling | ✅ | ✅ |
| Centralized Control | ✅ | ❌ |
| Reservation Stations | ❌ | ✅ |
| Register Renaming | ❌ | ✅ |
| RAW Detection | ✅ | ✅ |
| WAR Elimination | ❌ | ✅ |
| WAW Elimination | ❌ | ✅ |
| Common Data Bus (CDB) | ❌ | ✅ |

---

# 🏗 Project Architecture

## Backend

Built with **Python + FastAPI**

```text
src/
├── instruction.py      # Instruction parser and model
├── utils.py            # Utilities and configuration loader
├── scoreboard.py       # Scoreboard simulator
├── tomasulo.py         # Tomasulo simulator
├── simulator.py        # Simulation orchestrator
└── api.py              # REST API
```

---

## Frontend

Built with **Flutter + BLoC**

```text
lib/
├── models/
├── screens/
│   ├── onboarding/
│   ├── dashboard/
│   ├── scenario/
│   ├── simulator/
│   └── compare/
├── widgets/
├── bloc/
├── services/
└── core/
```

---

# ⚙ Installation

## Prerequisites

### Backend

- Python 3.8+
- FastAPI
- Uvicorn

### Frontend

- Flutter 3.0+

---

## Backend Setup

```bash
git clone https://github.com/yourusername/aca_project.git

cd aca_project

pip install fastapi uvicorn python-multipart

uvicorn src.api:app --reload --host 0.0.0.0 --port 8000
```

---

## Frontend Setup

```bash
cd frontend

flutter pub get

flutter run
```

---

# 🚀 Usage

## 1. Create a Scenario

1. Click **New Scenario**
2. Enter a scenario name
3. Select scheduling algorithm
4. Configure functional units
5. Configure execution latencies
6. (Optional) Configure reservation stations
7. Enter assembly instructions
8. Save or run the scenario

---

## 2. Run Simulation

1. Open a saved scenario
2. Click **Run Simulation**
3. Control execution using Play/Pause or manual stepping
4. Navigate between visualization tabs

---

## 3. Compare Algorithms

Select two scenarios and press **Compare** to view side-by-side comparisons of:

- Execution timeline
- Total cycles
- Performance metrics
- Hazard statistics

---

# 📝 Supported Assembly Instructions

| Instruction | Format | Example |
|--------------|--------|---------|
| LOAD | `LOAD Rd offset(Rs)` | `LOAD R1 0(R2)` |
| STORE | `STORE Rs offset(Rbase)` | `STORE R3 4(R2)` |
| ADD | `ADD Rd Rs1 Rs2` | `ADD R4 R1 R5` |
| SUB | `SUB Rd Rs1 Rs2` | `SUB R6 R7 R8` |
| MUL | `MUL Rd Rs1 Rs2` | `MUL R3 R1 R4` |
| DIV | `DIV Rd Rs1 Rs2` | `DIV R8 R2 R9` |

---

## Example Program

```assembly
LOAD R1 0(R2)
MUL R3 R1 R4
ADD R5 R3 R6
SUB R1 R7 R8
MUL R9 R1 R10
ADD R11 R9 R12
STORE R11 0(R13)
```

---

# 🌐 REST API

## Endpoints

| Method | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/` | Health check |
| `POST` | `/run_simulation` | Execute a simulation |

---

## Example Request

```json
{
  "mode": "scoreboard",
  "instructions": [
    "LOAD R1 0(R2)",
    "MUL R3 R1 R4"
  ],
  "config": {
    "registers": [
      "R0",
      "R1",
      "R2",
      "R3",
      "R4",
      "R5"
    ],
    "functional_units": {
      "ALU": {
        "count": 2,
        "latency": 2
      },
      "MULT": {
        "count": 1,
        "latency": 10
      },
      "LOAD_STORE": {
        "count": 1,
        "latency": 2
      }
    }
  }
}
```

---

# 🧪 Sample Programs

## Program 1 — Hazard Demonstration

```assembly
LOAD R1 0(R2)
MUL R3 R1 R4
ADD R5 R3 R6
SUB R1 R7 R8
MUL R9 R1 R10
ADD R11 R9 R12
STORE R11 0(R13)
```

Expected hazards:

- RAW ×3
- WAR ×1
- WAW ×1

---

## Program 2 — RAW Hazard

```assembly
MUL R1 R2 R3
ADD R4 R1 R5
```

---

## Program 3 — WAW Hazard

```assembly
MUL R1 R2 R3
SUB R1 R4 R5
```

---

## Program 4 — WAR Hazard

```assembly
ADD R1 R2 R3
MUL R4 R1 R5
ADD R1 R6 R7
```

---

# ⚙ Default Configuration

## Functional Units

| Unit | Count | Latency | Operations |
|------|------:|--------:|------------|
| ALU | 2 | 2 | ADD, SUB, AND, OR, XOR |
| MULT | 1 | 10 | MUL, DIV |
| LOAD/STORE | 1 | 2 | LOAD, STORE |

---

## Tomasulo Reservation Stations

| Functional Unit | Stations |
|-----------------|---------:|
| ALU | 3 |
| MULT | 2 |
| LOAD/STORE | 2 |

---

# 🔧 Troubleshooting

## Backend won't start

```bash
pip install fastapi uvicorn python-multipart

netstat -ano | findstr :8000
```

---

## Frontend cannot connect

Verify that:

- Backend is running
- API URL is correct
- CORS is enabled
- Port **8000** is available

---

## Type Casting Errors

Ensure:

- Functional unit counts are integers
- Latencies are integers
- Configuration maps are correctly formatted

---

# 👨‍💻 Technologies Used

### Backend

- Python
- FastAPI

### Frontend

- Flutter
- Dart
- flutter_bloc

### Visualization

- Custom Flutter Widgets
- Interactive Gantt Charts
- Data Tables
- Charts

---

# 👤 Author

**Reza Tahmasbi**

Advanced Computer Architecture Course

Amirkabir University of Technology

Summer 1405

Version **1.1**

---

# 📄 License

This project is intended **solely for educational purposes**.

All rights reserved.

---

# 📬 Contact

For questions, bug reports, or suggestions, please contact the author through the course platform.