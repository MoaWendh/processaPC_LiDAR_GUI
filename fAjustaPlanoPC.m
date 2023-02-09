
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcfitplane()" para eliminar os outliers da nuvem de pontos
% segmentada. Este procedimento refina a segmentação da PC quando esta segmenta 
% uma região que contenha um plano.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fAjustaPlanoPC(handles)
clc;
close all;

msg=sprintf('1º- Click Ok para escolher as PCs para ajuste de plano.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFiles pathToRead]= uigetfile(path, 'Escolhas as PCs que serão plano ajustadas.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sairá desta função
if pathToRead== 0 
    handles.msg= sprintf('Escolha das PCs foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

% Só abre o diálogo para gerar o path se está função estiver habilitada. 
% Ver a opção "Salva PC plano ajustada" no GUI.
if (handles.HabSavePcPlanoAjustada)
    msg=sprintf('2º- Click Ok para escolher o folder onde as PCs ajustadas serão salvas.');
    figMsg= msgbox(msg);
    uiwait(figMsg); 

    % Abre tela para escolher o folder onde as PCs serão salvas:
    pathToSave= uigetdir(pathToRead, 'Escolha o folder onde as PCs segmentadas serão salvas.');

    % Se a escolha do path onde as PCs serão salvas for cancelada o programa sairá desta função
    if pathToSave== 0 
        handles.msg= sprintf('Escolha do folder para salvar as PCs foi cancelada.');
        msgbox(handles.msg, 'Atenção!', 'warn');
        return;
    end
    
    % Define o path omnde serão salvas as PCs segmentadas:
    fullPathToSave= fullfile(pathToSave, handles.path.PCPlanoAdjustada); 
    
    % Se o folder onde serão salvas as PCs não existir ele será criado:
    if ~(isfolder(fullPathToSave))
        mkdir(fullPathToSave); 
    end
end


if iscell(nameFiles)
    numPCs= length(nameFiles);
else
    numPCs= 1;
end

% Define os parâmetros utilziados para o ajuste de plano:
% O parâmetro "maxDistance" define a distânica máxima que um ponto deve ter 
% do plano para ser considerado um inlier, se a distânica for maior este ponto 
% será um outlier. 
maxDistance= str2double(handles.editDistanciaMaxPontoPlano.String);

% O parâmetro "vetorRestricaoDeOrientacao" restringe a direção para análise
% e é utilziado conjuuntamente com o parâmetro "maxDistAngular".
vetorRestricaoDeOrientacao= str2num(handles.editVetorDeRestricaoDeOrientacao.String);

% O parâmetro "maxDistAngular" define a distância angular máxima entre o vetor 
% de referência dado por "vetorRestricaoDeOrientacao" e o vetor normal a o plano.
maxDistAngular= str2double(handles.editDistanciaMaxAngularPlano.String);

for (ctPC=1:numPCs)
    close all;
    
    % Especifica a nuvem de pontos de referência a ser lida. Path completo.  
    if iscell(nameFiles)
        fullPath= fullfile(pathToRead, nameFiles{ctPC});
    else
        fullPath= fullfile(pathToRead, nameFiles);        
    end
    
    % Efetua a leitura da nuvem depontos de referência. 
    pc= pcread(fullPath);
    
    % Caso necessário passar um filtro para eliminar os ruídos da nuvem de 
    % pontos de referência:
    % pcDenoised = pcdenoise(pc);   

    % Chama a função de ajuste de plano:    
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
      
    % Salva PC plano ajustada se esta função estiver habilitada, verificar
    % a habilitação na interface GUI:    
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
