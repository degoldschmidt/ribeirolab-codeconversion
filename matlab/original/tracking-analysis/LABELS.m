function [ConditionIndex,Labels_Features4Cond,Labels,LabelsShort] = LABELS(params,FlyDB,LabelsDB,flies_idx)
% LABELS Gives labels of the respective conditions. 
%   [ConditionIndex,rowLabels,colLabels,Labels,LabelsShort] = LABELS(params,FlyDB,LabelsDB)
%   params must have field 'Features4Cond':
%   params.Features4Cond={'MetabState';'Mating'};% {Row,Col}

%% Condition Index
rows_cols_pags=cell(3,1);%Cols, rows, pages
for lentry=1:3
    rows_cols_pags{lentry}=ones(1,length(flies_idx));% When only one row or column%
end

for lentry=1:length(params.Features4Cond)
    rows_cols_pags{lentry}=[FlyDB(flies_idx).(params.Features4Cond{lentry})];
end



cols=unique(rows_cols_pags{1});
rows=unique(rows_cols_pags{2});
pags=unique(rows_cols_pags{3});

%%% Since not all features start with 1, I must transform them so the
%%% Condition Index equation works.
row_n_tmp=nan(1,params.numflies);
col_n_tmp=nan(1,params.numflies);
pag_n_tmp=nan(1,params.numflies);

for lrow=1:length(rows)
    row_n_tmp(rows_cols_pags{2}==rows(lrow))=lrow;
end
for lcol=1:length(cols)
    col_n_tmp(rows_cols_pags{1}==cols(lcol))=lcol;
end
for lpag=1:length(pags)
    pag_n_tmp(rows_cols_pags{3}==pags(lpag))=lpag;
end


ConditionIndex=numel(cols).*row_n_tmp-numel(cols)+col_n_tmp+(numel(cols)*numel(rows))*(pag_n_tmp-1);
%% Labels
Labels=cell(numel(rows)*numel(cols)*numel(pags),1);
LabelsShort=cell(numel(rows)*numel(cols)*numel(pags),1);

%%% Filling the  missing entries
Labels_Features4Cond=cell(3,1);
for lentry=1:length(params.Features4Cond)
    Labels_Features4Cond{lentry}=LabelsDB.(params.Features4Cond{lentry}){2};
    display(Labels_Features4Cond{lentry})
end

if length(params.Features4Cond)<3
    for lentry=length(params.Features4Cond)+1:3
        Labels_Features4Cond{lentry}=cell(1,1);
    end
end

for m=1:numel(rows)
    for n=1:numel(cols)
        for p=1:numel(pags)
            cond=numel(cols)*m-numel(cols)+n+(numel(cols)*numel(rows))*(p-1);
            Labels{cond,1}= [Labels_Features4Cond{1}{n} ' ',...
                Labels_Features4Cond{2}{m} ', ',...
                Labels_Features4Cond{3}{p},...
                ' n=' num2str(sum(ConditionIndex==cond))];
            if numel(pags)>1
                LabelsShort{cond,1}=  [Labels_Features4Cond{1}{n} ' ',...
                    Labels_Features4Cond{2}{m} ' ',...
                    Labels_Features4Cond{3}{p}];
            else
                LabelsShort{cond,1}=  [Labels_Features4Cond{1}{n} ' ',...
                    Labels_Features4Cond{2}{m}];
            end
        end
    end
end
display(Labels)
