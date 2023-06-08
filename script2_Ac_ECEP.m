
% dissect the contributions of each groups

addpath("canopy\");
addpath("common\");
clear;

figure();
hold on;
for stage = 1:5 % 选择时期%%%

    cultivars = {'W64A','A619'}; % or 'A619'
    DASList = [31 38 45 52 59];
    DOYList = [239,246,253,260,267];

    %% 下面的adjList1和adjList2需要与script1里面的一致

    % W64A 变为 A619
    % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
    adjList1 = [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1;... % WT
        1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 2];  ... % EC all

    % A619 变为 W64A
    % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
    adjList2 = [1, 1, 0, 0, 1, 1, 0, 0, 0, 2, 2;... % WT 1是W64A，2是A619
        1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1];  ... % EC all

    %%
    AQparaFile = '..\AQ_fit_param_W64A_A619.xlsx';
    % for 3 big categorates
    repN = 5;
    %temp is used for saving Ac results
    temp = zeros(0, 4);
    LAI_output = zeros(0, repN);
    Ac_output = zeros(0, repN);

    adjAll = zeros(0, 11);
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
        for x = 1:row
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

            lable = strcat(num2str(adjustConfig.leafWidthMultiply.b),'_',num2str(adjustConfig.leafLengthMultiply.b),'_', ...
                num2str(adjustConfig.leafCurvatureAdd.b),'_',num2str(adjustConfig.leafAngleAdd.b),'_', ...
                num2str(adjustConfig.leafWidthMultiply.u),'_',num2str(adjustConfig.leafLengthMultiply.u),'_', ...
                num2str(adjustConfig.leafCurvatureAdd.u),'_',num2str(adjustConfig.leafAngleAdd.u),'_', ...
                num2str(adjustConfig.leafNumberAdd),'_',num2str(ChlConfig(1)),'_',num2str(ChlConfig(2)) );

            cultivarIDSeries = ones(1,8);
            for cultivarID_P = 1:2

                if cultivarID_P == 1
                    cultivarIDSeries(:) = 1; % 1: W64A
                elseif cultivarID_P == 2
                    cultivarIDSeries(:) = 2; % 2: A619
                end

                AQparaAdj = ones(1,8); % multiplier
                [canopy, LAI, Ac] = calculateAc(strcat('PPFD_',cn,'_',DAS,'_mesh_', lable),repN, AQparaFile, cultivarIDSeries, AQparaAdj, stage, ''); % cultivar 1: W64A, stage 3: DAS45.

                %%%%%%%TODO 保存Ac,最后计算相对比例的变化

                temp = [temp; [canopy.LAI.mean, canopy.LAI.sd, canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd]];
                LAI_output = [LAI_output; LAI];
                Ac_output = [Ac_output; Ac];

                adjAll(k,:) = adj;

                RowNames{k} = strcat(cultivars{cultivarID},'-S',num2str(x),'-P',num2str(cultivarID_P));
                k = k+1;
            end
        end
    end

    O = Ac_output(1,:);
    P = Ac_output(2,:);
    C = Ac_output(3,:);
    CP = Ac_output(4,:);
    SC = Ac_output(5,:);
    SCP = Ac_output(6,:);
    S = Ac_output(7,:);
    SP = Ac_output(8,:);

    contribution_S = (S-O)./O * 100; % unit: Percent
    contribution_P = (P-O)./O * 100;
    contribution_C = (C-O)./O * 100;
    contribution_SPinter = (SP-S-P+O)./O * 100;
    contribution_SCinter = (SC-S-C+O)./O * 100;
    contribution_PCinter = (CP-P-C+O)./O * 100;
    contribution_SPCinter = (SCP-SC-CP-SP+S+P+C-O)./O * 100;

    % for plotting figure, subplot
    contribution_collection = [contribution_S; contribution_P; contribution_C; contribution_SPinter; contribution_SCinter; contribution_PCinter; contribution_SPCinter];
    contribution_collection_avg = mean(contribution_collection,2);
    contribution_collection_sd = std(contribution_collection,0,2);

    subplot(2,3,stage);
    x = categorical({'S','P','C','SP inter','SC inter','PC inter','SPC inter'});
    x = reordercats(x,{'S','P','C','SP inter','SC inter','PC inter','SPC inter'});

    bar(x,contribution_collection_avg,0.67); hold on;
    errlow = contribution_collection_sd;
    errhigh = contribution_collection_sd;
    er = errorbar(x,contribution_collection_avg,errlow,errhigh);
    er.Color = [0 0 0]; 
    er.LineStyle = 'none';  

    ylim([-5,40]);
    labelString = strcat('Stage ',num2str(stage));
    text(4,35, labelString, FontSize=9);
    if stage == 1 || stage == 4
        ylabel('Relative change of A_c_,_d (%)');
    end
    if stage == 1
        labelString = strcat('A');
        text(0.5, 37, labelString, FontSize=9);
    elseif stage == 2
        labelString = strcat('B');
        text(0.5, 37, labelString, FontSize=9);
    elseif stage == 3
        labelString = strcat('C');
        text(0.5, 37, labelString, FontSize=9);
    elseif stage == 4
        labelString = strcat('D');
        text(0.5, 37, labelString, FontSize=9);
    elseif stage == 5
        labelString = strcat('E');
        text(0.5, 37, labelString, FontSize=9);
    else
    end


    %% output to file
    T = table(adjAll(:,1), adjAll(:,2), adjAll(:,3), adjAll(:,4), adjAll(:,5), adjAll(:,6), adjAll(:,7), adjAll(:,8), adjAll(:,9), adjAll(:,10), adjAll(:,11), temp(:,1),temp(:,2),temp(:,3),temp(:,4), LAI_output(:,1), LAI_output(:,2), LAI_output(:,3), LAI_output(:,4), LAI_output(:,5), Ac_output(:,1),Ac_output(:,2),Ac_output(:,3),Ac_output(:,4),Ac_output(:,5), 'VariableNames',{'LWb','LLb','LCb','LAb','LWu','LLu','LCu','LAu','LN','ECb','ECu','LAI','LAI SD','Ac','Ac SD','LAI_rep1','LAI_rep2','LAI_rep3','LAI_rep4','LAI_rep5','Ac_rep1','Ac_rep2','Ac_rep3','Ac_rep4','Ac_rep5'},'RowNames',RowNames);
    writetable(T,strcat('Ac_summary_ECEP-DAS',DAS,'.xlsx'),'Sheet',1,'WriteRowNames',true);

end

