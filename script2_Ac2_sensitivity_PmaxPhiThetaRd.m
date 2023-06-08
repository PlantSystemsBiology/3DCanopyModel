
%% AQ参数单一替换以及全部替换的Ac
% 2023-2-7
% Qingfeng
%%
addpath("canopy\");
AQparaFile = '..\AQ_fit_param_W64A_A619.xlsx';
% for 3 big categorates
repN = 5;

cultivars = {'W64A','A619'}; % or 'A619'
DASList = [31 38 45 52 59];
ParaName = {'boPmax','boPhi','boTheta','boRd',...
    'upPmax','upPhi','upTheta','upRd'};

adjAll = zeros(0, 8);
LAIandAc = zeros(0, 4);
k = 1;

for stage = 2:2 % 选择时期
    DAS = num2str(DASList(stage));
    
    figure(stage); hold on; % new a figure window for one stage
    set(gcf,'unit','centimeters','position',[3 5 28 13]);

    for traitId = 1:8
        for cultivarID = 1:2
            cultivarIDSeries = ones(1,8); % all 1 for W64A
            if cultivarID == 2
                cultivarIDSeries(:) = 2; % change to A619 when cultivarID is 2
            end
            Ac_oneTrait = zeros(0,repN); % re-initialize to empty.
            AQparaAdj = ones(1,8); % multiplier
            for i = 0.6:0.2:1.4
                AQparaAdj(traitId) = i;
                [canopy, LAI, Ac] = calculateAc(strcat('PPFD_',cultivars{cultivarID},'_',DAS,'_mesh_1_1_0_0_1_1_0_0_0_1_1'),repN, AQparaFile, cultivarIDSeries, AQparaAdj, stage, ''); % cultivar 1: W64A, stage 3: DAS45.
                LAIandAc = [LAIandAc; [canopy.LAI.mean, canopy.LAI.sd, canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd]];
                Ac_oneTrait = [Ac_oneTrait; Ac];
                adjAll(k,:) = AQparaAdj;
                RowNames{k} = strcat('stage_',num2str(stage),cultivars{cultivarID},'-adj-',ParaName{traitId},'-by-',num2str(i));
                k = k+1;
            end

            % plot
            xdata = 0.6:0.2:1.4; % same as above i
            ydata = mean(Ac_oneTrait,2);
            ydata_sd = std (Ac_oneTrait,0,2);
            if traitId<=4
                subplotId = traitId+4;
            else
                subplotId = traitId-4;
            end
            subplot(2, 4, subplotId); hold on;
            if cultivarID == 1
                plot(xdata, ydata, Color='#0072BD', LineWidth=1);
            elseif cultivarID == 2
                plot(xdata, ydata, Color='#D95319', LineWidth=1);
            else
            end
            errlow = ydata_sd;
            errhigh = ydata_sd;
            er = errorbar(xdata,ydata,errlow,errhigh);
            if cultivarID == 1
                er.Color = '#0072BD';
            elseif cultivarID == 2
                er.Color = '#D95319';
            else
            end

        end

        if traitId == 8
            subplot(2,4,1);
            ylabel('A_c (\mumol m^-^2 s^-^1)', 'FontWeight','bold');
            subplot(2,4,5);
            ylabel('A_c (\mumol m^-^2 s^-^1)', 'FontWeight','bold');

            subplot(2,4,1);
            xlabel('Relative change of P_m_a_x', 'FontWeight','bold');
            labelString = strcat('A');
            text(0.7, 1.7, labelString, FontSize=9);

            subplot(2,4,2);
            xlabel('Relative change of \phi', 'FontWeight','bold');
            labelString = strcat('B');
            text(0.7, 1.7, labelString, FontSize=9);

            subplot(2,4,3);
            xlabel('Relative change of \theta', 'FontWeight','bold');
            labelString = strcat('C');
            text(0.7, 1.7, labelString, FontSize=9);

            subplot(2,4,4);
            xlabel('Relative change of R_d', 'FontWeight','bold');
            text(1.55, 1.5, 'Up layer','rotation',-90, 'FontWeight','bold')
            labelString = strcat('D');
            text(0.7, 1.7, labelString, FontSize=9);
            
            subplot(2,4,5);
            xlabel('Relative change of P_m_a_x', 'FontWeight','bold');
            labelString = strcat('E');
            text(0.7, 1.5, labelString, FontSize=9);

            subplot(2,4,6);
            xlabel('Relative change of \phi', 'FontWeight','bold');
            labelString = strcat('F');
            text(0.7, 1.5, labelString, FontSize=9);

            subplot(2,4,7);
            xlabel('Relative change of \theta', 'FontWeight','bold');
            labelString = strcat('G');
            text(0.7, 1.5, labelString, FontSize=9);

            subplot(2,4,8);
            xlabel('Relative change of R_d', 'FontWeight','bold');
            text(1.55, 1.47, 'Bottom layer','rotation',-90, 'FontWeight','bold')
            labelString = strcat('H');
            text(0.7, 1.5, labelString, FontSize=9);

        end
    end
end

% output to file
% T = table(adjAll(:,1), adjAll(:,2), adjAll(:,3), adjAll(:,4), adjAll(:,5), adjAll(:,6), adjAll(:,7), adjAll(:,8), LAIandAc(:,1),LAIandAc(:,2),LAIandAc(:,3),LAIandAc(:,4), 'VariableNames',{'boPmax','boPhi','boTheta','boRd',...
%     'upPmax','upPhi','upTheta','upRd','LAI','LAI SD','Ac','Ac SD'},'RowNames',RowNames);
% writetable(T,strcat('Ac_summary-sensitivityPmaxPhiThetaRd-TwoCultivars_allStages.xlsx'),'Sheet',1,'WriteRowNames',true);


