%% Data Tester
% Examine the data

clc;
clear;
clf;
% close all;

%

%% Filter
db = DBHelper;
% sql = ['SELECT * from data WHERE bat_mean_bat>0 AND ', ...
%     'len>1000 AND gps_mean_lng<0 AND trs_maj_trs=4;'];
sql = ['SELECT * from data WHERE bat_mean_bat>0 AND ', ...
    'len>3000 AND gps_mean_lng<0;'];

filtered = db.query(sql);
disp(filtered(:,1:2));

num_filtered = size(filtered,1);
fprintf('# of Filtered Data: %d\n', num_filtered);

%% Choose Record
color = ['r', 'g', 'b', 'k'];
for idx = 1:num_filtered;
    load(['data/' filtered{idx,1} '/' filtered{idx,2} '.mat']);
    figure(1);
    hold on;
    Dat.print_info();
    Dat.gps_plot();
    Dat.acc_abs_plot();
    Dat.acc_plot();
    Dat.vel_plot();
%     Dat.acc_fft_plot();
%     Dat.dir_plot();
%     gps_tf = input('Is gps reliable? ');
%     acc_tf = input('Is acc reliable? ');
%     sql = ['UPDATE data SET gps_reliable=' num2str(gps_tf) ...
%         ',acc_reliable=' num2str(acc_tf) ...
%         ' WHERE sbj_name=''' filtered{idx,1} ''' AND dat_name=''' ...
%         filtered{idx,2} ''';'];
%     db.query(sql);
    pause;
end

%%
% 
% % Direction
% figure(4);
% 
% mags = Dat.mag.mag;
% accs = Dat.acc.acc;
% title('Acc Direction');
% for frm=1:Dat.len

%     clf;
%     subplot(2,2,[3,4]), plot(Dat.acc.abs_acc);
%     yL = get(gca,'YLim');
%     line([frm frm], yL, 'Color', 'r');
% 
% 
%     subplot(2,2,1);
%     quiver3(0,0,0,accs(frm,1),accs(frm,2),accs(frm,3), 1/norm(accs(frm,:),2), 'r');
%     axis([-1,1,-1,1,-1,1,-1,1]);
%     hold on;
%     quiver3(0,0,0,mags(frm,1),mags(frm,2),mags(frm,3), 1/norm(mags(frm,:),2), 'b');
% %     axis([-0.1,0.1,-0.1,0.1,-0.1,0.1,-1,1]);
%     axis([-1,1,-1,1,-1,1,-1,1]);
%     drawnow;
%     pause(0.001);
% end