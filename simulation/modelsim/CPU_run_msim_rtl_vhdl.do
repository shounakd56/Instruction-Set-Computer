transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/Sequencer.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/RegisterFile.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/Memory.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/InstructionReg.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/Halfadder.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/Fulladder.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/CPU.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/ALU.vhd}
vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/16bitadder.vhd}

vcom -93 -work work {C:/Users/SHOUNAK DAS/Desktop/224_Project/EE224 Project/CPUProject/simulation/modelsim/Waveform.vwf.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  CPU_vhd_vec_tst

add wave *
view structure
view signals
run -all
