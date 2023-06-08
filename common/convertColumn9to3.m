
% this function in mCanopy, used to convert data format with 9 column to 3
% column.
function [X, Y, Z] = convertColumn9to3 (matrixOf9Column)

[row,col]=size(matrixOf9Column);

if col~=9
    error('not 9 column matrix!');
else
    X = [matrixOf9Column(:,1);matrixOf9Column(:,4);matrixOf9Column(:,7)];
    Y = [matrixOf9Column(:,2);matrixOf9Column(:,5);matrixOf9Column(:,8)];
    Z = [matrixOf9Column(:,3);matrixOf9Column(:,6);matrixOf9Column(:,9)];
end

end
