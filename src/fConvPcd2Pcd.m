function fConvPcd2Pcd(pcStart, pcStop)
clear;
clc;
close all;
pathBase= 'D:\Moacir\ensaios\Calibração\LiDAR_Camera\27_10_2022_18_51_49';
pathPCD= '\LiDAR\Rotacionada';
pathIMG= '\Camera\L';
pathSavePCD= '\LiDAR\Rotacionada\pcdMatlab';

extPCD= 'pcd';
extIMG= 'png';
pcStart= 1;
pcStop= 18;

for (i=pcStart:pcStop)
    close;
    nameFile= sprintf('\\%0.4d.%s',i,extPCD);
    fullPathFile = fullfile(pathBase,pathPCD,nameFile);
    pt = pcread(fullPathFile);

    nameFile= sprintf('\\L%0.4d.%s',i,extIMG);
    fullPathFile = fullfile(pathBase,pathIMG, nameFile);
    img = imread(fullPathFile); 

    nameFile= sprintf('\\%0.4d.%s',i,extPCD);
    fullPathFile = fullfile(pathBase,pathSavePCD,nameFile);
    pcwrite(pt,fullPathFile)
   
    figure;
    subplot(1,2,1);
    imshow(img);
    subplot(1,2,2);
    pcshow(pt);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end
end
 
 


