
function fShowDenoisedPC(param)
clc;
close all;

pathBase= param.pathBase;
pathToRead1= param.PathPC.Rotacionada;
pathToRead2= param.PathPC.Denoised;

for (i=param.startPC:param.stopPC)   
    close all;
    figure;
    nameFile= sprintf('%0.4d.pcd',i);
    fullPathFile = fullfile(pathBase, pathToRead1, nameFile);
    pcRotated = pcread(fullPathFile);

    nameFile= sprintf('%0.4d.pcd',i);
    fullPathFile = fullfile(pathBase, pathToRead2, nameFile);
    pcDenoised = pcread(fullPathFile);

    subplot(1,2,1);
    pcshow(pcRotated, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
    subplot(1,2,2);
    pcshow(pcDenoised, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');            

    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');    
end
end
 
 


