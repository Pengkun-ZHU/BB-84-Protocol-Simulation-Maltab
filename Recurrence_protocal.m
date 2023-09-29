%% Define constant
H = [1;0]; V = [0;1];
I4x4 = [1 0 0 0;
    0 1 0 0;
    0 0 1 0
    0 0 0 1];
I = [1 0;
    0 1];
Z = [1 0;0 -1];
X = [0 1;1 0];
Y = [0 -1i;
    1i 0];
HDM = [1,1;1,-1]/sqrt(2);
% CNOT = [1 0 0 0;
%     0 1 0 0
%     0 0 0 1
%     0 0 1 0];
% Define U set
U = [{I} {X} {Y} {Z}];
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

%% Alice and Bob share two indentical noisy Bell states (i.e. identical)
a = 1/3 + 2/3 * rand(1);
AB1 = a * Bell{4} * Bell{4}' + (1-a) * I4x4/4;
AB2 = AB1;
Fin = Bell{4}' * AB1 * Bell{4};

%% Alice picks up a U matrix from the set [I,X,Y,Z] and informs Bob her choice, then they apply that U to their quanta
U = U{randi(4)};
UAB1 = tensor({sqrtm(U),sqrtm(U)}) * AB1 * tensor({sqrtm(U),sqrtm(U)})';
UAB1 = tensor({Y,I}) * UAB1 * tensor({Y',I'});
UAB2 = UAB1;


%% Alice and Bob apply cnot gate
AB1AB2 = tensor({UAB1,UAB2});
BobCNOT = tensor({I,H * H',I,I}) + tensor({I,V * V',I,X});
AliceCNOT = tensor({H * H',I,I,I}) + tensor({V * V',I,X,I});
AB1AB2 = AliceCNOT * BobCNOT * AB1AB2 * AliceCNOT' * BobCNOT';


%% Alice and Bob do local measurement in standard basis
p = zeros(1,4);
p(1) = trace(AB1AB2 * tensor({I,I,H * H',H * H'}));
p(2) = trace(AB1AB2 * tensor({I,I,H * H',V * V'}));
p(3) = trace(AB1AB2 * tensor({I,I,V * V',H * H'}));
p(4) = trace(AB1AB2 * tensor({I,I,V * V',V * V'}));



Collapse = randsrc(1,1,[1,2,3,4;p(1),p(2),p(3),p(4)]);
switch Collapse
    case 1
        Numerator = tensor({I,I,H * H',H * H'})* AB1AB2 * tensor({I,I,H * H',H * H'})';
        Denominator = p(1);
        S = Numerator/Denominator;
        flag = 1;
    case 2
        flag = 0;
    case 3
        flag = 0;
    case 4
        Numerator = tensor({I,I,V * V',V * V'})* AB1AB2 * tensor({I,I,V * V',V * V'})';
        Denominator = p(1);
        S = Numerator/Denominator;
        flag =2;
end

switch flag
    case 0
        disp('a ~= b, Alice and Bob throw out all systems and restart the protocl')
    case 1
        AB = tensor({I,I,(H * H'),(H * H')})' * S * tensor({I,I,H * H',H * H'});
    case 2
        AB = tensor({I,I,(V * V')',(V * V')})' * S * tensor({I,I,V * V',V * V'});
end

if flag ~= 0
Fin
Fout = Bell{4}' * AB * Bell{4}
end


