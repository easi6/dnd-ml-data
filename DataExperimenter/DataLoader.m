%% Data Loader
% Load data and save it as "data_set.mat". Some useful information shall be
% printed.

clc;
clear;
close;

%% CAUTION
% Following assumes there exists data in './data' folder
% Inside the './data' folder, there exist folders named after user id.
% Inside each user's directory, logdata files reside.
%
% This structure can be constructed by '> gzip -rd' option, after
% extracting [data_set].tar.gz file and merging down useless hierarchy of
% folders.
%
% Alternatively, you can download tar.gz in ./data and execute the script
% 'extract.plx'

%% DB Connection
db = DBHelper;

%% Import Subjects
sbj_list = dir('data/*');
sbj_list = struct2cell(sbj_list);
sbj_list = sbj_list(1,cell2mat(sbj_list(4,:)) == 1);
exc_list = [];
for i=1:length(sbj_list)
    if ~isempty(regexp(sbj_list{i}, '(^\.\.?$|\.gz$|\.mat$|\.plx$)', 'once'))
        exc_list = [exc_list, i];
    end
end
sbj_list(exc_list) = [];

dup_cnt = 0;
new_cnt = 0;
skip_cnt = 0;
for sbj_idx = 1:length(sbj_list) % For every subject
    sbj_name = sbj_list{sbj_idx};
    %% Import data 

    data_list = dir(fullfile('data', sbj_name));
    data_list = struct2cell(data_list);
    data_list = data_list(1,:);
    exc_list = [];
    for i=1:length(data_list)
        if ~isempty(regexp(data_list{i}, '(^\.\.?$|\.gz$|\.mat$|\.plx$)', 'once'))
            exc_list = [exc_list, i];
        end
    end
    data_list(exc_list) = [];
    
%     data_set = cellfun(@(x) dlmread(fullfile('data', sbj_name, x)), data_list, 'UniformOutput', false);
    %% Create Data objects

    for data_idx = 1:length(data_list) % For every data
        dat_name = data_list{data_idx};
        path = fullfile('data', sbj_name, dat_name);
        info = dir(path);
        
        if info.bytes == 0 % Skip zero byte files
            fprintf('Skipping "%s: %s" ... Skip\n', sbj_name, dat_name);
            skip_cnt = skip_cnt + 1;
            continue;
        end
        fprintf('Creating "%s: %s" ... ', sbj_name, dat_name);
        
        % Read File
        try
            data_val = dlmread(path);
        catch err
            fprintf('WARNING: badly formatte5d file\n');
            continue;
        end
        
        % Duplicate Check
        sql = ['SELECT * from data WHERE sbj_name="', ...
            sbj_name, '" AND dat_name="' dat_name '";'];
        result = db.query(sql);
        res = result{1};
        if strcmp(res, 'No Data') % No stored data
            clear('Dat');
            try
                Dat = Data(sbj_name, dat_name, data_val, true);
            catch err
                fprintf('GPS Error skipping\n');
                continue;
            end
            save(['data/' sbj_name '/' dat_name '.mat'], 'Dat');
            fprintf('Complete\n');
            new_cnt = new_cnt + 1;
        else
            fprintf('Duplicate\n');
            dup_cnt = dup_cnt + 1;
        end
    end

end

%% Print some info
fprintf('# of Subjects: %d\n', length(sbj_list));
fprintf('# of Total Data: %d (Dup: %d, New: %d)\n', dup_cnt+new_cnt, dup_cnt, new_cnt);
fprintf('# of Skipped Data: %d\n', skip_cnt);
labels = {'Bus', 'Subway', 'Walk', 'Car', 'Bicycle'};
fprintf('%s\t', labels{1:end});
fprintf('\n');
for i=1:5 
    sql = ['SELECT COUNT(*) from data WHERE bat_mean_bat>0 AND len>1000 AND gps_mean_lng < 0 AND trs_maj_trs=' num2str(i) ';'];
    result = db.query(sql);
    fprintf('%d\t', result{1});
end
fprintf('\n');

%% Save
% save('data_set', 'data_set');






