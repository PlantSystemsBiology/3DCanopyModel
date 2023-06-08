
% 2022-5-7
% maize virtual canopy construction
% developed by Qingfeng

% the input files has the same format of M files
% it calls plantStructureAdjust and plantStructureAdjustLN

function generateVirtualPlant(canopyModel_acceptor_M_file, canopyModel_acceptor_meshModel_prefix, canopyModel_donor_M_file, traitID, outputfilename, outputMeshPrefix)

% traitID is one of these IDs: 'TN', 'LN', 'SH'，'LL', 'LW', 'LC', 'LA', 'LS'.
% (for maize) traitID is one of these IDs: 'LN', 'SH'，'LL', 'LW',  'LA', 'LS'.


modelA = readmatrix(strcat('..\M\',canopyModel_acceptor_M_file));
modelA_original = modelA;
modelB = readmatrix(strcat('..\M\',canopyModel_donor_M_file));
% modelB
col = 8;
modelA_with_B_trait = zeros(0,col); % the output matrix

%% IDs column number
PlantID_ind = 1;
TillerID_ind = 2;
OrganID_ind = 3;
leafBaseHeight_ind = 4;
leafLength_ind = 5;
leafWidth_ind = 6;
leafCurvatureAngle_ind = 7;
leafAngle_ind = 8;

for plantId = 1:4 % for every plant, maize 4 plants
    % tiller number of the two models
    TN_A = max(modelA(modelA(:,PlantID_ind)==plantId,TillerID_ind));
    TN_B = max(modelB(modelB(:,PlantID_ind)==plantId,TillerID_ind));

    % load the single plant CM data
    modelA_mesh = readmatrix(strcat('..\CM-singlePlant\',canopyModel_acceptor_meshModel_prefix,num2str(plantId),'.txt'));

    % first, the traits for organ (tiller or leaf) numbers.
    if traitID == "TN" % change tiller number of A to the same as B.
        % tiller number
        % A map to B

        indexVector = heteroMapping(TN_B, TN_A);
        for i = 1:length(indexVector)
            temp = modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==indexVector(i),:);
            temp(:,TillerID_ind) = i;
            modelA_with_B_trait = [modelA_with_B_trait; temp]; %modelA_with_B_trait is the final output
        end

    elseif traitID == "LS"
        % leaf area
        LeafAreaModelA = sum (modelA(modelA(:,PlantID_ind)==plantId,leafLength_ind) .* modelA(modelA(:,PlantID_ind)==plantId,leafWidth_ind) * 0.7); %计算modelA的总叶面积，长*宽*0.7估算
        LeafAreaModelB = sum (modelB(modelB(:,PlantID_ind)==plantId,leafLength_ind) .* modelB(modelB(:,PlantID_ind)==plantId,leafWidth_ind) * 0.7); %计算modelA的总叶面积，长*宽*0.7估算
        BAratio = LeafAreaModelB / LeafAreaModelA; %计算B/A的面积比值

        modelA(modelA(:,PlantID_ind)==plantId,leafLength_ind) = modelA(modelA(:,PlantID_ind)==plantId,leafLength_ind).* sqrt(BAratio); %调整modelA的叶长
        modelA(modelA(:,PlantID_ind)==plantId,leafWidth_ind) = modelA(modelA(:,PlantID_ind)==plantId,leafWidth_ind).* sqrt(BAratio); %调整modelA的叶宽

    elseif traitID == "LN" % change leaf number of A to be the same as B
        traitID
        % leaf number
        % search A from B, then A map to B.
        indexVector = heteroMapping(TN_A, TN_B);
        for i = 1:length(indexVector)
            LN_A = max(modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i,OrganID_ind));
            LN_B = max(modelB(modelB(:,PlantID_ind)==plantId & modelB(:,TillerID_ind)==indexVector(i),OrganID_ind));
            indexVector2 = heteroMapping(LN_B, LN_A);

            % calculate stem length and adjust leaf base height
            stemL = max(modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i, leafBaseHeight_ind))-...
                min(modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i, leafBaseHeight_ind));
            adjustLeafBaseHeight = stemL/length(indexVector2)/2;

            % calculate the adjust values for every leaf from bottom to top
            adjustLeafBaseHeightVector = zeros(length(indexVector2),1); % initial an zeros vector
            for j = 1: length(indexVector2)
                if j==1
                    if indexVector2(j)==indexVector2(j+1)
                        adjustLeafBaseHeightVector(j)= -adjustLeafBaseHeight; % the bottom one leaf, leaves from bottom to up
                    end

                elseif j==length(indexVector2)
                    if indexVector2(j)==indexVector2(j-1)
                        adjustLeafBaseHeightVector(j)= +adjustLeafBaseHeight; % the top one leaf
                    end
                else
                    if indexVector2(j)==indexVector2(j+1)
                        adjustLeafBaseHeightVector(j)= -adjustLeafBaseHeight; % it is the same as the upper one
                    end
                    if indexVector2(j)==indexVector2(j-1)
                        adjustLeafBaseHeightVector(j)= +adjustLeafBaseHeight; % it is the same as the lower one
                    end
                end
            end % calcualte the adjust values for every leaf from bottom to top

            %
            for j = 1:length(indexVector2)
                temp = modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==indexVector2(j),:);
                temp(:,OrganID_ind) = j;
                temp(:,leafBaseHeight_ind) = temp(:,leafBaseHeight_ind) + adjustLeafBaseHeightVector(j); % adjust leaf base height
            %   temp(:,leafTipHeight_ind) = temp(:,leafTipHeight_ind) + adjustLeafBaseHeightVector(j); % adjust leaf base height
                modelA_with_B_trait = [modelA_with_B_trait; temp];
            end

            % 针对点云模型，利用上述计算的调整叶片数之后的叶片index, indexVector2, 和调整之后重新计算的adjustLeafBaseHeightVector
            % 调整输入的modelA_mesh，得到新模型。
            modelA_mesh_out = plantStructureAdjustLN(modelA_mesh, indexVector2, adjustLeafBaseHeightVector); %调整叶数量

        end

    else % for those traits related to organ size, not organ numbers.
        targetTrait_ind = 0; % initial value 0
        if traitID == "SH"  % stem height, or leaf base height
            targetTrait_ind = leafBaseHeight_ind;
        elseif traitID == "LL"  % leaf length
            targetTrait_ind = leafLength_ind;
        elseif traitID == "LW"  % leaf width
            targetTrait_ind = leafWidth_ind;
        elseif traitID == "LC"  % leaf curvature angle
            targetTrait_ind = leafCurvatureAngle_ind;
        elseif traitID == "LA"  % leaf angle
            targetTrait_ind = leafAngle_ind;
        else
            % Add other traits from here
        end

        % search A from B, then change A's SH equals to B's
        indexVector = heteroMapping(TN_A, TN_B);

        for i = 1:length(indexVector)
            LN_A = max(modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i,OrganID_ind));
            LN_B = max(modelB(modelB(:,PlantID_ind)==plantId & modelB(:,TillerID_ind)==indexVector(i),OrganID_ind));
            indexVector2 = heteroMapping(LN_A, LN_B);
            for j = 1:length(indexVector2)

            %    if traitID == "SH" % only when 'SH', need to adjust leaf tip height
            %        diff_betweenBandA = modelB(modelB(:,PlantID_ind)==plantId & modelB(:,TillerID_ind)==indexVector(i) & modelB(:,OrganID_ind)==indexVector2(j), targetTrait_ind) - ...
              %          modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, targetTrait_ind); % will be used when 'SH' for adjusting leaf tip height
                %    modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, leafTipHeight_ind) = ...
                %        modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, leafTipHeight_ind) + diff_betweenBandA; % adjust leaf tip height

             %   end
% 
%              plantId
%              i
%              j
% 
%              modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, targetTrait_ind)
%              modelB(modelB(:,PlantID_ind)==plantId & modelB(:,TillerID_ind)==indexVector(i) & modelB(:,OrganID_ind)==indexVector2(j), targetTrait_ind)

                % 将B的M文件的对应性状的参数替换到A里面
                modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i              & modelA(:,OrganID_ind)==j,               targetTrait_ind) = ...
                modelB(modelB(:,PlantID_ind)==plantId & modelB(:,TillerID_ind)==indexVector(i) & modelB(:,OrganID_ind)==indexVector2(j), targetTrait_ind);

            end

            % when it is 'SH', adjust leaf base height for modelA
            if traitID == "SH"
                % calcualte stem length and adjust leaf base height
                stemL = max(modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i, leafBaseHeight_ind))-...
                    min(modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i, leafBaseHeight_ind));
                adjustLeafBaseHeight = stemL/length(indexVector2)/2;

                % calcualte the adjust values for every leaf from bottom to top
                adjustLeafBaseHeightVector = zeros(length(indexVector2),1); % initial an zeros vector
                for j = 1: length(indexVector2)
                    if j==1
                        if indexVector2(j)==indexVector2(j+1)
                            adjustLeafBaseHeightVector(j)= -adjustLeafBaseHeight; % the bottom one leaf, leaves from bottom to up
                        end

                    elseif j==length(indexVector2)
                        if indexVector2(j)==indexVector2(j-1)
                            adjustLeafBaseHeightVector(j)= +adjustLeafBaseHeight; % the top one leaf
                        end
                    else
                        if indexVector2(j)==indexVector2(j+1)
                            adjustLeafBaseHeightVector(j)= -adjustLeafBaseHeight; % it is the same as the upper one
                        end
                        if indexVector2(j)==indexVector2(j-1)
                            adjustLeafBaseHeightVector(j)= +adjustLeafBaseHeight; % it is the same as the lower one
                        end
                    end
                end % calcualte the adjust values for every leaf from bottom to top

                %
                for j = 1:length(indexVector2)
                    modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, leafBaseHeight_ind) = ...
                        modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, leafBaseHeight_ind) + adjustLeafBaseHeightVector(j); % adjust leaf base height

             %       modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, leafTipHeight_ind) = ...
             %           modelA(modelA(:,PlantID_ind)==plantId & modelA(:,TillerID_ind)==i & modelA(:,OrganID_ind)==j, leafTipHeight_ind) + adjustLeafBaseHeightVector(j); % adjust leaf tip height

                end
            end


        end

        % 因为是对于点云的模型，不能直接从M参数直接构建；而是用读入的modelA_mesh来调整出来的。所以和水稻的纯参数模型不一样。
        % adjust the single plant model. for those traits that not change
        % organ number, only changing organ size. 
        % modelA is the result of above calculation. 


        % prepare the ratios
        length_rate= modelA(modelA(:,PlantID_ind)==plantId,leafLength_ind)./modelA_original(modelA(:,PlantID_ind)==plantId,leafLength_ind); % ratio
        width_rate = modelA(modelA(:,PlantID_ind)==plantId,leafWidth_ind) ./modelA_original(modelA(:,PlantID_ind)==plantId,leafWidth_ind); % ratio
        degree_la  = modelA(modelA(:,PlantID_ind)==plantId,leafAngle_ind) - modelA_original(modelA(:,PlantID_ind)==plantId,leafAngle_ind); % minus

        % do the adjustment
        modelA_mesh_out = plantStructureAdjust(modelA_mesh,length_rate,width_rate,degree_la);

    end

    % write the model to file
    modelA_mesh_out(:,1:9) = round(modelA_mesh_out(:,1:9),3); % set to 0.001 accurancy. round
    modelA_mesh_out(:,10:11) = round(modelA_mesh_out(:,10:11),0); % set to 1 accurancy. round
    filename = strcat('..\CM-singlePlant\',outputMeshPrefix,num2str(plantId),'.txt');
    writematrix(modelA_mesh_out, filename, 'Delimiter', 'tab');

end % plants
% write to file
if traitID == "TN"
    % modelA_with_B_trait is added one tiller by one tiller
elseif traitID == "LN"
    % modelA_with_B_trait is added one leaf by one leaf
else
    modelA_with_B_trait = modelA;
end

writematrix(modelA_with_B_trait,strcat('..\M\',outputfilename));

end


