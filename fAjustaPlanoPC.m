
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcfitplane()" para eliminar os outliers da nuvem de pontos
% segmentada. Este procedimento refina a segmenta��o da PC quando esta segmenta 
% uma regi�o que contenha um plano.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fAjustaPlanoPC(handles)
clc;
close all;

msg=sprintf('1�- Click Ok para escolher as PCs para ajuste de plano.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFiles pathToRead]= uigetfile(path, 'Escolhas as PCs que ser�o plano ajustadas.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sair� desta fun��o
if pathToRead== 0 
    handles.msg= sprintf('Escolha das PCs foi cancelada.');
    msgbox(handles.msg, 'Aten��o!', 'warn');
    return;
end

% S� abre o di�logo para gerar o path se est� fun��o estiver habilitada. 
% Ver a op��o "Salva PC plano ajustada" no GUI.
if (handles.HabSavePcPlanoAjustada)
    msg=sprintf('2�- Click Ok para escolher o folder onde as PCs ajustadas ser�o salvas.');
    figMsg= msgbox(msg);
    uiwait(figMsg); 

    % Abre tela para escolher o folder onde as PCs ser�o salvas:
    pathToSave= uigetdir(pathToRead, 'Escolha o folder onde as PCs segmentadas ser�o salvas.');

    % Se a escolha do path onde as PCs ser�o salvas for cancelada o programa sair� desta fun��o
    if pathToSave== 0 
        handles.msg= sprintf('Escolha do folder para salvar as PCs foi cancelada.');
        msgbox(handles.msg, 'Aten��o!', 'warn');
        return;
    end
    
    % Define o path omnde ser�o salvas as PCs segmentadas:
    fullPathToSave= fullfile(pathToSave, handles.path.PCPlanoAdjustada); 
    
    % Se o folder onde ser�o salvas as PCs n�o existir ele ser� criado:
    if ~(isfolder(fullPathToSave))
        mkdir(fullPathToSave); 
    end
end


if iscell(nameFiles)
    numPCs= length(nameFiles);
else
    numPCs= 1;
end

% Define os par�metros utilziados para o ajuste de plano:
% O par�metro "maxDistance" define a dist�nica m�xima que um ponto deve ter 
% do plano para ser considerado um inlier, se a dist�nica for maior este ponto 
% ser� um outlier. 
maxDistance= str2double(handles.editDistanciaMaxPontoPlano.String);

% O par�metro "vetorRestricaoDeOrientacao" restringe a dire��o para an�lise
% e � utilziado conjuuntamente com o par�metro "maxDistAngular".
vetorRestricaoDeOrientacao= str2num(handles.editVetorDeRestricaoDeOrientacao.String);

% O par�metro "maxDistAngular" define a dist�ncia angular m�xima entre o vetor 
% de refer�ncia dado por "vetorRestricaoDeOrientacao" e o vetor normal a o plano.
maxDistAngular= str2double(handles.editDistanciaMaxAngularPlano.String);

for (ctPC=1:numPCs)
    close all;
    
    % Especifica a nuvem de pontos de refer�ncia a ser lida. Path completo.  
    if iscell(nameFiles)
        fullPath= fullfile(pathToRead, nameFiles{ctPC});
    else
        fullPath= fullfile(pathToRead, nameFiles);        
    end
    
    % Efetua a leitura da nuvem depontos de refer�ncia. 
    pc= pcread(fullPath);
    
    % Caso necess�rio passar um filtro para eliminar os ru�dos da nuvem de 
    % pontos de refer�ncia:
    % pcDenoised = pcdenoise(pc);   

    % Chama a fun��o de ajuste de plano:    
    [model1, inlierIndices, outlierIndices]= pcfitplane(pc, maxDistance);
    
    % Seleciona os pontos de interesse, inliers:
    pcPlane= select(pc, inlierIndices);
    
    % Separa os outliers:
    remainPtCloud= select(pc,outlierIndices);
    
    if (handles.ExibePcPlanoAjustada)
        % Exibe a nuvem de pontos segmentada inteira:
        pcshow(pcPlane.Location);
        title('PC plano ajustada');
        xlabel('X (m)');
        ylabel('Y (m)');
        zlabel('Z (m)');        
    end
      
    % Salva PC plano ajustada se esta fun��o estiver habilitada, verificar
    % a habilita��o na interface GUI:    
    if (handles.HabSavePcPlanoAjustada)
        if iscell(nameFiles)
            fullPath= fullfile(fullPathToSave, nameFiles{ctPC});
        else
            fullPath= fullfile(fullPathToSave, nameFiles);        
        end
        
        % Salva PC plano ajustada
        pcwrite(pcPlane,fullPath);
        
        if (ctPC==numPCs)
            handles.msg= sprintf(' Foram plano-ajustadas e salvas %d PCs.', ctPC);
            msg= sprintf(' Foram plano-ajustadas e salvas %d PCs.\n Ok para finalizar.', ctPC);
        else
            handles.msg= sprintf(' PC %d foi plano-ajustada e salva.', ctPC);
            msg= sprintf(' PC %d foi plano-ajustada e salva. \n Ok para continuar.', ctPC);
        end    
        figMsg= msgbox(handles.msg);
        uiwait(figMsg);
    else
        if (ctPC==numPCs)
            handles.msg= sprintf(' Foram plano-ajustadas %d PCs.', ctPC);
            msg= sprintf(' Foram plano-ajustadas %d PCs.\n Ok para finalizar.', ctPC);
        else
            handles.msg= sprintf(' PC %d foi plano-ajustada.', ctPC);
            msg= sprintf(' PC %d foi plano-ajustada. \n Ok para continuar.', ctPC);
        end    
        figMsg= msgbox(msg);
        uiwait(figMsg);        
    end
end

close all;
end
