%% This code is used to simulate the teleporation under a noisy enviroment
%% No extra input required

clear; clc
%% Define constant
H = [1;0]; V = [0;1];
I = [1 0;0 1];
Z = [1 0;0 -1];
X = [0 1;1 0];
HDM = [1,1;1,-1]/sqrt(2);
Plus = 1/sqrt(2) * [1;1];
PlusOperator = Plus * Plus';
Minus = 1/sqrt(2) * [1;-1];
MinusOperator = Minus * Minus';
CNOT = [1 0 0 0;
    0 1 0 0
    0 0 0 1
    0 0 1 0];
Bell = cell(1,4);
BO = cell(1,4); % BO denotes Bell Operator
BO{1} = (1/sqrt(2)) * (kron(H,H) + kron(V,V)) * (1/sqrt(2)) * (kron(H,H) + kron(V,V))'; % 00
BO{2} = (1/sqrt(2)) * (kron(H,H) - kron(V,V)) * (1/sqrt(2)) * (kron(H,H) - kron(V,V))'; % 01
BO{3} = (1/sqrt(2)) * (kron(H,V) + kron(V,H)) * (1/sqrt(2)) * (kron(H,V) + kron(V,H))'; % 10
BO{4} = (1/sqrt(2)) * (kron(H,V) - kron(V,H)) * (1/sqrt(2)) * (kron(H,V) - kron(V,H))'; % 11
Bell{1} = (1/sqrt(2)) * (kron(H,H) + kron(V,V));
Bell{2} = (1/sqrt(2)) * (kron(H,H) - kron(V,V));
Bell{3} = (1/sqrt(2)) * (kron(H,V) + kron(V,H));
Bell{4} = (1/sqrt(2)) * (kron(H,V) - kron(V,H));

%% Alice and Charlie possess a Bell state, respectively
AA = Bell{1};
CC = Bell{1};

%% Build two noisy channels
a1 = 0.99^2; b1 = rand(1); c1 = rand(1); d1 = rand(1);
a2 = 0.99^2; b2 = rand(1); c2 = rand(1); d2 = rand(1);
% Normalize
all1 = b1 + c1 + d1;
b1 = b1 / (all1*1/0.0199); c1 = c1 / (all1*1/0.0199); d1 = d1 / (all1*1/0.0199);
all2 = b2 + c2 + d2;
b2 = b2 / (all2*1/0.0199); c2 = c2 / (all2*1/0.0199); d2 = d2 / (all2*1/0.0199);
% The two channels can hence be built
E1 = sqrt(a1) * I + sqrt(b1) * X + sqrt(c1) * Z + sqrt(d1) * (X * Z);
E2 = sqrt(a2) * I + sqrt(b2) * X + sqrt(c2) * Z + sqrt(d2) * (X * Z);

%% Alice and Charlie send A' and C' to Bob through the two noisy channel
AA = tensor({I,E1}) * AA; CC = tensor({I,E2}) * CC;
AACC = tensor({AA,CC});
p = zeros(1,4);
for i = 1:4
    p(i) = AACC' * tensor({I,BO{i},I}) * AACC;
end
Bell_Detected = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)]);
Numerator = tensor({I,BO{Bell_Detected},I}) * AACC;
Denominator = sqrt(AACC' * tensor({I,BO{Bell_Detected},I}) * AACC);
AACC = Numerator/Denominator;

%% Charlie tries to vary his quantum states based on the Bell measurement results
switch Bell_Detected
    case 1
        AACC = tensor({I,I,I,I}) * AACC;
    case 2
        AACC = tensor({I,I,I,Z}) * AACC;
    case 3
        AACC = tensor({I,I,I,X}) * AACC;
    case 4
        AACC = tensor({I,I,I,Z * X}) * AACC;
end


%% Trace out and verify
AC = tensor({I,Bell{Bell_Detected}',I})* AACC;
% Calculate the fidelity
Fidelity = abs(Bell{1}'* AC)^2




