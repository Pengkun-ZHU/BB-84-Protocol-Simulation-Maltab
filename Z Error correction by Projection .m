clear all; clc
%% Task 10
%% This program simulates the Z error correction by applying projection ..
%% operator directly on transmitted qubits.
%% Define constants
% Define basis
S1 = 1/sqrt(2) * [1;1];
S2 = 1/sqrt(2) * [1;-1];

I = [1, 0; 0, 1];
Z = [1, 0; 0, -1];

% Control Z gate
CZGATE = kron(S1*S1',kron(I,I))+kron(S2*S2',kron(Z,Z));

% Define projection operators
P = cell(1,4);
P1_Left = kron(S2,kron(S1,S1)); P1_Right = kron(S1,kron(S2,S2));
P{1} = P1_Left * P1_Left' + P1_Right * P1_Right';

P2_Left = kron(S1,kron(S2,S1)); P2_Right = kron(S2,kron(S1,S2));
P{2} = P2_Left * P2_Left' + P2_Right * P2_Right';

P3_Left = kron(S1,kron(S1,S2)); P3_Right = kron(S2,kron(S2,S1));
P{3} = P3_Left * P3_Left' + P3_Right * P3_Right';

P4_Left = kron(S1,kron(S1,S1)); P4_Right = kron(S2,kron(S2,S2));
P{4} = P4_Left * P4_Left' + P4_Right * P4_Right';

%% Alice prepares quantum to be transmitted 
a = rand(1);
b = sqrt(1-a^2); 
c = a * S1 + b * S2
% Alice appends two more qubits
c = kron(c,kron(S1,S1));
% Alice entangles them by control Z gate
S = CZGATE * c;

%% % The 3 qubits go through a potential error channel
Error_Index = randi(3)
switch Error_Index
    case 1
        S = kron(Z,kron(I,I)) * S;
    case 2
        S = kron(I,kron(Z,I)) * S;
    case 3
        S = kron(I,kron(I,Z)) * S;
end

%% Bob receives the quantum and tries to detect and correct error
p = zeros(1,4);
for i = 1:4
    p(i) = S' * P{i} * S;
end

for j = 1:4
    if p(j) > 0.9
        Error_Found = j
    end
end
% correct the corresponding qubit
switch Error_Found
    case 1
        c_Final = kron(Z,kron(I,I)) * S;
    case 2
        c_Final = kron(I,kron(Z,I)) * S;
    case 3
        c_Final = kron(I,kron(I,Z)) * S;
end

% Detangle
c_Final = CZGATE * c_Final;
% Trace out
S = kron(I,kron(S1',S1')) * c_Final