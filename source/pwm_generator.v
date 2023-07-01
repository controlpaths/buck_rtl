/**
  Module name:  pwm generator
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2023
  Description: module that generates a pwm signal
  Revision: 1.0 Module created
**/

module pwm_generator #(
  parameter counter_width = 12
)(
  input aclk, 
  input resetn, 

  input [counter_width-1:0] period, 
  input [counter_width-1:0] comparator, 
  
  output reg [counter_width-1:0] counter, 

  output pwm
);

  always @(posedge aclk)
    if (!resetn)
      counter <= 1'b0;
    else 
      if (counter <= period)
        counter <= counter + 1;
      else 
        counter <= 0;

  assign pwm = (!resetn || (comparator < counter))? 1'b0: 1'b1;

endmodule