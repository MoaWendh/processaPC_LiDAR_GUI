%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles= fReprojetaPcSobreImagem(handles)
clc;
close all;

msg=sprintf('1�- Click Ok para escolher a imagem.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.png');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFileImg pathToReadImg]= uigetfile(path, 'Escolhar a imagem para reproje��o.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sair� desta fun��o
if pathToReadImg== 0 
    handles.msg= sprintf('Escolha da image foi cancelada.');
    msgbox(handles.msg, 'Aten��o!', 'warn');
    return;
end

msg=sprintf('2�- Click Ok para escolher a PC para reproje��o sobre a imagem.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFilePcd pathToReadPcd]= uigetfile(path, 'Escolher a PC que ser� reprojetada.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sair� desta fun��o
if pathToReadPcd== 0 
    handles.msg= sprintf('Escolha da PC foi cancelada.');
    msgbox(handles.msg, 'Aten��o!', 'warn');
    return;
end

msg=sprintf('3�- Click Ok para escolher o arq. de calibra��o da c�mera.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.mat');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFileCalibCam pathToReadFileCalibCam]= uigetfile(path, 'Escolher o arq. de calibra��o da c�mera.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sair� desta fun��o
if pathToReadFileCalibCam== 0 
    handles.msg= sprintf('Escolha do arq. e calibra��o foi cancelada.');
    msgbox(handles.msg, 'Aten��o!', 'warn');
    return;
end

msg=sprintf('4�- Click Ok para escolher o arq. da calibra��o cruzada LiDARx x C�mera.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.mat');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFileCalibaCamLidar pathToReadFileCalibaCamLidar]= uigetfile(path, 'Escolher o arq. de calibra��o cruzada LiDAR x C�merada.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sair� desta fun��o
if pathToReadFileCalibaCamLidar== 0 
    handles.msg= sprintf('Escolha do arq. dcalibra��o LiDAR x C�mera foi cancelada.');
    msgbox(handles.msg, 'Aten��o!', 'warn');
    return;
end

% Define os paths:
fullPathFileImage= fullfile(pathToReadImg, nameFileImg);
fullPathFilePC= fullfile(pathToReadPcd, nameFilePcd);
fullPathFileCalibCam= fullfile(pathToReadFileCalibCam, nameFileCalibCam);
fullPathFileCalibCamLidar= fullfile(pathToReadFileCalibaCamLidar, nameFileCalibaCamLidar);

% Carrega os dados de transforma��o LiDAR-Camera:
load(fullPathFileCalibCamLidar);

% Carrega os par�metros de calibra��o da c�mera:
load(fullPathFileCalibCam);
[filepath, name, ext] = fileparts(nameFileCalibCam);

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

