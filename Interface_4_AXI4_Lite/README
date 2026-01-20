# AXI4-Lite Master–Slave Interface (Verilog)

## 📌 Overview

This project implements a complete AXI4-Lite system in Verilog, consisting of:

- AXI4-Lite Master
- AXI4-Lite Slave (Register File based)
- Top-level SoC-style wrapper

The design demonstrates single read and single write AXI4-Lite transactions, using FSM-based control, intended for educational, simulation, and learning purposes.

---

## 🧱 Project Structure

├── master.v     # AXI4-Lite Master  
├── axi4.v       # AXI4-Lite Slave (32x32-bit registers)  
├── top.v        # Top-level integration module  
└── README.md  

---

## ✨ Features

### AXI4-Lite Master
- Supports single write OR single read at a time
- FSM-controlled sequencing for:
  - Write Address (AW)
  - Write Data (W)
  - Write Response (B)
  - Read Address (AR)
  - Read Data (R)
- User-friendly control interface:
  - wr_en, rd_en
- Status signals:
  - busy
  - read_done
  - write_done
  - error (SLVERR detection)

### AXI4-Lite Slave
- 32 × 32-bit register file
- Memory-mapped registers using addr[6:2]
- Independent read and write handling
- Always responds with OKAY response (2'b00)
- Fully AXI4-Lite compliant handshaking

### Top Module
- Integrates master and slave
- Acts like a simple SoC
- Exposes only user-side signals
- No external AXI interconnect required

---

## 🔌 AXI4-Lite Signals Used

### Write Channel
- AWVALID, AWREADY, AWADDR
- WVALID, WREADY, WDATA
- BVALID, BREADY, BRESP

### Read Channel
- ARVALID, ARREADY, ARADDR
- RVALID, RREADY, RDATA, RRESP

---

## 🧠 Functional Description

### Write Transaction Flow
1. User asserts wr_en
2. Master sends:
   - Write Address (AW)
   - Write Data (W)
3. Slave stores data in register file
4. Slave sends write response (B)
5. Master asserts write_done

### Read Transaction Flow
1. User asserts rd_en
2. Master sends Read Address (AR)
3. Slave reads register file
4. Slave returns read data (R)
5. Master asserts read_done

NOTE:
Simultaneous read and write requests are detected and flagged as an error.

---

## 📍 Address Mapping

- Address bits used: addr[6:2]
- Total registers: 32

Address map:
0x00 → Register 0  
0x04 → Register 1  
0x08 → Register 2  
...  
0x7C → Register 31  

---

## 🧪 How to Simulate

1. Add master.v, axi4.v, and top.v to the simulator (Vivado / ModelSim / Questa)
2. Apply clock and reset
3. Drive user signals:
   - wr_en, rd_en
   - addr
   - wdata_in
4. Observe outputs:
   - rdata_out
   - read_done, write_done
   - busy, error

---

## 🎓 Educational Purpose

This design is intended for:
- Understanding AXI4-Lite protocol
- Learning FSM-based bus control
- FPGA / SoC academic coursework
- Interview preparation for AXI fundamentals

WARNING:
This implementation is not intended for high-performance or production SoC designs.

---

## 🚀 Future Improvements

- Add WSTRB support in master
- Support pipelined transactions
- Add timeout handling
- Introduce multiple slaves and interconnect
- Add SystemVerilog assertions

---


