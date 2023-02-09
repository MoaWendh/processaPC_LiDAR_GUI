
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% .
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fShowPlanedPC(param, pcStart, pcStop)

pathBase= param.path.Base;
pathPCSegmented= param.path.PCSegmentada;
pathPCPalneAdjusted= param.path.PCPlaneAdjusted;
pathImage= param.path.Image;

for (ctPC=param.startPC:param.stopPC)
    close;
    nameFileImg= sprintf('%0.4d.%s',ctPC,param.ext.Image);
    fullPathFile= fullfile(pathBase,pathImage, nameFileImg);
    img= imread(fullPathFile);

    nameFile= sprintf('%0.4d.%s',ctPC,param.ext.PC);
    fullPathFile= fullfile(pathBase,pathPCSegmented, nameFile);
    pcSegmented= pcread(fullPathFile);
    
    nameFile= sprintf('%0.4d.%s',ctPC,param.ext.PC);
    fullPathFile= fullfile(pathBase,pathPCPalneAdjusted, nameFile);
    pcPlaneAdjusted= pcread(fullPathFile);
    
    figure;
    subplot(2,2,[1 3]);
    imshow(img);
    title('Image');

    subplot(2,2,2); 
    pcshow(pcSegmented.Location);
    title('PC clustered ');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');

    subplot(2,2,4); 
    pcshow(pcPlaneAdjusted.Location);
    title('PC plane adjusted');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end
end
