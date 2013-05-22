numClass = 5;


addpath('toolbox/libsvm-3.14/matlab/');

load('data/FeatureMatrix/DataIndexMappingTable.mat');
numData=size(filtered, 1);
clear filtered;

load('data/FeatureMatrix/1_FeatureSet.mat');
numFeatures=size(oneFeatureSet, 2);
clear oneFeatureSet;

allFeatures=[];
for dataIdx=1:3
    load(['data/FeatureMatrix/' int2str(dataIdx) '_FeatureSet.mat']);
%     label=oneFeatureSet(:,numFeatures);
    allFeatures=[allFeatures; oneFeatureSet];
    
    
end

model=svmtrain(allFeatures(:,114),allFeatures(:,14:113));

load('data/FeatureMatrix/4_FeatureSet.mat');
[a,b,c]=svmpredict(oneFeatureSet(:, 114),oneFeatureSet(:,14:113),model);