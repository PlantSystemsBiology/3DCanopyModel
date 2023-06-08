
addpath("canopy\");
addpath("common\");
clear;

cultivars = {'W64A','A619'}; % or 'A619'
DASList = [31 38 45 52 59];
DOYList = [239,246,253,260,267];

%% 下面的adjList1和adjList2需要与script1里面的一致

% W64A 变为 A619
% LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
adjustTable_A619compW64A = ...
    [0.64 	1.24 	5.8 	-9.1 	1.03 	1.41 	38.3 	8.1 	2 ;
    1.05 	1.09 	5.2 	2.6 	1.20 	0.91 	47.8 	-1.0 	0 ;
    1.01 	1.20 	39.9 	5.7 	1.21 	1.03 	63.0 	-0.9 	-2 ;
    1.16 	1.34 	23.6 	4.6 	1.00 	1.09 	34.6 	-13.9 	-1 ;
    1.02 	1.20 	33.5 	5.8 	1.09 	0.96 	33.3 	-21.0 	-2 ;
    ];

traitsDiffA619ReltiveToW64A = ...
    [1	1	-35.6 	23.8 	4.7 	-21.4 	28.6 ;
    1	2	3.4 	41.2 	38.6 	27.8 	28.6 ;
    2	1	4.6 	9.0 	3.6 	6.3 	-2.6 ;
    2	2	20.2 	-9.0 	55.3 	-3.0 	-2.6 ;
    3	1	0.5 	20.3 	30.5 	13.7 	-16.7 ;
    3	2	21.4 	3.1 	74.5 	-2.0 	-16.7 ;
    4	1	16.5 	34.3 	18.6 	9.8 	-13.2 ;
    4	2	-0.2 	9.5 	37.8 	-25.9 	-13.2 ;
    5	1	2.4 	19.7 	23.1 	12.5 	-22.5 ;
    5	2	9.4 	-3.9 	37.2 	-34.8 	-22.5
    ];

senarioNum = 1+3+1+9; % WT, ECbo+up, ECbo, ECup, Estructure, LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu and LN.

%%
AQparaFile = '..\AQ_fit_param_W64A_A619.xlsx';
% for 3 big categorates
repN = 5;
%temp is used for saving Ac results
temp = zeros(0, 4);
adjAll = zeros(0, 11);
LAI_output = zeros(0, repN);
Ac_output = zeros(0, repN);

k = 1;

figure();
set(gcf,'unit','centimeters','position',[3 5 32 11]);

for cultivarID = 1:1 % 品种编号

    cn = cultivars{cultivarID};
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

    for stage = 1:5 % 选择时期% 选择日期

        % traits本身的差异画图，百分比数值差异

        % 以下部分是AQ曲线的表型参数的计算和画图
        td = traitsDiffA619ReltiveToW64A;
        [row, col] = size(td);
        bo = 1;
        up = 2;

        bo_LWLLetc = (td(td(:,1)==stage & td(:,2)==bo, 3:7));
        up_LWLLetc = (td(td(:,1)==stage & td(:,2)==up, 3:6));
        all_LWLLetc = [up_LWLLetc, bo_LWLLetc];

        subplot(2, 5, stage);
        x = categorical({'LW\_up','LL\_up','LC\_up','LA\_up','LW\_bo','LL\_bo','LC\_bo','LA\_bo','LN'});
        x = reordercats(x,{'LW\_up','LL\_up','LC\_up','LA\_up','LW\_bo','LL\_bo','LC\_bo','LA\_bo','LN'});
        b = bar(x, all_LWLLetc, 0.67); hold on;
        b.FaceColor = 'flat'; % set to using b.CData for coloring
        for i=1:9
            if i<=4
                b.CData(i,:) = [0.8500 0.3250 0.0980];
            elseif i<=8
                b.CData(i,:) = [0 0.4470 0.7410];
            else
                b.CData(i,:) = [0.9290 0.6940 0.1250];
            end
        end
        ylim([-50,100]);
        if stage == 1
            labelString = strcat('A');
            text(0.8, 80, labelString, FontSize=9);
            labelString = strcat('Stage ',num2str(stage));
            text(3.5, 120, labelString, FontSize=9);
        elseif stage == 2
            labelString = strcat('B');
            text(0.8, 80, labelString, FontSize=9);
            labelString = strcat('Stage ',num2str(stage));
            text(3.5, 120, labelString, FontSize=9);
        elseif stage == 3
            labelString = strcat('C');
            text(0.8, 80, labelString, FontSize=9);
            labelString = strcat('Stage ',num2str(stage));
            text(3.5, 120, labelString, FontSize=9);
        elseif stage == 4
            labelString = strcat('D');
            text(0.8, 80, labelString, FontSize=9);
            labelString = strcat('Stage ',num2str(stage));
            text(3.5, 120, labelString, FontSize=9);
        elseif stage == 5
            labelString = strcat('E');
            text(0.8, 80, labelString, FontSize=9);
            labelString = strcat('Stage ',num2str(stage));
            text(3.5, 120, labelString, FontSize=9);
        else

        end

        DAS = num2str(DASList(stage));
        DOY = num2str(DOYList(stage));

        Ac_oneStage  = zeros(0,repN);
        LAI_oneStage = zeros(0,repN);

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
            if cultivarID == 1
                cultivarIDSeries(:) = 1; % 1: W64A
            elseif cultivarID == 2
                cultivarIDSeries(:) = 2; % 2: A619
            end

            AQparaAdj = ones(1,8); % multiplier
            [canopy,LAI,Ac] = calculateAc(strcat('PPFD_',cn,'_',DAS,'_mesh_', lable),repN, AQparaFile, cultivarIDSeries, AQparaAdj, stage, ''); % cultivar 1: W64A, stage 3: DAS45.
            temp = [temp; [canopy.LAI.mean, canopy.LAI.sd, canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd]];

            LAI_oneStage = [LAI_oneStage; LAI];
            Ac_oneStage = [Ac_oneStage; Ac];

            LAI_output(k,:) = LAI;
            Ac_output(k,:) = Ac;
            adjAll(k,:) = adj;
            RowNames{k} = strcat(cultivars{cultivarID},'-stage ',num2str(stage),'-S',num2str(x));
            k = k+1;
        end

        WT = Ac_oneStage(1,:);
        EC = Ac_oneStage(2,:);
        ECb = Ac_oneStage(3,:);
        ECu = Ac_oneStage(4,:);
        ES = Ac_oneStage(5,:);
        LWb = Ac_oneStage(6,:);
        LLb = Ac_oneStage(7,:);
        LCb = Ac_oneStage(8,:);
        LAb = Ac_oneStage(9,:);
        LWu = Ac_oneStage(10,:);
        LLu = Ac_oneStage(11,:);
        LCu = Ac_oneStage(12,:);
        LAu = Ac_oneStage(13,:);
        LN = Ac_oneStage(14,:);

        contribution_LWb = (LWb-WT)./WT * 100; % unit: Percent
        contribution_LLb = (LLb-WT)./WT * 100;
        contribution_LCb = (LCb-WT)./WT * 100;
        contribution_LAb = (LAb-WT)./WT * 100;

        contribution_LWu = (LWu-WT)./WT * 100; % unit: Percent
        contribution_LLu = (LLu-WT)./WT * 100;
        contribution_LCu = (LCu-WT)./WT * 100;
        contribution_LAu = (LAu-WT)./WT * 100;

        contribution_LN = (LN-WT)./WT * 100;

        % for plotting figure, subplot
        contribution_collection = [contribution_LWu; contribution_LLu; contribution_LCu; contribution_LAu; ...
            contribution_LWb; contribution_LLb; contribution_LCb; contribution_LAb; contribution_LN];
        contribution_collection_avg = mean(contribution_collection, 2);
        contribution_collection_sd = std(contribution_collection, 0, 2);

        subplot(2, 5, 5+stage);
        x = categorical({'LW\_up','LL\_up','LC\_up','LA\_up','LW\_bo','LL\_bo','LC\_bo','LA\_bo','LN'});
        x = reordercats(x,{'LW\_up','LL\_up','LC\_up','LA\_up','LW\_bo','LL\_bo','LC\_bo','LA\_bo','LN'});

        b = bar(x,contribution_collection_avg,0.67); hold on;
        b.FaceColor = 'flat'; % set to using b.CData for coloring
        for i=1:9
            if i<=4
                b.CData(i,:) = [0.8500 0.3250 0.0980];
            elseif i<=8
                b.CData(i,:) = [0 0.4470 0.7410];
            else
                b.CData(i,:) = [0.9290 0.6940 0.1250];
            end
        end

        errlow = contribution_collection_sd;
        errhigh = contribution_collection_sd;
        er = errorbar(x,contribution_collection_avg,errlow,errhigh);
        er.Color = [0 0 0];
        er.LineStyle = 'none';

        if stage == 1
            ylim([-20,20]);
        elseif stage <=4
            ylim([-10,10]);
        elseif stage == 5
            ylim([-15,15]);
        else

        end

        if stage == 1
            ylabel('Relative change of A_c_,_d (%)');
        end

        if cultivarID == 1
            %             if stage == 1
            %                 labelString = strcat('A');
            %                 text(0.6, 16, labelString, FontSize=9);
            %                 labelString = strcat('Stage ',num2str(stage));
            %                 text(4, 25, labelString, FontSize=9);
            %             elseif stage == 2
            %                 labelString = strcat('B');
            %                 text(0.6, 8, labelString, FontSize=9);
            %                 labelString = strcat('Stage ',num2str(stage));
            %                 text(4, 12.5, labelString, FontSize=9);
            %             elseif stage == 3
            %                 labelString = strcat('C');
            %                 text(0.6, 8, labelString, FontSize=9);
            %                 labelString = strcat('Stage ',num2str(stage));
            %                 text(4, 12.5, labelString, FontSize=9);
            %             elseif stage == 4
            %                 labelString = strcat('D');
            %                 text(0.6, 8, labelString, FontSize=9);
            %                 labelString = strcat('Stage ',num2str(stage));
            %                 text(4, 12.5, labelString, FontSize=9);
            %             elseif stage == 5
            %                 labelString = strcat('E');
            %                 text(0.6, 12, labelString, FontSize=9);
            %                 labelString = strcat('Stage ',num2str(stage));
            %                 text(4, 18.75, labelString, FontSize=9);
            %             else
            %
            %             end
        elseif cultivarID == 2
            if stage == 1
                labelString = strcat('F');
                text(0.6, 16, labelString, FontSize=9);
            elseif stage == 2
                labelString = strcat('G');
                text(0.6, 8, labelString, FontSize=9);
            elseif stage == 3
                labelString = strcat('H');
                text(0.6, 8, labelString, FontSize=9);
            elseif stage == 4
                labelString = strcat('I');
                text(0.6, 8, labelString, FontSize=9);
            elseif stage == 5
                labelString = strcat('J');
                text(0.6, 12, labelString, FontSize=9);
            else

            end
        end

    end
end

%% output to file
T = table(adjAll(:,1), adjAll(:,2), adjAll(:,3), adjAll(:,4), adjAll(:,5), adjAll(:,6), adjAll(:,7), adjAll(:,8), adjAll(:,9), adjAll(:,10), adjAll(:,11), temp(:,1),temp(:,2),temp(:,3),temp(:,4), LAI_output(:,1), LAI_output(:,2), LAI_output(:,3), LAI_output(:,4), LAI_output(:,5), Ac_output(:,1),Ac_output(:,2),Ac_output(:,3),Ac_output(:,4),Ac_output(:,5), 'VariableNames',{'LWb','LLb','LCb','LAb','LWu','LLu','LCu','LAu','LN','ECb','ECu','LAI','LAI SD','Ac','Ac SD', 'LAI_rep1','LAI_rep2','LAI_rep3','LAI_rep4','LAI_rep5','Ac_rep1','Ac_rep2','Ac_rep3','Ac_rep4','Ac_rep5'},'RowNames',RowNames);
writetable(T,strcat('Ac_summary_subChlStructuralTraits.xlsx'),'Sheet',1,'WriteRowNames',true);


