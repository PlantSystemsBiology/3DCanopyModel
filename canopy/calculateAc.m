
%% input and output summary
% Input:
% PPFD 3D model,
% AQ para file (and stageID, genotypeID).

% Output:
% canopy.LAI, canopy.plantHeight, canopy.groundArea,
% canopy.incidentPAR, canopy.absorbedPPFD, canopy.canopyAbs,
% canopy.diurnalAc, canopy.dailyTotalAc,
% others will be added...

% PPFD_File_Name_base: "PPFD_0711-JP69-CA2-rep" is the Name base of
% "PPFD_0711-JP69-CA2-rep1.txt".
% replicateNum is 5.

% AQ_fit_param_file, it can be:
% "AQ_fit_param_JYY.txt", "AQ_fit_param_WYJ.txt", "AQ_fit_param_313.txt"

% stageID and genotypeID is used for indexing the AQ curves parameters for calculating leaf photosynthesis.
% stageID; % 1 for 0724 (0711 also use it), 2 for 0807, 3 for HS.
% genotypeID; % 1 for ca1, 2 for CA2, 3 for F1.

%cultivarID是数组，cultivarID=[1,1,1,1,1,1,1,1]; 
% [bottomPmax, bottomPhi,bottomTheta, bottomRd, upPmax, upPhi, upTheta, upRd], ... 1:W64A, 2:A619. 
%%
function [canopy, LAI, dailyTotalAc] = calculateAc(PPFD_File_Name_base, replicateNum, AQ_fit_param_file, cultivarID, AQparaAdj, stageID, AQflag)

addpath("common\");
addpath("maizePC\");

%% this block is PROJECT SPECIFIC hard code constant
canopy.groundArea = 8250/10000; % unit: 6600/10000 8250/10000 m2, its for maize. Constant

% ambient total PAR, stage1
PARs1 = [0.424456	234.968	681.916	1119.49	1470.33	1694.95	1772.11	1694.95	1470.33	1119.49	681.916	234.968	0.424456; % direct PPFD
         78.2143	270.576	335.636	364.615	379.315	386.522	388.708	386.522	379.315	364.615	335.636	270.576	78.2143]; % diffuse PPFD
PARs1 = sum(PARs1); % total PPFD

% .................., stage2
PARs2 = [0.0345849	209.994	652.897	1091.42	1443.89	1669.72	1747.32	1669.72	1443.89	1091.42	652.897	209.994	0.0345849; % direct PPFD
         57.1966	263.956	332.999	363.193	378.371	385.778	388.02	385.778	378.371	363.193	332.999	263.956	57.1966]; % diffuse PPFD
PARs2 = sum(PARs2); % total PPFD

% .................., stage3
PARs3 = [0.000126049	183.975	620.512	1058.65	1411.86	1638.39	1716.25	1638.39	1411.86	1058.65	620.512	183.975	0.000126049; % direct PPFD
           35.0506	256.29	329.902	361.476	377.197	384.833	387.139	384.833	377.197	361.476	329.902	256.29	35.0506]; % diffuse PPFD
PARs3 = sum(PARs3); % total PPFD

%stage 4
PARs4 = [1.04086E-15	157.59	585.19	1021.47	1374.42	1601.03	1678.96	1601.03	1374.42	1021.47	585.19	157.59	1.04086E-15;
         12.2987	247.511	326.32	359.447	375.78	383.673	386.052	383.673	375.78	359.447	326.32	247.511	12.2987];
PARs4 = mean(PARs4);

%stage 5
PARs5 = [0	131.592	547.536	980.396	1332.01	1558.08	1635.84	1558.08	1332.01	980.396	547.536	131.592	0;
         0	237.577	322.24	357.1	374.114	382.294	384.755	382.294	374.114	357.1	322.24	237.577	0];
PARs5 = mean(PARs5);

PAR_all = [PARs1;
    PARs2;
    PARs3;
    PARs4;
    PARs5]'; % merge together
PAR_all = PAR_all([2,4,6], :); % only use [2,4,6] for [7,9,11h] , 2:12 for 7:17h time point
%%

%% PPFD file format, CONSTANT
plantID_ind = 1;
tillerID_ind = 2;
leafID_ind = 3; % the third column is organ ID，1.2.3 etc are leaves, from bottom to top, 0 is stem.
position_ind = 4;
extraID_ind = 5; % 1 for bottom layer, 2 for up layer, 3 for stem. 
XYZ_ind = 6:14;
NpArea_ind = 15;
Kt_ind = 16;
Kr_ind = 17;
facetS_ind = 18;
WholeDayTimePoints = 3; % NEED TO BE EDITED
TotalPAR_ind = (18+7):7:(18+7*WholeDayTimePoints);

%%
LAI = zeros(1,replicateNum);
absorbedPPFD = zeros(WholeDayTimePoints, replicateNum);
canopyAbs = zeros(WholeDayTimePoints, replicateNum);
diurnalAc = zeros(WholeDayTimePoints, replicateNum);
dailyTotalAc = zeros(1, replicateNum);

for rep = 1:replicateNum

    PPFD_file = strcat('..\PPFD\',PPFD_File_Name_base, '-rep',num2str(rep),'-n0.2.txt');
    PPFD_file
    d = importdata(PPFD_file); % with header
    d = d.data;

    d_leaf_idx = d(:,leafID_ind) >= 1; % 
    d_leaf_bottom_idx = d(:,leafID_ind) >= 1 & d(:,extraID_ind) == 1; % the 3rd column is organID
    d_leaf_up_idx = d(:,leafID_ind) >= 1 & d(:,extraID_ind) == 2; % the 3rd column is organID
    d_stem = d(d(:,3) == 0,:);

    % LAI
    leafArea = d(d_leaf_idx,facetS_ind)./10000; % leaf area, exclude stem, unit: m2
    leafArea_bottom = d(d_leaf_bottom_idx,facetS_ind)./10000; % leaf area, exclude stem, unit: m2
    leafArea_up = d(d_leaf_up_idx,facetS_ind)./10000; % leaf area, exclude stem, unit: m2
    LA = sum(leafArea); % unit: m2
    LAI(rep) = LA/canopy.groundArea;

    % PPFD and canopy absorbance, include leaf and stem absorbed.
    leafStemAbsPPFD = d(:,TotalPAR_ind); % for [7,9,11h] 3 time points
    absorbedPPFD(:,rep) = (  (d(:,facetS_ind)/10000)' * leafStemAbsPPFD./canopy.groundArea )'; %unit: umol m-2 ground area s-1
    canopy.incidentPAR = PAR_all(:,stageID); %unit: umol m-2 ground area s-1
    canopyAbs(:,rep) = absorbedPPFD(:,rep)./canopy.incidentPAR; % unit: 0-1 , dimentionless

    % AQ curve parameters loading and searching from input
    AQpara= readtable(AQ_fit_param_file);
    
    % for bottom layer,   leaf A for bottom layer
%     cultivarID
%     cultivarID(1)
    ind = (AQpara.cultivarID == cultivarID(1) & AQpara.stageID == stageID & AQpara.layerID == 1); % for bottom layer, layerID is 1. 
    Pmax = mean(AQpara.Pmax(ind))*AQparaAdj(1);
    ind = (AQpara.cultivarID == cultivarID(2) & AQpara.stageID == stageID & AQpara.layerID == 1);
    phi = mean(AQpara.phi(ind))*AQparaAdj(2);
    ind = (AQpara.cultivarID == cultivarID(3) & AQpara.stageID == stageID & AQpara.layerID == 1);
    theta = mean(AQpara.theta(ind))*AQparaAdj(3);
    ind = (AQpara.cultivarID == cultivarID(4) & AQpara.stageID == stageID & AQpara.layerID == 1);
    Rd = mean(AQpara.Rd(ind))*AQparaAdj(4);
    x = d(d_leaf_bottom_idx,TotalPAR_ind);
    A_bottom = (phi.*x+Pmax-sqrt((phi.*x+Pmax).^2-4*theta.*phi.*x.*Pmax))./(2*theta)-Rd; % unit, umol m-2 leaf s-1

    % for up layer, leaf A for up layer
    ind = (AQpara.cultivarID == cultivarID(5) & AQpara.stageID == stageID & AQpara.layerID == 2); % for up layer, layerID is 2. 
    Pmax = mean(AQpara.Pmax(ind))*AQparaAdj(5);
    ind = (AQpara.cultivarID == cultivarID(6) & AQpara.stageID == stageID & AQpara.layerID == 2);
    phi = mean(AQpara.phi(ind))*AQparaAdj(6);
    ind = (AQpara.cultivarID == cultivarID(7) & AQpara.stageID == stageID & AQpara.layerID == 2);
    theta = mean(AQpara.theta(ind))*AQparaAdj(7);
    ind = (AQpara.cultivarID == cultivarID(8) & AQpara.stageID == stageID & AQpara.layerID == 2);
    Rd = mean(AQpara.Rd(ind))*AQparaAdj(8);
    x = d(d_leaf_up_idx,TotalPAR_ind);
    A_up = (phi.*x+Pmax-sqrt((phi.*x+Pmax).^2-4*theta.*phi.*x.*Pmax))./(2*theta)-Rd; % unit, umol m-2 leaf s-1

    % total A
    temp = leafArea_bottom' * A_bottom + leafArea_up' * A_up;
    
    % canopy Ac
    diurnalAc(:,rep) = temp ./ canopy.groundArea; % unit: umol m-2 ground s-1
    dailyTotalAc(rep) = sum(diurnalAc(:,rep).*3600*2*2)/1e6; % CHANGED FOR 3 TIME POINTS. unit: mol m-2 d-1, the 3600 is 3600 seconds per hour as the interval is 1 hour.
    %*3600*2*2
end

% calculate Mean and Sd
canopy.LAI.mean = mean(LAI);   canopy.LAI.sd = std(LAI);
canopy.absorbedPPFD.mean = mean(absorbedPPFD,2);  canopy.absorbedPPFD.sd = std(absorbedPPFD,0,2);
canopy.canopyAbs.mean = mean(canopyAbs,2);     canopy.canopyAbs.sd = std(canopyAbs,0,2);
canopy.diurnalAc.mean = mean(diurnalAc,2);     canopy.diurnalAc.sd = std(diurnalAc,0,2);
canopy.dailyTotalAc.mean = mean(dailyTotalAc);  canopy.dailyTotalAc.sd = std(dailyTotalAc);

% output to Excel file
matrix_output = [
    canopy.LAI.mean, canopy.LAI.sd;
    canopy.absorbedPPFD.mean, canopy.absorbedPPFD.sd;
    canopy.canopyAbs.mean, canopy.canopyAbs.sd;
    canopy.diurnalAc.mean, canopy.diurnalAc.sd;
    canopy.dailyTotalAc.mean, canopy.dailyTotalAc.sd];
rowNames = {'LAI',...
    'absorbedPPFD_6.5h','absorbedPPFD_7.5h','absorbedPPFD_8.5h','absorbedPPFD_9.5h','absorbedPPFD_10.5h','absorbedPPFD_11.5h',...
    'absorbedPPFD_12.5h','absorbedPPFD_13.5h','absorbedPPFD_14.5h','absorbedPPFD_15.5h','absorbedPPFD_16.5h','absorbedPPFD_17.5h',...
    'canopyAbs_6.5h','canopyAbs_7.5h','canopyAbs_8.5h','canopyAbs_9.5h','canopyAbs_10.5h','canopyAbs_11.5h',...
    'canopyAbs_12.5h','canopyAbs_13.5h','canopyAbs_14.5h','canopyAbs_15.5h','canopyAbs_16.5h','canopyAbs_17.5h',...
    'diurnalAc_6.5h','diurnalAc_7.5h','diurnalAc_8.5h','diurnalAc_9.5h','diurnalAc_10.5h','diurnalAc_11.5h',...
    'diurnalAc_12.5h','diurnalAc_13.5h','diurnalAc_14.5h','diurnalAc_15.5h','diurnalAc_16.5h','diurnalAc_17.5h',...
    'dailyTotalAc'};
rowNames7to17 = {'LAI',...
    'absorbedPPFD_7h','absorbedPPFD_8h','absorbedPPFD_9h','absorbedPPFD_10h','absorbedPPFD_11h',...
    'absorbedPPFD_12h','absorbedPPFD_13h','absorbedPPFD_14h','absorbedPPFD_15h','absorbedPPFD_16h','absorbedPPFD_17h',...
    'canopyAbs_7h','canopyAbs_8h','canopyAbs_9h','canopyAbs_10h','canopyAbs_11h',...
    'canopyAbs_12h','canopyAbs_13h','canopyAbs_14h','canopyAbs_15h','canopyAbs_16h','canopyAbs_17h',...
    'diurnalAc_7h','diurnalAc_8h','diurnalAc_9h','diurnalAc_10h','diurnalAc_11h',...
    'diurnalAc_12h','diurnalAc_13h','diurnalAc_14h','diurnalAc_15h','diurnalAc_16h','diurnalAc_17h',...
    'dailyTotalAc'};

rowNames_11 = {'LAI',...
    'absorbedPPFD_11.5h',...
    'canopyAbs_11.5h',...
    'diurnalAc_11.5h',...
    'dailyTotalAc'};


rowNames_7_9_11 = {'LAI',...
    'absorbedPPFD_7h',...
    'absorbedPPFD_9h',...
    'absorbedPPFD_11h',...
    'canopyAbs_7h',...
    'canopyAbs_9h',...
    'canopyAbs_11h',...
    'diurnalAc_7h',...
    'diurnalAc_9h',...
    'diurnalAc_11h',...
    'dailyTotalAc'};

table1 = table(matrix_output(:,1), matrix_output(:,2),'VariableNames',{'Mean','SD'}, 'RowNames', rowNames_7_9_11);
filename  = strcat('.\Ac_LAI_excels\',PPFD_File_Name_base,'_',AQflag,'.xlsx');
writetable(table1,filename,'Sheet',1,'WriteRowNames',true);



