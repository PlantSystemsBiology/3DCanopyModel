

% 调整叶片的数量
% 针对点云模型，利用上述计算的调整叶片数之后的叶片index, indexVector2, 和调整之后重新计算的, adjustLeafBaseHeightVector
function plantMeshModel_out = plantStructureAdjustLN(plantMeshModel, indexVector2, adjustLeafBaseHeightVector)

Positive = 1;
Negative = -1;

d = plantMeshModel;
% basic information
LEAF_ID_idx = 10;
leafNum = max(d(:,LEAF_ID_idx));

[row,col]=size(d);
plantMeshModel_out = zeros(0,col); % 初始化空的矩阵，列数与输入model一致

% for each leaf, do the adjustment.
for i = 1:length(indexVector2)
    j = indexVector2(i);
    temp = d(d(:,10)==j,:);

    [X, Y, Z] = convertColumn9to3 (temp(:,1:9));
    temp2 = [X,Y,Z];
%     size(temp2)

    if i==1
        if abs(max(temp2(:,2))) > abs(min(temp2(:,2)))
            direction = Positive;
        else
            direction = Negative;
        end
    else % i>1， 第2片叶片
        if abs(max(temp2(:,2))) > abs(min(temp2(:,2))) 
            if direction == Positive  %% 当前的叶片和上一个叶片同为Positive
                [~, I] = min(temp2(:,2)); leafBasePoint = temp2(I,1:3); 
                temp2(:,1:3) = coordinate_rotate2(temp2(:,1:3),180,leafBasePoint,3); % 
                direction = Negative; % 旋转后的方向
            else
                direction = Positive;
            end
        elseif abs(max(temp2(:,2))) < abs(min(temp2(:,2)))
            if direction == Negative % 当前的叶片和上一个叶片同为Negative
                [~, I] = max(temp2(:,2)); leafBasePoint = temp2(I,1:3); 
                temp2(:,1:3) = coordinate_rotate2(temp2(:,1:3),180,leafBasePoint,3); % 
                direction = Positive; % 旋转后的方向
            else
                direction = Negative;
            end
        else
            %没有别的情况了
        end
    end
    temp(:,1:9) = convertColumn3to9 (temp2);
%     size(temp)
    temp(:,10) = i; % 重新给与一个leafID
    temp(:,[3,6,9]) = temp(:,[3,6,9]) + adjustLeafBaseHeightVector(i); % z = z+v;
    plantMeshModel_out = [plantMeshModel_out; temp];
    % 调整叶片数的同时调整叶基部高度
end 
plantMeshModel_out = [plantMeshModel_out;d(d(:,10)==0,:)]; % 最后补充茎秆，即id=0

end

% 编写完成，可运行，结果未查看


