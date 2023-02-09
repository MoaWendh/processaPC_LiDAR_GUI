
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% .
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fShowImageAndPC(param)  
    pathBase= param.path.Base;
    pathImage= param.path.ImageFiltrada;
    pathPC= param.path.PCRotacionada;
    
    for (ctPC=param.startPC:param.stopPC)
        close all;
        nameFileImg= sprintf('\\LF%0.4d.png',ctPC);
        fullPathFile= fullfile(pathBase,pathImage, nameFileImg);
        img= imread(fullPathFile);
        
        nameFilePC= sprintf('%0.4d.%s',ctPC,param.ext.PC);
        fullPathFile = fullfile(pathBase,pathPC, nameFilePC);
        pcPlaned= pcread(fullPathFile);
        
        figure;
        subplot(1,2,1);
        imshow(img);
        title('Image');

        subplot(1,2,2);    
        pcshow(pcPlaned);
        title('Plano detectado');
        xlabel('X (m)');
        ylabel('Y (m)');
        zlabel('Z (m)');
    end
end
