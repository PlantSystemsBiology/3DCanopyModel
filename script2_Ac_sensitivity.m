
% structural traits change, stage 1,2,5 in figure, 3 and 4 in supplementary
% figure. 

addpath("canopy\");
addpath("common\");
clear;
stageList = [1 2 5 3 4];

for stageID = 4:5 % 选择时期

    stage = stageList(stageID);
    cultivars = {'W64A','A619'}; % or 'A619'
    DASList = [31 38 45 52 59];
    DOYList = [239,246,253,260,267];

    %% 下面的adjList1和adjList2需要与script1里面的一致
    % W64A 变为 A619
    % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
    adjList1 = [0.6, 1, 0, 0,    0.6, 1, 0, 0, 0, 1, 1;... % LW 15
        0.7, 1, 0, 0,    0.7, 1, 0, 0, 0, 1, 1;...
        0.8, 1, 0, 0,    0.8, 1, 0, 0, 0, 1, 1;...
        0.9, 1, 0, 0,    0.9, 1, 0, 0, 0, 1, 1;...
        1,   1, 0, 0,      1, 1, 0, 0, 0, 1, 1;...
        1.1, 1, 0, 0,    1.1, 1, 0, 0, 0, 1, 1;...
        1.2, 1, 0, 0,    1.2, 1, 0, 0, 0, 1, 1;...
        1.3, 1, 0, 0,    1.3, 1, 0, 0, 0, 1, 1;...
        1.4, 1, 0, 0,    1.4, 1, 0, 0, 0, 1, 1;...
        1.5, 1, 0, 0,    1.5, 1, 0, 0, 0, 1, 1;...
        1.6, 1, 0, 0,    1.6, 1, 0, 0, 0, 1, 1;...
        1.7, 1, 0, 0,    1.7, 1, 0, 0, 0, 1, 1;...
        1.8, 1, 0, 0,    1.8, 1, 0, 0, 0, 1, 1;...
        1.9, 1, 0, 0,    1.9, 1, 0, 0, 0, 1, 1;...
        2.0, 1, 0, 0,    2.0, 1, 0, 0, 0, 1, 1;...

        1, 0.6, 0, 0,    1, 0.6, 0, 0, 0, 1, 1;... % LL  15 adj
        1, 0.7, 0, 0,    1, 0.7, 0, 0, 0, 1, 1;...
        1, 0.8, 0, 0,    1, 0.8, 0, 0, 0, 1, 1;...
        1, 0.9, 0, 0,    1, 0.9, 0, 0, 0, 1, 1;...
        1, 1.0, 0, 0,    1, 1.0, 0, 0, 0, 1, 1;...
        1, 1.1, 0, 0,    1, 1.1, 0, 0, 0, 1, 1;...
        1, 1.2, 0, 0,    1, 1.2, 0, 0, 0, 1, 1;...
        1, 1.3, 0, 0,    1, 1.3, 0, 0, 0, 1, 1;...
        1, 1.4, 0, 0,    1, 1.4, 0, 0, 0, 1, 1;...
        1, 1.5, 0, 0,    1, 1.5, 0, 0, 0, 1, 1;...
        1, 1.6, 0, 0,    1, 1.6, 0, 0, 0, 1, 1;...
        1, 1.7, 0, 0,    1, 1.7, 0, 0, 0, 1, 1;...
        1, 1.8, 0, 0,    1, 1.8, 0, 0, 0, 1, 1;...
        1, 1.9, 0, 0,    1, 1.9, 0, 0, 0, 1, 1;...
        1, 2.0, 0, 0,    1, 2.0, 0, 0, 0, 1, 1;...

        1, 1, 0, 0,   1, 1, 0, 0, -4, 1, 1;... % LN 13 adj
        1, 1, 0, 0,    1, 1, 0, 0, -3, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, -2, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, -1, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 0, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 1, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 2, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 3, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 4, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 5, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 6, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 7, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 8, 1, 1;...

        1, 1, -180, 0,    1, 1, -180, 0, 0, 1, 1;... % LC 11adj
        1, 1, -90, 0,    1, 1, -90, 0, 0, 1, 1;...
        1, 1, -60, 0,    1, 1, -60, 0, 0, 1, 1;...
        1, 1, -30, 0,    1, 1, -30, 0, 0, 1, 1;...
        1, 1, -15, 0,    1, 1, -15, 0, 0, 1, 1;...
        1, 1, 0, 0,     1, 1, 0, 0, 0, 1, 1;...
        1, 1, 15, 0,    1, 1, 15, 0, 0, 1, 1;...
        1, 1, 30, 0,    1, 1, 30, 0, 0, 1, 1;...
        1, 1, 60, 0,    1, 1, 60, 0, 0, 1, 1;...
        1, 1, 90, 0,    1, 1, 90, 0, 0, 1, 1;...
        1, 1, 180, 0,   1, 1, 180, 0, 0, 1, 1;...

        1, 1, 0, -20,   1, 1, 0, -20, 0, 1, 1;... % LA 13 adj
        1, 1, 0, -15,    1, 1, 0, -15, 0, 1, 1;...
        1, 1, 0, -10,    1, 1, 0, -10, 0, 1, 1;...
        1, 1, 0, -5,    1, 1, 0, -5, 0, 1, 1;...
        1, 1, 0, 0,    1, 1, 0, 0, 0, 1, 1;...
        1, 1, 0, 5,    1, 1, 0, 5, 0, 1, 1;...
        1, 1, 0, 10,    1, 1, 0, 10, 0, 1, 1;...
        1, 1, 0, 15,    1, 1, 0, 15, 0, 1, 1;...
        1, 1, 0, 20,    1, 1, 0, 20, 0, 1, 1;...
        1, 1, 0, 25,    1, 1, 0, 25, 0, 1, 1;...
        1, 1, 0, 30,    1, 1, 0, 30, 0, 1, 1;...
        1, 1, 0, 35,    1, 1, 0, 35, 0, 1, 1;...
        1, 1, 0, 40,    1, 1, 0, 40, 0, 1, 1;...

        1, 1, -180, -20,   1, 1, -180, -20, 0, 1, 1;... % LA with straight leaf, 13 adj
        1, 1, -180, -15,    1, 1, -180, -15, 0, 1, 1;...
        1, 1, -180, -10,    1, 1, -180, -10, 0, 1, 1;...
        1, 1, -180, -5,    1, 1, -180, -5, 0, 1, 1;...
        1, 1, -180, 0,    1, 1, -180, 0, 0, 1, 1;...
        1, 1, -180, 5,    1, 1, -180, 5, 0, 1, 1;...
        1, 1, -180, 10,    1, 1, -180, 10, 0, 1, 1;...
        1, 1, -180, 15,    1, 1, -180, 15, 0, 1, 1;...
        1, 1, -180, 20,    1, 1, -180, 20, 0, 1, 1;...
        1, 1, -180, 25,    1, 1, -180, 25, 0, 1, 1;...
        1, 1, -180, 30,    1, 1, -180, 30, 0, 1, 1;...
        1, 1, -180, 35,    1, 1, -180, 35, 0, 1, 1;...
        1, 1, -180, 40,    1, 1, -180, 40, 0, 1, 1;...
        ];

    % A619 变为 W64A
    % LWb, LLb, LCb, LAb, LWu, LLu, LCu, LAu, LN, ECb, ECu
    adjList2 = adjList1;
    adjList2(:,10:11) = 2;

    %%
    AQparaFile = '..\AQ_fit_param_W64A_A619.xlsx';
    % for 3 big categorates
    repN = 5;
    %temp is used for saving Ac results
    temp = zeros(0, 4);
    adjAll = zeros(0, 11);
    k = 1;


    DAS = num2str(DASList(stage));
    DOY = num2str(DOYList(stage));

    traitAdjNum = [15, 15, 13, 11, 13, 13];
    for traitId = 1:6 % they are LW, LL, LC, LA, LA-straightleaf

        for cultivarID = 1:2 % 品种编号
            cn = cultivars{cultivarID};
            if cultivarID == 1
                adjList = adjList1;
            elseif cultivarID == 2
                adjList = adjList2;
            end
            %  [row,col] = size(adjList);

            LAI_oneTrait = zeros(0,repN);
            Ac_oneTrait = zeros(0,repN);

            traitAdjStartRowShift = 0;
            if traitId > 1
                traitAdjStartRowShift = sum(traitAdjNum(1: traitId-1));
            end

            traitColumId = traitId;

            if traitId == 3
                traitColumId = 9;
            elseif traitId == 4
                traitColumId = 3;
            elseif traitId == 5 || traitId == 6
                traitColumId = 4;
            else

            end

            xdata = adjList(traitAdjStartRowShift+1: traitAdjStartRowShift+traitAdjNum(traitId), traitColumId);

            for x = 1: traitAdjNum(traitId)
                adj = adjList(traitAdjStartRowShift + x, :);
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
                [canopy, LAI, Ac] = calculateAc(strcat('PPFD_',cn,'_',DAS,'_mesh_', lable),repN, AQparaFile, cultivarIDSeries, AQparaAdj, stage, ''); % cultivar 1: W64A, stage 3: DAS45.
                temp = [temp; [canopy.LAI.mean, canopy.LAI.sd, canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd]];

                LAI_oneTrait = [LAI_oneTrait; LAI];
                Ac_oneTrait = [Ac_oneTrait; Ac];
                adjAll(k,:) = adj;
                RowNames{k} = strcat(cultivars{cultivarID},'-S',num2str(x));
                k = k+1;
            end

            ydata = mean(Ac_oneTrait,2);
            ydata_sd = std (Ac_oneTrait,0,2);
            subplot(2, 6, (stageID-4)*6+traitId ); hold on;
            if cultivarID == 1
                plot(xdata, ydata, Color='#0072BD', LineWidth=1);
            elseif cultivarID == 2
                plot(xdata, ydata, Color='#D95319', LineWidth=1);
            else

            end

            if traitId <= 3
                ylim ([0.5, 1.6]);
            else
                ylim ([0.7, 1.4]);
            end
            
            errlow = ydata_sd;
            errhigh = ydata_sd;
            er = errorbar(xdata, ydata, errlow, errhigh);
            if cultivarID == 1
                er.Color = '#0072BD';
            elseif cultivarID == 2
                er.Color = '#D95319';
            else
            end
            
            er.LineStyle = 'none';

            if traitId == 1
                ylabel('A_c_,_d (\mumol m^-^2 s^-^1)');
            end
            if stageID == 3
            if traitId == 1
                xlabel('Relative Change of LW');
                labelString = strcat('A');
                text(0.74, 1.5, labelString, FontSize=9);
            elseif traitId == 2
                xlabel('Relative Change of LL');
                labelString = strcat('B');
                text(0.74, 1.5, labelString, FontSize=9);
            elseif traitId == 3
                xlabel('LN change (number)');
                labelString = strcat('C');
                text(-2.6, 1.5, labelString, FontSize=9);
            elseif traitId == 4
                xlabel('LC change (degree)');
                labelString = strcat('D');
                text(-160, 1.3364, labelString, FontSize=9);
            elseif traitId == 5
                xlabel('LA change (degree)');
                labelString = strcat('E');
                text(-13, 1.3364, labelString, FontSize=9);
            elseif traitId == 6
                xlabel('LA change (degree)');
                labelString = strcat('F');
                text(-13, 1.3364, labelString, FontSize=9);
            end
            end
        end

    end % traitID

    %% output to file
%    T = table(adjAll(:,1), adjAll(:,2), adjAll(:,3), adjAll(:,4), adjAll(:,5), adjAll(:,6), adjAll(:,7), adjAll(:,8), adjAll(:,9), adjAll(:,10), adjAll(:,11), temp(:,1),temp(:,2),temp(:,3),temp(:,4), 'VariableNames',{'LWb','LLb','LCb','LAb','LWu','LLu','LCu','LAu','LN','ECb','ECu','LAI','LAI SD','Ac','Ac SD'},'RowNames',RowNames);
%    writetable(T,strcat('Ac_summary_sensitivity-stage',num2str(stage),'.xlsx'),'Sheet',1,'WriteRowNames',true);


end
%

subplot(2,6,7);
xlabel('Relative Change of LW');
labelString = strcat('G');
text(0.74, 1.5, labelString, FontSize=9);

subplot(2,6,8);
xlabel('Relative Change of LL');
labelString = strcat('H');
text(0.74, 1.5, labelString, FontSize=9);

subplot(2,6,9);
xlabel('LN change (number)');
labelString = strcat('I');
text(-2.6, 1.5, labelString, FontSize=9);

subplot(2,6,10);
xlabel('LC change (degree)');
labelString = strcat('J');
text(-13, 1.3364, labelString, FontSize=9);

subplot(2,6,11);
xlabel('LA change (degree)');
labelString = strcat('K');
text(-13, 1.3364, labelString, FontSize=9);

subplot(2,6,12);
xlabel('LA change (degree)');
labelString = strcat('L');
text(-13, 1.3364, labelString, FontSize=9);


