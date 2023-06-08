
% 输出和 queryNum 一样长度的编号
% used to map two vectors with different length
% when compare different tiller numbers and leaf numbers
function targetIndex = heteroMapping (targetNum, originNum)
% targetIndex = heteroMapping (queryNum, targetNum)

queryList = (1/targetNum/2): (1/targetNum) : 1;  % generate the query quantiles

targetList = (1/originNum/2) : (1/originNum) : 1; % generate the target quantiles

targetIndex = zeros(targetNum,1); % output vector


for i = 1:targetNum
    diff_minimal = 1; % maximal initial
    for j = 1:originNum
        diff = abs(queryList(i)-targetList(j));
        
        if diff<=diff_minimal
            diff_minimal = diff; % update the diff_minimal
            targetIndex(i) = j;
        end
    end
end


end


