/**
  Module name:  ramp
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2023
  Description: module that generates a ramp
  Revision: 1.0 Module created
**/

module ramp #(
  parameter signal_width = 12
)(
  input aclk, 
  input resetn, 
  
  input clock_enable,
  input [signal_width-1:0] goal, 
  
  output reg [signal_width-1:0] out_ramp 
);

  always @(posedge aclk)
    if (!resetn)
      out_ramp <= 0;
    else 
      if (clock_enable)
        if (goal > out_ramp)
          out_ramp <= out_ramp + 1;
        else if (goal < out_ramp)
          out_ramp <= out_ramp - 1;
        else
          out_ramp <= out_ramp;

endmodule