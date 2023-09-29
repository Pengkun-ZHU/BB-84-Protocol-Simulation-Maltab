%% This code is used to simulate the entanglement swap
%% No extra input required

clear all; clc
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

%% Alice and Charlie possess a bipartite state that is a random Bell state
AC = Bell{randi(4)};

%% Alice and Bob share a Bell state
AB = Bell{1};
ACAB = tensor({AC, AB});

%% Alice and Bob perform Bell measurement
p = zeros(1,4);
for i = 1:4
    p(i) = ACAB' * tensor({I,BO{i},I}) * ACAB;
end
Bell_Detected = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)]);
Numerator = tensor({I,BO{Bell_Detected},I}) * ACAB;
Denominator = sqrt(ACAB' * tensor({I,BO{Bell_Detected},I}) * ACAB);
ACAB = Numerator/Denominator;

%% Apply recover scheme
switch Bell_Detected
    case 1
        ACAB = tensor({I,I,I,I})* ACAB;
    case 2
        ACAB = tensor({I,I,I,Z})* ACAB;
    case 3
        ACAB = tensor({I,I,I,X})* ACAB;
    case 4
        ACAB = tensor({I,I,I,Z*X})* ACAB;
end

%% Trace out
BC = tensor({I,Bell{Bell_Detected}',I})* ACAB;
AC
full(BC)
if sum(abs(AC - BC)) < 1e-10
    disp('Succeeded')
end