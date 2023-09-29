%% This code is used to simulate teleportation
%% No extra input required

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

%% Alice and Bob share particles a and b, which are in an entangled Bell state
AB = Bell{1};

%% Alice adds a new qubit c and entangles them
alpha = rand(1);
beta = sqrt(1-alpha^2);
c = alpha*H+beta*V
CAB = tensor({c,AB});

%% Alice does a Bell measurement on c and a
p = zeros(1,4);
for i = 1:4
p(i) = CAB' * tensor({BO{i},I}) * CAB;
end
Bell_Detected = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)])
Numerator = tensor({BO{Bell_Detected},I}) * CAB;
Denominator = sqrt(CAB' * tensor({BO{Bell_Detected},I}) * CAB);
CAB = Numerator/Denominator;
b = tensor({Bell{Bell_Detected},I})' * CAB;
switch Bell_Detected
    case 1
    case 2
        b = Z * b
    case 3
        b = X * b
    case 4
        b = Z * X * b 
end

% Verify
if sum(abs(c - b)) < 1e-10
    disp('Teleportation succeeds')
end