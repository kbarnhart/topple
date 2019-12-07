
figure(1)
hold on

resultsDir='testExperiment#x001/';
method={'rhMethod_', 'whiteMethod_'};
color={'r', 'b'};
cd(resultsDir)
for i=1:length(method)
      
    findex = dir(strcat(method{i} , '*','.mat'));
            
    for j=1:length(findex)
        results=findex(j).name;

        load(results)
        
        
        plot(t, notch, color{i})
       

    end

end