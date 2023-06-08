

% 从Vector模型中提取LL，LW，LC，LA，LN等5个参数，保存到csv文件中
% 保存的格式包括植株编号，叶片编号，上下层编号等

function output = extractTraitFromVectorModel(vectorModel)

LN = max(vectorModel(:,10)); % 第10列是叶片编号，0是stem，最大值为叶片数

output = zeros(LN,7); % 第1是叶片编号，第2列是上下层，3-7是LL，LW, LC, LA, LN
output(:,7) = LN;

for i=1:LN

    vm1 = vectorModel(vectorModel(:,10)==i,:);
    vm = vm1(2:end,:);
    [row, col] = size(vm);
    vt = vm(:,1:3);
    vtu = vm(:,4:6);
    vtb = vm(:,7:9);

    output(i,1) = i; % 叶片编号
    output(i,2) = vm(1,11); % 上下层
    output(i,3) = sum(sqrt(sum(vt.^2, 2))); % LL

    leafWidthList = sqrt(sum(vtu.^2, 2)) + sqrt(sum(vtb.^2, 2));
    [B, I] = sort(leafWidthList,'descend'); % 降序排列

    leafWidthMax = B(1); % 默认是最大值，
    for x=1:9
        if x>=length(B)
            break;
        end
        if B(x)/B(x+1)<1.1 %如果最大值大于第二大的值超过10%，则认为是异常值，继续检测下一个，并设置为叶宽
            leafWidthMax = B(x);
        end
    end
    output(i,4) = leafWidthMax;

    % 转换为点云
    pt = zeros(row+1, 3);
    pt(1,:) = [0,0,0]; % leaf base point adjusted to 0 before.

    for n=2:row+1
        pt(n,1:3) = pt(n-1,1:3) + vm(n-1,1:3);
    end

    ptu = pt(1:row,:) + vtu(:, 1:3);
    ptb = pt(1:row,:) + vtb(:, 1:3);

    % 计算叶片角度
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
        % 中线点，上边点，下边点分为三个数组，同步的旋转
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
        pt(j:row+1,1:3) = leaf_pos_transfer(pt(j:row+1,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); %旋转
        ptu(j:row,1:3)  = leaf_pos_transfer(ptu(j:row,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); %旋转
        ptb(j:row,1:3)  = leaf_pos_transfer(ptb(j:row,1:3), O_Pt, 1, 1, turnAngle, rotationDegree, turnAngleDirection); %旋转
    end
    % 然后，按照给定的弯曲LC弯折叶片1/3到3/3段，0-1/3段不变。
    output(i,5) = sum(turnAngleSave(round(row/3):end,:)); % 计算1/3（含）到3/3段的总的弯曲度，LC
    

end


end

