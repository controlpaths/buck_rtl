
`timescale 1ns/1ns

`define delay_1ms 1000000
`define delay_10ms 10000000
`define delay_100ms 100000000
`define base_time 0.000000001

`define clkcycle 10

module buck_test ();

  real fs; /* sampling frequency */
  real prescaler; /* number of ticks per sampling period */

  reg aclk; /* clock for dut */
  reg resetn; /* reset for dut */
  reg clock_enable; /* clock enable signal */
  reg clock_enable_ramp; /* clock enable signal for ramp */
  wire pwm; /* pwm generation */

  reg [15:0] duty_cycle; /* pwm duty cycle */
  wire [15:0] duty_cycle_ramp; /* pwm duty cycle ramped */

  wire [24:0] output_current;
  wire [24:0] output_voltage;
  wire [24:0] inductor_current;

  integer file_id;

  /* clock generation */
  initial begin
    aclk <= 1'b0;
    
    forever begin
      #(`clkcycle/2);
      aclk <= ~aclk;
    end
  end

  /* reset generation */
  initial begin
    resetn <= 1'b0;

    #(5*`clkcycle);
    resetn <= 1'b1; /* release reset after 5 clk cycles */
  end

    /* stimulus generation */
  initial begin
    /* initial conditions of the test */
    fs = 500000; /* 500ksps */

    prescaler = 1/(fs*`base_time); 
    
    clock_enable <= 1'b0;

    forever begin
      
      #(prescaler-`clkcycle)
      clock_enable <= 1'b1;
      #(`clkcycle)
      clock_enable <= 1'b0;

    end
  end

  initial begin
    clock_enable_ramp <= 0;

    forever begin
      #10000;
      clock_enable_ramp <= 1'b1;
      #(`clkcycle);
      clock_enable_ramp <= 1'b0;
    end
  end

  ramp #(
  .signal_width(16)
  ) ramp_inst (
  .aclk(aclk), 
  .resetn(resetn), 
  .clock_enable(clock_enable_ramp),
  .goal(duty_cycle), 
  .out_ramp(duty_cycle_ramp) 
  );

  /* pwm generation */
  pwm_generator #(
  .counter_width(16)
  ) pwm_inst(
  .aclk(aclk), 
  .resetn(resetn), 
  .period(16'd6666), 
  .comparator(duty_cycle), 
  .counter(), 
  .pwm(pwm)
  );

  buck_v1_0 #(
  .model_data_width(25),
  .model_decimal_width(16)
  ) dut (
  .aclk(aclk), 
  .resetn(resetn), 
  .clock_enable(clock_enable),
  .pwm(pwm), 
  .input_voltage(25'd1572864),
  .period_inductor(25'd655),
  .period_capacitor(25'd198),
  .inverse_resistor(25'd6553),
  .inductor_current(inductor_current),
  .capacitor_current(),
  .output_current(output_current),
  .output_voltage(output_voltage)  
  );


  /* test flow */
  initial begin
  
    /* create vcd file and save all signals */
    $dumpfile("test_result.vcd");
    $dumpvars();

    duty_cycle <= 0.25*6666;

    #(`delay_100ms);

    // duty_cycle <= 0.75*6666;

    #(`delay_100ms);

    $finish();
  end

  /* output file */
  initial
    begin
      file_id = $fopen("data.csv","w");

      $fwrite(file_id, "time, inductor_current, output_voltage \n");

      forever begin
        @(posedge clock_enable);  
        $fwrite(file_id, "%f, %d, %d \n", $time*`base_time, inductor_current, output_voltage);
      end
      
    end

endmodule