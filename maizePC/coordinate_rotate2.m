


function pos_end=coordinate_rotate2(pos1,degree,zero_point,type)

% xyz原点
pos_t=[pos1(:,1)-zero_point(:,1), pos1(:,2)-zero_point(:,2), pos1(:,3)-zero_point(:,3)];

X = pos_t(:,1);
Y = pos_t(:,2);
Z = pos_t(:,3);

if type == 1
% X-axis rotate
        [theta,r,h] = cart2pol(Y,Z,X);    % X-axis, rotate.
        theta = theta + degree/180*pi;     
        [Y,Z,X] = pol2cart(theta,r,h);    % convert to X-Y-Z coordinates.

elseif type == 2
% Y-axis rotate
        [theta,r,h] = cart2pol(Z,X,Y);    % Y-axis, rotate. 
        theta = theta + degree/180*pi;     
        [Z,X,Y] = pol2cart(theta,r,h);    % convert to X-Y-Z coordinates.


elseif type == 3
% Z-axis rotate
        [theta,r,h] = cart2pol(X,Y,Z);    % Z-axis, rotate.
        theta = theta + degree/180*pi;     
        [X,Y,Z] = pol2cart(theta,r,h);    % convert to X-Y-Z coordinates


else

    error("type not 1,2,3!");

end
pos_end = [X+zero_point(:,1),Y+zero_point(:,2),Z+zero_point(:,3)];

end


