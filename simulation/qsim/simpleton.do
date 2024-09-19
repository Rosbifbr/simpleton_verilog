onerror {exit -code 1}
vlib work
vlog -work work simpleton.vo
vlog -work work Waveform.vwf.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.simpleton_pitanga_vlg_vec_tst -voptargs="+acc"
vcd file -direction simpleton.msim.vcd
vcd add -internal simpleton_pitanga_vlg_vec_tst/*
vcd add -internal simpleton_pitanga_vlg_vec_tst/i1/*
run -all
quit -f
