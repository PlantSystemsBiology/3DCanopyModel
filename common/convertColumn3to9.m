
% this function in mCanopy, used to convert data format with 9 column to 3
% column.
function matrixOf9col = convertColumn3to9 (matrixOf3Column)

[row,col]=size(matrixOf3Column);
row = row/3;
if col~=3
    error('not 3 column matrix!');
else
    
    matrixOf9col = [ ...
        matrixOf3Column(1:row,1),           matrixOf3Column(1:row,2),           matrixOf3Column(1:row,3),       ...
        matrixOf3Column(row+1:row*2,1),     matrixOf3Column(row+1:row*2,2),     matrixOf3Column(row+1:row*2,3), ...
        matrixOf3Column(row*2+1:row*3,1),   matrixOf3Column(row*2+1:row*3,2),   matrixOf3Column(row*2+1:row*3,3)...
        ];
    
end
end
