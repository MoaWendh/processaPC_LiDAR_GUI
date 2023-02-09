%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles= fReprojetaPcSobreImagem(handles)
clc;
close all;

msg=sprintf('1º- Click Ok para escolher a imagem.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.png');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFileImg pathToReadImg]= uigetfile(path, 'Escolhar a imagem para reprojeção.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sairá desta função
if pathToReadImg== 0 
    handles.msg= sprintf('Escolha da image foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

msg=sprintf('2º- Click Ok para escolher a PC para reprojeção sobre a imagem.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFilePcd pathToReadPcd]= uigetfile(path, 'Escolher a PC que será reprojetada.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sairá desta função
if pathToReadPcd== 0 
    handles.msg= sprintf('Escolha da PC foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

msg=sprintf('3º- Click Ok para escolher o arq. de calibração da câmera.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.mat');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFileCalibCam pathToReadFileCalibCam]= uigetfile(path, 'Escolher o arq. de calibração da câmera.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sairá desta função
if pathToReadFileCalibCam== 0 
    handles.msg= sprintf('Escolha do arq. e calibração foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

msg=sprintf('4º- Click Ok para escolher o arq. da calibração cruzada LiDARx x Câmera.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.mat');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFileCalibaCamLidar pathToReadFileCalibaCamLidar]= uigetfile(path, 'Escolher o arq. de calibração cruzada LiDAR x Câmerada.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sairá desta função
if pathToReadFileCalibaCamLidar== 0 
    handles.msg= sprintf('Escolha do arq. dcalibração LiDAR x Câmera foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

% Define os paths:
fullPathFileImage= fullfile(pathToReadImg, nameFileImg);
fullPathFilePC= fullfile(pathToReadPcd, nameFilePcd);
fullPathFileCalibCam= fullfile(pathToReadFileCalibCam, nameFileCalibCam);
fullPathFileCalibCamLidar= fullfile(pathToReadFileCalibaCamLidar, nameFileCalibaCamLidar);

% Carrega os dados de transformação LiDAR-Camera:
load(fullPathFileCalibCamLidar);

% Carrega os parâmetros de calibração da câmera:
load(fullPathFileCalibCam);
[filepath, name, ext] = fileparts(nameFileCalibCam);

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

