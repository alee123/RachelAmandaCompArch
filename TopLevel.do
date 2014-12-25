vlog -reportprogress 300 -work work TopLevel.v
vsim -voptargs="+acc" musicTest

add wave -position insertpoint  \
sim:/musicTest/clk \
sim:/musicTest/speaker 
run -all
wave zoom full

