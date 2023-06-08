
% ** --- adjust plant architecture and leaf number --- **
% input: plantModel
% the input plant model is the VectorModel of a plant, in which the stem part is presented by triangle facets, leaves are presented by vector
% column 1-9 is structure data, column 10 is leaf ID, column 11 is flag
% （1,2）for bottom (1) layer or up (2) layer. 
% adjustConfig
% adjustConfig.leafWidthMultiply
% adjustConfig.leafLengthMultiply
% adjustConfig.leafAngleAdd
% adjustConfig.leafCurvatureTo
% adjustConfig.leafNumberTo

function PlantTris = adjustPlantArchitecture(plantModel, adjustConfig, removeStamen)

PlantTris = zeros(0, 11);

leafNum = max(plantModel(:,10));   % total leaf number
top1leaf = plantModel(plantModel(:,10) == leafNum, :); % data for the first leaf on top. 
stemHeight = min(top1leaf(1,3)); % leaf base height of the first leaf on top. which is used as stem length.

stemTris = plantModel(plantModel(:,10) == 0, :); % stem facets。
if removeStamen
    stemTris = stemTris(stemTris(:,3)<=stemHeight,:);
end
PlantTris = [PlantTris; stemTris]; % put the stem into an array. 

for i = 1:leafNum

    i
    % first, apply different adjust rates for bottom and up layers. 
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

    % then, adjust each leaf. 
    vectorModel = plantModel(plantModel(:,10) == i, 1:9); % leaf i vector model。
    [points, tris] = adjustLeafArchitecture (vectorModel, adj);
    tris(:, 10) = i; tris(:,11) = d(1,11); % add info of column 10, 11.
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

    PlantTris = [PlantTris; tris]; % save the facets.
end

% at last, adjust leaf number. 
aln = adjustConfig.leafNumberAdd; % adjust leaf number.
if aln ~= 0
    indexVector = heteroMapping(leafNum+aln, leafNum); % adjust current leafNum to the target aln number. 
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
    PlantTris = plantStructureAdjustLN(PlantTris, indexVector, adjustLeafBaseHeightVector); % adjust leaf number. 
end

end


