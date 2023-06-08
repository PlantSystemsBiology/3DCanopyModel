function [outputVectorModel, outputMeshModel] = leafVectorModel(stemPtCloud, leafPtCloud, segDistance)

% leafMeshModel, 将叶片点云，识别中轴线，并且切片法检测叶边缘点，再构建叶三角形面元
% Qingfeng,2022-12-13
% Input format stemPtCloud and leafPtCloud are [X, Y, Z];
outputVectorModel = zeros(0,9);
% step 1
% 计算叶片中轴线LeafLenPath
[leafLength,leafAngle,leaf_base_idx,LeafLenPath,LeafWidthPath,leafWidth] = leaflength_leafangle(stemPtCloud,leafPtCloud,1,0);

if isempty(LeafLenPath)
    return;
end
X1 = leafPtCloud(:,1); Y1=leafPtCloud(:,2); Z1=leafPtCloud(:,3);
% step 2
% 计算叶片边缘线
[leafEdge_minimalX_idx, leafEdge_maximalX_idx] = find_leaf_edges(X1,Y1,Z1,LeafLenPath);

% 依据 segDistance的距离，分割叶片成段，然后重新构建叶片模型
N = length(LeafLenPath); % 1, 69
% size(leafEdge_minimalX_idx): 69, 1
% size(leafEdge_maximalX_idx): 69, 1

vectorModel = zeros(0,9); % 初始化向量模型矩阵

% 下边的代码段是直接构建三角mesh model的
triangles = zeros(0,9); %初始化三角面元存储矩阵


mP_1 = zeros(1,3); % 初始化点变量
ePu_1 = mP_1;
ePb_1 = mP_1;
mP_2 = zeros(1,3);
ePu_2 = mP_2;
ePb_2 = mP_2;

i = 1; % 先给后拖点赋值
mP_2 = leafPtCloud(LeafLenPath(i),:); % 中间的点
ePu_2 = leafPtCloud(leafEdge_maximalX_idx(i),:); % 边点（up）
ePb_2 = leafPtCloud(leafEdge_minimalX_idx(i),:); % 边点（botom）

% 叶基部点的坐标
leafBase = [mP_2, mP_2, mP_2]; % 一个点，一行9个位置，所以重复3次。
vectorModel = [vectorModel; leafBase]; % 将叶基部点加入到第一行。

for i=2:N

    mP_1 = leafPtCloud(LeafLenPath(i),:); % 前导点 从2到N依次前进
    ePu_1 = leafPtCloud(leafEdge_maximalX_idx(i),:);
    ePb_1 = leafPtCloud(leafEdge_minimalX_idx(i),:);

    if norm(mP_1-mP_2) >= segDistance % 

        % 达到阈值可以画一个段
        vec1 = mP_1 - mP_2; % 中线的向量
        vec2 = ePu_2 - mP_2; % 上边的向量
        vec3 = ePb_2 - mP_2; % 下边的向量
        vectorGroup = [vec1, vec2, vec3]; % 三个向量
        vectorModel = [vectorModel; vectorGroup];

%         下边的代码段是直接构建三角mesh model的
        tri1 = [ePu_2, mP_2, mP_1];
        tri2 = [mP_2, ePb_2, mP_1];
        tri3 = [ePu_2, mP_1, ePu_1];
        tri4 = [ePb_2, ePb_1, mP_1];
        triangles = [triangles; tri1; tri2; tri3; tri4];

        % update the 后拖点
        mP_2 = mP_1;
        ePu_2 = ePu_1;
        ePb_2 = ePb_1;

    elseif i==N % reach the last point
        vec1 = mP_1 - mP_2; % 中线的向量
        vec2 = ePu_2 - mP_2; % 上边的向量
        vec3 = ePb_2 - mP_2; % 下边的向量
        vectorGroup = [vec1, vec2, vec3]; % 三个向量
        vectorModel = [vectorModel; vectorGroup];

%         下边的代码段是直接构建三角mesh model的
        tri1 = [ePu_2, mP_2, mP_1];
        tri2 = [mP_2, ePb_2, mP_1];
        triangles = [triangles; tri1; tri2];
    end

end

% output
outputVectorModel = vectorModel;

% 下边的代码段是直接构建三角mesh model的
outputMeshModel = triangles;

% % plot 画图
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


