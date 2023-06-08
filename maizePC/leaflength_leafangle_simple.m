
% 2022-5-6
% code original from Fusang Liu, QF modified it.
% This is a simple method calcualte leaf length and leaf angle with input
% of leaf length path. used for adjust the leaf shape modifications. 

function [leafLength,leafAngle,O_Pt] = leaflength_leafangle_simple(pts,leafBasePoint_idx,LeafLenPath,scale,show)

% pts is leaf_pts. 
leaf_length_point=[pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3)];

% calcualte leaf length. 
[leaf_length_point_num, ~] = size(leaf_length_point);
leaf_length_steps = zeros(leaf_length_point_num,1);
for i = 2:leaf_length_point_num
    dis_p2p = sqrt(sum((leaf_length_point(i,:)-leaf_length_point(i-1,:)).^2));
    leaf_length_steps(i,1) = leaf_length_steps(i-1,1) + dis_p2p;
end
leafLength = leaf_length_steps(end)*scale;


% calculate leaf angle, the leaf angle is the calcualted at the point of
% 1/3 of leaf length. 
[~,leafLengthPointAtLeafAngleCal_idx] = min(abs(leaf_length_steps - 0.333*leaf_length_steps(end,1)));
leafAngleCalPoint_idx = LeafLenPath(leafLengthPointAtLeafAngleCal_idx);
T_Pt = pts(leafAngleCalPoint_idx,:);
O_Pt = pts(leafBasePoint_idx,:);
Pp = [T_Pt(:,1:2) O_Pt(:,3)];
leafAngle = 90-acosd(norm(O_Pt-Pp)/norm(O_Pt-T_Pt)); % norm () is for calculating vector length, edge length of triangle. 
% the leaf angle is angle between stem and leaf base (1/3 of leaf length from leaf base)


% draw figure
if show
     scatter3(pts(:,1),pts(:,2),pts(:,3),1,[0 0.3922 0], 'filled');
     hold on;
     scatter3(pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3),20,[1 0 0], 'filled');%     hold on;
     axis off; axis equal; 
     set(gcf,'Color',[1 1 1])
end


end

