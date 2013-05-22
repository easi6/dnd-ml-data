clear;

%% Filter
db = DBHelper;
sql = ['SELECT * from data WHERE bat_mean_bat>0 AND ', ...
    'len>1000 AND gps_mean_lng<0;'];
filtered = db.query(sql);
disp(filtered(:,1:2));

num_filtered = size(filtered,1);
fprintf('# of Filtered Data: %d\n', num_filtered);

save('data/FeatureMatrix/DataIndexMappingTable.mat', 'filtered');
%% Extract features
% Columns of the original data
% 1.timestamp, 2.longitude, 3.latitude, 4.gps accuracy, 5.accel.x, 6.accel.y, 7.accel.z, 
% 8.magnet.x, 9.magnet.y, 10.magnet.z, 11.magnet.accuracy, 12.battery(0~1.0), 13.transport method

fft_step=101;
offset=floor(fft_step/2);
    
for idx = 1:num_filtered;
    load(['data/' filtered{idx,1} '/' filtered{idx,2} '.mat']);
    oneDatum = Dat.data;
    sizeDatum = size(oneDatum,1);
    sizeCol = size(oneDatum,2);
    oneFeatureSet = zeros(sizeDatum-2*offset,sizeCol+fft_step);
    
    abs_acc = Dat.acc.abs_acc;
    
    for frm = offset+1 : sizeDatum-offset
        %%Feature 1. FFT of acc
        fft_acc = abs(fft(abs_acc(frm-offset:frm+offset)))./fft_step;
    
        oneFeatureSet(frm-offset,:)=[oneDatum(frm,1:12) fft_acc' oneDatum(frm, 13)];
    end
    
    save(['data/FeatureMatrix/' int2str(idx) '_FeatureSet.mat'], 'oneFeatureSet'); 

end

