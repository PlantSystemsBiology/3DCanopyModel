

% extract LL，LW，LC，LA，LN etc five parameters from the Vector model. 
% Save results to a .csv file. 
% the format of output file include plant ID, leaf ID, layer ID. 

function output = extractTraitFromVectorModel(vectorModel)

LN = max(vectorModel(:,10)); % the 10th column is leaf ID, 0 for stem. 

output = zeros(LN,7); % the 1st is leaf ID, column 2 is up, bottom layer ID, the 3-7th columns are LL，LW, LC, LA, LN
output(:,7) = LN;

for i=1:LN

    vm1 = vectorModel(vectorModel(:,10)==i,:);
    vm = vm1(2:end,:);
    [row, col] = size(vm);
    vt = vm(:,1:3);
    vtu = vm(:,4:6);
    vtb = vm(:,7:9);

    output(i,1) = i; % leaf ID
    output(i,2) = vm(1,11); % layer
    output(i,3) = sum(sqrt(sum(vt.^2, 2))); % LL

    leafWidthList = sqrt(sum(vtu.^2, 2)) + sqrt(sum(vtb.^2, 2));
    [B, I] = sort(leafWidthList,'descend'); % sort

    leafWidthMax = B(1); % default value is the maximal 
    for x=1:9
        if x>=length(B)
            break;
        end
        if B(x)/B(x+1)<1.1 
            leafWidthMax = B(x);
        end
    end
    output(i,4) = leafWidthMax;

    % convert to point cloud
    pt = zeros(row+1, 3);
    pt(1,:) = [0,0,0]; % leaf base point adjusted to 0 before.

    for n=2:row+1
        pt(n,1:3) = pt(n-1,1:3) + vm(n-1,1:3);
    end

    ptu = pt(1:row,:) + vtu(:, 1:3);
    ptb = pt(1:row,:) + vtb(:, 1:3);

    % calculate leaf angle
    O_Pt = pt(1,1:3);
%     O_Pt
    T_Pt = pt(round(row/3),1:3);
%     T_Pt
    Pp = [T_Pt(:,1:2) O_Pt(:,3)];
    leafAngle = 90-acosd(norm(O_Pt-Pp)/norm(O_Pt-T_Pt));
%     leafAngle
    output(i,6) = leafAngle; % LA


    % leaf curvature
    turnAngleSave = zeros(row,1);
    for j=1:row
        % mid line, and two leaf edages, rotate together. 
        O_Pt = pt(j,1:3);
        T_Pt = pt(j+1,1:3);
        Pp = [T_Pt(:,1:2) O_Pt(:,3)];
        turnAngle = 90-acosd(norm(O_Pt-Pp)/norm(O_Pt-T_Pt));
        turnAngleSave(j) = turnAngle;
        rotationDegree = atand((T_Pt(:,1) - O_Pt(:,1)) / (T_Pt(:,2) - O_Pt(:,2)));
        if T_Pt(:,2) > O_Pt(:,2)
            turnAngleDirection = 1;
        else
            turnAngleDirection = -1;
        end
        pt(j:row+1,1:3) = leaf_pos_transfer(pt(j:row+1,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); % rotate
        ptu(j:row,1:3)  = leaf_pos_transfer(ptu(j:row,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); % rotate
        ptb(j:row,1:3)  = leaf_pos_transfer(ptb(j:row,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); % rotate
    end
    % then, turn the leaf from 1/3 to 3/3 leaf segement, the 0-1/3 part not change.
    output(i,5) = sum(turnAngleSave(round(row/3):end,:)); % calculate leaf curvature from 1/3 to 3/3. LC
    

end


end

