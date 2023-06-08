function [outputVectorModel, outputMeshModel] = leafVectorModel(stemPtCloud, leafPtCloud, segDistance)

% leafMeshModel
% Qingfeng,2022-12-13
% Input format stemPtCloud and leafPtCloud are [X, Y, Z];
outputVectorModel = zeros(0,9);
% step 1
% calculate leaf mid line, LeafLenPath
[leafLength,leafAngle,leaf_base_idx,LeafLenPath,LeafWidthPath,leafWidth] = leaflength_leafangle(stemPtCloud,leafPtCloud,1,0);

if isempty(LeafLenPath)
    return;
end
X1 = leafPtCloud(:,1); Y1=leafPtCloud(:,2); Z1=leafPtCloud(:,3);
% step 2
% calcualte the leaf edages.
[leafEdge_minimalX_idx, leafEdge_maximalX_idx] = find_leaf_edges(X1,Y1,Z1,LeafLenPath);

% according to segDistance, divide leaf into segements. then, remodel the
% leaf. 
N = length(LeafLenPath); % 1, 69
% size(leafEdge_minimalX_idx): 69, 1
% size(leafEdge_maximalX_idx): 69, 1

vectorModel = zeros(0,9); % initalize the matrix

% directly construct triange mesh model：
triangles = zeros(0,9); % initalize the matrix


mP_1 = zeros(1,3); % initalize the points
ePu_1 = mP_1;
ePb_1 = mP_1;
mP_2 = zeros(1,3);
ePu_2 = mP_2;
ePb_2 = mP_2;

i = 1; % first, set values to the lagging point
mP_2 = leafPtCloud(LeafLenPath(i),:); % middle point
ePu_2 = leafPtCloud(leafEdge_maximalX_idx(i),:); % leaf edge point, up
ePb_2 = leafPtCloud(leafEdge_minimalX_idx(i),:); % leaf edge point, botom

% leaf base point
leafBase = [mP_2, mP_2, mP_2]; % one point, includes 9 values
vectorModel = [vectorModel; leafBase]; % add the leaf base into first row

for i=2:N

    mP_1 = leafPtCloud(LeafLenPath(i),:); % leading point, from 2 to N, 
    ePu_1 = leafPtCloud(leafEdge_maximalX_idx(i),:);
    ePb_1 = leafPtCloud(leafEdge_minimalX_idx(i),:);

    if norm(mP_1-mP_2) >= segDistance % 

        % draw a segment
        vec1 = mP_1 - mP_2; % vector for mid line
        vec2 = ePu_2 - mP_2; % vector for edge
        vec3 = ePb_2 - mP_2; % vector for edge
        vectorGroup = [vec1, vec2, vec3]; % three vectors
        vectorModel = [vectorModel; vectorGroup];

%         direclty construct mesh model
        tri1 = [ePu_2, mP_2, mP_1];
        tri2 = [mP_2, ePb_2, mP_1];
        tri3 = [ePu_2, mP_1, ePu_1];
        tri4 = [ePb_2, ePb_1, mP_1];
        triangles = [triangles; tri1; tri2; tri3; tri4];

        % update the lagging point
        mP_2 = mP_1;
        ePu_2 = ePu_1;
        ePb_2 = ePb_1;

    elseif i==N % reach the last point
        vec1 = mP_1 - mP_2; % 
        vec2 = ePu_2 - mP_2; % 
        vec3 = ePb_2 - mP_2; % 
        vectorGroup = [vec1, vec2, vec3]; % 
        vectorModel = [vectorModel; vectorGroup];

        tri1 = [ePu_2, mP_2, mP_1];
        tri2 = [mP_2, ePb_2, mP_1];
        triangles = [triangles; tri1; tri2];
    end

end

% output
outputVectorModel = vectorModel;


outputMeshModel = triangles;

% % plot 
% tri = triangles;
% [row,col] = size(tri);
% seq = [1:row]';
% T = [seq, seq+row, seq+row*2];
% x = [tri(:,1);tri(:,4);tri(:,7)];
% y = [tri(:,2);tri(:,5);tri(:,8)];
% z = [tri(:,3);tri(:,6);tri(:,9)];
% 
% C = z;
% % draw figure
% figure;
% trisurf(T, x,y,z,C,'FaceAlpha', 1, 'EdgeColor', 'none'); % or use 'FaceColor','g'
% axis equal
% view(-70,15)
% hold on;

end


