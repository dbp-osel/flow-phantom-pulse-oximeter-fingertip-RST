% finger pump
% This code is for use with National Instruments DAQs.
% POC - sandhya.vasudevan@fda.hhs.gov

clear
clc
close all

% Run this section first
s = daq.createSession('ni');
addAnalogInputChannel(s,'cDAQ2Mod2','ai0','Voltage');  % Flow input
addAnalogInputChannel(s,'cDAQ2Mod2','ai1','Voltage'); %Pressure input
addAnalogOutputChannel(s,'cDAQ2Mod1','ao0','Voltage'); % Command input to the pump
s.Rate = 1000; % Sampling rate
data = [];
t = [];

% This part determines the shape of the flow and pressure waveforms
k = 1.9; % scaling the flow and adjusting the flow
Vint = xlsread('flowAo15.xlsx');  % Input flow -- adjust you pulse length for pulse rate adjustment

Vint0 = [];
for i=1:60  % adjust the number of pulses;; usually you should run this for at least 90 seconds
    Vint0 = [Vint0;Vint];
end

Vint=[];
Vint = Vint0;
time_length=size(Vint,1)/s.Rate; %generate each signal for 10 seconds
seg_samps=linspace(0,time_length,s.Rate*time_length)';
plot(seg_samps,Vint); ylabel 'Flow (volt)'

for i = 1:2

    running pump in a loop
    queueOutputData(s,k*Vint(1:end))
    [captured_data, time]=s.startForeground();
    data= [data;captured_data];
    t = [t;time];
end

flow  = data(:,1).*100;% ml/min
Meanflow = mean (flow) %ml/min
p = data(:,2).*100;%mmHg
p_lowpass = lowpass(p,15,1000);
meanP = mean (p)

plot(t,p); ylabel 'Pressure (mmHg)'


disp ('finished')
s.Rate = 1000; %sampling frequency
rezero=zeros(s.Rate,1); %after every command, rezero to make sure PPG doesn't output high pressure
queueOutputData(s,rezero)
s.startForeground();

disp('done')
clear s