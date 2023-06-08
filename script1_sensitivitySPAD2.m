
%% 说明
% 表型替换分析脚本。对于两个品种的WT，叶绿素参数替换以及上下层单独替换，全部株型参数替换以及单一株型参数替换的模拟分析，模拟ray tracing

%% 2023-2-7
%% Qingfeng

addpath("canopy\");
addpath("common\");
addpath("maizePC\");
addpath("virtualPlant\");

%输入
removeStamen = true; %true去掉雄蕊
stage = 3; % 选择时期，共5个时期
cultivarID = 2; % 品种编号 ， 1：W64A, 2: A619

% 品种信息
cultivars = {'W64A','A619'}; % or 'A619'
cn = cultivars{cultivarID};
%时期，日期信息
DASList = [31 38 45 52 59];
DOYList = [239,246,253,260,267];
DAS = num2str(DASList(stage));
DOY = num2str(DOYList(stage));

if cultivarID == 1
    % W64A 变为 A619
    % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
    adjList = [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1;... % WT
        1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 2;... % WT+EC 改变叶绿素，株型是WT的
        1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 1;... % WT+EC 改变bottom叶绿素，株型是WT的
        1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 2;... % WT+EC 改变up叶绿素，株型是WT的
        1, 1.21, 38.4, 5.7, 1.21, 1.03, 61.7, -1.2, -2, 1, 1;... % W64A 变为 A619, 全替换
        1, 1,    0, 0, 1, 1, 0, 0, 0, 1, 1;... %仅LWb
        1, 1.21, 0, 0, 1, 1, 0, 0, 0, 1, 1;... %仅LLb
        1, 1, 38.4, 0, 1, 1, 0, 0, 0, 1, 1;... % 仅LCb
        1, 1, 0,  5.7, 1, 1, 0, 0, 0, 1, 1;...  % 仅LAb
        1, 1, 0, 0, 1.21, 1, 0, 0, 0, 1, 1;... %仅LWu
        1, 1, 0, 0, 1, 1.03, 0, 0, 0, 1, 1;... %仅LLu
        1, 1, 0, 0, 1, 1, 61.7, 0, 0, 1, 1;... % 仅LCu
        1, 1, 0, 0, 1, 1, 0, -1.2, 0, 1, 1;...  % 仅LAu
        1, 1, 0, 0, 1, 1, 0, 0   ,-2, 1, 1];  ... % LN

elseif cultivarID == 2
    % A619 变为 W64A
    % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
    adjList = [1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 2;... % WT 1是W64A，2是A619
        1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1;... % WT+EC 改变叶绿素，株型是WT的
        1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 2;... % WT+EC 改变bottom叶绿素，株型是WT的
        1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 1;... % WT+EC 改变up叶绿素，株型是WT的
        1, 0.83, -38.4, -5.7, 0.83, 0.98, -61.7, 1.2, 2, 2, 2;... % A619 变为 W64A, 全替换
        1, 1,    0, 0, 1, 1, 0, 0, 0, 2, 2;... %仅LWb
        1, 0.83, 0, 0, 1, 1, 0, 0, 0, 2, 2;... %仅LLb
        1, 1, -38.4, 0, 1, 1, 0, 0, 0, 2, 2;... % 仅LCb
        1, 1, 0,  -5.7, 1, 1, 0, 0, 0, 2, 2;... % 仅LAb
        1, 1, 0, 0, 0.83, 1, 0, 0, 0, 2, 2;... %仅LWu
        1, 1, 0, 0, 1, 0.98, 0, 0, 0, 2, 2;... %仅LLu
        1, 1, 0, 0, 1, 1, -61.7, 0, 0, 2, 2;...% 仅LCu
        1, 1, 0, 0, 1, 1, 0, 1.2, 0, 2, 2;  ...  % 仅LAu
        1, 1, 0, 0, 1, 1, 0, 0,   2, 2, 2];  ... % LN
end

[row, col] = size(adjList);
for x=1:1  % only for the WT.
    adj = adjList(x,:);
    %% step2, 改变植株结构
    adjustConfig.leafWidthMultiply.b = adj(1); % 下层
    adjustConfig.leafLengthMultiply.b = adj(2);
    adjustConfig.leafCurvatureAdd.b = adj(3);
    adjustConfig.leafAngleAdd.b = adj(4);

    adjustConfig.leafWidthMultiply.u = adj(5); % 上层
    adjustConfig.leafLengthMultiply.u = adj(6);
    adjustConfig.leafCurvatureAdd.u = adj(7);
    adjustConfig.leafAngleAdd.u = adj(8);

    adjustConfig.leafNumberAdd = adj(9); % 叶数量

    ChlConfig = [adj(10), adj(11)]; % 叶绿素的设置， bottom and up

    for layer = 1:2

        ChlAdj = ones(1,2);
        for i = 0.6:0.2:1.4

            ChlAdj(layer) = i;

            lable = strcat(num2str(adjustConfig.leafWidthMultiply.b),'_',num2str(adjustConfig.leafLengthMultiply.b),'_', ...
                num2str(adjustConfig.leafCurvatureAdd.b),'_',num2str(adjustConfig.leafAngleAdd.b),'_', ...
                num2str(adjustConfig.leafWidthMultiply.u),'_',num2str(adjustConfig.leafLengthMultiply.u),'_', ...
                num2str(adjustConfig.leafCurvatureAdd.u),'_',num2str(adjustConfig.leafAngleAdd.u),'_', ...
                num2str(adjustConfig.leafNumberAdd),'_',num2str(ChlConfig(1)),'_',num2str(ChlConfig(2)),'_', ...
                num2str(ChlAdj(1)),'_',num2str(ChlAdj(2)) );

            % 构建调节株型的单株mesh model
            for plantid = 1:4
                plantModel = importdata(strcat('../CM-singlePlant/CM_',cn,'_',DAS,'_',num2str(plantid),'_vector.txt'));
                PlantTris = adjustPlantArchitecture(plantModel, adjustConfig, removeStamen);
                writematrix(PlantTris, strcat('../CM-singlePlant/', 'CM_',cn,'_',DAS,'_mesh_', lable, '_plant',num2str(plantid),'.txt'), 'Delimiter', 'tab');
            end

            % build model and ray tracing，5次重复
            for rep = 1:5
                CMfile = strcat('CM_',cn,'_',DAS,'_mesh_',lable,'-rep',num2str(rep),'.txt');  %修改三维CM模型文件名
                rand_seed = rep;
                buildCanopy(strcat('CM_',cn,'_',DAS,'_mesh_', lable,'_plant'), 4, CMfile, ChlConfig, ChlAdj, 3, rand_seed); % ChlConfig 表示上下层叶绿素
                % ray tracing
                PPFDfile = strcat('PPFD_',cn,'_',DAS,'_mesh_', lable,'-rep',num2str(rep),'-n0.2.txt'); % 修改PPFD文件名
                cmdline = strcat("..\FastTracer_2021\fastTracerVS2019.exe -D 52.5 127.5 27.5 137.5 0 180 -L 21 -S 12 -A 0.7 -d ",DOY,' -W 7 2 11 -n 0.2 -m ..\CM\',CMfile,' -o ..\PPFD\',PPFDfile);
                cmdline
                system(cmdline);
            end

        end

    end

end




