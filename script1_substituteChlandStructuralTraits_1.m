
%% 说明
% 表型替换分析脚本。对于两个品种的WT，叶绿素参数替换以及上下层单独替换，全部株型参数替换以及单一株型参数替换的模拟分析，模拟ray tracing

%% 2023-2-16
%% Qingfeng
addpath("canopy\");
addpath("common\");
addpath("maizePC\");
addpath("virtualPlant\");

stage = 5; % 选择时期，共5个时期

% A619/W64A for LW and LL;  A619-W64A for LC, LA and LN
adjustTable_A619compW64A = ...
    [0.64 	1.24 	5.8 	-9.1 	1.03 	1.41 	38.3 	8.1 	2 ;
    1.05 	1.09 	5.2 	2.6 	1.20 	0.91 	47.8 	-1.0 	0 ;
    1.01 	1.20 	39.9 	5.7 	1.21 	1.03 	63.0 	-0.9 	-2 ;
    1.16 	1.34 	23.6 	4.6 	1.00 	1.09 	34.6 	-13.9 	-1 ;
    1.02 	1.20 	33.5 	5.8 	1.09 	0.96 	33.3 	-21.0 	-2 ;
    ];

senarioNum = 1+3+1+9; % WT, ECbo+up, ECbo, ECup, Estructure, LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu and LN.

%输入
removeStamen = true; %true去掉雄蕊

for cultivarID = 2:2
    % 品种信息
    cultivars = {'W64A','A619'}; % or 'A619'
    cn = cultivars{cultivarID};
    %时期，日期信息
    DASList = [31 38 45 52 59];
    DOYList = [239,246,253,260,267];
    DAS = num2str(DASList(stage));
    DOY = num2str(DOYList(stage));

    adjustTable = adjustTable_A619compW64A; % default is W64A

    if cultivarID == 2
        % A619 变为 W64A
        % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
        adjustTable(:,1:2) = 1./adjustTable_A619compW64A(:,1:2); %LW LL bo
        adjustTable(:,3:4) = -adjustTable_A619compW64A(:,3:4); % LC LA bo
        adjustTable(:,5:6) = 1./adjustTable_A619compW64A(:,5:6); % LW LL up
        adjustTable(:,7:8) = -adjustTable_A619compW64A(:,7:8); % LC LA up
        adjustTable(:,9) = -adjustTable_A619compW64A(:,9); % LN
    end

    for x=1:senarioNum
        adj = [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1]; % 每个循环重新初始化
        if cultivarID == 2
            adj(10:11) = 2;
        end
        % x==1 is for WT
        if x == 2 % EC all
            adj(10:11) = 3-adj(10:11);
        elseif x == 3 %ECbo
            adj(10) = 3-adj(10);
        elseif x == 4 %ECup
            adj(11) = 3-adj(11);
        elseif x == 5 % Estructure
            adj(1:9) = adjustTable(stage,:);
        elseif x >= 6
            adj(x-5) = adjustTable(stage,x-5);
        end

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


        lable = strcat(num2str(adjustConfig.leafWidthMultiply.b),'_',num2str(adjustConfig.leafLengthMultiply.b),'_', ...
            num2str(adjustConfig.leafCurvatureAdd.b),'_',num2str(adjustConfig.leafAngleAdd.b),'_', ...
            num2str(adjustConfig.leafWidthMultiply.u),'_',num2str(adjustConfig.leafLengthMultiply.u),'_', ...
            num2str(adjustConfig.leafCurvatureAdd.u),'_',num2str(adjustConfig.leafAngleAdd.u),'_', ...
            num2str(adjustConfig.leafNumberAdd),'_',num2str(ChlConfig(1)),'_',num2str(ChlConfig(2)) );

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
            ChlAdj = ones(1,2);
            buildCanopy(strcat('CM_',cn,'_',DAS,'_mesh_', lable,'_plant'), 4, CMfile, ChlConfig, ChlAdj, 3,rand_seed); % ChlConfig 表示上下层叶绿素
            % ray tracing
            PPFDfile = strcat('PPFD_',cn,'_',DAS,'_mesh_', lable,'-rep',num2str(rep),'-n0.2.txt'); % 修改PPFD文件名
            cmdline = strcat("..\FastTracer_2021\fastTracerVS2019.exe -D 52.5 127.5 27.5 137.5 0 180 -L 21 -S 12 -A 0.7 -d ",DOY,' -W 7 2 11 -n 0.2 -m ..\CM\',CMfile,' -o ..\PPFD\',PPFDfile);
            cmdline
            system(cmdline);
        end

    end

end


