

addpath("virtualPlant\");
addpath("common\");
addpath("maizePC\");
%读取一个单株的植物点云模型

cultivars = {'W64A','A619'}; % or 'A619'
DASList = [31 38 45 52 59];

for cultivarID = 1:1
    for stage = 1:1
        for rep = 1:2

            cv = cultivars{cultivarID};
            das = DASList(stage);

            filename = strcat('../CM-singlePlant/CM_',cv,'_',num2str(das),'_',num2str(rep),'.txt');
            filename
            % '../CM-singlePlant/CM_W64A_45_1.txt'
            outputfileprefix = strcat('CM_', cv ,'_',num2str(das),'_',num2str(rep));
            outputfileprefix
            % 'CM_W64A_45_1'
            d = importdata(filename); % format is 11 columns, CM_W64A_45_3.txt leaf 5 is bad

            plantMeshModel = zeros(0,11);
            plantVectorModel = zeros(0,11);

            % get the stem base point
            LEAF_ID_idx = 10;
            d2 = d(d(:,LEAF_ID_idx)==0, :);% for stem
            plantMeshModel = [plantMeshModel; d2]; %将stem的mesh加入
            plantVectorModel = [plantVectorModel; d2]; %将stem的mesh加入到vector里，虽然不是vector，当前的vector模型仅针对叶片
            X = [d2(:,1);d2(:,4);d2(:,7)];
            Y = [d2(:,2);d2(:,5);d2(:,8)];
            Z = [d2(:,3);d2(:,6);d2(:,9)];
            stemPtCloud = [X, Y, Z];

            % plot
            tri = d2(:,1:9); % stem's triangles
            [row,col] = size(tri);
            seq = [1:row]';
            T = [seq, seq+row, seq+row*2];
            x = [tri(:,1);tri(:,4);tri(:,7)];
            y = [tri(:,2);tri(:,5);tri(:,8)];
            z = [tri(:,3);tri(:,6);tri(:,9)];

            C = z;
            % draw figure
            figure(1);
            trisurf(T, x,y,z,C,'FaceAlpha', 1, 'EdgeColor', 'none'); % or use 'FaceColor','g'
            axis equal
            view(-70,15)
            hold on;

            for i = 1:max(d(:,LEAF_ID_idx))
                i
                d2 = d(d(:,LEAF_ID_idx) == i, :); % for 1st leaf
                layerID = d2(1,11);
                X = [d2(:,1);d2(:,4);d2(:,7)];
                Y = [d2(:,2);d2(:,5);d2(:,8)];
                Z = [d2(:,3);d2(:,6);d2(:,9)];
                leafPtCloud = [X, Y, Z];
                %针对每个叶片进行vector model构建
                segDistance = 3; % cm
                [outputVectorModel, outputMeshModel] = leafVectorModel(stemPtCloud, leafPtCloud, segDistance);
                if isempty(outputVectorModel)
                    continue;
                end
                outputMeshModel(:,10) = i;
                outputMeshModel(:,11) = layerID;
                plantMeshModel = [plantMeshModel; outputMeshModel]; %将当前叶片的mesh加入
                outputVectorModel(:,10) = i;
                outputVectorModel(:,11) = layerID;
                plantVectorModel = [plantVectorModel; outputVectorModel]; %将当前叶片的vector加入到vector里

                % mesh model 用于 plot
                tri = outputMeshModel;
                [row,col] = size(tri);
                seq = [1:row]';
                T = [seq, seq+row, seq+row*2];
                x = [tri(:,1);tri(:,4);tri(:,7)];
                y = [tri(:,2);tri(:,5);tri(:,8)];
                z = [tri(:,3);tri(:,6);tri(:,9)];

                C = z;
                % draw figure
                figure(1);
                trisurf(T, x,y,z,C,'FaceAlpha', 1, 'EdgeColor', 'none'); % or use 'FaceColor','g'
                axis equal
                view(-70,15)
                hold on;
            end

            % output to file
            writematrix(plantMeshModel, strcat('../CM-singlePlant/',outputfileprefix,'_mesh.txt'), 'Delimiter', 'tab');
            writematrix(plantVectorModel, strcat('../CM-singlePlant/',outputfileprefix,'_vector.txt'), 'Delimiter', 'tab');

        end
    end

end



