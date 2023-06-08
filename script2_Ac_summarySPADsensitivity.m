

addpath("canopy\");
addpath("common\");
clear;

for stage = 1:5 % 选择时期

cultivars = {'W64A','A619'}; % or 'A619'
DASList = [31 38 45 52 59];
DOYList = [239,246,253,260,267];

%% 下面的adjList1和adjList2需要与script1里面的一致

% W64A 变为 A619
% LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
adjList1 = [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1;... % WT
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

% A619 变为 W64A
% LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
adjList2 = [1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 2;... % WT 1是W64A，2是A619
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

%%
AQparaFile = '..\AQ_fit_param_W64A_A619.xlsx';
% for 3 big categorates
repN = 5;
%temp is used for saving Ac results
temp = zeros(0, 4);
adjAll = zeros(0, 11);
ChlAdjAll = zeros(0,2);
k = 1;

DAS = num2str(DASList(stage));
DOY = num2str(DOYList(stage));

for cultivarID = 1:2 % 品种编号
    cn = cultivars{cultivarID};
    if cultivarID == 1
        adjList = adjList1;
    elseif cultivarID == 2
        adjList = adjList2;
    end
    [row,col] = size(adjList);
    for x = 1:1 % only for WT structure
        adj = adjList(x,:);

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

        for layer = 1:2 % bo and up

            ChlAdj = ones(1,2);
            for i = 0.6:0.2:1.4 % adjust ratio

                ChlAdj(layer) = i;

                lable = strcat(num2str(adjustConfig.leafWidthMultiply.b),'_',num2str(adjustConfig.leafLengthMultiply.b),'_', ...
                    num2str(adjustConfig.leafCurvatureAdd.b),'_',num2str(adjustConfig.leafAngleAdd.b),'_', ...
                    num2str(adjustConfig.leafWidthMultiply.u),'_',num2str(adjustConfig.leafLengthMultiply.u),'_', ...
                    num2str(adjustConfig.leafCurvatureAdd.u),'_',num2str(adjustConfig.leafAngleAdd.u),'_', ...
                    num2str(adjustConfig.leafNumberAdd),'_',num2str(ChlConfig(1)),'_',num2str(ChlConfig(2)),'_', ...
                    num2str(ChlAdj(1)),'_',num2str(ChlAdj(2)) );

                cultivarIDSeries = ones(1,8);
                if cultivarID == 1
                    cultivarIDSeries(:) = 1; % 1: W64A
                elseif cultivarID == 2
                    cultivarIDSeries(:) = 2; % 2: A619
                end

                AQparaAdj = ones(1,8); % multiplier
                canopy = calculateAc(strcat('PPFD_',cn,'_',DAS,'_mesh_', lable),repN, AQparaFile, cultivarIDSeries, AQparaAdj, stage, ''); % cultivar 1: W64A, stage 3: DAS45.
                temp = [temp; [canopy.LAI.mean, canopy.LAI.sd, canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd]];

                adjAll(k,:) = adj;
                ChlAdjAll(k,:) = ChlAdj;

                RowNames{k} = strcat(cultivars{cultivarID},'-C',num2str(k));
                k = k+1;
            end
        end

    end
end


%% output to file
T = table(adjAll(:,1), adjAll(:,2), adjAll(:,3), adjAll(:,4), adjAll(:,5), adjAll(:,6), adjAll(:,7), adjAll(:,8), adjAll(:,9), adjAll(:,10), adjAll(:,11), ChlAdjAll(:,1), ChlAdjAll(:,2), temp(:,1),temp(:,2),temp(:,3),temp(:,4), 'VariableNames',{'LWb','LLb','LCb','LAb','LWu','LLu','LCu','LAu','LN','ECb','ECu','ECb_adj','ECu_adj','LAI','LAI SD','Ac','Ac SD'},'RowNames',RowNames);
writetable(T,strcat('Ac_summary_SPADsensitivity-DAS',DAS,'.xlsx'),'Sheet',1,'WriteRowNames',true);
end
