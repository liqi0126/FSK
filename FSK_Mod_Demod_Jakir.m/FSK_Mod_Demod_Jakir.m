% <<<<<<<<<<<<<<<<<<<< FSK Modulation and Demodulation >>>>>>>>>>>>>>>>>>>>

clc, clear all, close all;


% ******************* Digital/Binary input information ********************

x = input('Enter Digital Input Information = ');   % Binary information as stream of bits (binary signal 0 or 1)
N = length(x);
Tb = 0.0001;   %Data rate = 1MHz i.e., bit period (second)
disp('Binary Input Information at Transmitter: ');
disp(x);


% ************* Represent input information as digital signal *************

nb = 100;   % Digital signal per bit
digit = []; 
for n = 1:1:N
    if x(n) == 1
       sig = ones(1,nb);
    else x(n) == 0;
        sig = zeros(1,nb);
    end
     digit = [digit sig];
end

t1 = Tb/nb:Tb/nb:nb*N*(Tb/nb);   % Time period
figure('Name','FSK Modulation and Demodulation','NumberTitle','off');
subplot(3,1,1);
plot(t1,digit,'LineWidth',2.5);
grid on;
axis([0 Tb*N -0.5 1.5]);
xlabel('Time(Sec)');
ylabel('Amplitude(Volts)');
title('Digital Input Signal');


% **************************** FSK Modulation *****************************

Ac = 10;         % Carrier amplitude for binary input  
br = 1/Tb;       % Bit rate
Fc1 = br*10;     % Carrier frequency for binary input '1'
Fc2 = br*5;      % Carrier frequency for binary input '0'
t2 = Tb/nb:Tb/nb:Tb;   % Signal time   

mod = [];
for (i = 1:1:N)
    if (x(i) == 1)
        y = Ac*cos(2*pi*Fc1*t2);   % Modulation signal with carrier signal 1
    else
        y = Ac*cos(2*pi*Fc2*t2);   % Modulation signal with carrier signal 2
    end
    mod = [mod y];
end

t3 = Tb/nb:Tb/nb:Tb*N;   % Time period
subplot(3,1,2);
plot(t3,mod);
xlabel('Time(Sec)');
ylabel('Amplitude(Volts)');
title('FSK Modulated Signal');


% ********************* Transmitted signal x ******************************

x = mod;


% ********************* Channel model h and w *****************************

h = 1;   % Signal fading 
w = 0;   % Noise


% ********************* Received signal y *********************************

y = h.*x + w;   % Convolution


% *************************** FSK Demodulation ****************************
 

s = length(t2);
demod = [];
for n = s:s:length(y)
  t4 = Tb/nb:Tb/nb:Tb;        % Time period
  c1 = cos(2*pi*Fc1*t4);      % carrier signal for binary value '1'
  c2 = cos(2*pi*Fc2*t4);      % carrier siignal for binary value '0'
  mc1 = c1.*y((n-(s-1)):n);   % Convolution 
  mc2 = c2.*y((n-(s-1)):n);   % Convolution 
  t5 = Tb/nb:Tb/nb:Tb;
  z1 = trapz(t5,mc1);         % Intregation 
  z2 = trapz(t5,mc2);         % Intregation 
  rz1 = round(2*z1/Tb);
  rz2 = round(2*z2/Tb);
  if(rz1 > Ac/2)              % Logical condition 
    a = 1;
  else(rz2 > Ac/2)
    a = 0;
  end
  demod = [demod a];
end

disp('Demodulated Binary Information at Receiver: ');
disp(demod);


% ********** Represent demodulated information as digital signal **********

digit = [];
for n = 1:length(demod)
    if demod(n) == 1;
       sig = ones(1,nb);
    else demod(n) == 0;
        sig = zeros(1,nb);
    end
     digit = [digit sig];
end

t5 = Tb/nb:Tb/nb:nb*length(demod)*(Tb/nb);   % Time period
subplot(3,1,3)
plot(t5,digit,'LineWidth',2.5);grid on;
axis([0 Tb*length(demod) -0.5 1.5]);
xlabel('Time(Sec)');
ylabel('Amplitude(Volts)');
title('FSK Demodulated Signal');

% ************************** End of the program ***************************