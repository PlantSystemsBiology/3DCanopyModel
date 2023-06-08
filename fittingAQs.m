
% function, for fitting AQ curves

function AQfittingOutput_all= fittingAQs()

DASnew = [31, 38, 45, 52, 59]; % DAS
CULTIVAR = ["W64A","A619"]; % two cultivars
AQfittingOutput_all = zeros(0,11);
RowNames_stage_cultivar_genotype = ["ENPTY"];
outputFile = 'AQ_fit_param_W64A_A619.xlsx';
k = 1;
for c = 1:2

    if c == 1
        cultivar = CULTIVAR{c};
    elseif c == 2
        cultivar = CULTIVAR{c};
    end

    for s = 1:5

        for layer = 1:2

            if layer == 1
                uplow = 'low';
            elseif layer == 2
                uplow = 'up';
            end

            AQfile = strcat('.\AQcurves\',cultivar,'-DAS',num2str(DASnew(s)),'-',uplow,'.txt');
            AQfile
            AQdata = importdata(AQfile);
            d = AQdata.data;
            PPFD = d(:,1);
            [row,col]=size(d);
            AQfittingOutput = zeros(col-1, 11);
            AQfittingOutput(:,1) = c;
            AQfittingOutput(:,2) = s;
            AQfittingOutput(:,3) = layer;

            for n=2:col  % for every single AQ curve
                A = d(:,n);
                Rd_input = A(end,1);
                Rd = -Rd_input;
                [fitresult, gof] = createFit(PPFD, A, Rd);
                AQfittingOutput(n-1,4:end) = [fitresult.Pmax, fitresult.phi, fitresult.theta, Rd,  gof.sse, gof.rsquare, gof.adjrsquare, gof.rmse];
                temp = strcat(num2str(k),'_',cultivar,'_',num2str(DASnew(s)),'_',uplow);
                RowNames_stage_cultivar_genotype(k)=temp;
                k=k+1;
            end
            AQfittingOutput_all = [AQfittingOutput_all;AQfittingOutput];
        end
    end

    T = table(AQfittingOutput_all(:,1),AQfittingOutput_all(:,2),AQfittingOutput_all(:,3),AQfittingOutput_all(:,4),AQfittingOutput_all(:,5),...
        AQfittingOutput_all(:,6),AQfittingOutput_all(:,7),AQfittingOutput_all(:,8),AQfittingOutput_all(:,9),AQfittingOutput_all(:,10),AQfittingOutput_all(:,11),...
        'VariableNames',{'cultivarID','stageID','layerID','Pmax', 'phi', 'theta', 'Rd',  'sse', 'rsquare', 'adjrsquare', 'rmse'},...
        'RowNames',RowNames_stage_cultivar_genotype);

    writetable(T,outputFile,'Sheet',1,'WriteRowNames',true);
end

end

%%
function [fitresult, gof] = createFit(PPFD, A, Rd)
%  CREATEFIT(PPFD,A)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : PPFD
%      Y Output: Ac1
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.
%  由 MATLAB 于 03-May-2019 21:44:54 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData(PPFD, A);

% Set up fittype and options.
eqn = strcat('(phi*x+Pmax-sqrt((phi*x+Pmax)^2-4*theta*phi*x*Pmax))/(2*theta)-',num2str(Rd));
ft = fittype( eqn, 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0.001];
opts.StartPoint = [10 0.5 0.1];
opts.Upper = [80 0.1 1];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

%% Plot fit with data.
%figure( 'Name', 'untitled fit 1' );
%h = plot( fitresult, xData, yData );
%legend( h, 'A vs. PPFD', 'untitled fit 1', 'Location', 'NorthEast' );
%% Label axes
%xlabel PPFD
%ylabel A

% grid on

end

