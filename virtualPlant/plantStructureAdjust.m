
% adjust single plant model

function plantMeshModel_out = plantStructureAdjust(plantMeshModel,length_rate,width_rate,degree_la)

% input file format:
% triangle_point1 triangle_point2 triangle_point3 leaf_num leaf_position
%
% column 10: leaf_num is named by the height of leaf bases from bottom to top. 0 represents stem.
% column 11: leaf_poistion consists of lower part(1), upper part(2) and stem(0).

% plantModel = '..\CM_W64A_31_1.txt';

% read the plant Model file and convert the 9 column to x-y-z format.
d = plantMeshModel;
% d = d.data;

% basic information
LEAF_ID_idx = 10;
leafNum = max(d(:,LEAF_ID_idx));

% leaf length
length_rate_v = zeros(leafNum,1);
if length(length_rate)==1 % when input is a single value
    length_rate_v(:) = length_rate;
elseif length(length_rate) == leafNum % input is a vector, for every leaf. 
    length_rate_v = length_rate; % from the input vector
else
    error('input leaf length rate vector is not consistant with leaf number of the model');
end

% leaf width
width_rate_v = zeros(leafNum,1);
if length(width_rate)==1 % when input is a single value
    width_rate_v(:) = width_rate;
elseif length(width_rate) == leafNum % input is a vector, for every leaf. 
    width_rate_v = width_rate; % from the input vector
else
    error('input leaf width rate vector is not consistant with leaf number of the model');
end
%

% leaf angle degree
degree_la_v = zeros(leafNum,1);
if length(degree_la)==1 % when input is a single value
    degree_la_v(:) = degree_la;
elseif length(degree_la) == leafNum % input is a vector, for every leaf. 
    degree_la_v = degree_la; % from the input vector
else
    error('input leaf angle degree vector is not consistant with leaf number of the model');
end
%

% get the stem base point
d_stem = d(d(:,LEAF_ID_idx)==0, :);
X = [d_stem(:,1);d_stem(:,4);d_stem(:,7)];
Y = [d_stem(:,2);d_stem(:,5);d_stem(:,8)];
Z = [d_stem(:,3);d_stem(:,6);d_stem(:,9)];
pts_Stem = [X, Y, Z];

[min_Z, min_Z_idx] = min(d_stem(:, 3));
stemBase = d_stem(min_Z_idx, 1:3);

% figure()

% for each leaf, do the adjustment.
for i=1:leafNum

    d_oneLeaf = d(d(:,LEAF_ID_idx)==i,:);
    X = [d_oneLeaf(:,1);d_oneLeaf(:,4);d_oneLeaf(:,7)];
    Y = [d_oneLeaf(:,2);d_oneLeaf(:,5);d_oneLeaf(:,8)];
    Z = [d_oneLeaf(:,3);d_oneLeaf(:,6);d_oneLeaf(:,9)];
    pts_oneLeaf = [X, Y, Z];

    % get original leaf base point, leaf length, leaf width, leaf angle.
    % SAVE these parameters

    % calculate from point cloud
    [leafLength,leafAngle,leaf_base_idx,LeafLenPath,LeafWidthPath,leafWidth] = leaflength_leafangle(pts_Stem,pts_oneLeaf,1,0);

    if length(LeafLenPath)<=1
        % the leaf is too short, ignore the adjustment, use original data.
        pts_oneLeaf_tr = pts_oneLeaf;
    else

        % calculate from known leaf base and leaf length path.
        [leafLength,leafAngle,leafBase] = leaflength_leafangle_simple(pts_oneLeaf,leaf_base_idx,LeafLenPath,1,0);

        % Change leaf width by multiplying to X, change leaf
        % length by multiplying to Y and to Z simutanously.

        show = 0;
        if show
            pts = pts_oneLeaf;
            color = 0.2*i;
            if color >1
                color =1;
            end
            scatter3(pts(:,1),pts(:,2),pts(:,3),1,[1-color color 1-color], 'filled'); hold on;% GREEN color 0.3922
            scatter3(pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3),20,[1 0 0], 'filled'); hold on;%     hold on;
            scatter3(pts(LeafWidthPath,1),pts(LeafWidthPath,2),pts(LeafWidthPath,3),20,[0 0 1], 'filled'); hold on;

        end


%         disp('leaf base: 1')
%         leafBase
%         disp('max leaf xyz: ')
%         max(pts_oneLeaf)
        pts_oneLeaf_tr = leaf_pos_transfer2(pts_oneLeaf,leafBase,length_rate_v(i),width_rate_v(i),degree_la_v(i));

%         disp('max leaf xyz after 1st transfer: ')
%         max(pts_oneLeaf_tr)

%         disp('adj 1')
%         length_rate_v
        % get current leaf length, width and angle and compare to targets.
        [leafLength_tr,leafAngle_tr,leafBase_tr] = leaflength_leafangle_simple(pts_oneLeaf_tr,leaf_base_idx,LeafLenPath,1,0);

        % do the adjustment again and check it again. 1
        increased_rate=leafLength_tr/leafLength;
        remodify_rate=length_rate(i)/increased_rate;
        pts_oneLeaf_tr = leaf_pos_transfer2(pts_oneLeaf_tr,leafBase,remodify_rate,1,0); % only re modify leaf length. 1
%         disp('max leaf xyz after 2nd transfer: ')
%         max(pts_oneLeaf_tr)

        [leafLength_tr,leafAngle_tr,leafBase_tr] = leaflength_leafangle_simple(pts_oneLeaf_tr,leaf_base_idx,LeafLenPath,1,0);

%         disp('adj 2')
%         remodify_rate

        % do the adjustment again and check it again. 2
        increased_rate=leafLength_tr/leafLength;
        remodify_rate=length_rate(i)/increased_rate;
        pts_oneLeaf_tr = leaf_pos_transfer2(pts_oneLeaf_tr,leafBase,remodify_rate,1,0); % only re modify leaf length. 2
%         disp('max leaf xyz after 3rd transfer: ')
%         max(pts_oneLeaf_tr)

        [leafLength_tr,leafAngle_tr,leafBase_tr] = leaflength_leafangle_simple(pts_oneLeaf_tr,leaf_base_idx,LeafLenPath,1,0);

%         disp('adj 3')
%         remodify_rate

        show = 0;
        if show
            pts = pts_oneLeaf_tr;
            scatter3(pts(:,1),pts(:,2),pts(:,3),1,[0 0 0.3922*2], 'filled'); hold on; % BLUE color
            scatter3(pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3),20,[1 0 0], 'filled'); hold on;%     hold on;
            scatter3(pts(LeafWidthPath,1),pts(LeafWidthPath,2),pts(LeafWidthPath,3),20,[0 0 1], 'filled'); hold on;

        end
    end
    % update the model data, d.
    % d_oneLeaf = d(d(:,LEAF_ID_idx)==i,:);
    [row, col] = size(pts_oneLeaf_tr);
    d(d(:,LEAF_ID_idx)==i,1:9) = [pts_oneLeaf_tr(1:row/3, :), pts_oneLeaf_tr(row/3+1:row/3*2, :), pts_oneLeaf_tr(row/3*2+1:row, :)];

end

axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');

plantMeshModel_out = d; % for output


end



