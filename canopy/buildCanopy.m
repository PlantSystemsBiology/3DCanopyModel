% script 2
% Qingfeng, CEMPS, this script build a canopy from the CM single plant
% model files, four single plants are used to build a canopy.
% X -> north, Y -> west, Z -> up

% SPADcultivarIds = [1,1] 下层，上层的。1表示W64A，2表示A619

function buildCanopy(singlePlantMesh_prefix, meshModelNum, outputCMfilename, SPADcultivarIds, ChlAdj, SPADstage, rand_seed)
% buildCanopy('CM_W64A_45_A619_LA_', 4, 'CM_W64A_45_A619_LA-rep1.txt', 'W64A');
rng(rand_seed);
DASnew = [31, 38, 45, 52, 59]; % Qingfeng's DAS
CULTIVAR = ["W64A","A619"]; % two cultivars

%  % total plant number
% xNum = 18; % 13 plants/line
% xInterval = 10; % 15 cm plant distance between neighber plants
xNum = 13; % 13 plants/line
xInterval = 15; % 15 cm plant distance between neighber plants

yNum = 4; % 4 lines
yInterval = 55; % cm line distance
FormatColumnNumber = 15;

W64A_SPAD_Measured = [
    % DAS31	DAS38	DAS45	DAS52	DAS59
    41.7 	43.3 	39.9 	35.8 	37.5  % from bottom, the 1st leaf
    44.1 	44.1 	41.7 	41.1 	43.0  % from bottom, the 2nd leaf
    44.0 	43.9 	46.1 	43.9 	45.1
    44.0 	44.8 	44.6 	46.0 	46.5
    45.0 	45.4 	47.4 	45.7 	48.3
    43.0 	46.2 	47.8 	45.8 	48.7
    38.1 	47.8 	48.1 	48.4 	50.1
    31.8 	46.3 	46.1 	49.6 	51.5
    31.8 	44.2 	45.4 	49.3 	52.5 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	49.4 	50.1 	51.8 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.8 	40.5 	47.1 	50.9 	50.6 % assume if more leaf, the same as top 1st leaf SPAD
    ];

A619_SPAD_Measured =[
    26.9 	27.2 	29.3 	27.0 	27.5
    29.8 	34.4 	37.0 	31.6 	32.8
    32.2 	38.2 	39.6 	37.5 	36.7
    34.5 	39.8 	40.5 	39.5 	40.7
    33.9 	37.8 	40.1 	41.5 	43.3
    33.3 	37.2 	40.7 	43.6 	44.0
    31.0 	35.1 	40.1 	45.7 	44.4
    32.1 	34.2 	41.4 	44.5 	49.6
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    31.5 	34.2 	42.8 	46.7 	49.6 % assume if more leaf, the same as top 1st leaf SPAD
    ]; %                   （这个56.7改为了46.7）

SPADcultivar = zeros(20,1);

SPAD_Measured = zeros(20,5); %init empty matrix

% select SPAD data for specific cultivar

% bottom layer 1-4 leaves from bottom
if SPADcultivarIds(1) == 1 
    SPAD_Measured(1:4,:) = W64A_SPAD_Measured(1:4,:).*ChlAdj(1); % .*ChlAdj(1)是bo 的SPAD调节系数
    SPADcultivar(1:4)= 1;
elseif SPADcultivarIds(1) == 2
    SPAD_Measured(1:4,:) = A619_SPAD_Measured(1:4,:).*ChlAdj(1); % .*ChlAdj(1)是bo 的SPAD调节系数
    SPADcultivar(1:4)= 2;
else
    error('SPAD data for input cultivar not exist');
end

% up layer, others, 5 to top leaves
if SPADcultivarIds(2) == 1
    SPAD_Measured(5:end,:) = W64A_SPAD_Measured(5:end,:).*ChlAdj(2); % .*ChlAdj(2)是up 的SPAD调节系数;
    SPADcultivar(5:end)= 1;
elseif SPADcultivarIds(2) == 2
    SPAD_Measured(5:end,:) = A619_SPAD_Measured(5:end,:).*ChlAdj(2); % .*ChlAdj(2)是up 的SPAD调节系数;
    SPADcultivar(5:end)= 2;
else
    error('SPAD data for input cultivar not exist');
end

% load all the plant mesh model, 1 2 3 4. etc, to cell d. 
plantID = 1;  % for the canopy
d = cell(1,meshModelNum);
for k = 1:meshModelNum
    file = strcat('..\CM-singlePlant\',singlePlantMesh_prefix, num2str(k),'.txt');
    d1 = importdata(file);  % file name format: Cultivar_DAS_plant number
    d{1,k} = d1;
end

% build canopy with plants of 1,2,3,4..1,2,3,4.. to construct a canopy
dcanopy = zeros(0, FormatColumnNumber); % an empty matrix for saving a canopy.
k=1;
for y = 1:yNum
    yshift = (y-1)*yInterval;
    for x = 1:xNum
        xshift = (x-1)*xInterval;
        d1 = d{1,k};
        k = k + 1;
        if k>meshModelNum
            k = 1;
        end

        % build one plant
        [row2, col2] = size(d1);
        onePlant = zeros(row2, col2);
        onePlant(:,1) = plantID; % 1
        onePlant(:,2) = 0;       % 2
        onePlant(:,3) = d1(:,10); % 3, leaf ID: 0: stem, 1,2,3... number from bottom to top.
        onePlant(:,4) = 0;  % 4
        onePlant(:,5) = d1(:,11); % 5, leaf layers: 1: lower layer, 2: uppper layer, 0: stem
        onePlant(:,6:14) = d1(:,1:9);
        onePlant(:,15) = 0;  % leaf N content
        onePlant(:,16) = 0;  % default value, transmittance is 0. (for stem)
        onePlant(:,17) = 0.1; % default value, reflectance is 0.1 (for stem)

        % asign SPAD values and Leaf transmittance and Leaf reflectance for one plant.
        leafNum = max(onePlant(:,3)); % total leaf number
        for n = 1:leafNum
            SPAD = SPAD_Measured(n,SPADstage); % search the spad value measured at stage j for leaf n th from bottom
            leafT = leafTfromSPAD(SPAD); % calcualte leaf transmittance
            leafR = leafRfromSPAD(SPAD,SPADcultivar(n)); % calcualte leaf reflectance
            onePlant(onePlant(:,3) == n,16) = leafT; % assign leaf transmittance to all the triangles of leaf n th
            onePlant(onePlant(:,3) == n,17) = leafR; % assign leaf reflectance to all the triangles of leaf n th
        end

        % ROTATION of plants random to any orientation
        [X, Y, Z] = convertColumn9to3 (onePlant(:,6:14)); % 变换数据结构为3列
        [theta,r,h] = cart2pol(X,Y,Z);              % Z 方向为轴,  转换为柱坐标系, Z 方向为轴----------------------
        theta = theta+rand*2*pi;                         % 叶子沿着茎秆旋转到beta度到某一方向
        [X,Y,Z] = pol2cart(theta,r,h); %  convert to rectangular cartesian coordinate system -转换回笛卡尔坐标系---------------------------
        onePlant(:,6:14) = convertColumn3to9 ([X,Y,Z]); % 数据结构转换回9列

        % SET data format digitals
        onePlant(:,6:14) = roundn(onePlant(:,6:14),-3); % set to 0.001 accurancy
        onePlant(:,16:17) = roundn(onePlant(:,16:17),-4); % set to 0.0001 accurancy

        % SHIFT X, Y
        onePlant(:,[6,9,12]) = onePlant(:,[6,9,12]) + xshift;  % x direction interval is plant distance, North
        onePlant(:,[7,10,13]) = onePlant(:,[7,10,13]) + yshift;% y direction interval is row distance, West

        % add one plant to canopy model.
        dcanopy = [dcanopy;onePlant];

        % update plant ID
        plantID = plantID +1;

    end
end

% print to file
outputfile = strcat('..\CM\',outputCMfilename);
writematrix(dcanopy, outputfile, 'Delimiter', 'tab');

end




