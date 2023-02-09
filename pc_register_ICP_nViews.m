%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Registro de 2 nuvens de pontos geradas pelo Velodyne LiDAR VLP-16
% Formato da nuvem de pontos .PCAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

% Define alguns parâmetros
lidarModel= 'VLP16';
pointCloudPath= 'D:\Moacir\ensaios\lixo\16_11_2022_09_06_23\LiDAR\Rotacionada';
ext= 'pcd';
numFiles  = 20;
%gridSize  = 0.15;
gridSize  = 0.10;

%mergeSize = 0.012;
mergeSize = 0.010;

showImage= 1;

for (i=1:(numFiles-1))
    if (i==1)
        % Especifica a nuvem de pontos de referênica a ser lida. Path completo.  
        nameFile= sprintf('%0.4d.%s',i,ext);
        fullPath= fullfile(pointCloudPath,nameFile);
        % Efetua a leitura da nuvem depontos de referência. 
        ptcRef= pcread(fullPath);
        % Filtra o ruído da nuvem de pontos de referência.
        ptcRefDenoise = pcdenoise(ptcRef);
        % Faz uma sub amostragem da nuvem de pontos de referência.
        ptcRefDownSample = pcdownsample(ptcRefDenoise, 'gridAverage', gridSize);

        % Especifica a nuvem de pontos a ser registrada. Path completo. .     
        nameFile= sprintf('%0.4d.%s',i+1,ext);
        fullPath= fullfile(pointCloudPath,nameFile);
        % Efetua a leitura da nuvem depontos a ser registrada.
        ptcMovie= pcread(fullPath);
         % Filtra o ruído da nuvem de pontos a ser registrada.
        ptcMovieDenoise = pcdenoise(ptcMovie);
         % Faz uma sub amostragem da nuvem de pontos.
        ptcMovieDownSample = pcdownsample(ptcMovieDenoise, 'gridAverage', gridSize);
    else
        % A nuvem de pontos de referência passa a ser a nuvem de pontos que foi
        % registrada na iteração anterior.
        ptcRefDenoise= ptcMovieDenoise;
        ptcRefDownSample= ptcMovieDownSample;

        % Especifica a nuvem de pontos a ser registrada. Path completo. 
        nameFile= sprintf('%0.4d.%s',i+1,ext);
        fullPath= fullfile(pointCloudPath,nameFile);
        ptcMovie= pcread(fullPath);
        ptcMovieDenoise = pcdenoise(ptcMovie);
        ptcMovieDownSample = pcdownsample(ptcMovieDenoise, 'gridAverage', gridSize);  
    end

    % Registro das nuvens de pontos amostradas restantes.
    % A função pcregistericp()baseada no algoritmo IC, retorna a trasnformação 
    % do corpo rígido entre as duas nuvens.
    % tform = pcregistericp(ptcMovieDownSample, ptcRefDownSample, 'Metric','pointToPlane','Extrapolate', true);
    tform = pcregistericp(ptcMovieDenoise, ptcRefDenoise, 'Metric','pointToPlane','Extrapolate', true);
    %tform = pcregistericp(ptcMovieDownSample, ptcRefDownSample, 'Metric','pointToPoint','Extrapolate', true);     

    if (i==1)
        accumTform = tform;
    else
        accumTform = affine3d(tform.T * accumTform.T);
    end

    % A função pctransform() registra, alinha, i-ésima nuvem de pontos com 
    % relação a ptcRef, segundo a transformação obtida tform.
    ptcAligned = pctransform(ptcMovieDenoise, accumTform);

    % A função pcmerge, concatena a i-ésima nuvem depontos com a nuvem ptcFull
    % recosntruida a cada iteração.
    if (i==1)
        ptcFull = pcmerge(ptcRefDenoise, ptcAligned, mergeSize);
    else
        ptcFull = pcmerge(ptcFull, ptcAligned, mergeSize);
    end
    
    if (showImage)
        close;
        figure;
        subplot(1,2,1)
        pcshowpair(ptcRef,ptcMovie);
        title('First input image','Color','w')
        xlabel('X (m)')
        ylabel('Y (m)')
        zlabel('Z (m)')

        subplot(1,2,2)
        pcshow(ptcFull, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
        title('Initial world scene')
        xlabel('X (m)')
        ylabel('Y (m)')
        zlabel('Z (m)')
        a=0;
    end
end 

% ESalva a PC registrada.  
nameFile= sprintf('pcReg.%s',ext);
fullPath= fullfile(pointCloudPath,nameFile);
pcwrite(ptcFull,fullPath); 
figure;
ptcFullDenoise = pcdenoise(ptcFull);
pcshow(ptcFullDenoise, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down')
    