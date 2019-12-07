function wtemp=waterTempGenerator(t,spar, method)


if strcmp(method,'simpleSine')==1

wtemp=spar.Mw+spar.Ayw.*sin((t-spar.D)./365.25.*2.*pi)+spar.Adw.*sin((t-spar.D).*2.*pi);
end


if strcmp(method,'complexSine')==1

%%%%% More Complicated Stacked Sinusoids:

    t=date2doy(t);
    wtemp=spar.a0 + spar.a1.*cos(t.*spar.w) + spar.b1.*sin(t.*spar.w);

    %wtemp =  spar.a0 + spar.a1.*cos(t.*spar.w) + spar.b1.*sin(t.*spar.w) + spar.a2.*cos(2.*t.*spar.w) + spar.b2.*sin(2.*t.*spar.w);
     
    
end

if strcmp(method,'constant')==1

    wtemp=spar.Tconst.*ones(size(t));
    
end


if strcmp(method,'obs')==1
    load /Users/katherinebarnhart/MATLABwork/drewpointdataingest/all_drewpoint_data.mat

    wtemp=interp1(levellogger.date, levellogger.watertemp, t);
    
    
end

if strcmp(method,'mod')==1
%     load /Users/katherinebarnhart/MATLABwork/SSTTrends/modeledTemperaturesNov2012
    load modeledTemperaturesJan2013.mat

    wtemp=interp1(SSTModel.date, SSTModel.Twater, t);
    
    
end

if strcmp(method,'modShort')==1
    load modeledShortTemperaturesOct2013.mat

    wtemp=interp1(SSTModel.date, SSTModel.Twater, t);
    
    
end



end