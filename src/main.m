%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Conjunto de rotinas para tratar as nuvens de pontos do LiDAR.
%
% São definidas 4 rotinas:
% 1º) Rotacionar: a nuvem de pontos poderá ser rotacionada em função dos 
% ângulos de rotação de cada eixo coordenado. Por exemplo, o LiDAR poderá estar
% em 90º com relação à câmera, assim, basta rotacionar o eixo Y.
% 2º) Clusterizar: para segmentar uma região de interesse, por exemplo o plano
% do tabuleiro de xadrez para posterior calibração cruzada LiDAR x câmera.
% 3º) Planifica: depois de segmentada, a região de interesse poderá ser
% planificada, no caso do tabuleiro de xadrez, por exemplo.
% 4º) Reprojetar: significa reprojetar os potos 3D do LiDAR sobre uma imagem
% 
% Obs.: O frame da nuvem de pontos do LiDAR tem que ser rotacionada para ajustar ao 
% frame da câmera. Considerar também que o LiDAR quando usado com a câmera
% o seu frame é rotacionado de 90º, para as linhas lasers varrerem a imagem
% verticalmente. Assim, para ajustar o frame do LiDAR ao frame da câmera, o
% mesmo deverá ter o eixo Y rotacionado de -90º 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;
% pathOpenWindo= 'D:\Moacir\ensaios';
% param.pathBase= uigetdir(pathOpenWindo,'Entre com o path para as imagens:');

% Parâmetros que define os paths:
param.path.Base= 'D:\Moacir\ensaios\lixo\16_11_2022_09_06_23';
param.path.CalibCam= 'D:\Moacir\ensaios\Calibração\Estereo\12_11_2022_A\out';
param.path.CalibCamLidar= 'D:\Moacir\ensaios\Calibração\LiDAR_Camera\12_11_2022_A\out';
param.path.Image= '\Camera\L\';
param.path.ImageFiltrada= '\Camera\L\LF';
param.path.ImageROI= '\Camera\L\ROI';
param.path.ImageUndistorted= '\Camera\L\Undistorted';
param.path.PC= '\LiDAR\';
param.path.PCRotacionada= '\LiDAR\Rotacionada\';
param.path.PCDenoised= '\LiDAR\Denoised\';
param.path.PCSegmentada= '\LiDAR\Segmentada\';
param.path.PCPlaneAdjusted= '\LiDAR\PlanoAjustada\';

% Parâmetros gerais:
param.name.FileCalCamBouguet= '\Calib_ResultsL.mat';  
param.name.FileCalCamMatlab= '\paramsCalibrationL.mat';  
param.name.FileCalCamLidar= 'tform.mat';
param.name.UseCalibNative= 1;
param.ext.PC= 'pcd';
param.ext.Image= 'png';
param.lidarModel= 'VLP16';
param.startPC= 1;
param.stopPC= 23;

% Parâmetros que habilitam as rotinas:
param.hab.Rotacionar = 1; % Rotaciona nuvem de pontos do LiDAR.
param.hab.Filtrar    = 0; % Segmenta nuvem de pontos do LiDAR.
param.hab.Segmentar  = 1; % Segmenta nuvem de pontos do LiDAR.
param.hab.Planificar = 0; % Planifica nuvem de pontos do LiDAR.
param.hab.Reprojetar = 0; % Reprojeta a nuvem de pontos do LiDAr sobre a imagem.

% Parâmetros que habilitam plotar as nuvens de pontos:
param.show.Rotated          = 0;
param.show.Denoised         = 0;
param.show.ResultSegmented  = 1;
param.show.Segmented        = 0;
param.show.Planed           = 0;
param.show.ImageAndPCPlaned = 0;

% *************ParÂmetros para rotacionar:
% Para ajustar o frame do LiDAR ao frame da câmera, mesmo deverá ter o 
% eixo Y rotacionado de -90º: 
% param.rot= [0 -pi/2 0]; % Define os ângulos de rotação.
param.rot= [0 pi/2 0]; % Define os ângulos de rotação.
param.trans= [0 0 0]; % Define a translação.

%*************Parâmetros para filtragem:
% O parâmetros numNeighbors usado para estimar a distância média aos vizinhos
% para de todos os pontos. Diminuir este valor torna o filtro mais sensível ao ruído. 
% Aumentar esse valor aumenta o custo computacional.
param.numNeighbors= 100;
% thresHold serve para inferir os outliers, se a distância média de um ponto 
% com relação aos seus vizzinhos mais próximos for acima do limite especificado, 
% este ponto será considerado outlier e filtrado.
param.thresHold= 0.001;

%*************Parâmetros para segmentação:
% "param.mimDistance" define a distância euclidiana máxima que dois pontos
% devem ter para pertencer a um mesmo cluster. Assim, se a dist. Euclidiana
% entre dois pontos for inferior a "param.minDistance" eles pertencem ao
% mesmo cluster.
param.minDistance= 0.17; %0.16; %0.2; %0.17;
% Este parâmetro "param.minPoints" informa o número mínimo de pontos que um cluster
% deve ter para que seja considerado um cluster.
param.minPoints= 150;

%*************Parâmetros para ajustar plano:
param.maxDistance= 0.02;
% Preferênicial na direção da coordenada Z:
param.referenceVector= [0,0,1];
param.maxAngularDistance= 5;

% Chama as funções para tratar as nuvens de pontos:
if (param.hab.Rotacionar) 
    fRotacionaPC(param);
end

% Chama as funções para filtrar PC:
if (param.hab.Filtrar)
    fDenoisedPC(param);
end

% Chama as funções para segmentar as nuvens de pontos:
if (param.hab.Segmentar) 
    fSegmentaPC(param);
end

% Chama as funções para planificar, filtrar, as nuvens de pontos:
if (param.hab.Planificar)
    fAjustaPlanoPC(param);
end

% Verifica o resultado da reprojeção da pcl na imagem:
% Executar só depois que o LiDAR e a câmera estão calibrados!!
if (param.hab.Reprojetar)
    fReprojetaPcSobreImagem(param);
end

if (param.show.Rotated)
    fShowRotatedPC(param);
end

if (param.show.Denoised)
    fShowDenoisedPC(param);
end

if (param.show.Segmented)
    fShowSegmentedPC(param);
end

if (param.show.Planed)
    fShowPlanedPC(param);
end

if (param.show.ImageAndPCPlaned)
    fShowImageAndPC(param);
end



