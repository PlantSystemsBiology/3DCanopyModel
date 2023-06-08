

% change leaf number

function plantMeshModel_out = plantStructureAdjustLN(plantMeshModel, indexVector2, adjustLeafBaseHeightVector)

Positive = 1;
Negative = -1;

d = plantMeshModel;
% basic information
LEAF_ID_idx = 10;
leafNum = max(d(:,LEAF_ID_idx));

[row,col]=size(d);
plantMeshModel_out = zeros(0,col); % 

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
    else % i>1， 
        if abs(max(temp2(:,2))) > abs(min(temp2(:,2))) 
            if direction == Positive  %% 
                [~, I] = min(temp2(:,2)); leafBasePoint = temp2(I,1:3); 
                temp2(:,1:3) = coordinate_rotate2(temp2(:,1:3),180,leafBasePoint,3); % 
                direction = Negative; % 
            else
                direction = Positive;
            end
        elseif abs(max(temp2(:,2))) < abs(min(temp2(:,2)))
            if direction == Negative % 
                [~, I] = max(temp2(:,2)); leafBasePoint = temp2(I,1:3); 
                temp2(:,1:3) = coordinate_rotate2(temp2(:,1:3),180,leafBasePoint,3); % 
                direction = Positive; % 
            else
                direction = Negative;
            end
        else
          
        end
    end
    temp(:,1:9) = convertColumn3to9 (temp2);
%     size(temp)
    temp(:,10) = i; % 
    temp(:,[3,6,9]) = temp(:,[3,6,9]) + adjustLeafBaseHeightVector(i); % z = z+v;
    plantMeshModel_out = [plantMeshModel_out; temp];
    % 
end 
plantMeshModel_out = [plantMeshModel_out;d(d(:,10)==0,:)]; % 

end




