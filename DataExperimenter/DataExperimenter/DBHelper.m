classdef DBHelper < handle
    properties (Access=public)
        conn;
        is_octave;
    end
    
    methods (Access=public)
        function obj = DBHelper()
%             javaaddpath('/usr/share/java/mysql.jar');
            obj.is_octave = 0 < exist('OCTAVE_VERSION', 'builtin');
            if obj.is_octave
                
            else
                obj.conn = database('dnd_ml_bts', 'root', '12321', ...
                   'com.mysql.jdbc.Driver', ...
                   'jdbc:mysql://localhost/dnd_ml_bts');
            end
        end
        
        function result = query(obj, sql)
            
            if obj.is_octave
                
            else
                curs = exec(obj.conn, sql);
                curs = fetch(curs);
                result = curs.Data;
            end
            
        end
    end

    
end