
% 从vector model中提取参数
% extractTraitFromVectorModel_run
addpath('maizePC\');

cv = {'W64A', 'A619'};
DASList = [31 38 45 52 59];

outputAlldata = zeros(0, 9);
outputLayersAvg = zeros(0,9);
outputCultivarAvg = zeros(0,9);
for cultivarID = 1:2
    for stage = 1:5
        DAS = num2str(DASList(stage));

        outputLayersAvg_temp = zeros(0,9);
        for plantID = 1:4
            filename = strcat('../CM-singlePlant/CM_',cv{cultivarID},'_',DAS,'_',num2str(plantID),'_vector.txt');

            vectorModel = importdata(filename);
            output = extractTraitFromVectorModel(vectorModel);
            [row1,col1] = size(output);
            temp = zeros(row1,10);
            temp(:,4:10) = output; temp(:,1) = cultivarID; temp(:,2) = stage; temp(:,3) = plantID;
            tempLayer1Avg = mean(temp(temp(:,5)==1,:),'omitnan');
            tempLayer2Avg = mean(temp(temp(:,5)==2,:),'omitnan');
            outputAlldata = [outputAlldata; temp];
            outputLayersAvg = [outputLayersAvg; tempLayer1Avg; tempLayer2Avg];
            outputLayersAvg_temp = [outputLayersAvg_temp;tempLayer1Avg; tempLayer2Avg ];

        end
        outputCultivarAvg_temp1 = mean(outputLayersAvg_temp(outputLayersAvg_temp(:,5) == 1,:));
        outputCultivarAvg_temp2 = mean(outputLayersAvg_temp(outputLayersAvg_temp(:,5) == 2,:));
        outputCultivarAvg = [outputCultivarAvg; outputCultivarAvg_temp1; outputCultivarAvg_temp2]; 
    end
end

writematrix(outputAlldata,'plantTraits_output_all.csv');
writematrix(outputLayersAvg,'plantTraits_output_LayerAvg.csv');
writematrix(outputCultivarAvg,'plantTraits_output_CultivarAvg.csv');
