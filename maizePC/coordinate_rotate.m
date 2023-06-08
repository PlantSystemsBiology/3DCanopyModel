
% 2022-5-5
% code from Fusang Liu, QF not modified.


function pos_end=coordinate_rotate(pos1,degree,zero_point,type)

pos_t=[pos1(:,1)-zero_point(:,1),pos1(:,2)-zero_point(:,2),pos1(:,3)-zero_point(:,3),ones(size(pos1,1),1)];
sin2=sind(degree);
cos2=cosd(degree);

if type==1
    pos_tt=pos_t*[1 0 0 0;0 cos2 -sin2 0;0 sin2 cos2 0;0 0 0 1];
elseif type==2
    pos_tt=pos_t*[cos2 0 -sin2 0;0 1 0 0;sin2 0 cos2 0;0 0 0 1];
else
    pos_tt=pos_t*[cos2 sin2 0 0;-sin2 cos2 0 0;0 0 1 0;0 0 0 1];
end

pos_end=pos_tt(:,1:3)+zero_point;
end

