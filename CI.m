%% Cluster  Index (CI) analaysis
% This script designs the experiments for CI analysis.  
% CI calculation
% We are trying to experiment the cluster as a group of element
% functioning or interacting together. This is is called a fucntional cluster. This cluster of attributes might be associated with cognitive
% activities. We will test it later by checking the correlation with cognitive scores 
% We check the connectednesss of the instances includd in a BIC. Intra connectedness- normalized connectivity (sFNC) 
% within the subpopulation. And Inter connectedness - with rest of the brain 
% The ration of intra/inter conn. is defined as CI
clear
clc
%load data 
% add required paths 
% Assign putput directory 

load comm_subs_labels.mat
CI = struct('components',[],'inter_conn',[],'HC_inter_conn',[], 'SZ_inter_conn',[], 'intra_conn',[], 'SZ_intra_conn',[], ...
    'HC_intra_conn',[], 'overall_CI',[],'HC_CI',[],'SZ_CI',[],'comp_wise_inter_conn',[],'comp_wise_HC_inter_conn',[],'comp_wise_SZ_inter_conn',[], ...
    'HC_sorted_comps',[], 'HC_sorted_conn',[],'SZ_sorted_comps',[], 'SZ_sorted_conn',[], 'comp_wise_intra_conn',[],'comp_wise_HC_intra_conn',[], ...
    'comp_wise_SZ_intra_conn',[],'HC_sorted_comp_names',[],'SZ_sorted_comp_names',[],'HC_sorted_idx',[],'SZ_sorted_idx',[]);

%% Say we have a cluster of 'd' edges connecting unique 'n' nodes.
% sFNC is a graph of E = NC2 connections, N nodes
% We create a undirectional graph of D = nC2 connections - (a subgraph of sFNC)
% We can say 'd' is a subset of 'D'
% Now the intra = mean(d)
% Inter = mean(D-d)
clc
for i = 1:size(biclusters,2)
    
    % Preparing d 
    connections = biclusters(i).sFNC_pairs;
    [unique_pairs,idx] = intersect(connections,lt_indices); 
    intra_conn = mean(abs(biclusters(i).sFNC_values(:)));

    % Create the subsets of unique elements 
    bic_sFNC_matrix = biclusters(i).sFNC_matrix;
    [rows, cols] = find(bic_sFNC_matrix~=0);
    comps = union(rows,cols);
    if(length(unique(rows))>length(unique(cols)))
        dim = 1; % row_wise
    else
        dim = 2; % col_wise 
    end

    % SZ subjects 
    SZ_sFNC_matrix = biclusters(i).SZ_sFNC_matrix;
    SZ_intra_conn = mean(abs(biclusters(i).SZ_sFNC_vals(:)));
    SZ_mean_sFNC_matrix = reshape(mean(sFNC(biclusters(i).SZ_subs,:,:),1),[size(sFNC,2),size(sFNC,3)]); % all pairs
    
    % HC subjects 
    HC_sFNC_matrix = biclusters(i).HC_sFNC_matrix;
    HC_intra_conn = mean(abs(biclusters(i).HC_sFNC_vals(:)));
    HC_mean_sFNC_matrix = reshape(mean(sFNC(biclusters(i).HC_subs,:,:),1),[size(sFNC,2),size(sFNC,3)]); % all pairs


    % Preparing D and D-d subgraph, SZ D-d, HC D-d
    mean_sub_sFNC = reshape(mean(sFNC(biclusters(i).subjects,:,:),1),[size(sFNC,2),size(sFNC,3)]);
    subgraph_D = [];
    SZ_subgraph_D = [];
    HC_subgraph_D = [];
    comp_wise_inter_conn = [];
    SZ_comp_wise_inter_conn = [];
    HC_comp_wise_inter_conn = [];
    for j = 1:length(comps)
        conn_j = 0;
        HC_conn_j = 0;
        SZ_conn_j = 0;
        counter = 0;
        if dim == 1
            bic_edges = bic_sFNC_matrix(comps(j),:);
            HC_edges = HC_mean_sFNC_matrix(comps(j),:);
            SZ_edges = SZ_mean_sFNC_matrix(comps(j),:);
            all_edges = mean_sub_sFNC(comps(j),:);
        else
            bic_edges = bic_sFNC_matrix(:,comps(j));
            HC_edges = HC_mean_sFNC_matrix(:,comps(j));
            SZ_edges = SZ_mean_sFNC_matrix(:,comps(j));
            all_edges = mean_sub_sFNC(:,comps(j));
        end
        for k = 1:length(bic_edges)   
            % Not in the d graph.Same pairs for the HC and SZ
            if(bic_edges(k)== 0 && comps(j)~=k)    
                conn_j = conn_j + abs(all_edges(k));      % D-d
                HC_conn_j = HC_conn_j + abs(HC_edges(k)); % HC D-d
                SZ_conn_j = SZ_conn_j + abs(SZ_edges(k)); % SZ D-d
                counter = counter+1;
            end
        end
        comp_wise_inter_conn(j) = conn_j/counter;
        HC_comp_wise_inter_conn(j) = HC_conn_j/counter;
        SZ_comp_wise_inter_conn(j) = SZ_conn_j/counter;
    end
    
    % Component wise intra conn 
    comp_wise_intra_conn = [];
    HC_comp_wise_intra_conn = [];
    SZ_comp_wise_intra_conn = [];
    for jj = 1:length(comps)
        if dim == 1
            comp_jj = bic_sFNC_matrix(comps(jj),:);
            HC_edges = HC_sFNC_matrix(comps(jj),:); % Since intra 
            SZ_edges = SZ_sFNC_matrix(comps(jj),:); % sicne intra 
        else
            comp_jj = bic_sFNC_matrix(:,comps(jj));
            HC_edges = HC_sFNC_matrix(:,comps(jj));
            SZ_edges = SZ_sFNC_matrix(:,comps(jj));
        end
        nonzero_idx = find(comp_jj~=0);
        nonzero_cells = comp_jj(nonzero_idx);
        comp_wise_intra_conn(jj) = mean(abs(nonzero_cells));
        HC_comp_wise_intra_conn(jj) = mean(abs(HC_edges(nonzero_idx)));
        SZ_comp_wise_intra_conn(jj) = mean(abs(SZ_edges(nonzero_idx)));
    end
    
    % TAKE ABS VALUES for conn. Since we care about the undirectional connectivity 
    cluster_Index = intra_conn/mean(comp_wise_inter_conn);         % Overall cluster Index
    SZ_cluster_Index = SZ_intra_conn/mean(SZ_comp_wise_inter_conn); 
    HC_cluster_Index = HC_intra_conn/mean(HC_comp_wise_inter_conn);
    
    % Central and pheripheral 

    CI(i).components = comps;
    
    CI(i).inter_conn = mean(comp_wise_inter_conn);
    CI(i).HC_inter_conn = mean(HC_comp_wise_inter_conn);
    CI(i).SZ_inter_conn = mean(SZ_comp_wise_inter_conn);
    
    CI(i).intra_conn = intra_conn;
    CI(i).HC_intra_conn = HC_intra_conn;
    CI(i).SZ_intra_conn = SZ_intra_conn;
    
    CI(i).overall_CI = cluster_Index;
    CI(i).HC_CI = HC_cluster_Index;
    CI(i).SZ_CI = SZ_cluster_Index;

    CI(i).comp_wise_inter_conn = comp_wise_inter_conn;
    CI(i).comp_wise_HC_inter_conn = HC_comp_wise_inter_conn;
    CI(i).comp_wise_SZ_inter_conn = SZ_comp_wise_inter_conn;

    CI(i).comp_wise_intra_conn = comp_wise_intra_conn;
    CI(i).comp_wise_HC_intra_conn = HC_comp_wise_intra_conn;
    CI(i).comp_wise_SZ_intra_conn = SZ_comp_wise_intra_conn;

    % component wise intra connectivity to measure the central and pheripheral elelment   
    [HCconn,Hidx] = sort(CI(i).comp_wise_HC_intra_conn,'descend');
    [SZconn,Zidx] = sort(CI(i).comp_wise_SZ_intra_conn,'descend');
    CI(i).HC_sorted_comps = comps(Hidx);
    CI(i).HC_sorted_idx = Hidx;
    CI(i).SZ_sorted_comps = comps(Zidx);
    CI(i).SZ_sorted_idx = Zidx;
    CI(i).HC_sorted_conn = HCconn;
    CI(i).SZ_sorted_conn = SZconn;
    CI(i).HC_sorted_comp_names = all_components(comps(Hidx)); 
    CI(i).SZ_sorted_comp_names = all_components(comps(Zidx)); 

    fprintf('%d done',i);

end
%%
save('functional_cluster_index.mat','CI');

%%


