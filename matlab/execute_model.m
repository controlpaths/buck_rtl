
close all
clear all
clc

%% initialize model

L = 200e-6;
C = 660e-6;
R = 10;
vin = 24;
fsw = 15e3;
duty_cycle = 0.25;

%% output filter details

s = tf('s');
wn = 1/(sqrt(L*C));
Q = R*sqrt(C/L);
fc = wn/2/pi

hf = wn^2/(s^2+wn/Q*s+wn^2);

figure
bode(hf)
grid on

%% Execute simulation
data = sim("model_block.slx");

%% Read signals

il = data.simout(:,1);
vo = data.simout(:,2);

figure
plot(data.tout, vo)
title("Output voltage")

figure
plot(data.tout, il)
title("Inductor current")

%% read simulation data
 
rtl_data = csvread("../script/data.csv", 1,0);

rtl_time = rtl_data(:,1);
rtl_inductor_current = rtl_data(:,2) / 2^16;
rtl_output_voltage= rtl_data(:,3) / 2^16;

%% compare data

figure;
plot(data.tout, vo)
hold on
plot(rtl_time, rtl_output_voltage)
xlim([0, 0.2])
legend("Simulink", "RTL")
