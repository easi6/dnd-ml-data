%% Data Class
% Data class handles everything to do with data.

classdef Data < handle
    properties (Access=public)
        meta;
        data;
        len;
        
        time;
        gps;
        acc;
        mag;
        trs;
        bat;
    end
    
    methods (Access=public,Static)
        function timevec = unix2read(val)
            unix_offset = cdflib.computeEpoch([1970 1 1 0 0 0 0]);
            timevec = cdflib.epochBreakdown(val*1000+unix_offset)'; 
        end
        
    end
    
    methods (Access=public)
        function obj = Data(sbj_name, dat_name, data, tf)
            obj.meta.sbj_name = sbj_name;
            obj.meta.dat_name = dat_name;
                         
            % transit labels start from 1 
            data(:,13) = data(:,13) + 1;
            
            obj.data = data;

            obj.calc_info();
            if nargin > 3
                obj.db_insert();
            end
        end
                
        function calc_info(obj)
            

            % Meta info
            obj.len = size(obj.data,1);

            % Time info
            obj.time.time = obj.data(:,1);

            unix_offset = cdflib.computeEpoch([1970 1 1 0 0 0 0]);

            timevec = cdflib.epochBreakdown(obj.data(1,1)*1000+unix_offset);
            obj.time.start = datestr(timevec(1:end-1)');

            timevec = cdflib.epochBreakdown(obj.data(end,1)*1000+unix_offset);
            obj.time.end = datestr(timevec(1:end-1)');

            obj.time.duration = obj.data(end,1)-obj.data(1,1);

            % GPS
            obj.gps.gps = obj.data(:,2:3);
            obj.gps.mean_lat = mean(obj.gps.gps(:,2));
            obj.gps.mean_lng = mean(obj.gps.gps(:,1));
            drop_num = sum(obj.data(:,4)==0);
            obj.gps.drop_rate = 100*drop_num/obj.len;

            % Acc
            obj.acc.acc = obj.data(:,5:7);
            obj.acc.abs_acc = cellfun( @(x) norm(x,2), ...
                mat2cell(obj.acc.acc, ones(obj.len,1)) );
            obj.acc.mean_acc = mean(obj.acc.abs_acc);
            
            % Mag
            obj.mag.mag = obj.data(:,8:10);
            obj.mag.abs_mag = cellfun( @(x) norm(x,2), ...
                mat2cell(obj.mag.mag, ones(obj.len,1)) );
            obj.mag.mean_mag = mean(obj.mag.abs_mag);
            
            % Bat
            obj.bat.bat = obj.data(:,12);
            obj.bat.mean_bat = mean(obj.bat.bat);
            
            % Transit
            obj.trs.trs = obj.data(:,13);
            obj.trs.chg_idx = [];
            
            obj.trs.chg_trs = [];
            
            trs = -1;
            obj.trs.trs_list = {'Bus', 'Subway', 'Walk/Run', 'Car/Taxi', 'Bicycle'};
            for i=1:obj.len
                if trs ~= obj.data(i,13)
                    trs = obj.data(i,13);
                    obj.trs.chg_idx = [obj.trs.chg_idx i];
                    obj.trs.chg_trs = [obj.trs.chg_trs trs];
                end
            end
            [cnt tmp] = hist(obj.trs.trs, 1:length(obj.trs.trs_list));
            [tmp, obj.trs.maj_trs] = max(cnt);

        end % End of function "calc_info"
        
        function db_insert(obj)
            names = {
                'sbj_name';
                'dat_name';
                'len';
                'time_start';
                'gps_mean_lat';
                'gps_mean_lng';
                'gps_drop_rate';
                'acc_mean_acc';
                'mag_mean_mag';
                'bat_mean_bat';
                'trs_maj_trs';
            };
            vals = {
                ['"' obj.meta.sbj_name '"'];
                ['"' obj.meta.dat_name '"'];
                num2str(obj.len);
                num2str(obj.time.time(1));
                num2str(obj.gps.mean_lat);
                num2str(obj.gps.mean_lng);
                num2str(obj.gps.drop_rate);
                num2str(obj.acc.mean_acc);
                num2str(obj.mag.mean_mag);
                num2str(obj.bat.mean_bat);
                num2str(obj.trs.maj_trs)
                };
            sql = ['INSERT INTO data (', ...
                sprintf('%s,', names{1:end-1}), names{end}, ') VALUES(', ...
                sprintf('%s,', vals{1:end-1}), vals{end}, ');'];
            db = DBHelper;
            db.query(sql);
        end
        
        function print_info(obj)
            fprintf('\n\n');
            % Meta info
            fprintf('--------------------------------\n');
            fprintf('User ID = %s\n', obj.meta.sbj_name);
            fprintf('Data ID = %s\n', obj.meta.dat_name);
            fprintf('Num of Rows = %d\n', obj.len);

            % Time info
            fprintf('--------------------------------\n');
            fprintf('Record Start = \t%s\n', obj.time.start);
            fprintf('Record End = \t%s\n', obj.time.end);
            fprintf('Duration = %f s\n', obj.time.duration);

            % GPS
            fprintf('--------------------------------\n');
            fprintf('Mean Lat = %f\n', obj.gps.mean_lat);
            fprintf('Mean Lng = %f\n', obj.gps.mean_lng);
            fprintf('Unique Vals = %f\n', size(unique(obj.gps.gps, 'rows'), 1))
            drop_num = sum(obj.data(:,4)==0);
            fprintf('GPS Drop rate = %f%% (%d/%d)\n', obj.gps.drop_rate, drop_num, obj.len);

            % Acc
            fprintf('--------------------------------\n');
            fprintf('Mean Acc = %f\n', obj.acc.mean_acc);
            
            % Mag
            fprintf('--------------------------------\n');
            fprintf('Mean Mag = %f\n', obj.mag.mean_mag);
            
            % Bat
            fprintf('--------------------------------\n');
            fprintf('Mean Bat = %f%%\n', obj.bat.mean_bat);
            
            % Transit
            fprintf('--------------------------------\n');
            fprintf('Transit Mode(Start frm) =');
            for i=1:length(obj.trs.chg_idx)
                chg_idx = obj.trs.chg_idx(i);
                chg_trs = obj.trs.chg_trs(i);
                fprintf('> %s(%d) ', obj.trs.trs_list{chg_trs}, chg_idx);
            end
            fprintf('\n');
            
            fprintf('Major Transit Mode = %s\n', ...
                obj.trs.trs_list{obj.trs.maj_trs});

        end % End of function "print_info"
        
        function make_kml(obj) % Make KML Trajectory
            addpath(genpath('toolbox'));
            gpss = obj.gps.gps;
            gpss(gpss==0) = [];
            gpss = reshape(gpss, [], 2);

            kmlStr = ge_plot(gpss(:,1), gpss(:,2), 'lineColor', '7FFF0000', 'lineWidth', 3);
            ge_output('trip.kml', kmlStr);
            fprintf('FILE:trip.kml is created\n');
            % Now open 'trip.kml' in Google Earth
        end
        
        function gps_plot(obj) % GPS plot
            gpss = obj.gps.gps;

            figure(1);
            clf;
            plot(gpss(:,1), gpss(:,2), 'LineWidth', 3);
            uniq = unique(gpss, 'rows');
            hold on;
            scatter(uniq(:,1), uniq(:,2), 10, 'r');
                
            axis equal;
            title('GPS sequence');
            xlabel('Lng');
            ylabel('Lat');
        end
        
        function acc_abs_plot(obj) % Acc Plot
            figure(3);
            clf;
            
            abs_acc = obj.acc.abs_acc;
            plot(abs_acc);

            chg = obj.trs.chg_idx;
            yL = get(gca,'YLim');
            for i=1:length(chg)
                line([chg(i) chg(i)], yL, 'Color', 'r');
            end

            title('Acc Val');
            xlabel('Frm #');
            ylabel('Acc');

        end
        
        function acc_plot(obj)
            figure(5);
            clf;
            
            hold on;
            plot(obj.acc.acc(:,1), 'r');
            plot(obj.acc.acc(:,2), 'g');
            plot(obj.acc.acc(:,3), 'b');
                        
            title('Acc x,y,z');
            xlabel('Frm #');
            ylabel('Acc');
        end
        
        function acc_fft_plot(obj) % Acc FFT
            figure(4);
            clf;
            fft_step = 100;
            times = obj.time.time;
            abs_acc = obj.acc.abs_acc;
            for i=1:obj.len-fft_step
                clf;
                fft_acc = abs(fft(abs_acc(i:i+fft_step-1)))./fft_step;
                plot(fft_acc);
                axis([0, fft_step, 0, 2]);
                hold on;
                plot(abs_acc(i:i+fft_step-1), 'r');
                text(200,1.9, ['Duration: ', num2str( (times(i,1)-times(1,1))/1 ), ' s'] );
                drawnow;
                pause(0.001);
            end
        end
        
        function vel_plot(obj)
            figure(7);
            gpss = obj.gps.gps;
            vels = (gpss(301:300:end,:)-gpss(1:300:end-300,:))*111111.111;
            abs_vels = sqrt(vels(:,1).^2+vels(:,2).^2)/30;
            plot(abs_vels);
            
            title('Vel, every 30s');
            xlabel('frames');
            ylabel('vel (m/s)');
        end

        
        function dir_plot(obj)
            % Direction
            figure(4);

            mags = obj.mag.mag;
            accs = obj.acc.acc;
            
            fft_step = 300;
            abs_acc = obj.acc.abs_acc;

            gpss = obj.gps.gps;
            h_gps = subplot(2,4,3);
            plot(gpss(:,1), gpss(:,2));
            axis equal;
            
            h_vel = subplot(2,4,4);
            vels = (gpss(401:300:end,:)-gpss(1:300:end-400,:))*111111.111;
            abs_vels = sqrt(vels(:,1).^2+vels(:,2).^2)/30;
            plot(abs_vels);
            
            for frm=1:obj.len-fft_step

                h_acc = subplot(2,4,[5,8]);
                plot(abs_acc);
                yL = get(gca,'YLim');
                line([frm frm], yL, 'Color', 'r');

                h_fft = subplot(2,4,2);
                fft_acc = abs(fft(abs_acc(frm:frm+fft_step-1)))./fft_step;
                plot(fft_acc);
                axis([0, fft_step, 0, 0.2]);
                
%                 h_gps = subplot(2,3,3);
                hold(h_gps, 'on');
                scatter(h_gps, gpss(frm,1), gpss(frm,2), 2, 'r');
                
                h_dir = subplot(2,4,1);
                quiver3(0,0,0,accs(frm,1),accs(frm,2),accs(frm,3), 1/norm(accs(frm,:),2), 'r');
                axis([-1,1,-1,1,-1,1,-1,1]);
                hold on;
                quiver3(0,0,0,mags(frm,1),mags(frm,2),mags(frm,3), 1/norm(mags(frm,:),2), 'b');
            %     axis([-0.1,0.1,-0.1,0.1,-0.1,0.1,-1,1]);
                axis([-1,1,-1,1,-1,1,-1,1]);
                drawnow;
                pause(0.01);
                delete([h_acc h_fft h_dir]);
            end
        end
        
    end
end