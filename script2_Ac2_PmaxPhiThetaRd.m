
%% AQ参数单一替换以及全部替换的Ac
% 2023-2-7
% Qingfeng

%%
addpath("canopy\");
AQparaFile = '..\AQ_fit_param_W64A_A619.xlsx';
repN = 5;
cultivars = {'W64A','A619'};
DASList = [31 38 45 52 59];

%temp
temp = zeros(0, 4);
k = 1;

figure();
set(gcf,'unit','centimeters','position',[3 5 28 11]);
for cultivarID=1:2

    cn = cultivars{cultivarID};
    for stage = 1:5

        % 以下部分是AQ曲线的表型参数的计算和画图
AQparams = importdata('..\AQcurves\AQ_fit_param_all.txt');

[row, col] = size(AQparams);
w64a = 1;
a619 = 2;
bo = 1;
up = 2;
    AQparams_W64A_bo = mean(AQparams(AQparams(:,1)==w64a & AQparams(:,2)==stage & AQparams(:,3)==bo, 4:7));
    AQparams_W64A_up = mean(AQparams(AQparams(:,1)==w64a & AQparams(:,2)==stage & AQparams(:,3)==up, 4:7));
    AQparams_A619_bo = mean(AQparams(AQparams(:,1)==a619 & AQparams(:,2)==stage & AQparams(:,3)==bo, 4:7));
    AQparams_A619_up = mean(AQparams(AQparams(:,1)==a619 & AQparams(:,2)==stage & AQparams(:,3)==up, 4:7));
    
    bo_PmaxPhiThetaRd = (AQparams_A619_bo - AQparams_W64A_bo)./AQparams_W64A_bo * 100; 
    up_PmaxPhiThetaRd    = (AQparams_A619_up - AQparams_W64A_up)./AQparams_W64A_up * 100;

    all_PmaxPhiThetaRd = [up_PmaxPhiThetaRd, bo_PmaxPhiThetaRd];

    subplot(2, 5, stage);
    x = categorical({'Pmax\_up','\phi\_up','\theta\_up','Rd\_up','Pmax\_bo','\phi\_bo','\theta\_bo','Rd\_bo'});
    x = reordercats(x,{'Pmax\_up','\phi\_up','\theta\_up','Rd\_up','Pmax\_bo','\phi\_bo','\theta\_bo','Rd\_bo'});

    b = bar(x,all_PmaxPhiThetaRd,0.67); hold on;
    b.FaceColor = 'flat'; % set to using b.CData for coloring
    for i=1:8
        if i<=4
            b.CData(i,:) = [0.8500 0.3250 0.0980]; % up
        else
            b.CData(i,:) = [0 0.4470 0.7410]; % bo
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


    % 以下是Ac的计算和画图
        DAS = num2str(DASList(stage));
        Ac_oneStage = zeros(0,repN);
        for n=0:9
            cultivarIDSeries = ones(1,8); % all 1 for W64A
            changedToLeafID = 2;
            if cultivarID==2
                cultivarIDSeries(:) = 2;
                changedToLeafID = 1;
            end

            if n>0 && n<9
                cultivarIDSeries(n)=changedToLeafID; % 依次改变其中1个光合参数为A619的
            elseif n==9
                cultivarIDSeries(:)=changedToLeafID; % 全部改为 A619的，2 for A619
            end
            AQparaAdj = ones(1,8); % multiplier
            [canopy,LAI,Ac] = calculateAc(strcat('PPFD_',cn,'_',DAS,'_mesh_1_1_0_0_1_1_0_0_0_',num2str(cultivarID),'_',num2str(cultivarID)), repN, AQparaFile, cultivarIDSeries, AQparaAdj, stage, '');
            temp = [temp; [canopy.LAI.mean, canopy.LAI.sd, canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd]];

            RowNames{k} = strcat(cn,'-stage ',num2str(stage),'-P',num2str(n));
            k = k+1;
            Ac_oneStage = [Ac_oneStage; Ac];
        end

        WT = Ac_oneStage(1,:);
        pmaxBo = Ac_oneStage(2,:);
        phiBo = Ac_oneStage(3,:);
        thetaBo = Ac_oneStage(4,:);
        rdBo = Ac_oneStage(5,:);
        pmaxUp = Ac_oneStage(6,:);
        phiUp = Ac_oneStage(7,:);
        thetaUp = Ac_oneStage(8,:);
        rdUp = Ac_oneStage(9,:);

        contribution_pmaxBo = (pmaxBo-WT)./WT * 100; % unit: Percent
        contribution_phiBo = (phiBo-WT)./WT * 100;
        contribution_thetaBo = (thetaBo-WT)./WT * 100;
        contribution_rdBo = (rdBo-WT)./WT * 100;

        contribution_pmaxUp = (pmaxUp-WT)./WT * 100; % unit: Percent
        contribution_phiUp = (phiUp-WT)./WT * 100;
        contribution_thetaUp = (thetaUp-WT)./WT * 100;
        contribution_rdUp = (rdUp-WT)./WT * 100;

        contribution_collection = ...
            [contribution_pmaxUp; contribution_phiUp; contribution_thetaUp; contribution_rdUp;...
            contribution_pmaxBo; contribution_phiBo; contribution_thetaBo; contribution_rdBo];
        contribution_collection_avg = mean(contribution_collection, 2);
        contribution_collection_sd = std(contribution_collection, 0, 2);

        subplot(2,5, 5+stage);
        x = categorical({'Pmax\_up','\phi\_up','\theta\_up','Rd\_up','Pmax\_bo','\phi\_bo','\theta\_bo','Rd\_bo'});
        x = reordercats(x,{'Pmax\_up','\phi\_up','\theta\_up','Rd\_up','Pmax\_bo','\phi\_bo','\theta\_bo','Rd\_bo'});

        b = bar(x,contribution_collection_avg,0.67); hold on;
        b.FaceColor = 'flat'; % set to using b.CData for coloring
        for i=1:8
            if i<=4
                b.CData(i,:) = [0.8500 0.3250 0.0980]; % up
            else
                b.CData(i,:) = [0 0.4470 0.7410]; % bo
            end
        end

        errlow = contribution_collection_sd;
        errhigh = contribution_collection_sd;
        er = errorbar(x,contribution_collection_avg,errlow,errhigh);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        ylim([-10,15]);

        if stage == 1
            ylabel('Relative change of A_c_,_d (%)');
        end

        if cultivarID == 0
            if stage == 1
                labelString = strcat('A');
                text(0.8, 13, labelString, FontSize=9);
                labelString = strcat('Stage ',num2str(stage));
                text(3.5, 18, labelString, FontSize=9);
            elseif stage == 2
                labelString = strcat('B');
                text(0.8, 13, labelString, FontSize=9);
                labelString = strcat('Stage ',num2str(stage));
                text(3.5, 18, labelString, FontSize=9);
            elseif stage == 3
                labelString = strcat('C');
                text(0.8, 13, labelString, FontSize=9);
                labelString = strcat('Stage ',num2str(stage));
                text(3.5, 18, labelString, FontSize=9);
            elseif stage == 4
                labelString = strcat('D');
                text(0.8, 13, labelString, FontSize=9);
                labelString = strcat('Stage ',num2str(stage));
                text(3.5, 18, labelString, FontSize=9);
            elseif stage == 5
                labelString = strcat('E');
                text(0.8, 13, labelString, FontSize=9);
                labelString = strcat('Stage ',num2str(stage));
                text(3.5, 18, labelString, FontSize=9);
            else

            end
        elseif cultivarID == 1||2
            if stage == 1
                labelString = strcat('F');
                text(0.8, 13, labelString, FontSize=9);
            elseif stage == 2
                labelString = strcat('G');
                text(0.8, 13, labelString, FontSize=9);
            elseif stage == 3
                labelString = strcat('H');
                text(0.8, 13, labelString, FontSize=9);
            elseif stage == 4
                labelString = strcat('I');
                text(0.8, 13, labelString, FontSize=9);
            elseif stage == 5
                labelString = strcat('J');
                text(0.8, 13, labelString, FontSize=9);
            else

            end
        end

    end
end

% output to file
T = table(temp(:,1),temp(:,2),temp(:,3),temp(:,4), 'VariableNames',{'LAI','LAI SD','Ac','Ac SD'},'RowNames',RowNames);
writetable(T,strcat('Ac_summaryPmaxPhiThetaRd-twoCultivarAllstages.xlsx'),'Sheet',1,'WriteRowNames',true);


