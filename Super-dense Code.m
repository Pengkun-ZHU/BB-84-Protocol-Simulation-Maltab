%% This code is used to simulate super-dense code
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
Bell{1} = (1/sqrt(2)) * (kron(H,H) + kron(V,V)) * (1/sqrt(2)) * (kron(H,H) + kron(V,V))'; % 00
Bell{2} = (1/sqrt(2)) * (kron(H,H) - kron(V,V)) * (1/sqrt(2)) * (kron(H,H) - kron(V,V))'; % 01
Bell{3} = (1/sqrt(2)) * (kron(H,V) + kron(V,H)) * (1/sqrt(2)) * (kron(H,V) + kron(V,H))'; % 10
Bell{4} = (1/sqrt(2)) * (kron(H,V) - kron(V,H)) * (1/sqrt(2)) * (kron(H,V) - kron(V,H))'; % 11

%% Alice prepares
AA = CNOT * tensor({HDM * H, H});

%% Alice transmits qubit 2 to Bob, where the channel is assumed to be lossless
AA = tensor({I,I}) * AA;

%% Alice randomly collapse the 2-qubit system into one of the four bell states
x1 = randi(2) - 1
x2 = randi(2) - 1

switch x1
    case 1
        AB = tensor({X, I}) * AA;
    case 0
        AB = AA;
end
switch x2
    case 1
        AB = tensor({I, Z}) * AB;
    case 0
end

%% Alice sends qubit 1 to Bob, the channel is still assumed to be lossless
AB = tensor({I,I}) * AB;

%% Bob does Bell measurement and gets the outcomes
p = zeros(1,4);
for i=1:4
    p(i) = AB' * Bell{i} * AB;
end
Bell_Detected = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)]);
switch Bell_Detected
    case 1
        x12 = [0 0];
    case 2
        x12 = [0 1];
    case 3
        x12 = [1 0];
    case 4
        x12 = [1 1];
end
x12












