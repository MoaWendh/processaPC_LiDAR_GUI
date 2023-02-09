function fShowRotatedPC(param)

clc;
close all;
pathBase= param.path.Base;
pathToReadImg= param.path.Image;
%pathToReadImg= param.path.ImageFiltrada;
pathPC1= param.path.PC;
pathPC2= param.path.PCRotacionada;

for (i=param.startPC:param.stopPC)
    close;
    nameFile= sprintf('%0.4d.%s',i,param.ext.Image);
    fullPathFile = fullfile(pathBase,pathToReadImg, nameFile);
    img = imread(fullPathFile);

    nameFile= sprintf('%0.4d.%s',i,param.ext.PC);
    fullPathFile = fullfile(pathBase,pathPC1, nameFile);
    pc = pcread(fullPathFile);
    
    fullPathFile = fullfile(pathBase,pathPC2, nameFile);
    pcRotated= pcread(fullPathFile);

    figure;
    subplot(2,2,[1 3]);
    imshow(img);
    subplot(2,2,2);
    pcshow(pc);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    subplot(2,2,4);
    pcshow(pcRotated);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end
 
 


