%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Converte nuvem de pontos do formato .PCAP para o .PCD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fConvPCAP2PCB(param)
clc;
close all;
% Define alguns parâmetros
pathPCL= param.path.Base;

for (i=1:param.numFiles)
    % Faz a laitura de n nuvem de pontos no formato PCAP e converte a cada
    % i iteração.
    ext= 'pcap';
    nameFile= sprintf('%0.4d.%s',i,ext);
    fullPath= fullfile(pathPCL,nameFile);
    ptcPcapObj = velodyneFileReader(fullPath,lidarModel);
    ptcPcap = readFrame(ptcPcapObj);
    
    % Gera o arquivo no formato PCD a cada i iteração.
    ptcPcapAux = pointCloud(reshape(ptcPcap.Location, [],3), 'Intensity',single(reshape(ptcPcap.Intensity, [],1)));
    ext= 'pcd';
    nameFile= sprintf('%0.4d.%s',i,ext);
    fullPath= fullfile(pathPCL,nameFile);
    pcwrite(ptcPcapAux,fullPath,'Encoding','ascii');
end
end
