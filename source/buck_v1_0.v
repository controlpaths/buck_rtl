/**
  Module name:  buck
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2023
  Description: module that implements a smps buck model
  Revision: 1.0 Module created
**/

module buck_v1_0 #(
  parameter model_data_width = 25,
  parameter model_decimal_width = 15
)(
  input aclk, 
  input resetn, 
  input clock_enable,

  input pwm, 
  input signed [model_data_width-1:0] input_voltage,
  input signed [model_data_width-1:0] period_inductor,
  input signed [model_data_width-1:0] period_capacitor,
  input signed [model_data_width-1:0] inverse_resistor,
  
  output reg signed [model_data_width-1:0] inductor_current,
  output signed [model_data_width-1:0] capacitor_current,
  output signed [model_data_width-1:0] output_current,
  output reg signed [model_data_width-1:0] output_voltage  
);

  wire signed [model_data_width-1:0] voltage_diff; /* difference between voltage input and output */
  wire signed [(model_data_width*2)-1:0] voltage_diff_intl_2width; /* inductor integrator input double width*/
  wire signed [model_data_width-1:0] voltage_diff_intl; /* inductor integrator input */
  wire signed [(model_data_width*2)-1:0] capacitor_current_intc_2width; /* capacitor integrator input double width*/
  wire signed [model_data_width-1:0] capacitor_current_intc; /* capacitor integrator input */
  wire signed [(model_data_width*2)-1:0] output_current_2width; /* output current double width */

  /* voltage difference */
  assign voltage_diff = pwm? input_voltage - output_voltage: -output_voltage;
  
  /* inductor integrator gain */
  assign voltage_diff_intl_2width = voltage_diff * period_inductor;
  assign voltage_diff_intl = voltage_diff_intl_2width >>> model_decimal_width;

  /* inductor integrator */
  always @(posedge aclk)
    if (!resetn)
      inductor_current <= 0;
    else 
      if (clock_enable)
        inductor_current <= inductor_current + voltage_diff_intl;

  assign capacitor_current = inductor_current - output_current;

  /* capacitor integrator gain */
  assign capacitor_current_intc_2width = capacitor_current * period_capacitor;
  assign capacitor_current_intc = capacitor_current_intc_2width >>> model_decimal_width;

  /* capacitor integrator */
  always @(posedge aclk)
    if (!resetn)
      output_voltage <= 0;
    else 
      if (clock_enable)
        output_voltage <= output_voltage + capacitor_current_intc;

  /* resize output current */
  assign output_current_2width = output_voltage * inverse_resistor;
  assign output_current = output_current_2width >>> model_decimal_width;


endmodule