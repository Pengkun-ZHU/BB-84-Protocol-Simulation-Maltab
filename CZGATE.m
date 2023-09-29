function [czgate] = CZGATE(Control,Target) % Target should be a sequence
I = [1 0;0 1];
Z = [1 0;0 -1];
H = [1;0]; V = [0;1];

%% 17 bits input
for i = 1:17
    L(i) = {I};
    R(i) = {I};
end

L{Control} = H*H';
R{Control} = V*V';

for q = 1:length(Target)
    R{Target(q)} = Z;
end

czgate = tensor(L) + tensor(R);

end
