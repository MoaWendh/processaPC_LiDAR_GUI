%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles= fReprojetaPcSobreImagem(handles)
clc;
close all;

% Exibe as op��es para leitura dos arquivos de imagem e uvem de pontos:
myChoice = questdlg('Continuar com a reproje��o?', ...
	'Confirma��o de reproje��o..', ...
	'Sim','N�o','Sim');

switch myChoice
    case 'N�o'
        return;
    case 'Sim'
        % Caso seja fechada a janel com o "X" a execu��o da fun��o continuar�
        % normalmente.
end    

% Define os paths: 
fullPathFileImage= fullfile(handles.pathToReadImgToReproj, handles.nameFileImgToReproj);
fullPathFilePC= fullfile(handles.pathToReadPcdToReproj, handles.nameFilePcdToReproj);
fullPathFileCalibCam= fullfile(handles.pathToReadFileCalibCam, handles.nameFileCalibCam);
fullPathFileCalibCamLidar= fullfile(handles.pathToReadFileCalibCamLidar, handles.nameFileCalibCamLidar);

% Carrega os dados de transforma��o LiDAR-Camera:
load(fullPathFileCalibCamLidar);

% Carrega os par�metros de calibra��o da c�mera:
load(fullPathFileCalibCam);
[filepath, name, ext] = fileparts(handles.nameFileCalibCam);

% Extrai os par�metros intr�nsecos da c�mera:
intrinsics = paramsCalibrationL.Intrinsics;

% Efetua a leitura da nuvem depontos de refer�ncia. 
pc= pcread(fullPathFilePC);

% Sub amostra a nuvem de pontos:
pcDown = pcdownsample(pc,'gridAverage',0.01);

% Faz a proje��o da nuvem depontos sobre a imagem:
% tform=invert(tform);
imPts = projectLidarPointsOnImage(pc, intrinsics, tform);
    
% Carrega imagem:  
image= imread(fullPathFileImage);

% Exibe a proje��o dos pontos sobre as imagens: 
f1=figure;
f1.WindowState='maximized';

subplot(1,2,1)
imshow(image);
hold on;
plot(imPts(:,1),imPts(:,2),'.','Color','g');
hold off;
msg= sprintf('Proje��o Pontos LiDAR sobre imagem.');
title(msg);

subplot(1,2,2)
pcshow(pc.Location);
title('Nuvem Pontos LiDAR');

end

