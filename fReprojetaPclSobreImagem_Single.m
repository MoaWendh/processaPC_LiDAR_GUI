%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fReprojetaPclSobreImagem_Single()

clear;
clc;
close all;
numImages=3;
% Define alguns par�metros:
pathBase= 'D:\Moacir\ensaios\LiDAR_Estereo\Plano\28_10_2022_A\ComFiltro';
pathImage= '\Camera\L\LF';
pathImageUndistorted= '\Camera\L\Undistorted';

pointCloudPath= '\LiDAR\Rotacionada';
%pointCloudPath= param.PathToSavePclPlanAdjusted;
pathCalibFiles= '\Calibracao';
imageExt= 'png';
pclExt= 'pcd';

% Carrega os dados de transforma��o LiDAR-Camera:
nameFileTform= 'tform_LiDAR_CameraCalibration.mat';
fullPath= fullfile(pathBase, pathCalibFiles, nameFileTform);
tformCell= load(fullPath);
% Extrai a matriz de transforma��o:
tform= tformCell.tform;

% Carrega os par�metros de calibra��o da c�mera:
nameFileCalCam= 'cameraParamsCalibrationL.mat';
fullPath= fullfile(pathBase,pathCalibFiles, nameFileCalCam);
load(fullPath);
intrinsics = a.Intrinsics;

% Para exibir a proje��o sobre as imagens com distor��o e sem distor��o:
% ativar: ExibeProjecaoComDistorcao= 1.
% Para exibir a proje��o apenas sobre a imagem corrigida:
% desativar: ExibeProjecaoComDistorcao=0. 
ExibeProjecaoComDistorcao= 1;

for (i=1:numImages)
    close all;
    % Carrega imagem filtrada:.  
    nameFileImage= sprintf('LF%0.4d.%s', i, imageExt);
    fullPath= fullfile(pathBase,pathImage, nameFileImage);
    image= imread(fullPath);
    imageUndistorted= undistortImage(image,intrinsics,'OutputView','full');
    % Carrega a imagem com distor��o corrigida:  
    nameFileImage= sprintf('LU%0.4d.%s', i, imageExt);
    fullPath= fullfile(pathBase,pathImageUndistorted, nameFileImage);
    imwrite(imageUndistorted, fullPath);
    
    % Especifica a nuvem de pontos de refer�nica a ser lida. Path completo.  
    nameFile= sprintf('%0.4d.%s',i,pclExt);
    fullPath= fullfile(pathBase,pointCloudPath,nameFile);
    % Efetua a leitura da nuvem depontos de refer�ncia. 
    pc= pcread(fullPath);
    % Sub amostra a nuvem de pontos:
    pcDown = pcdownsample(pc,'gridAverage',0.01);
    
    % Faz a proje��o da nuvem depontos sobre a imagem:
    tformInv=invert(tform);
    imPts = projectLidarPointsOnImage(pc,intrinsics,tform);
    
    % Exibe a proje��o dos pontos sobre as imagens com e sem distor��o
    % apenas para verificar visualmente a diferen�a: 
    if (ExibeProjecaoComDistorcao)
        f1=figure;
        f1.WindowState='maximized';
        subplot(1,2,1)
        imshow(image);
        hold on;
        plot(imPts(:,1),imPts(:,2),'.','Color','r');
        hold off;
        msg= sprintf('Proje��o Pontos LiDAR sobre imagem %d "com" distor��o',i);
        title(msg);
        
        subplot(1,2,2)
        imshow(imageUndistorted);
        hold on;
        plot(imPts(:,1),imPts(:,2),'.','Color','r');
        hold off; 
        msg= sprintf('Proje��o Pontos LiDAR sobre imagem %d "sem" distor��o',i);
        title(msg);  
    else    
    % Exibe a proje��o dos pontos sobre a imagem com a distor��o corrigida, 
    % a nuvem de pontos do LiDAR e a imagem:
        f1=figure;
        f1.WindowState='maximized';
        subplot(2,2,1);
        imshow(imageUndistorted);  
        title('Imagem com distor��o corrigida');
    
        subplot(2,2,3);
        pcshow(pc.Location);
        title('Nuvem Pontos LiDAR');
        
        subplot(2,2,[2 4]);
        imshow(imageUndistorted);
        hold on;
        plot(imPts(:,1),imPts(:,2),'.','Color','g');
        hold off; 
        title('Proje��o Pontos LiDAR sobre imagem');
    end
    a=0;
end
end

