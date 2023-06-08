
% 2022-5-5
% original CODE FROM FUSANG LIU, Modified by QF, 2022-5-5. 
% checked
% get the leaf base point, based on the distance from stem
% the input are two point clouds, which are already segmented and clean. 
% the algorithm is based on the closest distance of leaf from stem. 

function [leafBasePoint, leafBasePoint_idx] = findleafBase(leaf_pts,stem_pts)

% QF changed pts_orig to leaf_pts
% labels = double(pcsegdist(pointCloud(pts_orig),0.01)); % point cloud segmentation by Eucliean distance 
% data_dis=hist(labels,unique(labels)); % histgram, 
% [~,labels_t]=max(data_dis);
% idx=labels == labels_t;
% pts=pts_orig(idx,:);


% calculate the distance from one leaf pc to stem pc. 
[row, col] = size(leaf_pts);
squaredDistanceFromStem = zeros(row,1);
for i=1:row
    squaredDistanceFromStem(i,1) = min( sum( (stem_pts-leaf_pts(i,:)) .^2 ,2) );
end

% get the closest 2% quantile leaf points
distance_threshold = prctile(squaredDistanceFromStem,2); 
% leafBasePointCluster_idx = find(squaredDistanceFromStem <= distance_threshold);

leafBasePointCluster_idx = find(squaredDistanceFromStem <= distance_threshold); % QF used this

% % Rotate the leaf, QF not used 
% [coeff, ~,~]= pca(pts(:,1:2));
% dir1=coeff(:,1)';
% degree=atand(dir1(1,2)/dir1(1,1));
% newpts=coordinate_rotate(pts,90-degree,[0 0 0],3);

% % get the middle points at the X direction (leaf width direction), QF not used. 
% leaf_base_p=sortrows([newpts(leaf_base_idx_g,:),leaf_base_idx_g],1);
% mid_num=ceil(size(leaf_base_p,1)/2);
% leaf_base_idx=leaf_base_p(mid_num,4);
% leafBase=pts(leaf_base_idx,:);

% calcualte the center point of the leaf base point cluster
leafBasePointCenter = mean(leaf_pts(leafBasePointCluster_idx,:));

% loop for points of the leaf base point cluster and select the closest
% point from the center of the cluster. 
row2 = length(leafBasePointCluster_idx);
leafBasePoint = zeros(1,3);
minimalSquaredDistance = Inf;
for i=1:row2
    temp = sum((leaf_pts(leafBasePointCluster_idx(i),:) - leafBasePointCenter).^2, 2);
    if temp<minimalSquaredDistance
        minimalSquaredDistance = temp;
        leafBasePoint_idx = leafBasePointCluster_idx(i);
        leafBasePoint = leaf_pts(leafBasePoint_idx,:);
    end
end


% finish, the leaf base point is a point from the original leaf point
% cloud that close to the stem and at the center of 2% closest points. 
% accurancy: when leaf is 50cm, the 2% closet points should within a range
% of 1cm and the center of this cluster should be about 5mm distance from
% stem. 

end

