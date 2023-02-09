
function showPointClouds()
%clear;
clc;
close all;

% Define alguns parâmetros
lidarModel= 'VLP16';
pathIMG= 'D:\Moacir\ensaios\lixo\16_11_2022_09_06_23\LiDAR';
pathPC= 'D:\Moacir\ensaios\lixo\16_11_2022_09_06_23\LiDAR\Rotacionada';
startFile= 1;
stopFile= 23;
plotImgToghter= 0;
denoised= 0;

for (i=startFile:stopFile)   
    close all;
    if (plotImgToghter)        
        nameFileImg= sprintf('%0.4d.%s',i,'png');
        fullPathFile= fullfile(pathIMG, nameFileImg);
        img= imread(fullPathFile);

        figure;
        nameFile= sprintf('%0.4d.pcd',i);
        fullPathFile = fullfile(pathPC,nameFile);
        %figure;
        % Faz a leitura da i-ésima nuvem de ponto de 2 até numFiles 
        ptCloud = pcread(fullPathFile);  
        subplot(1,2,1);
        imshow(img);
        subplot(1,2,2);
        pcshow(ptCloud, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
        a=0;
    else
        if (denoised)
            figure;
            nameFile= sprintf('%0.4d.pcd',i);
            fullPathFile = fullfile(pathPC,nameFile);
            ptCloud = pcread(fullPathFile); 
            pcDenoised = pcdenoise(ptCloud,  'NumNeighbors', 100, 'Threshold' , 0.0001);
            subplot(1,2,1);
            pcshow(ptCloud, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
            subplot(1,2,2);
            pcshow(pcDenoised, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');            
            a=0; 
        else
            figure;
            nameFile= sprintf('%0.4d.pcd',i);
            fullPathFile = fullfile(pathPC,nameFile);
            ptCloud = pcread(fullPathFile);
            pcshow(ptCloud, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
            a=0; 
        end
    end
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end
end
 
 


