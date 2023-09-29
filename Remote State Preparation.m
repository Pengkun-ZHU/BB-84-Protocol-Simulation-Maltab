%% This code is used to simulate remote state preparation
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

%% Alice and Bob share a Bell state
AB = Bell{1};

%% Alice possesses information of a state to be remotely prepared
% Randomly choose a phi value (radian)
phi = pi / (15 * rand(1));
% The state that Alice wants to send can hence be presented as
A = 1/sqrt(2) * (H + exp(phi * 1i) * V);

%% Alice measures her particle
p = zeros(1,2);
P1 = (H + V * exp(-1i*phi)) / sqrt(2) * (H + V * exp(-1i*phi))' / sqrt(2);
P2 = (H - V * exp(-1i*phi)) / sqrt(2) * (H - V * exp(-1i*phi))' / sqrt(2);
p(1) = AB' * tensor({P1,I}) * AB;
p(2) = AB' * tensor({P2,I}) * AB;
p = real(p);
% Randomly collapse into a basis according to the probability
Collapse = rand(1);
if Collapse >= p(1)
    AB = tensor({P2,I}) * AB / sqrt(p(2));
    flag = 2;
else
    AB = tensor({P1,I}) * AB / sqrt(p(1));
    flag = 1;
end

%% Trace out Alice's half for further verification
if flag == 1
    B = tensor({((H + V * exp(-1i*phi)) / sqrt(2))',I}) * AB;
else
    B = tensor({((H - V * exp(-1i*phi)) / sqrt(2))',I}) * AB;
end

%% Bob recovers his half based on the result told by Alice
if flag == 1
else
    B = Z * B;
end

%% Verify
A
B
if sum(abs(A - B)) < 1e-10
    disp('The recover operation is successful')
end
