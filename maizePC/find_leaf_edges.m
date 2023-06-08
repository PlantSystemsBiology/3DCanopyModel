
% 2022-5-5
% get leaf edges points, return index of these points.
% original code from Fusang Liu, modified by Qingfeng
% input, X,Y,Z are coordinates of points of a leaf. X is leaf width
% (horizontal) direction, Y is leaf length (horizontal) direction,
% Z is vertical up direction.

function [leafEdge_minimalX_idx, leafEdge_maximalX_idx] = find_leaf_edges(X1,Y1,Z1,LeafLenPath)

lt_y = Y1(LeafLenPath); % horizontal
lt_z = Z1(LeafLenPath); % vertical
leaf_length_points = [lt_y,lt_z]; % in 2D. (Y-Z)

leaf_length_points_num = size(leaf_length_points,1);

% calcaulte leaf section planes normal vectors
leafSectionPlaneNormals = zeros(leaf_length_points_num,2); % 2D (Y-Z)
for i = 1:leaf_length_points_num-1
    leafSectionPlaneNormals(i,:) = leaf_length_points(i+1,:) - leaf_length_points(i,:);
end
leafSectionPlaneNormals(leaf_length_points_num,:) = leafSectionPlaneNormals(leaf_length_points_num-1,:);

normal_u = normalize(leafSectionPlaneNormals,'norm',2); % convert each row to unit normals, with vector length equals to 1.
a=normal_u(:,1); b=normal_u(:,2); c=0;
d=-(normal_u(:,1).*lt_y+normal_u(:,2).*lt_z);


leafEdge_minimalX_idx = zeros(leaf_length_points_num,1); % initial 
leafEdge_maximalX_idx = zeros(leaf_length_points_num,1); % initial

for i=1:leaf_length_points_num % for each points on the leaf length path, 
    dis2plane = abs(a(i,1).*Y1+b(i,1).*Z1+d(i,1))./sqrt(a(i,1)^2+b(i,1)^2+c^2); % calculate distance of leaf points to one plane
    dis2LeafPathPoint = sqrt((X1 - X1(LeafLenPath(i))).^2 + (Y1 - Y1(LeafLenPath(i))).^2 + (Z1 - Z1(LeafLenPath(i))).^2);
    slide_points_idx = find(dis2plane < 0.5 & dis2LeafPathPoint<10); % threshold of slide thickness*2, % get the points near the plane
    if isempty(slide_points_idx) % if no points
        slide_points_idx = find(dis2plane < 1 & dis2LeafPathPoint<10);  % threshold of slide thickness*2, larger the distance and then calculate. 
    end
    if isempty(slide_points_idx) % if no points
        slide_points_idx = find(dis2plane < 2 & dis2LeafPathPoint<10);  % threshold of slide thickness*2, larger the distance and then calculate. 
    end
    if isempty(slide_points_idx) % if no points
        slide_points_idx = find(dis2plane < 5 & dis2LeafPathPoint<10);  % threshold of slide thickness*2, larger the distance and then calculate. 
    end
    if isempty(slide_points_idx) % if no points
        slide_points_idx = find(dis2plane < 15 & dis2LeafPathPoint<10);  % threshold of slide thickness*2, larger the distance and then calculate. 
    end
    if isempty(slide_points_idx) % still no points. give zeros. 
        error('leaf width detection failed!')
     %   leafEdge_minimalX_idx(i,1) = 0;
     %   leafEdge_maximalX_idx(i,1) = 0;
    else

        [~,min_idx] = min(X1(slide_points_idx)); % get the minimal X as leaf edge, and return the index in the slide
        [~,max_idx] = max(X1(slide_points_idx)); % get the maximal X as leaf edge, and return the index in the slide

        leafEdge_minimalX_idx(i,1) = slide_points_idx(min_idx); % get the edge point index in the leaf
        leafEdge_maximalX_idx(i,1) = slide_points_idx(max_idx); % get the edge point index in the leaf

    end
end


end


