addpath('matlab_func');
common_settings;
% is_printed = 1;
%%
barWidth = 0.5;
queue_num = 20;
cluster_size=10;
figureSize = figSizeThreeFourth;
plots  = [false true];
methods = {strDRF, strES,  strAlloX, 'SRPT'};
% files = {'DRF', 'ES',  'AlloX'};
% speedups = [0.1, 0.5, 1.0]
% alphas = [0.05 0.1 0.2 0.3 0.4];
alphas = [0.05 0.1 0.2];
files = {'DRF', 'ES',  'FS', 'SRPT'};
DRFId = 1; ESId = 2; AlloXId = 3; SRPTId = 4;
methodColors = {colorES; colorDRF; colorProposed};

%% load data
resVals = zeros(length(methods),length(alphas)); 
for i=1:length(methods)
    for j=1:length(alphas)
        if j~=AlloXId
            extraStr = ['_' int2str(queue_num) '_' int2str(cluster_size) '_a' sprintf('%1.1f',alphas(j))];
        else
            extraStr = ['_' int2str(queue_num) '_' int2str(cluster_size)];
        end
        
        outputFile = [ 'output/' files{i} '-output' extraStr  '.csv'];
        [JobIds{i,j}, startTimes{i,j}, endTimes{i,j}, durations{i,j}, queueNames{i,j}] = import_compl_time_real_job(outputFile);
        if(~isnan(durations{i,j}))
            resVals(i,j) = mean(durations{i,j});
        end
    end
end
avgCmpltES = resVals(ESId,1);
avgCmpltSRPT = resVals(SRPTId,1);
%%
if plots(1)    
    figIdx=figIdx +1;         
    figures{figIdx} = figure;
    scrsz = get(groot, 'ScreenSize');   
    plot(alphas, resVals(AlloXId,length(alphas))./resVals(AlloXId,:), 'LineWidth', lineWidth);   
    hold on;
    plot(alphas, resVals(AlloXId,length(alphas))/avgCmpltES*ones(size(alphas)), 'LineWidth', lineWidth);   

    xLabel='\alpha';
    yLabel=strFactorImprove;
    legendStr=methods;    
    ylim([0 1]);
    xlim([0.1 1]);
    legend({'AlloX', 'ES+RP'},'Location', 'best','FontSize',fontAxis);
    set (gcf, 'Units', 'Inches', 'Position', figureSize, 'PaperUnits', 'inches', 'PaperPosition', figureSize);
    %     xlabel(xLabel,'FontSize',fontAxis);
    ylabel(yLabel,'FontSize',fontAxis);    
    xlabel(xLabel,'FontSize',fontAxis);   
    fileNames{figIdx} = 'analysis_alpha';
    
end
%
%%
minImproveVsES = zeros(size(alphas));
maxImproveVsES = zeros(size(alphas));
for i=1:length(alphas)
    [~, DRFSortIds] = sort(JobIds{DRFId,i});
    [~, ESSortIds] = sort(JobIds{ESId,i});
    [~, AlloXSortIds] = sort(JobIds{AlloXId,i});
    [~, SRPTSortIds] = sort(JobIds{SRPTId,i});

    DRFQueues = queueNames{DRFId,i}(DRFSortIds);
    ESQueues = queueNames{ESId,i}(ESSortIds);
    AlloXQueues = queueNames{AlloXId,i}(AlloXSortIds);
    SRPTQueues = queueNames{SRPTId,i}(SRPTSortIds);

    ESTotalCompltTime = [];
    DRFTotalCompltTime = [];
    AlloXTotalCompltTime = [];
    SRPTTotalCompltTime = [];

    ESDurations = durations{ESId,i}(ESSortIds);
    DRFDurations = durations{DRFId,i}(DRFSortIds);
    AlloXDurations = durations{AlloXId,i}(AlloXSortIds);
    SRPTDurations = durations{SRPTId,i}(SRPTSortIds);

    queueSet = {};
    for q=1:length(ESQueues)
        queueName = ESQueues{q};
        idx = 0;        
        if ~any(strcmp(queueSet,queueName))
            queueSet{length(queueSet)+1} = queueName;
            idx = length(queueSet);
            ESTotalCompltTime = [ESTotalCompltTime  ESDurations(q)];
%             DRFTotalCompltTime = [DRFTotalCompltTime  DRFDurations(q)];
            AlloXTotalCompltTime = [AlloXTotalCompltTime  AlloXDurations(q)];
            SRPTTotalCompltTime = [SRPTTotalCompltTime SRPTDurations(q)];
        else            
            idx = strcmp(queueSet,queueName);
            ESTotalCompltTime(idx) = ESTotalCompltTime(idx) + ESDurations(q);
%             DRFTotalCompltTime(idx) = DRFTotalCompltTime(idx) + DRFDurations(q);
            AlloXTotalCompltTime(idx) = AlloXTotalCompltTime(idx) + AlloXDurations(q);
            SRPTTotalCompltTime(idx) = SRPTTotalCompltTime(idx) + SRPTDurations(q);
        end        
    end
    improvement = (ESTotalCompltTime./AlloXTotalCompltTime - 1)*100;
    minImproveVsES(i) = min(improvement);
    maxImproveVsES(i) = max(improvement);
    stdVsES(i) = std(improvement);
end

    
if plots(2)    
    figIdx=figIdx +1;         
    figures{figIdx} = figure;
    scrsz = get(groot, 'ScreenSize');       
    improvePercent = (resVals(ESId,:)./resVals(AlloXId,:) -1)*100;
%     improvePercent = (resVals(SRPTId,:)./resVals(AlloXId,:))*100;
    plot(alphas, improvePercent, 'LineWidth', lineWidth);  
    hold on;
%     improveStd = 0.0*improvePercent;
%     errorbar(alphas,improvePercent,minImproveVsES, maxImproveVsES, '.');
%     errorbar(alphas, improvePercent, stdVsES,'.');
    xLabel='fairness parameter \alpha';
    yLabel=strImprovement;
    legendStr=methods;        
    xlim([0.05 1]);
%     ylim([0 max(improvePercent)*1.1]);
    ylim([0 100]);
    set (gcf, 'Units', 'Inches', 'Position', figureSize, 'PaperUnits', 'inches', 'PaperPosition', figureSize);
    %     xlabel(xLabel,'FontSize',fontAxis);
    ylabel(yLabel,'FontSize',fontAxis);    
    xlabel(xLabel,'FontSize',fontAxis);   
    fileNames{figIdx} = 'fairness_alpha';
end

return;
%%
extra='';
for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    print (figures{i}, '-depsc', epsFile);    
    pdfFile = [ fig_path fileName '.pdf']  
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end