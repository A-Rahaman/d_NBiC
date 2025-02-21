%% static FNC
clear
clc
% calculate FNC
[Num_scores,FILE_ID]  = xlsread('domains.xlsx', 'Sheet1', 'A1:K101');
ICN_idx = 10;
temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'SCN'))-1;
ICN_SC = Num_scores(temp_idx,2);

temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'AUD'))-1;
ICN_AD = Num_scores(temp_idx,2);

temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'SMN'))-1;
ICN_SM = Num_scores(temp_idx,2);

temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'VIS'))-1;
ICN_VS = Num_scores(temp_idx,2);

temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'CON'))-1;
ICN_CC = Num_scores(temp_idx,2);

temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'DMN'))-1;
ICN_DM = Num_scores(temp_idx,2);

temp_idx = find(strcmp(FILE_ID(:,ICN_idx),'CER'))-1;
ICN_CB = Num_scores(temp_idx,2);

temp_NAN = find(strcmp(FILE_ID(:,ICN_idx),'NAN'))-1;

select_ICN = [ICN_SC; ICN_AD; ICN_SM; ICN_VS; ICN_CC; ICN_DM; ICN_CB];
domain_ICN  = {ICN_SC, ICN_AD, ICN_SM, ICN_VS, ICN_CC, ICN_DM, ICN_CB};
num_ICN  = length(select_ICN);

%% load FNC data (you can make changes here)
% B = triu(A.',1) + tril(A)  - To make symmetric matrix  
load biclusters.mat
domain_Name = {'SC', 'AD', 'SM', 'VS', 'CO', 'DM', 'CB'};
% The Draw_FC_Domain_update_munna fucntion has been modified to generate gridless figures 
cd output_figures
colorbar_scale = [-max(abs(mean_FNC(:))) max(abs(mean_FNC(:)))];

for i =1:size(biclusters,2)
    
    Draw_FC_Domain(biclusters(i).HC_SZ_diff, domain_Name, domain_ICN, colorbar_scale);
    fig_name = ['HC-SZ_diff_' num2str(i)];
    set(gcf, 'Position',  [100, 100, 250, 250])
    colormap(bluewhitered)
    if(i~=5)
        colorbar('off' )
    end
    set(gcf,'color','w');
    saveas(gcf,[fig_name '.fig'])
    saveas(gcf,[fig_name '.png'])
    close all

    fig_name = ['HC_sFNC_' num2str(i)];
    Draw_FC_Domain(biclusters(i).HC_sFNC_matrix, domain_Name, domain_ICN, colorbar_scale);
    set(gcf, 'Position',  [100, 100, 250, 250])
    colormap(bluewhitered)
    set(gcf,'color','w');
    colorbar('off' )
    saveas(gcf,[fig_name '.fig'])
    saveas(gcf,[fig_name '.png'])
    close all

    fig_name = ['SZ_sFNC_' num2str(i)];
    Draw_FC_Domain(biclusters(i).SZ_sFNC_matrix, domain_Name, domain_ICN, colorbar_scale);
    %colormap(bluewhitered(256)), colorbar
    set(gcf, 'Position',  [100, 100, 250, 250])
    colormap(bluewhitered)
    set(gcf,'color','w');
    colorbar('off' )
    saveas(gcf,[fig_name '.fig'])
    saveas(gcf,[fig_name '.png'])
    close all
end
%%