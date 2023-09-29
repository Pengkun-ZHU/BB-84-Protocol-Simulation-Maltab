%% This code is used to simulate Third-party teleportation
%% No extra input required

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

%% Alice, Bob and Charlie share three qubits that are entangled, namely GHZ state
GHZ = 1/sqrt(2) * (tensor({H,H,H}) + tensor({V,V,V}));

%% Alice adds a new qubit c to be teleported hence forms a four-bit system
alpha = rand(1);
beta = sqrt(1-alpha^2);
c = alpha*H+beta*V
S4 = tensor({c,GHZ});

%% Alice applies a bell measurement to her 2 qubits, which will force the 4-qubit system into a new state
p = zeros(1,4);
for i = 1:4
    p(i) = S4' * tensor({BO{i},I,I}) * S4;
end

Bell_Detected = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)]);
Numerator = tensor({BO{Bell_Detected},I,I}) * S4;
Denominator = sqrt(S4' * tensor({BO{Bell_Detected},I,I}) * S4);
S4 = Numerator/Denominator;

%% Charlie applies a Hadamard measurement to his qubit.
pPlus = S4' * tensor({I,I,I,PlusOperator}) * S4;
pMinus = S4' * tensor({I,I,I,MinusOperator}) * S4;

p = rand(1);
if p > pPlus % + state occurs
    Numerator = tensor({I,I,I,PlusOperator}) * S4;
    Denominator = sqrt(S4' * tensor({I,I,I,PlusOperator}) * S4);
    S4 = Numerator/Denominator;
    flag = 1;
else % - state occurs
    Numerator = tensor({I,I,I,MinusOperator}) * S4;
    Denominator = sqrt(S4' * tensor({I,I,I,MinusOperator}) * S4);
    S4 = Numerator/Denominator;
    flag = 2;
end

%% Bob applies corresponding unitary matrix to recover the system
switch Bell_Detected
    case 1
        if flag == 1
            S4_Final = S4;
        else
            S4_Final = tensor({I,I,Z,I}) * S4;
        end
    case 2
        if flag == 1
            S4_Final = tensor({I,I,Z,I}) * S4;
        else
            S4_Final = S4;
        end
    case 3
        if flag == 1
            S4_Final = tensor({I,I,X,I}) * S4;
        else
            S4_Final = tensor({I,I,X * Z,I}) * S4;
        end
    case 4
        if flag == 1
            S4_Final = tensor({I,I,Z * X,I}) * S4;
        else
            S4_Final = tensor({I,I,Z * X * Z,I}) * S4;
        end
end

%% Bob traces other qubits
TrA2 = tensor({Bell{Bell_Detected}',I,I}) * S4_Final;
if flag == 1
TrC = tensor({I,Plus'}) * TrA2;
else
    TrC = tensor({I,Minus'}) * TrA2;
end
Final = full(TrC)