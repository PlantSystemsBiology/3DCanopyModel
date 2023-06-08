
% Maize leaf transmittance fitting:
% A619, B73 and W64A use  Y = 0.005956 X2 - 0.7954 X + 28.96 

% Maize leaf reflectance fitting:
% A619 use: 
% Y = 0.002478 X2 - 0.3554 X + 16.66
% B73 and W64A use:
% Y = -0.04642 X + 8.648
% Unit: X is SPAD, eg. 40.4, 54.8. Y is % eg. 9.53, 3.05. 
% 400-700nm, solar light. 

function Y = leafRfromSPAD(SPAD,cultivar)
X = SPAD;

if cultivar == 2 %"A619"  % A619, light green
    Y = 0.002478 *X*X - 0.3554 *X + 16.66;
elseif cultivar == 1 || cultivar == 3 % 1 for "W64A, 3 for "B73"  % B73 and W64A, dark green
    Y = -0.04642 * X + 8.648;
end
Y = Y/100;

end



