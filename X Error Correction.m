clear; clc
%% Task 9
%% This program simulates the quantum error correction for X error exclusively
%% Define relevant parameters
H = [1;0];V = [0;1];   
I = [1 0;0 1];
X = [0 1;1 0];

% Define CNOT gate
CNOT = tensor({H*H',I,I})+tensor({V*V',X,X});

% Define four projection operators correspongding to no error and error ...
% occurs at first, second, third bit respectively
P = cell(1,4);
P{1} = tensor({H,H,H})*tensor({H',H',H'})+tensor({V,V,V})*tensor({V',V',V'});
P{2} = tensor({V,H,H})*tensor({V',H',H'})+tensor({H,V,V})*tensor({H',V',V'});
P{3} = tensor({H,V,H})*tensor({H',V',H'})+tensor({V,H,V})*tensor({V',H',V'});
P{4} = tensor({H,H,V})*tensor({H',H',V'})+tensor({V,V,H})*tensor({V',V',H'});

%% Alice commences the transmission
% Alice prepares a photon to be transmitted 
a = rand(1);
b = sqrt(1-a^2); 
c = a*H+b*V % c denotes the photon transmitted by Alice

% Alice appends 2 qubits for protection use and applies a CNOT gate to ... 
% entangle them
Appended_c = tensor({c,H,H});
EntangledPhoton = CNOT*Appended_c;

% Alice transmits the qubits, during which at most one X error is assumed .
% to happen, ReceviedPhonton deonots the photons received by Bob
ErrorPos = randi([1,4]) % 1 denotes no error occurs
switch ErrorPos
    case 1
        ReceivedPhoton = EntangledPhoton;
    case 2
        ReceivedPhoton = tensor({X,I,I}) * EntangledPhoton;
    case 3
        ReceivedPhoton = tensor({I,X,I}) * EntangledPhoton;
    case 4
        ReceivedPhoton = tensor({I,I,X}) * EntangledPhoton;
end % SWITCH ends here

%% Bob receives and do an error correction
% After Bob received the photons, he apply projection operators to check ..
% error
Probability = zeros(1,4);
for p = 1:4 % p denotes which projection operator is used this time
    Probability(p) = ReceivedPhoton'*P{p}*ReceivedPhoton;
end
ErrorPosFound = find(Probability >= 0.9)
switch ErrorPosFound
    case 1
        Corrected = ReceivedPhoton;
    case 2
        Corrected = tensor({X,I,I})*ReceivedPhoton;
    case 3
        Corrected = tensor({I,X,I})*ReceivedPhoton;
    case 4
        Corrected = tensor({I,I,X})*ReceivedPhoton;
end 

%% Check whether the correction succeeded
% Disentangle the three
Final_Appended_c = CNOT * Corrected;
% Separated c from the three
Final_c = full(tensor({I, H', H'}) * Final_Appended_c)
% Compare Final_c with c
if sum((c - Final_c).^2) < 1e-10
    disp('Correction succeeds')
else
    disp('Correction fails')
end


