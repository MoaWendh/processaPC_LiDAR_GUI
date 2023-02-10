%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles= fReprojetaPcSobreImagem(handles)
clc;
close all;

% Exibe as opções para leitura dos arquivos de imagem e uvem de pontos:
myChoice = questdlg('Continuar com a reprojeção?', ...
	'Confirmação de reprojeção..', ...
	'Sim','Não','Sim');

switch myChoice
    case 'Não'
        return;
    case 'Sim'
        % Caso seja fechada a janel com o "X" a execução da função continuará
        % normalmente.
end    

% Define os paths: 
fullPathFileImage= fullfile(handles.pathToReadImgToReproj, handles.nameFileImgToReproj);
fullPathFilePC= fullfile(handles.pathToReadPcdToReproj, handles.nameFilePcdToReproj);
fullPathFileCalibCam= fullfile(handles.pathToReadFileCalibCam, handles.nameFileCalibCam);
fullPathFileCalibCamLidar= fullfile(handles.pathToReadFileCalibCamLidar, handles.nameFileCalibCamLidar);

% Carrega os dados de transformação LiDAR-Camera:
load(fullPathFileCalibCamLidar);

% Carrega os parâmetros de calibração da câmera:
load(fullPathFileCalibCam);
[filepath, name, ext] = fileparts(handles.nameFileCalibCam);

% Extrai os parãmetros intrínsecos da câmera:
intrinsics = paramsCalibrationL.Intrinsics;

% Efetua a leitura da nuvem depontos de referência. 
pc= pcread(fullPathFilePC);

% Sub amostra a nuvem de pontos:
pcDown = pcdownsample(pc,'gridAverage',0.01);

% Faz a projeção da nuvem depontos sobre a imagem:
% tform=invert(tform);
imPts = projectLidarPointsOnImage(pc, intrinsics, tform);
    
% Carrega imagem:  
image= imread(fullPathFileImage);

% Exibe a projeção dos pontos sobre as imagens: 
f1=figure;
f1.WindowState='maximized';

subplot(1,2,1)
imshow(image);
hold on;
plot(imPts(:,1),imPts(:,2),'.','Color','g');
hold off;
msg= sprintf('Projeção Pontos LiDAR sobre imagem.');
title(msg);

subplot(1,2,2)
pcshow(pc.Location);
title('Nuvem Pontos LiDAR');

end

