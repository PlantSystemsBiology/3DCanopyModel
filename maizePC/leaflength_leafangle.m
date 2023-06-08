
% 2022-5-5
% Code original from Fusang Liu, modified by Qingfeng
% this function get leaf features as well as the length and width path

function [leafLength,leafAngle,leafBasePoint_idx,LeafLenPath,LeafWidthPath,leafWidth_t] = leaflength_leafangle(stem_pts,leaf_pts,scale,show)

%% axis transfer
% labels = double(pcsegdist(pointCloud(pts_orig),0.01));
% data_dis=hist(labels,unique(labels));
% [~,labels_t]=max(data_dis);
% idx=labels == labels_t;
% pts=pts_orig(idx,:);

% rotate leaf orientation


[coeff, ~,~]= pca(leaf_pts(:,1:2));
dir1 = coeff(:,1)';
degree = atand(dir1(1,2)/dir1(1,1));
leaf_pts = coordinate_rotate(leaf_pts,90-degree,[0 0 0],3);


[PointsNum, ~] = size(leaf_pts);
% calculate leaf base point
[leafBasePoint, leafBasePoint_idx] = findleafBase(leaf_pts,stem_pts);

% shift the leaf base point to [0,0,0]
leaf_pts = leaf_pts - leafBasePoint;
leaf_pts(:,1) = leaf_pts(:,1) - min(leaf_pts(:,1)); % shift the leaf X to positive value

X = leaf_pts(:,1); Y = leaf_pts(:,2); Z = leaf_pts(:,3);

%%
[~,mid_point_idx] = max(Z); % get the highest point of a leaf

part1_idx = find(abs(Y) <  abs(Y(mid_point_idx))); % the base part
part2_idx = find(abs(Y) >= abs(Y(mid_point_idx))); % the tip part

if isempty(part2_idx)  % for erect or vertical leaf, directly calculate the maximal distance from stem base
%     disp('xxx1')
    maximalSquaredDisFromStemBase = sum((leaf_pts-[0 0 0]).^2,2);
    [~,LeafTipPoint_idx] = max(maximalSquaredDisFromStemBase);

elseif length(part2_idx) < 5    % the part2 is very short.
%     disp('xxx2')
    [~,LeafTipPoint_idx] = max(abs(Y)); % use the Y maximal point directly
else
%     disp('xxx3')
    % the part 2 is long part of a leaf, then need to calculate the min and
    % max X, Y, and min Z. select the maximal distance from the mid point,
    % which is the highest point of a leaf.
    maximalSquaredDisFromMidPoint = 0;
    % X minimal point
    [~, idx] = min(X(part2_idx));
    part2minX_idx = part2_idx(idx);
    temp = sum((leaf_pts(mid_point_idx,:) - leaf_pts(part2minX_idx,:)).^2);
    if temp > maximalSquaredDisFromMidPoint
        maximalSquaredDisFromMidPoint = temp;
        LeafTipPoint_idx = part2minX_idx;
%         disp('i1')
    end

    % X maximal point
    [~, idx] = max(X(part2_idx));
    part2maxX_idx = part2_idx(idx);
    temp = sum((leaf_pts(mid_point_idx,:) - leaf_pts(part2maxX_idx,:)).^2);
    if temp > maximalSquaredDisFromMidPoint
        maximalSquaredDisFromMidPoint = temp;
        LeafTipPoint_idx = part2maxX_idx;
%         disp('i2')
    end

    % Y minimal point
    [~, idx] = min(Y(part2_idx));
    part2minY_idx = part2_idx(idx);
    temp = sum((leaf_pts(mid_point_idx,:) - leaf_pts(part2minY_idx,:)).^2);
    if temp > maximalSquaredDisFromMidPoint
        maximalSquaredDisFromMidPoint = temp;
        LeafTipPoint_idx = part2minY_idx;
%         disp('i3')
    end

    % Y maximal point
    [~, idx] = max(Y(part2_idx));
    part2maxY_idx = part2_idx(idx);
    temp = sum((leaf_pts(mid_point_idx,:) - leaf_pts(part2maxY_idx,:)).^2);
    if temp > maximalSquaredDisFromMidPoint
        maximalSquaredDisFromMidPoint = temp;
        LeafTipPoint_idx = part2maxY_idx;
%         disp('i4')
    end

    % Z minimal point
    [~, idx] = min(Z(part2_idx));
    part2minZ_idx = part2_idx(idx);
    temp = sum((leaf_pts(mid_point_idx,:) - leaf_pts(part2minZ_idx,:)).^2);
    if temp > maximalSquaredDisFromMidPoint
        maximalSquaredDisFromMidPoint = temp;
        LeafTipPoint_idx = part2minZ_idx;
%         disp('i5')
    end
    % the leaf tip point index is got, LeafTipPoint_idx.
end

[~,LeafMaxZPoint_idx] = max(Z); % get the highest point of a leaf
[~,LeafMaxYPoint_idx] = max(abs(Y)); % get the maximal distance from stem
[~,LeafMinXPoint_idx] = min(X); % get the maximal X point of a leaf
[~,LeafMaxXPoint_idx] = max(X); % get the minimal X point of a leaf


% scatter3(Z1(maxXId),X1(maxXId),Y1(maxXId),'*','r')
% hold on
% pcshow([X1,Y1,Z1])
% hold on
% scatter3(X1(part_2_idx),Y1(part_2_idx),Z1(part_2_idx),'.','r')
% hold on
% scatter3(pts_2(:,1),pts_2(:,2),pts_2(:,3),'.','g')
% % hold on
% % scatter3(X1(pt),Y1(pt),Z1(pt),'.','g')
% hold on
% scatter3(X1(point_1_idx),Y1(point_1_idx),Z1(point_1_idx),'.','r')
% %
% scatter3(X1(maxXId),Y1(maxXId),Z1(maxXId),'*','r')
% hold on
% scatter3(X1(minXId),Y1(minXId),Z1(minXId),'*','r')
% hold on
% pcshow([X1,Y1,Z1])
% axis equal

%% construct ajmatrix
D=zeros(PointsNum,PointsNum); % row is the number of points.
sumd=0;
k=0;
m=PointsNum;
for i=1:PointsNum-1
    for j=i+1:PointsNum
        vi=leaf_pts(i,:);
        vj=leaf_pts(j,:);
        d=norm(vi-vj);
        sumd=sumd+d;
        k=k+1;
        D(i,j)=d;
        D(j,i)=d;
    end
end

%计算矩阵中每行前k个值的位置并赋值（先按大小排列）
W1=zeros(m,m);
k=500; %  Qingfeng tested, 数值越大越能把两个点连接起来，不会断开
for i=1:m
    A=D(i,:);
    t=sort(A(:));%对每行进行排序后构成一个从小到大有序的列向量
    k_=k;
    if(length(t)<k)
        k_=length(t);
    end
    [~,col]=find(A<=t(k_),k_);%找出每行前K个最小数的位置
    for j=1:k_
        c=col(1,j);
        W1(i,c)=D(i,c); %W1(i,c)=1;%给k近邻赋值为距离
    end
end
for i=1:m
    for j=1:m
        if W1(i,j)==0&&i~=j
            W1(i,j)=inf;
        end
    end
end

% calculate leaf length

[leafLen,LeafLenPath] = mydijkstra(W1, leafBasePoint_idx, LeafTipPoint_idx);
% disp('t1')
% LeafTipPoint_idx
% disp('leafLen 1')
% leafLen
if leafLen == inf
    leafLen = 0;
end

% if leafLen == 0 % if above dijsktra failed to get path from leaf tip to leaf base, then try again from leaf base to leaf tip.
%   [leafLen,LeafLenPath] = mydijkstra(W1, LeafTipPoint_idx,leafBasePoint_idx);
%   LeafLenPath = fliplr(LeafLenPath);
% end

% compare this leaf tip calcualted leaf length with others potential 'leaf
% tip points', if longer than, update the leaf length, leaf lenPath and
% leaf tip point index.
[leafLen_temp,LeafLenPath_temp] = mydijkstra(W1, leafBasePoint_idx, LeafMaxZPoint_idx);  % get the highest point of a leaf
if leafLen_temp > leafLen && leafLen_temp ~= Inf
    leafLen = leafLen_temp; LeafLenPath = LeafLenPath_temp; LeafTipPoint_idx = LeafMaxZPoint_idx;
%     disp('t2')
%     LeafTipPoint_idx
%     disp('leafLen 2')
%     leafLen
end

[leafLen_temp,LeafLenPath_temp] = mydijkstra(W1, leafBasePoint_idx, LeafMaxYPoint_idx);  % get the maximal distance from stem
% disp('leafLentemp 3')
if leafLen_temp == Inf
    [~,I] = sort(abs(Y),'descend');
    YMaxPtInd = 2;
    while leafLen_temp == Inf
        LeafMaxYPoint_idx = I(YMaxPtInd);
        [leafLen_temp,LeafLenPath_temp] = mydijkstra(W1, leafBasePoint_idx, LeafMaxYPoint_idx);  % get the maximal distance from stem
        YMaxPtInd = YMaxPtInd + 5; %每次扔掉5个点，再选择一个新的叶尖部，根据Y的绝对值最大值
    end
end

if leafLen_temp > leafLen  && leafLen_temp ~= Inf
    leafLen = leafLen_temp; LeafLenPath = LeafLenPath_temp; LeafTipPoint_idx = LeafMaxYPoint_idx;
%     disp('t3')
%     LeafTipPoint_idx
end


[leafLen_temp,LeafLenPath_temp] = mydijkstra(W1, leafBasePoint_idx, LeafMinXPoint_idx);  % get the maximal X point of a leaf
% disp('leafLentemp 4')
% leafLen_temp
if leafLen_temp > leafLen && leafLen_temp ~= Inf
    leafLen = leafLen_temp; LeafLenPath = LeafLenPath_temp; LeafTipPoint_idx = LeafMinXPoint_idx;
%     disp('t4')
%     LeafTipPoint_idx
end


[leafLen_temp,LeafLenPath_temp] = mydijkstra(W1, leafBasePoint_idx, LeafMaxXPoint_idx);  % get the minimal X point of a leaf
% disp('leafLentemp 5')
% leafLen_temp
if leafLen_temp > leafLen && leafLen_temp ~= Inf
    leafLen = leafLen_temp; LeafLenPath = LeafLenPath_temp; LeafTipPoint_idx = LeafMaxXPoint_idx;
%     disp('t5')
%     LeafTipPoint_idx
end

% leafLen
% LeafLenPath
% leafBasePoint_idx
% LeafTipPoint_idx

if false
    figure;
    pts = leaf_pts;

    scatter3(pts(:,1),pts(:,2),pts(:,3),1,[0 0.3922 0], 'filled');
    hold on;
    scatter3(pts(leafBasePoint_idx,1),pts(leafBasePoint_idx,2),pts(leafBasePoint_idx,3),20,[1 0 0], 'filled');%     hold on;
    hold on
    scatter3(pts(LeafTipPoint_idx,1),pts(LeafTipPoint_idx,2),pts(LeafTipPoint_idx,3),20,[0 0 1], 'filled');
    axis on; axis equal;
    set(gcf,'Color',[1 1 1])
    xlabel('X');ylabel('Y');zlabel('Z');
end

leafLength = leafLen*scale;

if length(LeafLenPath)<=1 % leaf is too short, ignore it.
    leafLength=leafLen*scale;
    leafAngle=0;
    leafBasePoint_idx=0;
    LeafWidthPath = 0;
    leafWidth_t = 0;
    return;
end

% calcualte leaf width, first get leaf width minimal and maximal Y points' idx.
[leafEdge_minimalX_idx, leafEdge_maximalX_idx] = find_leaf_edges(X,Y,Z,LeafLenPath);

%lw_e = [leafEdge_minimalX_idx,leafEdge_maximalX_idx];

leaf_length_point = [X(LeafLenPath,1),Y(LeafLenPath,1),Z(LeafLenPath,1)];
[leaf_length_point_num, ~] = size(leaf_length_point);

leaf_length_steps = zeros(leaf_length_point_num,1);
for i = 2:leaf_length_point_num
    dis_p2p = sqrt(sum((leaf_length_point(i,:)-leaf_length_point(i-1,:)).^2));
    leaf_length_steps(i,1) = leaf_length_steps(i-1,1) + dis_p2p;
end

[~,leafLengthPointAtMaxLeafWidth_idx] = min(abs(leaf_length_steps-0.4*leaf_length_steps(end,1))); % Assume the maximal leaf width is
% at the 0.4 position from leaf base. then, get the index of this point in
% the leaf length path and also in the leaf edge index vectors.

[leafWidth,LeafWidthPath] = mydijkstra(W1,leafEdge_minimalX_idx(leafLengthPointAtMaxLeafWidth_idx,1),...
    leafEdge_maximalX_idx(leafLengthPointAtMaxLeafWidth_idx,1)); % calculate the path between the two leaf edge points at 0.4 * leaf length position.
leafWidth_t = leafWidth * scale;

% calculate leaf angle, the leaf angle is the calcualted at the point of
% 1/3 of leaf length.
[~,leafLengthPointAtLeafAngleCal_idx] = min(abs(leaf_length_steps - 0.333*leaf_length_steps(end,1)));
leafAngleCalPoint_idx = LeafLenPath(leafLengthPointAtLeafAngleCal_idx);
T_Pt = leaf_pts(leafAngleCalPoint_idx,:);
O_Pt = leaf_pts(leafBasePoint_idx,:);
Pp = [T_Pt(:,1:2) O_Pt(:,3)];
leafAngle = 90-acosd(norm(O_Pt-Pp)/norm(O_Pt-T_Pt)); % norm () is for calcualting vector length, edge length of triangle.
% the leaf angle is angle between stem and leaf base (1/3 of leaf length from leaf base)

% Draw figure
show = true;
if show
    figure;
    pts = leaf_pts;

    scatter3(pts(:,1),pts(:,2),pts(:,3),1,[0 0.3922 0], 'filled');
    hold on;
    scatter3(pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3),20,[1 0 0], 'filled');%     hold on;
    hold on
    scatter3(pts(LeafWidthPath,1),pts(LeafWidthPath,2),pts(LeafWidthPath,3),20,[0 0 1], 'filled');
    axis on; axis equal;
    set(gcf,'Color',[1 1 1])
    xlabel('X');ylabel('Y');zlabel('Z');
end


end



