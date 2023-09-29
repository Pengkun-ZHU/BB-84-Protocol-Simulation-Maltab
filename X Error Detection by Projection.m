clear; clc
%% Task 11
%% This program simulates the X error correction by applying projection ..
%% operator on the two ancillaries by which reserve the superposition ...
%% However, this scheme cannot correct the error but only detect it
H = [1;0]; V = [0;1];
I = [1 0;0 1];
Z = [1 0;0 -1];
X = [0 1;1 0];
UZ = tensor({I,I,H*H'}) + tensor({Z,Z,V*V'});
CNOT = [1 0 0 0;
    0 1 0 0
    0 0 0 1
    0 0 1 0];
HDM = [1,1;1,-1]/sqrt(2);
% Define projection operator
P{1} = tensor({I,I,H*H'});
P{2} = tensor({I,I,V*V'});

%% Alice commences the transmission
% Alice prepares a photon to be transmitted 
a = rand(1);
b = sqrt(1-a^2); 
c = a*H+b*V; % c denotes the photon transmitted by Alice

% Alice appends one bits and entangle them
Appended_c = tensor({c,H});
Entangled_c = CNOT * Appended_c;

% The 2 qubits go through a potential error channel
Error = randi(4) % 1 denotes no error occurs
switch Error
    case 1
        ReceivedPhotons = Entangled_c;
    case 2
        ReceivedPhotons = tensor({X,I})*Entangled_c;
    case 3
        ReceivedPhotons = tensor({I,X})*Entangled_c;
    case 4
        ReceivedPhotons = tensor({X,X})*Entangled_c;
end

%% Bob Receives and does error correction
% Bob appends a new bit that also serves as a control bit of the incoming .
% Z-gate
Appended_c = tensor({ReceivedPhotons,HDM*H});
ZZ_c = UZ * Appended_c;
HZZH_c = tensor({I,I,HDM})*ZZ_c;

% Apply projection operators
Probability = zeros(1,2);
for p = 1:2 % p denotes which projection operator is used this time
    Probability(p) = HZZH_c'*P{p}*HZZH_c;
end

Syndrome = find(Probability >= 0.9) - 1


        


