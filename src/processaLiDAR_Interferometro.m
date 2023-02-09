%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para abrir e registra as nuven de pontos do experimento
% feito no lab do CERTI.
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all

medicoesInterferometro= [ 204.3343 
                          404.3929 
                          604.6028
                          802.4468
                         1007.3131
                         1204.3622
                         1402.9977
                         1600.8074
                         1802.2988
                         2000.7954
                         2206.4818
                         2401.4466
                         2604.4383
                         2801.7304
                         3003.6714];

% Principais parâmetros.
% N é o número de posições onde o LiDAR gerou as nuvens de pontos.

pathBase= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferômetro\experimento_01\pcd';
nameFileBase= '\2022_11_25_01_';
nameFolderBase= '\2022_11_25_01_';
pathValInterferometro= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferômetro\medicoes_interferometro_exp_01.mat';

numFolders= 15;
extPC= 'pcd';
fileIni= 2;
fileEnd= 2;
showPC= 0;
showPCReg= 0;
ctPos= 0;

load(pathValInterferometro);

% Faz a leitura de todas as nuvens de pontos no formato '.pcd'.
for (ctFolder=1:numFolders) 
    pathFolder= sprintf('%s%s%0.4d\\', pathBase, nameFolderBase, ctFolder*200);
    % Verifica os folders
    infoFolder= dir(fullfile(pathFolder, '*.pcd'));
    %¨numFiles= length(infoFolder(not([infoFolder.isdir])));
    for (ctFile=fileIni:fileEnd)
        ctPos= ctPos+1;
        nameFile= sprintf('%s%d_%0.4d.%s', nameFileBase, ctFolder*200, ctFile, extPC);
        fullPathFile = fullfile(pathFolder,nameFile);
        pc{ctFolder,ctFile-fileIni+1}= pcread(fullPathFile);  
        % Filtra o ruído da nuvem de pontos a ser registrada.
        pcDenoised{ctFolder,ctFile-fileIni+1} = pcdenoise(pc{ctFolder,ctFile-fileIni+1});
    end
    if showPC
        close all;
        handle= figure;
        subplot(1,2,1);
        pcshow(pc{ctFolder,ctFile});
        subplot(1,2,2);
        pcshow(pcDenoised{ctFolder,ctFile});
        handle.WindowState='maximized';
    end
end


% Parâmetros para efetuar o downSample da PC
maxNumPoints= 12;
mergeSize   = 0.001;
gridSize    = 0.9;

% Toma a primeira PC como referência.
pcFull= pcDenoised{1,1};

% Faz uma subamostragem.
% pcDownSampleRef= pcdownsample(pcFull, 'gridAverage', gridSize); 
pcDownSampleRef= pcdownsample(pcFull, 'nonuniformGridSample', maxNumPoints);

% Cria uma tranformação neutra
tformAccum= affine3d;

for (ctPC=2:numFolders)
   pcAux= pc{ctPC,1};
   
   % Faz uma sub-amostragem no PC, este procedimento melhora o desempenho
   % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
   % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
   % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
   % 'planeToPlane'. 
   pcDownSample= pcdownsample(pcAux, 'gridAverage', gridSize);
   
   % O parâmetro 'nonuniformGridSample' tem melhor desempenho quando a
   % métrica usada no registro das PC é 'pointToPlane'.
   % pcDownSample= pcdownsample(pcAux, 'nonuniformGridSample', maxNumPoints);
   
   % Calcula a tranformação de corpo rígido.
   tformAux = pcregistericp(pcDownSample, pcDownSampleRef, 'Metric','pointToPlane','Extrapolate', true);
   
   % Acumula a transformação a cada iteração. 
   tformAccum = affine3d(tformAux.T * tformAccum.T);
   
   % Executa o registro, alinhamento das PCs.
   pcAligned = pctransform(pcAux, tformAccum);
   
   % Faz a fusão das PC a cada iteração.
   pcFull = pcmerge(pcFull, pcAligned, mergeSize);
   
   % Armazena o PC atual na variável "pcDownSampleRef" para a próxima
   % iteração.
   pcDownSampleRef= pcDownSample;
   
   % Guarda algumas variáveis para análise posterior:
   tform{ctPC-1}= tformAux; 
   translation(ctPC-1,:)= tformAux.Translation(1,:);
   
   % Exibe o resultado do registro das PCs a cada iteração
   if (showPCReg)
       if (ctPC==2)
           handle= figure;
       end
       pcshow(pcFull);

       title('PCs concatenadas');
       xlabel('X (m)');
       ylabel('Y (m)');
       zlabel('Z (m)');
       handle.WindowState='maximized';
   end  
end

% Análise do registro das PCs:
vetorTranslRef= [0 0 0];

for (ct=1:(numFolders-1))
    vetorTransl= translation(ct,:);
    % Calcula a diferença em "mm" entre os vetores de translação:
    diffVetorTransl(ct,:)= (vetorTransl - vetorTranslRef)*1000; 
    
    % Calcula o módulo do vetor diferença das translações. Se for zero
    % a translação da transformação de corpo rigido foi ideal:
    normDiffVetorTransl(ct)= (norm(diffVetorTransl(ct,:)));
    
    % Determina o deslocamento medido pelo interferômetro para cada
    % posição:
    deslInterferometro(ct)= medicoesInterferometro_exp_01(ct+1)-medicoesInterferometro_exp_01(ct); 
end

figure;
subplot(2,2,1);
a=bar(translation);
xlabel('num PC');
ylabel('mm');
title('Deslocamento do LiDAR: Eixos X, Y e Z pelo Algoritmo Matlab');

subplot(2,2,2);
dataX= [normDiffVetorTransl(1,:); deslInterferometro];
b=bar(dataX);
xlabel('num PC');
ylabel('mm');
title('Deslocamento: Registro PC x Interferêmetro');
b.l

subplot(2,2,[3 4]);
erroX= (deslInterferometro - normDiffVetorTransl(1,:));
c=bar(erroX);

xlabel('num PC');
ylabel('mm');
title('Erro do deslocamento do LiDAR com relação ao Interferômetro - eixo X ');

maxVal=-999;
minVal= 999;
zeroXYZ= [0 0 0];
figure;
for (ct=1:length(diffVetorTransl))  
    if (max(diffVetorTransl(ct,:)) > maxVal)
        maxVal= max(diffVetorTransl(ct,:));
    end
    if (min(diffVetorTransl(ct,:)) < minVal)
        minVal= min(diffVetorTransl(ct,:));
    end
    
    quiver3(zeroXYZ(1),zeroXYZ(2),zeroXYZ(3),diffVetorTransl(ct,1),diffVetorTransl(ct,2),diffVetorTransl(ct,3));
    hold on;
end

xlim([minVal maxVal]);
ylim([minVal maxVal]);
zlim([minVal maxVal]);

xlim([-maxVal maxVal]);
ylim([-maxVal maxVal]);
zlim([-maxVal maxVal]);

