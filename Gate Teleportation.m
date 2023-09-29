%% This code is used to simulate gate teleportation
%% No extra input required

clear; clc
%% Define constant
H = [1;0]; V = [0;1];
I = [1 0;0 1];
Z = [1 0;0 -1];
X = [0 1;1 0];
HDM = [1,1;1,-1]/sqrt(2);
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

% Define a random Unitary matrix whose order is 1
x = complex(rand(2),rand(2))/sqrt(2);
% factorize the matrix
[Q,R] = qr(x);
R = diag(diag(R)./abs(diag(R)));
% unitary matrix
U = Q*R;

%% Alice and Bob first prepares a bell state and Alice applies a random unitary  matrix
S2 = Bell{1};
S2 = tensor({I,U}) * S2;

%% Alice adds a new qubit c to be teleported hence forms a 3-bit system
alpha = rand(1);
beta = sqrt(1-alpha^2);
c = alpha*H+beta*V;
S3 = tensor({c,S2});

%% Alice applies a bell measurement to her 2 qubits, which will force the 3-qubit system into a new state
p = zeros(1,4);
for i = 1:4
    p(i) = S3' * tensor({BO{i},I}) * S3;
end
p = real(p);
Bell_Detected = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)]);
Numerator = tensor({BO{Bell_Detected},I}) * S3;
Denominator = sqrt(S3' * tensor({BO{Bell_Detected},I}) * S3);
S3 = Numerator/Denominator;

%% Bob performs one of the four corrective operations on his qubit
switch Bell_Detected
    case 1
        S3 = tensor({I,I,U * U'}) * S3;
    case 2
        S3 = tensor({I,I,U * Z * U'}) * S3;
    case 3
        S3 = tensor({I,I,U * X * U'}) * S3;
    case 4
        S3 = tensor({I,I,U * Z * X * U'}) * S3;
end

%% Trace out
Final = full(tensor({Bell{Bell_Detected}',I}) * S3);

%% Verify
if sum((Final - U * c).^2) < 1e-10
    display('succeeds');
else
    display('fails');
end

Final
U * c


