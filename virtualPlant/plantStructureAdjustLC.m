

% degreeLC: leaf curvature
function plantMeshModel_out = plantStructureAdjustLC(plantMeshModel, degreeLC)

for p = 1:4

    filename = strcat('..\CM-singlePlant\', plantMeshModel, num2str(p), '.txt');
% filename
    d = importdata(filename);
    %d = plantMeshModel;
    LEAF_ID_idx = 10;
    leafNum = max(d(:,LEAF_ID_idx));

    % get the stem base point
    d_stem = d(d(:,LEAF_ID_idx)==0, :);
    X = [d_stem(:,1);d_stem(:,4);d_stem(:,7)];
    Y = [d_stem(:,2);d_stem(:,5);d_stem(:,8)];
    Z = [d_stem(:,3);d_stem(:,6);d_stem(:,9)];
    pts_Stem = [X, Y, Z];

    show = 0;
    if show
        pts = pts_Stem;
        color = 0.2*0;
        if color >1
            color =1;
        end
        figure(1);
        scatter3(pts(:,1),pts(:,2),pts(:,3),1,[1-color color 1-color], 'filled'); hold on;% GREEN color 0.3922
        axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');
    end

    [min_Z, min_Z_idx] = min(d_stem(:, 3));
    stemBase = d_stem(min_Z_idx, 1:3);
    leafBaseOriginal = zeros(1,3);
    leafBaseBefore = zeros(1,3);
    originalLeafFlag = 1;
    N = 10; 

    for i=1:leafNum
        i
        % get the initial leaf coordinates
        d_oneLeaf = d(d(:,LEAF_ID_idx)==i,:);
        %     size(d_oneLeaf)
        X = [d_oneLeaf(:,1);d_oneLeaf(:,4);d_oneLeaf(:,7)];
        Y = [d_oneLeaf(:,2);d_oneLeaf(:,5);d_oneLeaf(:,8)];
        Z = [d_oneLeaf(:,3);d_oneLeaf(:,6);d_oneLeaf(:,9)];
        pts_oneLeaf = [X, Y, Z];
        %size(pts_oneLeaf)

        %get leaf mid line 
        if ~isempty(pts_oneLeaf)
            [leafLength,leafAngle,leaf_base_idx,LeafLenPath,LeafWidthPath,leafWidth] = leaflength_leafangle(pts_Stem, pts_oneLeaf, 1, 0);
        else
            continue;
        end

%         size(LeafLenPath)
        if length(LeafLenPath)<10 % when leaf is short, do not change leaf curvature.
            [row, col] = size(pts_oneLeaf);
            d(d(:,LEAF_ID_idx)==i,1:9) = [pts_oneLeaf(1:row/3, :), pts_oneLeaf(row/3+1:row/3*2, :), pts_oneLeaf(row/3*2+1:row, :)];
            continue;
        end
        %% show
        show = 0;
        if show
            pts = pts_oneLeaf;
            color = 0.2*i;
            if color >1
                color =1;
            end
            figure(1);
            scatter3(pts(:,1),pts(:,2),pts(:,3),1,[1-color color 1-color], 'filled'); hold on;% GREEN color 0.3922
            scatter3(pts(LeafLenPath,1),pts(LeafLenPath,2),pts(LeafLenPath,3),20,[1 0 0], 'filled'); hold on;%     hold on;
            scatter3(pts(LeafWidthPath,1),pts(LeafWidthPath,2),pts(LeafWidthPath,3),20,[0 0 1], 'filled'); hold on;
        end
        axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');
        %%

        pts_oneLeaf2 = pts_oneLeaf; % pts_oneLeaf2 is the part after cutting. 
        [row,col] = size(pts_oneLeaf2);

        indexLeafSegs = zeros(row,0); %for saving leaf index 0 or 1.
        preRotationDegree_Save = zeros(1,0); %
        turnAngleDirection_Save = zeros(1,0); %
        O_Pt_base_Save = zeros(0,3); %

        serials = [1:length(pts_oneLeaf2)]' ; % serials of the original points，1 column
        pts_oneLeaf2 = [pts_oneLeaf2, serials]; % 
        pts_oneLeaf_straight = pts_oneLeaf2; % for saving the points after adjustment

        %     a = pts_oneLeaf2(:,4)==6158;
        %     disp('find 6158')
        %     sum(a)
        k=0;
        O_Pt_leafbase = zeros(1,3);
        turnAngle_leafangle = 0;
        preRotationDegree_ori = 0;
        finishFlag = false;
        turnAngleDirection = 0;
        turnAngleDirection_ori = 0;

        while(true)
           % k

            %     a = pts_oneLeaf2(:,4)==6158;
            %     disp('find 6158')
            %     sum(a)
            % adjust leaf curvature
            if ( 1+(k+1)*N >= length(LeafLenPath)) % determine whether it is the end. 
                %             disp('x1')
                T_Pt_ind = length(LeafLenPath); %use the last point.
                %             T_Pt_ind
                finishFlag = true;
            else
                %             disp('x2')
                T_Pt_ind = 1+(k+1)*N;
            end
            O_Pt = pts_oneLeaf2(pts_oneLeaf2(:,4)==LeafLenPath(1+k*N),1:3);     % mid line, use the 1+k*N th point as base point, the 4th column is serials
            T_Pt = pts_oneLeaf2(pts_oneLeaf2(:,4)==LeafLenPath(T_Pt_ind),1:3);  % 

            %         disp('x3')
            %         LeafLenPath(T_Pt_ind)

            [row, col] = size(pts_oneLeaf2);
            if (isempty(T_Pt) || row < 10) % 
                % when the next point not found, save current points. 
                pts_oneLeaf_straight(pts_oneLeaf_tr(:, 4),:) = pts_oneLeaf_tr;
                indexLeafSegs(pts_oneLeaf_tr(:, 4),k+1) = true; 
                preRotationDegree_Save(k+1) = preRotationDegree;
                turnAngleDirection_Save(k+1) = turnAngleDirection;
                O_Pt_base_Save(k+1,:) = O_Pt;
                break;
            end

            Pp = [T_Pt(:,1:2) O_Pt(:,3)];
            turnAngle = 90-acosd(norm(O_Pt - Pp)/norm(O_Pt-T_Pt)); % norm () is for calculating vector length, edge length of triangle.
            if (k==0)
                O_Pt_leafbase = O_Pt; % 
                turnAngle_leafangle = turnAngle;% 
            end
            % calculate leaf direction
            [coeff, ~, ~] = pca(pts_oneLeaf2(:,1:2));
            dir1 = coeff(:,1)';
            preRotationDegree = 90-atand(dir1(1,2)/dir1(1,1));
            
            newpts = coordinate_rotate(pts_oneLeaf2,preRotationDegree,O_Pt_leafbase,3);
            if abs(max(newpts(:,2)))>abs(min(newpts(:,2)))
                turnAngleDirection = 1;
            else
                turnAngleDirection = -1;
            end

            if (k==0)
                preRotationDegree_ori = preRotationDegree;
                turnAngleDirection_ori = turnAngleDirection;
            end

            preRotationDegree_Save(k+1) = preRotationDegree;
            turnAngleDirection_Save(k+1) = turnAngleDirection;

            O_Pt_base_Save(k+1,:) = O_Pt;
            pts_oneLeaf_tr = leaf_pos_transfer(pts_oneLeaf2(:,1:3), O_Pt, 1, 1, turnAngle, preRotationDegree, turnAngleDirection); %%%%
            pts_oneLeaf_tr(:,4) = pts_oneLeaf2(:,4);

            % cut leaf base part
            T_Pt_tr = pts_oneLeaf_tr(pts_oneLeaf_tr(:,4)==LeafLenPath(T_Pt_ind),1:3); % 
            ind = pts_oneLeaf_tr(:,3) < T_Pt_tr(:,3) & abs(pts_oneLeaf_tr(:,1) - T_Pt_tr(:,1))<15 & abs(pts_oneLeaf_tr(:,2) - T_Pt_tr(:,2))<15;
            % restrict x y range
            if finishFlag
                pts_oneLeaf_straight(pts_oneLeaf_tr(:, 4),:) = pts_oneLeaf_tr;
                indexLeafSegs(pts_oneLeaf_tr(:, 4),k+1) = true; % 
            else
                pts_oneLeaf2 = pts_oneLeaf_tr(~ind, :);    % 
                pts_oneLeaf_straight(pts_oneLeaf_tr(ind, 4),:) = pts_oneLeaf_tr(ind, :); % 
                indexLeafSegs(pts_oneLeaf_tr(ind, 4),k+1) = true; %  
            end

            k=k+1; % next segment
            show = 0;
            if show
                pts = pts_oneLeaf_straight(pts_oneLeaf_tr(ind, 4),1:3);
                color = 0.2*i;
                if color >1
                    color =1;
                end
                figure(2);
                scatter3(pts(:,1),pts(:,2),pts(:,3),1,[1-color color 1-color], 'filled'); hold on;% GREEN color 0.3922
                axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');

                pts2 = pts_oneLeaf_tr;
                color = 0.2*i;
                if color >1
                    color =1;
                end
                figure(2);
                scatter3(pts2(:,1),pts2(:,2),pts2(:,3),1,[1-color color 1-color], 'filled'); hold on;% GREEN color 0.3922
                axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');
            end

            if finishFlag % 
                break;
            end

        end % 

        % 
        leafCurvature = degreeLC; % 30; % degree
        [row, col] = size(indexLeafSegs);
        k1 = round(k*1/3); %
        k2 = round(k*2/3); % 
        turnAngle = leafCurvature/k2; % from 1 to k
        for ki = col:-1:1
            pts_oneLeaf2 = pts_oneLeaf_straight(logical(sum(indexLeafSegs(:,ki:col),2)), 1:3); % 
            if ki>k1
                pts_oneLeaf_tr = leaf_pos_transfer(pts_oneLeaf2(:,1:3), O_Pt_base_Save(ki,:), 1, 1, -turnAngle, preRotationDegree_Save(ki), turnAngleDirection_Save(ki));
            else
                pts_oneLeaf_tr = pts_oneLeaf2;
            end
            pts_oneLeaf_straight(logical(sum(indexLeafSegs(:,ki:end),2)), 1:3) = pts_oneLeaf_tr; % 

        end

       
        pts_oneLeaf_tr = leaf_pos_transfer(pts_oneLeaf_straight(:,1:3), O_Pt_leafbase, 1, 1, -turnAngle_leafangle, preRotationDegree_ori, turnAngleDirection_ori);

        show = 0;
        if show
            pts = pts_oneLeaf_tr(:,1:3);
            color = 0.2*i;
            if color >1
                color =1;
            end
            figure(1);
            scatter3(pts(:,1),pts(:,2),pts(:,3),1,[1-color color 1-color], 'filled'); hold on;% GREEN color 0.3922
            axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');
        end
        [row, col] = size(pts_oneLeaf_tr);
        d(d(:,LEAF_ID_idx)==i,1:9) = [pts_oneLeaf_tr(1:row/3, :), pts_oneLeaf_tr(row/3+1:row/3*2, :), pts_oneLeaf_tr(row/3*2+1:row, :)];

    end
    axis equal; set(gcf,'Color',[1 1 1]); xlabel('X');ylabel('Y');zlabel('Z');

    plantMeshModel_out = d; % for output
    plantMeshModel_out(:,1:9) = round(plantMeshModel_out(:,1:9),3); % set to 0.001 accurancy. round
    plantMeshModel_out(:,10:11) = round(plantMeshModel_out(:,10:11),0); % set to 1 accurancy. round
    filename = strcat('..\CM-singlePlant\',plantMeshModel,'LC_',num2str(p),'.txt');
    writematrix(plantMeshModel_out, filename, 'Delimiter', 'tab');


end

end
