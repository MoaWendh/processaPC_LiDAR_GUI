%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Registro de 2 nuvens de pontos geradas pelo Velodyne LiDAR VLP-16
% Formato da nuvem de pontos .PCAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
% Define alguns parâmetros
lidarModel= 'VLP16';
nameFile1 = '0001.pcap';
nameFile2 = '0002.pcap';
gridSize  = 0.1;
mergeSize = 0.015;

% Gera dois objetos nuvens de pontos a paritr de duas NP no formato PCAP: 
ptcObj01 = velodyneFileReader(nameFile1,lidarModel);
ptcObj02 = velodyneFileReader(nameFile2,lidarModel);

% Extrai as duas nuvens de pontos dos dois objetos. A primeira nuvem de
% ponto é tomada com referência, ptCloudRef. 
ptcRef = readFrame(ptcObj01);
ptcCurrent = readFrame(ptcObj02);

% Efetua uma sub-amostragem para reduzir o tamanho da nuvem de pontos, 
% utiliza um critério de redução conforme a especificação do gridSize.
ptcRefDownSample = pcdownsample(ptcRef, 'gridAverage', gridSize);
ptcCurrentDownSample = pcdownsample(ptcCurrent, 'gridAverage', gridSize);

% Registro das duas nuvem de pontos subamostradas.
% A função pcregistericp()baseada no algoritmo IC, retorna a trasnformação 
% do corpo rígido entre as duas nuvens.
tform = pcregistericp(ptcCurrentDownSample, ptcRefDownSample, 'Metric','pointToPlane','Extrapolate', true);

% A função pctransform() registra a segunda nuvem de pontos conforme a 
% transformação obtida tform.
ptcAligned = pctransform(ptcCurrent,tform);

% A função pcmerge, une as duas nuvens de pontos.
ptcFull = pcmerge(ptcRef, ptcAligned, mergeSize);

%pcshow(ptcRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
%hold;
%figure;
%pcshow(ptcFull, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');

% Visualiza a nuvem de referência:
figure;
subplot(2,2,1);
%imshow(ptcRef.Color);
pcshow(ptcRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
title('First input image','Color','b');
drawnow;

% Visualiza a nuvem a ser registrada:
subplot(2,2,3);
%imshow(ptcCurrent.Color);
pcshow(ptcCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
title('Second input image','Color','g');
drawnow;

% Visualiza a nuvem completa.
subplot(2,2,[2,4])
pcshow(ptcFull, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
title('Initial world scene');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
