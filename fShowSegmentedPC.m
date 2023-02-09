
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fShowSegmentedPC(param)
clc;
close all;

pathBase= param.path.Base;
pathToRead= param.path.PCSegmentada; 
%pathImage= param.path.Image;
pathImage= param.path.ImageFiltrada;

for (i=param.startPC:param.stopPC)
    close all;
    % Exibe imagem com PC
    nameFileImg= sprintf('%0.4d.%s',i,param.ext.Image);
    fullPathFile= fullfile(pathBase,pathImage, nameFileImg);
    img= imread(fullPathFile);

    % Especifica a nuvem de pontos de referênica a ser lida. Path completo.  
    nameFile= sprintf('%0.4d.%s',i,param.ext.PC);
    fullPath= fullfile(pathBase,pathToRead,nameFile);
    % Efetua a leitura da nuvem depontos de referência. 
    pc= pcread(fullPath);

    figure;
    subplot(1,2,1);
    imshow(img);
    title('Image');

    subplot(1,2,2); 
    pcshow(pc.Location);
    title('PC clustered');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end
end
