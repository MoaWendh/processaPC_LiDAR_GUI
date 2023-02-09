%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Conjunto de rotinas para tratar as nuvens de pontos do LiDAR.
%
% S�o definidas 4 rotinas:
% 1�) Rotacionar: a nuvem de pontos poder� ser rotacionada em fun��o dos 
% �ngulos de rota��o de cada eixo coordenado. Por exemplo, o LiDAR poder� estar
% em 90� com rela��o � c�mera, assim, basta rotacionar o eixo Y.
% 2�) Clusterizar: para segmentar uma regi�o de interesse, por exemplo o plano
% do tabuleiro de xadrez para posterior calibra��o cruzada LiDAR x c�mera.
% 3�) Planifica: depois de segmentada, a regi�o de interesse poder� ser
% planificada, no caso do tabuleiro de xadrez, por exemplo.
% 4�) Reprojetar: significa reprojetar os potos 3D do LiDAR sobre uma imagem
% 
% Obs.: O frame da nuvem de pontos do LiDAR tem que ser rotacionada para ajustar ao 
% frame da c�mera. Considerar tamb�m que o LiDAR quando usado com a c�mera
% o seu frame � rotacionado de 90�, para as linhas lasers varrerem a imagem
% verticalmente. Assim, para ajustar o frame do LiDAR ao frame da c�mera, o
% mesmo dever� ter o eixo Y rotacionado de -90� 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;
% pathOpenWindo= 'D:\Moacir\ensaios';
% param.pathBase= uigetdir(pathOpenWindo,'Entre com o path para as imagens:');

% Par�metros que define os paths:
param.path.Base= 'D:\Moacir\ensaios\lixo\16_11_2022_09_06_23';
param.path.CalibCam= 'D:\Moacir\ensaios\Calibra��o\Estereo\12_11_2022_A\out';
param.path.CalibCamLidar= 'D:\Moacir\ensaios\Calibra��o\LiDAR_Camera\12_11_2022_A\out';
param.path.Image= '\Camera\L\';
param.path.ImageFiltrada= '\Camera\L\LF';
param.path.ImageROI= '\Camera\L\ROI';
param.path.ImageUndistorted= '\Camera\L\Undistorted';
param.path.PC= '\LiDAR\';
param.path.PCRotacionada= '\LiDAR\Rotacionada\';
param.path.PCDenoised= '\LiDAR\Denoised\';
param.path.PCSegmentada= '\LiDAR\Segmentada\';
param.path.PCPlaneAdjusted= '\LiDAR\PlanoAjustada\';

% Par�metros gerais:
param.name.FileCalCamBouguet= '\Calib_ResultsL.mat';  
param.name.FileCalCamMatlab= '\paramsCalibrationL.mat';  
param.name.FileCalCamLidar= 'tform.mat';
param.name.UseCalibNative= 1;
param.ext.PC= 'pcd';
param.ext.Image= 'png';
param.lidarModel= 'VLP16';
param.startPC= 1;
param.stopPC= 23;

% Par�metros que habilitam as rotinas:
param.hab.Rotacionar = 1; % Rotaciona nuvem de pontos do LiDAR.
param.hab.Filtrar    = 0; % Segmenta nuvem de pontos do LiDAR.
param.hab.Segmentar  = 1; % Segmenta nuvem de pontos do LiDAR.
param.hab.Planificar = 0; % Planifica nuvem de pontos do LiDAR.
param.hab.Reprojetar = 0; % Reprojeta a nuvem de pontos do LiDAr sobre a imagem.

% Par�metros que habilitam plotar as nuvens de pontos:
param.show.Rotated          = 0;
param.show.Denoised         = 0;
param.show.ResultSegmented  = 1;
param.show.Segmented        = 0;
param.show.Planed           = 0;
param.show.ImageAndPCPlaned = 0;

% *************Par�metros para rotacionar:
% Para ajustar o frame do LiDAR ao frame da c�mera, mesmo dever� ter o 
% eixo Y rotacionado de -90�: 
% param.rot= [0 -pi/2 0]; % Define os �ngulos de rota��o.
param.rot= [0 pi/2 0]; % Define os �ngulos de rota��o.
param.trans= [0 0 0]; % Define a transla��o.

%*************Par�metros para filtragem:
% O par�metros numNeighbors usado para estimar a dist�ncia m�dia aos vizinhos
% para de todos os pontos. Diminuir este valor torna o filtro mais sens�vel ao ru�do. 
% Aumentar esse valor aumenta o custo computacional.
param.numNeighbors= 100;
% thresHold serve para inferir os outliers, se a dist�ncia m�dia de um ponto 
% com rela��o aos seus vizzinhos mais pr�ximos for acima do limite especificado, 
% este ponto ser� considerado outlier e filtrado.
param.thresHold= 0.001;

%*************Par�metros para segmenta��o:
% "param.mimDistance" define a dist�ncia euclidiana m�xima que dois pontos
% devem ter para pertencer a um mesmo cluster. Assim, se a dist. Euclidiana
% entre dois pontos for inferior a "param.minDistance" eles pertencem ao
% mesmo cluster.
param.minDistance= 0.17; %0.16; %0.2; %0.17;
% Este par�metro "param.minPoints" informa o n�mero m�nimo de pontos que um cluster
% deve ter para que seja considerado um cluster.
param.minPoints= 150;

%*************Par�metros para ajustar plano:
param.maxDistance= 0.02;
% Prefer�nicial na dire��o da coordenada Z:
param.referenceVector= [0,0,1];
param.maxAngularDistance= 5;

% Chama as fun��es para tratar as nuvens de pontos:
if (param.hab.Rotacionar) 
    fRotacionaPC(param);
end

% Chama as fun��es para filtrar PC:
if (param.hab.Filtrar)
    fDenoisedPC(param);
end

% Chama as fun��es para segmentar as nuvens de pontos:
if (param.hab.Segmentar) 
    fSegmentaPC(param);
end

% Chama as fun��es para planificar, filtrar, as nuvens de pontos:
if (param.hab.Planificar)
    fAjustaPlanoPC(param);
end

% Verifica o resultado da reproje��o da pcl na imagem:
% Executar s� depois que o LiDAR e a c�mera est�o calibrados!!
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



