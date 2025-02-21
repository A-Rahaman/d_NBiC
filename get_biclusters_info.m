%% Analyzing the biclusters 
% it extracts the biclusters real data from the sFNC matrix 
% Create diverse stats  
clear
clc
addpath(genpath('NeuroData'))
addpath(genpath('NeuroResults'))

load comm_subs_labels.mat
load biclusters.mat
% 2: HC, 1: SZ
biclusters = struct('subjects',[],'sFNC_pairs',[], 'sFNC_values',[], 'sFNC_matrix',[], 'SZ_sFNC_matrix',[], ...
    'HC_sFNC_matrix',[], 'HC_SZ_diff',[],'SZ_subs', [],'HC_subs', [], 'SZ_sFNC_vals', [], 'HC_sFNC_vals', []);

load sFNC.mat;
data = reshape(sFNC,size(sFNC,1),size(sFNC,2)*size(sFNC,3));


for i = 1:size(bics,1)
    ss = bics(i,:);
    subjects = find(ss==1);
    pp = fcluster(i,:); 
    sFNC_pairs = find(pp ==1); 
    sFNC_values = data(subjects,sFNC_pairs); 
    biclusters(i).subjects = subjects;
    biclusters(i).sFNC_pairs = sFNC_pairs;
    biclusters(i).sFNC_values = sFNC_values;
    sFNC_mat = zeros(1,size(data,2));
    sFNC_mat(1,sFNC_pairs) = mean(sFNC_values);
    biclusters(i).sFNC_matrix = reshape(sFNC_mat,53,53);
    
    % SZ sFNC
    sub_labels = labels(subjects);
    SZ_idx = find(sub_labels == 1);
    SZ_subs = subjects(SZ_idx);
    SZ_sFNC_values = data(SZ_subs,sFNC_pairs);
    SZ_sFNC_mat = zeros(1,size(data,2));
    SZ_sFNC_mat(1,sFNC_pairs) = mean(SZ_sFNC_values);
    biclusters(i).SZ_sFNC_matrix = reshape(SZ_sFNC_mat,53,53);
    biclusters(i).SZ_subs = SZ_subs; 
    biclusters(i).SZ_sFNC_vals = SZ_sFNC_values;


    % HC sFNC
    HC_idx = find(sub_labels == 2);
    HC_subs = subjects(HC_idx);
    HC_sFNC_values = data(HC_subs,sFNC_pairs);
    HC_sFNC_mat = zeros(1,size(data,2));
    HC_sFNC_mat(1,sFNC_pairs) = mean(HC_sFNC_values);
    biclusters(i).HC_sFNC_matrix = reshape(HC_sFNC_mat,53,53);
    biclusters(i).HC_subs = HC_subs; 
    biclusters(i).HC_sFNC_vals = HC_sFNC_values;

    % HC-SZ sFNC diff
    biclusters(i).HC_SZ_diff = biclusters(i).HC_sFNC_matrix - biclusters(i).SZ_sFNC_matrix;

end