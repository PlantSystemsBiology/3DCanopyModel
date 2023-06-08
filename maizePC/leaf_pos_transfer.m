
% 2022-5-5
% code from Fusang Liu, QF not modified.

function leaf_pos_tr = leaf_pos_transfer(pts,leaf_base,length_rate,width_rate,degree_la,preRotationDegree,turnAngleDirection)

% pre-rotation
% [coeff, ~,~] = pca(pts(:,1:2));
% dir1=coeff(:,1)';
% degree = 90-atand(dir1(1,2)/dir1(1,1));
degree = preRotationDegree;
newpts = coordinate_rotate(pts,degree,leaf_base,3);

% adjust leaf width
newpts(:,1)=newpts(:,1).*width_rate;

% adjust leaf length
newpts(:,2)=newpts(:,2).*length_rate;
newpts(:,3)=newpts(:,3).*length_rate;

% adjust leaf angle, 
% the leaf angle adjust degree, used to add up
if degree_la ~= 0 
    if turnAngleDirection == 1 %abs(max(newpts(:,2)))>abs(min(newpts(:,2)))
        newpts = coordinate_rotate(newpts,-degree_la,[leaf_base(1)*width_rate,leaf_base(2)*length_rate,leaf_base(3)],1);
    else % turnAngleDirection = -1
        newpts = coordinate_rotate(newpts,degree_la,[leaf_base(1)*width_rate,leaf_base(2)*length_rate,leaf_base(3)],1);
    end
end
% rotation back to original
leaf_pos_tr=coordinate_rotate(newpts,-degree,[leaf_base(1)*width_rate,leaf_base(2)*length_rate,leaf_base(3)],3);


end

