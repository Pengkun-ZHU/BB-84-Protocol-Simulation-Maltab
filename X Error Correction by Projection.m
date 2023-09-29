%% Task 12
%% This program simulates the X error correction by applying projection ..
%% operator on the two ancillaries by which reserve the superposition and .
%% correct the error
clear; clc
H = [1;0]; V = [0;1];
I = [1 0;0 1];
Z = [1 0;0 -1];
X = [0 1;1 0];
UZ124 = tensor({I,I,I,H*H',I}) + tensor({Z,Z,I,V*V',I});
UZ235 = tensor({I,I,I,I,H*H'}) + tensor({I,Z,Z,I,V*V'});
CNOT = tensor({H*H',I,I})+tensor({V*V',X,X});
HDM = [1,1;1,-1]/sqrt(2);

% Define projection operator
P{1} = tensor({I, I, I, H*H', H*H'}); %00
P{2} = tensor({I, I, I, H*H', V*V'}); %01
P{3} = tensor({I, I, I, V*V', H*H'}); %10
P{4} = tensor({I, I, I, V*V', V*V'}); %11

%% Alice commences the transmission
% Alice prepares a photon to be transmitted 
a = rand(1);
b = sqrt(1-a^2); 
c = a*H+b*V % c denotes the photon transmitted by Alice

% Alice appends two bits and entangle them
Appended_c = tensor({c,H,H});
Entangled_c = CNOT * Appended_c;

% The 2 qubits go through a potential error channel
Error = randi([1,4]); % 1 denotes no error occurs
switch Error
    case 1
        ReceivedPhotons = Entangled_c;
    case 2
        ReceivedPhotons = tensor({X,I,I})*Entangled_c;
    case 3
        ReceivedPhotons = tensor({I,I,X})*Entangled_c;
    case 4
        ReceivedPhotons = tensor({I,X,I})*Entangled_c;
end

%% Bob Receives and does error correction
% Bob appends two new bits that also serve as control bits of the incoming
% Z-gates
Appended_c = tensor({ReceivedPhotons,HDM*H,HDM*H});
ZZ_c = UZ124 * UZ235 * Appended_c;
HZZH_c = tensor({I,I,I,HDM,I})*ZZ_c;
HZZHH_c = tensor({I,I,I,I,HDM})*HZZH_c;

% Apply projection operators
Probability = zeros(1,4);
for p = 1:4 % p denotes which projection operator is used this time
    Probability(p) = HZZHH_c'*P{p}*HZZHH_c;
end
Syndrome_Index = find(Probability >= 0.9);
SyndromeTable = {'00', '01', '10', '11'};
disp(['Sydrome: ', SyndromeTable{Syndrome_Index}]);

% Apply correction operator accordingly
Index = [3, 1, 2];
Correction = {I, I, I, I, I};
if Syndrome_Index - 1 >0
    Correction{Index(Syndrome_Index - 1)} = X;
end
c_Final = tensor(Correction) * HZZHH_c;

%% Bob decodes the qubits
% Detangle
c_Final = tensor({CNOT, I, I}) * c_Final;
% Trace out
c_Final = (tensor({I, H', H', H', H'}) + tensor({I, H', H', H', V'}) + tensor({I, H', H', V', H'}) + tensor({I, H', H', V', V'})) * c_Final;
c_Final = full(c_Final)

