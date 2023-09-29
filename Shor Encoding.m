clear; clc
%% Task 13
%% This program simulates the Shor-code encoding by which prevent the ...
%% quanta from the error caused by the channel
%% Define syndrome table
Syndrome = [1 0 0 0 0 0 0 0; %X1
       1 1 0 0 0 0 0 0; %X2
       0 1 0 0 0 0 0 0; %X3
       0 0 1 0 0 0 0 0; %X4
       0 0 1 1 0 0 0 0; %X5
       0 0 0 1 0 0 0 0; %X6
       0 0 0 0 1 0 0 0; %X7
       0 0 0 0 1 1 0 0; %X8
       0 0 0 0 0 1 0 0; %X9
       0 0 0 0 0 0 1 0; %Z123
       0 0 0 0 0 0 1 1; %Z456
       0 0 0 0 0 0 0 1; %Z789
       1 0 0 0 0 0 1 0; %X1Z1
       1 1 0 0 0 0 1 0; %X2Z2
       0 1 0 0 0 0 1 0; %X3Z3
       0 0 1 0 0 0 1 1; %X4Z4
       0 0 1 1 0 0 1 1; %X5Z5
       0 0 0 1 0 0 1 1; %X6Z6
       0 0 0 0 1 0 0 1; %X7Z7
       0 0 0 0 1 1 0 1; %X8Z8
       0 0 0 0 0 1 0 1; %X9Z9
       0 0 0 0 0 0 0 0];% no error

%% Define constant
% Define quantum states and gates
H = [1;0]; V = [0;1];
I = [1 0;0 1];
Z = [1 0;0 -1];
X = [0 1;1 0];
HDM = [1,1;1,-1]/sqrt(2);

%% Alice Prepare the qubits aggregation
% Alice prepares the photon to be transmitted
alpha = rand(1);
beta = sqrt(1-alpha^2);
c = alpha*H+beta*V

% Alice appends extra qubits for protection use
S_1 = tensor({c,tensor({H},8)});
S_1 = CNOT(9,1,[4,7]) * S_1;
S_1 = tensor({HDM,I,I,HDM,I,I,HDM,I,I}) * S_1;
S_1 = CNOT(9,1,[2,3]) * CNOT(9,4,[5,6]) * CNOT(9,7,[8,9]) * S_1;

%% Alice sents the qubits going through a realistic channel
p_channel = zeros(1,4);
for j = 1:4
    p_channel(j) = rand(1);
end

% Normalize
p_channel_all = p_channel(1) + p_channel(2) + p_channel(3) + p_channel(4);
pc1 = p_channel(1) / p_channel_all; %No error
pc2 = p_channel(2) / p_channel_all;
pc3 = p_channel(3) / p_channel_all;
pc4 = p_channel(4) / p_channel_all;

% Channel model
W = sqrt(pc1) * I + sqrt(pc2) * X + sqrt(pc3) * Z + sqrt(pc4) * X * Z


% Go through the channel that corrupts at most 1 qubit
ErrorIndex = randi(9);
Error = {I,I,I,I,I,I,I,I,I};
Error{ErrorIndex} = W;
Error = tensor(Error);
S_Error = Error * S_1;

%% Bob receives and does the preparation for syndrome extraction
% Append 8 more bits
S_2 = S_Error;
for j = 1:8
    S_2 = tensor({S_2,HDM*H});
end

% Apply Control-Z-Gate and Control-X-Gate
S_3 = CZGATE(10,[1,2]) * S_2;
S_3 = CZGATE(11,[2,3]) * S_3;
S_3 = CZGATE(12,[4,5]) * S_3;
S_3 = CZGATE(13,[5,6]) * S_3;
S_3 = CZGATE(14,[7,8]) * S_3;
S_3 = CZGATE(15,[8,9]) * S_3;
S_3 =  CNOT(17,16,[1,2,3,4,5,6]) * CNOT(17,17,[4,5,6,7,8,9]) * S_3;

% Cancel Hadmard gates by applying them again
S_3 = tensor({tensor({I},9),tensor({HDM},8)}) * S_3;

%% Bob extracts syndromes
syndrome = zeros(1, 8);
% Apply projection operator
for j = 1:8
    p = zeros(1,2);
    O = cell(1,2); % O denotes operator
    Tr = cell(1,2); % Tr denotes tracer
    
    O{1} = tensor({tensor({I}, 17 - j), H*H'}); % Eigen value = +1
    O{2} = tensor({tensor({I}, 17 - j), V*V'}); % Eigen value = -1
    
    Tr{1} = tensor({tensor({I}, 17 - j), H'});
    Tr{2} = tensor({tensor({I}, 17 - j), V'});
    
    % Calculate the probability
    for i = 1:2
        p(i) = S_3' * O{i} * S_3;
    end 
    
    Collapse = rand(1); % The system randomly collapses into a state according to the possibility
    if Collapse > p(2) % If operator 1's outcome occurs
        Numerator = O{1} * S_3;
        Denominator = sqrt(S_3' * O{1} * S_3);
        S_3 = Numerator / Denominator; % State after projecting
        S_3 = Tr{1} * S_3; % Trace out
        syndrome(j) = 0;
    else % If operator 2's outcome occurs
        Numerator = O{2} * S_3;
        Denominator = sqrt(S_3' * O{2} * S_3);
        S_3 = Numerator / Denominator; % State after projecting
        S_3 = Tr{2} * S_3; % Trace out
        syndrome(j) = 1;
    end
    
end

syndrome = fliplr(syndrome)

%% Bob does error correction
for i = 1:22
    if syndrome == Syndrome(i, :)
        Syndrome_Index = i;
    end
end

% Define correction matrix
Correction = cell(9, 1);
for i = 1:9
   Correction{i} = I; 
end
if Syndrome_Index <= 9 % correct x error
    Correction{Syndrome_Index} = X;
elseif Syndrome_Index == 12 % correct z789 error
    Correction{7} = Z;
    elseif Syndrome_Index == 11 % correct z456 error
    Correction{4} = Z;
    elseif Syndrome_Index == 10 % correct z456 error
    Correction{1} = Z;
elseif Syndrome_Index <= 21 % correct xz error
    Correction{Syndrome_Index - 12} = Z * X;
end

S_4 = tensor(Correction) * S_3;

%% Bob traces out the qubit desired
S = CNOT(9,7,[8,9]) * CNOT(9,4,[5,6]) * CNOT(9,1,[2,3]) * S_4;
S = tensor({HDM, I, I}, 3) * S;
S = CNOT(9,1,[4,7]) * S;
S = tensor({I, tensor({H'}, 8)}) * S;
s = full(S) % Convert the matrix from sparse to full

%% Verify the correctness of this transmission
if sum((c - s).^2) < 1e-10
    disp('Transmission succeeds')
else
    disp('Transmission fails')
end







