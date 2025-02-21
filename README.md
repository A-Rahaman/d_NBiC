## A Deep Biclustering Framework for Brain Network Analysis.  
# Abstract
Functional connectivity (FC) also known as brain network has become the central medium of understanding the human brain
dynamics and a reliable pursuit for brain disorder analysis. The brain operates as a modular unit, with different regions forming
semantically cohesive submodules to execute essential neuronal processing. Identifying these granules can provide insights
into the underlying neurobiological mechanisms. However, these fragments also vary across subjects and are often confined to
smaller subdivisions of the samples. The wide spectrum of neuropsychiatric disease manifestations elevates this variability
further. As such, the diagnosis/prognosis, treatment planning, and interventions are diversified even within a single phenotype
or disease group. Therefore, stratifying both subjects and feature dimensions is indispensable for meaningful knowledge
extraction and post hoc analysis. To perform a shared probing of the neuroimaging dataset, we propose a deep biclustering
framework to discover homogeneous subsets of neural features across a sub-population. The deep neural network (DNN)
leverages semantic locality to preserve coherence in the subgrouped neural patterns and jointly optimizes instance and feature
assignment probability distributions for a novel bicluster retrieval. We ported multiple neuroimaging datasets to our model
for feature learning and biclustering. The framework outperforms state-of-the-art biclustering methods on connectivity data
and the biclusters render more modular and semantically coherent communities in the brain network highlighting significant
neuroscientific relevance. In addition, we design extensive experiments on the submodules to investigate how these connectivity
signatures dictate human brain dynamics in healthy and diseased conditions. The subgroupings demonstrate a significant
association with cognitive/behavioral variables and substantiate the method’s utility in disease subtyping.

# Configurations and navigating the codebase:
It builds the distance matrix using earthe mover distance (EMD) kernel. The training scripts instantiate the models and train for certain epochs untill convergence. The survelieance can be conducted on model loss and fine-tuned by adjusting the hyper-parameters
In the inference phase, store model's weight matrix and activations. Then,  leverage these attributes using inclusion heuristic to quantify the subjects and features associations to build the biclusters.     
 
