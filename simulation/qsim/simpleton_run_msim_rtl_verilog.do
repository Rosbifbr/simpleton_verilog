transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/rodrigo/Desktop/becnhmark {/home/rodrigo/Desktop/becnhmark/simpleton_pitanga.v}

