function varargout=CumulativeFeedingEventsFig2(Events,Substrate,Mean_Or_Median,labels,Colors,Dur)
varargout{1}=nan;
nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
nCond=nCond(~isnan(nCond));

    for nRows=1:size(Events.Ons,1)
        % get number of events per condition
        for C=nCond
            Ons1{nRows,C}=Events.Ons(nRows,Events.Substrate{nRows}==1&Events.Condition{nRows}==nCond(C));
            Ons2{nRows,C}=Events.Ons(nRows,Events.Substrate{nRows}==2&Events.Condition{nRows}==nCond(C));

            C1N{nRows,C}=cellfun(@numel,Events.Ons(nRows,Events.Substrate{nRows}==1&Events.Condition{nRows}==nCond(C)));
            C2N{nRows,C}=cellfun(@numel,Events.Ons(nRows,Events.Substrate{nRows}==2&Events.Condition{nRows}==nCond(C)));
        end
    end
    
    for n=1:size(C1N,2)
        CSubstr1N{n}=[C1N{:,n}];
    end
    
    for n=1:size(Ons1,2)
        ku=[];
        for m=1:size(Ons1,1)
            ku=[ku Ons1{m,n}];
        end
        
        for nn=1:max(size(ku))
        ONS1{nn,n}=ku{nn};
        end
    end
    
    for n=1:size(Ons2,2)
        ku=[];
        for m=1:size(Ons2,1)
            ku=[ku Ons2{m,n}];
        end
        for nn=1:max(size(ku))
            ONS2{nn,n}=ku{nn};
        end
    end
%     % remove flies that has less than 10 feeding events
%     for n=1:size(ONS2,2)
%         for m=1:size(ONS2,1)
%             if size(ONS2{m,n})<10
%                 ONS2{m,n}=[];
%             end
%         end
%     end
%     
%     for n=1:size(ONS1,2)
%         for m=1:size(ONS1,1)
%             if size(ONS1{m,n})<10
%                 ONS1{m,n}=[];
%             end
%         end
%     end



    
    
if Substrate==2
    clear DUR
    for x=1:size(ONS2,1)
        for y=1:size(ONS2,2)
            DUR{x,y}=Dur;
        end
    end
    output=cellfun(@CumulativeFeeding,ONS2,DUR,'UniformOutput',false);
    
    for n=1:size(output,2)
        puk{n}=cell2mat(output(:,n));
    end
    
    MeanwithPatchflyPAD(puk,labels,1:Dur,Colors,Mean_Or_Median,1000)
    varargout{1}=puk;
elseif Substrate==1
                clear DUR

    for x=1:size(ONS1,1)
        for y=1:size(ONS1,2)
            DUR{x,y}=Dur;
        end
    end
    output=cellfun(@CumulativeFeeding,ONS1,DUR,'UniformOutput',false);
    
    for n=1:size(output,2)
        puk{n}=cell2mat(output(:,n));
    end
    varargout{1}=puk;
    
    MeanwithPatchflyPAD(puk,labels,1:Dur,Colors,Mean_Or_Median,1000)
end

function output=CumulativeFeeding(ONS2,Dur)


% Dur=310000;
if numel(ONS2)<10
  output(1:Dur)=nan;
else
    ONS2(ONS2>Dur)=[];
    
    dummy=false(1,numel(1:Dur));

dummy(ONS2)=1;
output=cumsum(double(dummy));
end