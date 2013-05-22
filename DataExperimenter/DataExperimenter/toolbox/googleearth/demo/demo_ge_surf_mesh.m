function demo_ge_surf_mesh()%% Demo ge_imagesc


z = peaks(30);
x = linspace(3.5,5.5,size(z,2));
y = linspace(51,52.5,size(z,1));
cLimLow = min(z(:));
cLimHigh = max(z(:));

kmlFileName = 'demo_ge_surf_mesh.kml';

% Ix = 1+round(rand(10,1)*(numel(data)-1));
% data(Ix)=NaN;

output = ge_surf(x,y,z,...
                 'polyAlpha','00',...
                 'lineColor','FF00CCFF',...
                 'lineWidth',0.3,...
                   'cLimLow',cLimLow,...
                  'cLimHigh',cLimHigh,...
                 'vertExagg',5e3,...
               'altRefLevel',2e4,...
                   'extrude',false);

ge_output(kmlFileName,output,...
                'name','&#0039;peaks&#0039; function mesh');
                                           
                                           