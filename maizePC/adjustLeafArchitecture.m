
% adjustConfig
% adjustConfig.leafWidthMultiply
% adjustConfig.leafLengthMultiply
% adjustConfig.leafAngleAdd
% adjustConfig.leafCurvatureTo
% adjustConfig.leafNumberTo, this is used in single plant model, current function is for single leaf adjustment. 

function [points, tris_out] = adjustLeafArchitecture (vectorModel, adjustConfig)

leafBase = vectorModel(1, 1:3);
vectorModel = vectorModel(2:end, :);

aw = adjustConfig.leafWidthMultiply;
al = adjustConfig.leafLengthMultiply;
ac = adjustConfig.leafCurvatureAdd;
aa = adjustConfig.leafAngleAdd;

% from vectorModel to adjust leaf width and length
% adjust leaf length
if al~=1
    vectorModel(:,1:3) = vectorModel(:,1:3)*al; % adjust leaf length
end
if aw~=1
    vectorModel(:,4:9) = vectorModel(:,4:9)*aw; % adjust leaf width
end
%% convert vector to points

[row,col] = size(vectorModel);
pt = zeros(row+1, 3);
pt(1,:) = [0,0,0]; % leaf base point adjusted to 0 before.

for n=2:row+1
    pt(n,1:3) = pt(n-1,1:3) + vectorModel(n-1,1:3);
end

ptu = pt(1:row,:) + vectorModel(:, 4:6);
ptb = pt(1:row,:) + vectorModel(:, 7:9);
% 
% figure(2);
% scatter3(pt(:,1),pt(:,2),pt(:,3)); hold on;
% scatter3(ptu(:,1),ptu(:,2),ptu(:,3),'red');
% scatter3(ptb(:,1),ptb(:,2),ptb(:,3),'blue');

%% adjust leaf curvature
if ac~=0
    % first, make the leaf straight
    turnAngleSave = zeros(row,1);
    rotationDegreeSave = zeros(row,1);
    turnAngleDirectionSave = zeros(row,1);
    for i=1:row
        % the points on mid-line and two leaf edages are rotated. 

        O_Pt = pt(i,1:3);
        T_Pt = pt(i+1,1:3);

        Pp = [T_Pt(:,1:2) O_Pt(:,3)];
        turnAngle = 90-acosd(norm(O_Pt-Pp)/norm(O_Pt-T_Pt));
        turnAngleSave(i) = turnAngle;
        rotationDegree = atand((T_Pt(:,1) - O_Pt(:,1)) / (T_Pt(:,2) - O_Pt(:,2)));
        rotationDegreeSave(i) = rotationDegree;

        if T_Pt(:,2) > O_Pt(:,2)
            turnAngleDirection = 1;
        else
            turnAngleDirection = -1;
        end
        turnAngleDirectionSave(i) = turnAngleDirection;

        pt(i:row+1,1:3) = leaf_pos_transfer(pt(i:row+1,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); %旋转
        ptu(i:row,1:3)  = leaf_pos_transfer(ptu(i:row,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); %旋转
        ptb(i:row,1:3)  = leaf_pos_transfer(ptb(i:row,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); %旋转
    end

%     figure(2);
%     scatter3(pt(:,1),pt(:,2),pt(:,3));

    % then, change the leaf curvature as input. the curvature is adjusted from 1/3 to 3/3. 
    % The parts between 0-1/3 is maintained. 
    turnAngleTargetLC = sum(turnAngleSave(round(row/3):end,:)) + ac; % unit: degree
    turnLCstep = turnAngleTargetLC/round(row*2/3); % adjust leaf 1/3 ~ 3/3 segments, the turnLCstep is the angle for turning each leaf segment along the leaf.
    if turnLCstep<0
        turnLCstep = 0;
    end
    for i = row:-1:1
        if i >= round(row/3)
            turnAngle = turnLCstep;       
        else
            turnAngle = turnAngleSave(i); % the leaf 0/3 ~ 1/3 segment maintained
        end
        rotationDegree = rotationDegreeSave(i);
        turnAngleDirection = turnAngleDirectionSave(i);
        O_Pt = pt(i,1:3);
        pt(i:row+1,1:3) = leaf_pos_transfer(pt(i:row+1,1:3), O_Pt, 1, 1, -turnAngle, rotationDegree, turnAngleDirection); %旋转
        ptu(i:row,1:3)  = leaf_pos_transfer(ptu(i:row,1:3), O_Pt, 1, 1, -turnAngle, rotationDegree, turnAngleDirection); %旋转
        ptb(i:row,1:3)  = leaf_pos_transfer(ptb(i:row,1:3), O_Pt, 1, 1, -turnAngle, rotationDegree, turnAngleDirection); %旋转
    end
end

%% adjust leaf angle
[row_temp, ~]=size(pt);
if row_temp<4
    aa=0; % if row number of the pt matrix is too small, do not need the leaf angle adjustment. 
end
if aa~=0
    turnAngle = aa;
    if pt(4,2) > pt(1,2)
        turnAngleDirection = 1;
    else
        turnAngleDirection = -1;
    end
    
    O_Pt = pt(1,1:3);
    T_Pt = pt(4,1:3);
    rotationDegree = atand((T_Pt(:,1) - O_Pt(:,1)) / (T_Pt(:,2) - O_Pt(:,2)));
    O_Pt = [0,0,0];

%     disp('turnAngle: ')
%     turnAngle
%     disp('rotationDegree: ')
%     rotationDegree
%     disp('turnAngleDirection: ')
%     turnAngleDirection

    pt(:,1:3) = leaf_pos_transfer(pt(:,1:3), O_Pt, 1, 1, -turnAngle, rotationDegree, turnAngleDirection); %旋转
    ptu(:,1:3)  = leaf_pos_transfer(ptu(:,1:3), O_Pt, 1, 1, -turnAngle, rotationDegree, turnAngleDirection); %旋转
    ptb(:,1:3)  = leaf_pos_transfer(ptb(:,1:3), O_Pt, 1, 1, -turnAngle, rotationDegree, turnAngleDirection); %旋转
end
%% add leaf base
pt(:,1:3) = pt(:,1:3) + leafBase;
ptu(:,1:3) = ptu(:,1:3) + leafBase;
ptb(:,1:3) = ptb(:,1:3) + leafBase;

points = [pt; ptu; ptb]; % point cloud model

%% convert to mesh model
tris1 = [pt(1:row, :), pt(2:row+1, :), ptu(1:row, :)];
tris2 = [ptu(2:row, :),ptu(1:row-1,:), pt(2:row, :)];
tris3 = [pt(2:row+1,:),pt(1:row, :),   ptb(1:row,:)];
tris4 = [ptb(1:row-1,:),ptb(2:row, :), pt(2:row, :)];
tris = [tris1; tris2; tris3; tris4];

% indzero1 = sum(tris(:,1:3) - tris(:,4:6),2) == 0;
% indzero2 = sum(tris(:,1:3) - tris(:,7:9),2) == 0;
% indzero3 = sum(tris(:,4:6) - tris(:,7:9),2) == 0;

indzero1 = abs(sum(tris(:,1:3) - tris(:,4:6),2)) <= 0.01;
indzero2 = abs(sum(tris(:,1:3) - tris(:,7:9),2)) <= 0.01;
indzero3 = abs(sum(tris(:,4:6) - tris(:,7:9),2)) <= 0.01;
tris_out = tris(~(indzero1|indzero2|indzero3), :); % delete those 'facet' with area of zero.

% convert to mesh model/end


end

