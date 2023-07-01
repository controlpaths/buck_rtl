iverilog ../test/buck_test.sv ../source/pwm_generator.v ../source/ramp.v ../source/buck_v1_0.v -s buck_test -o ./sim.vvp
vvp sim.vvp
rm ./sim.vvp