
% ** --- 对一株植物调节叶片结构和叶片数 --- **
% input: plantModel
% 是当前的单株植物的VectorModel,其中stem的部分是tris三角面元，叶片的部分是vector，1-9是结构，10是叶片ID，11是上下层flag
% adjustConfig
% adjustConfig.leafWidthMultiply
% adjustConfig.leafLengthMultiply
% adjustConfig.leafAngleAdd
% adjustConfig.leafCurvatureTo
% adjustConfig.leafNumberTo

function PlantTris = adjustPlantArchitecture(plantModel, adjustConfig, removeStamen)

PlantTris = zeros(0, 11);

leafNum = max(plantModel(:,10));   % 总叶片数
top1leaf = plantModel(plantModel(:,10) == leafNum, :); % 最上1叶片的数据
stemHeight = min(top1leaf(1,3)); % 最上第一叶的叶基部高度，等于 stem length 茎长度

stemTris = plantModel(plantModel(:,10) == 0, :); % stem的面元，留存。
if removeStamen
    stemTris = stemTris(stemTris(:,3)<=stemHeight,:);
end
PlantTris = [PlantTris; stemTris]; % 把stem的放入到输出数组里

for i = 1:leafNum

    i
    %首先，按照上下层给与不同的调整参数
    d = plantModel(plantModel(:,10) == i,:);
    if d(1,11) == 1 % bottom layer
        adj.leafWidthMultiply = adjustConfig.leafWidthMultiply.b;
        adj.leafLengthMultiply = adjustConfig.leafLengthMultiply.b;
        adj.leafAngleAdd = adjustConfig.leafAngleAdd.b;
        adj.leafCurvatureAdd = adjustConfig.leafCurvatureAdd.b;
    elseif d(1,11) == 2 % up layer
        adj.leafWidthMultiply = adjustConfig.leafWidthMultiply.u;
        adj.leafLengthMultiply = adjustConfig.leafLengthMultiply.u;
        adj.leafAngleAdd = adjustConfig.leafAngleAdd.u;
        adj.leafCurvatureAdd = adjustConfig.leafCurvatureAdd.u;
    else
        error('layer ID should be 1 or 2');
    end

    % 然后，对于每个叶片调节
    vectorModel = plantModel(plantModel(:,10) == i, 1:9); % leaf i 的vector model。
    [points, tris] = adjustLeafArchitecture (vectorModel, adj);
    tris(:, 10) = i; tris(:,11) = d(1,11); % 补全10，11列的信息
% plot
%     tri = tris;
%     [row,col] = size(tri);
%     seq = [1:row]';
%     T = [seq, seq+row, seq+row*2];
%     x = [tri(:,1);tri(:,4);tri(:,7)];
%     y = [tri(:,2);tri(:,5);tri(:,8)];
%     z = [tri(:,3);tri(:,6);tri(:,9)];
%     C = z;
%     % draw figure
%     figure(1);
%     trisurf(T, x,y,z,C,'FaceAlpha', 1, 'EdgeColor', 'none'); % or use 'FaceColor','g'
%     axis equal
%     view(-70,15)
%     hold on;

    PlantTris = [PlantTris; tris]; % 仅保存面元即可
end

% 最后是调节叶片数
aln = adjustConfig.leafNumberAdd; %调节叶片数
if aln ~= 0
    indexVector = heteroMapping(leafNum+aln, leafNum); % 将当前的leafNum调节到目标的aln数
    adjstep = stemHeight/length(indexVector)/2;
    % calculate the adjust values for every leaf from bottom to top
    adjustLeafBaseHeightVector = zeros(length(indexVector),1); % initial an zeros vector
    for j = 1: length(indexVector)
        if j==1
            if indexVector(j)==indexVector(j+1)
                adjustLeafBaseHeightVector(j)= -adjstep; % the bottom one leaf, leaves from bottom to up
            end
        elseif j==length(indexVector)
            if indexVector(j)==indexVector(j-1)
                adjustLeafBaseHeightVector(j)= +adjstep; % the top one leaf
            end
        else
            if indexVector(j)==indexVector(j+1)
%                 adjstep
                adjustLeafBaseHeightVector(j)= -adjstep; % it is the same as the upper one
            end
            if indexVector(j)==indexVector(j-1)
                adjustLeafBaseHeightVector(j)= +adjstep; % it is the same as the lower one
            end
        end
    end % calcualte the adjust values for every leaf from bottom to top
    PlantTris = plantStructureAdjustLN(PlantTris, indexVector, adjustLeafBaseHeightVector); %调整叶数量
end

end


