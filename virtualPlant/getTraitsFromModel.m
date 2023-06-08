

function traits = getTraitsFromModel(plantModelFile)

% input:
% 3D model file. The leaves and stem are segementated and labeled with leaf ID.  
% input file format is: 
% triangle_point1 triangle_point2 triangle_point3 leaf_num leaf_position
% column 10: leaf_num is named by the height of leaf bases from bottom to top. 0 represents stem.
% column 11: leaf_poistion consists of lower part(1), upper part(2) and stem(0).

% output:
% traits.leafLength
% traits.leafWidth
% traits.leafAngle
% traits.leafNumber

d = importdata(plantModelFile);

LEAF_ID_idx = 10;
leafNum = max(d(:,LEAF_ID_idx));
traits.leafNumber = leafNum;

% get the stem base point
d_stem = d(d(:,LEAF_ID_idx)==0, :);
X = [d_stem(:,1);d_stem(:,4);d_stem(:,7)];
Y = [d_stem(:,2);d_stem(:,5);d_stem(:,8)];
Z = [d_stem(:,3);d_stem(:,6);d_stem(:,9)];
pts_Stem = [X, Y, Z];


% for each leaf, get the traits.
figure;

for i=1:leafNum
%for i=7:7
    d_oneLeaf = d(d(:,LEAF_ID_idx)==i,:);
    X = [d_oneLeaf(:,1);d_oneLeaf(:,4);d_oneLeaf(:,7)];
    Y = [d_oneLeaf(:,2);d_oneLeaf(:,5);d_oneLeaf(:,8)];
    Z = [d_oneLeaf(:,3);d_oneLeaf(:,6);d_oneLeaf(:,9)];
    pts_oneLeaf = [mean(d_oneLeaf(:,[1 4 7]),2), mean(d_oneLeaf(:,[2 5 8]),2), mean(d_oneLeaf(:,[3 6 9]),2)]; % the points of center of triangle facets.
    pts_oneLeaf2 = [X, Y, Z]; % the points of triangle facets

    size(pts_oneLeaf)
    % get original leaf base point, leaf length, leaf width, leaf angle.
    % SAVE these parameters

    % calculate from point cloud
    [leafLength,leafAngle,leaf_base_idx,LeafLenPath,LeafWidthPath,leafWidth] = leaflength_leafangle(pts_Stem,pts_oneLeaf,1,0);

    traits.leafBaseHeight(i) = pts_oneLeaf(leaf_base_idx,3); % the Z of leaf base point. 
    traits.leafLength(i) = leafLength; 
    traits.leafWidth(i) = leafWidth;
    traits.leafAngle(i) = leafAngle;
    
%    if length(LeafLenPath)<=3
        % the leaf is too short, ignore the adjustment, use original data.
%        length(LeafLenPath)
%    else
        show = 1;
        if show
            pts = pts_oneLeaf; 
            scatter3(pts(:,1),pts(:,2),pts(:,3),1,[0 0 0.3922*2], 'filled'); hold on; % BLUE color
            scatter3(pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3),20,[1 0 0], 'filled'); hold on;%     hold on;
            scatter3(pts(LeafWidthPath,1),pts(LeafWidthPath,2),pts(LeafWidthPath,3),20,[0 0 1], 'filled'); hold on;

        end
 %   end

end
axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');


end



