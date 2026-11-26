APP ?= app.S
# ==========================================
# Directories
# ==========================================
FPGA_BUILD_DIR := fpga/build
SIM_DIR        := sim
SIM_WORK_DIR   := $(SIM_DIR)/work
SIM_LOGS_DIR   := $(SIM_DIR)/logs
SW_BUILD_DIR   := sw/build
HEX_FILE := sw/build/program.txt

# ==========================================
# Clean Targets
# ==========================================
.PHONY: clean clean_sim clean_sw clean_fpga clean_py clean_all

# Default clean: cleans simulation, software builds, and python cache (keeps FPGA builds)
clean: clean_sim clean_sw clean_py
	@echo "[CLEAN] Simulation, software, and temporary files cleaned."

# Clean simulation artifacts (calls sim/Makefile if needed, plus direct cleanup)
clean_sim:
	@echo "[CLEAN] Removing simulation work and log files..."
	@# If sim/Makefile also has a clean target, uncomment the next line:
	@# $(MAKE) -C $(SIM_DIR) clean
	rm -rf $(SIM_WORK_DIR)/* $(SIM_LOGS_DIR)/* $(SIM_DIR)/obj_dir
	rm -f *.vcd *.fst *.wlf *.log transcript

# Clean software / assembler outputs
clean_sw:
	@echo "[CLEAN] Removing software build artifacts..."
	rm -rf $(SW_BUILD_DIR)/*
	find sw/ -type f \( -name "*.hex" -o -name "*.bin" -o -name "*.elf" -o -name "*.mem" -o -name "*.dump" \) -delete

# Clean FPGA synthesis/implementation builds (Vivado & ISE) and stray logs
clean_fpga:
	@echo "[CLEAN] Removing FPGA build directories and stray Xilinx files..."
	rm -rf $(FPGA_BUILD_DIR)/*
	rm -rf .Xil fpga/.Xil fpga/vivado/.Xil fpga/ISE/.Xil
	find . -type f \( -name "vivado*.jou" -o -name "vivado*.log" -o -name "vivado*.str" -o -name "vivado*.backup.*" \) -delete
	find . -type d \( -name "_xmsgs" -o -name "xlnx_auto_0_xdb" -o -name "iseconfig" -o -name "_ngo" \) -exec rm -rf {} +

# Clean Python cache files
clean_py:
	@echo "[CLEAN] Removing Python cache..."
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.py[cod]" -delete
	rm -f iss_trace.log

# Deep clean: wipes EVERYTHING generated (including FPGA builds)
clean_all: clean clean_fpga
	@echo "[CLEAN] Deep clean complete (including FPGA builds)."



asm:
	python3 tools/assembler.py $(APP)

run_iss: asm
	@echo "[ISS] Running simulation on $(HEX_FILE)..."
	python3 tools/mips_iss.py $(HEX_FILE)
