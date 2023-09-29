function [cnot] = CNOT(BitNum,Control,Target) % Target should be a sequence
I = [1 0;0 1];
X = [0 1;1 0];
H = [1;0]; V = [0;1];

%% Exclusively for 9 bits
switch BitNum
    case 9

for i = 1:9
    L(i) = {I};
    R(i) = {I};
end

L{Control} = H*H';
R{Control} = V*V';


for q = 1:length(Target)
    R{Target(q)} = X;
end

case 17
for i = 1:17
    L(i) = {I};
    R(i) = {I};
end

L{Control} = H*H';
R{Control} = V*V';

for q = 1:length(Target)
    R{Target(q)} = X;
end
end

cnot = tensor(L) + tensor(R);

end
