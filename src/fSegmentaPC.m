
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fSegmentaPC(handles)
clc;
ctPcNaoSalva=0;
nameFiles= 0;

msg=sprintf('1º- Click Ok para escolher as PCs para segmentação.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFiles pathToRead]= uigetfile(path, 'Escolhas as PCs que serão segmentadas.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sairá desta função
if pathToRead== 0 
    handles.msg= sprintf('Escolha da PC foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

handles.path.base= pathToRead;

% Só abre o diaálogo para gerar o path se está função estiver habilitada. 
% Ver a oção "Salva PC segmentada".
if (handles.HabSavePcSegmentada)
    msg=sprintf('2º- Click ok para definir o folder onde as PCs serão salvas.');
    figMsg= msgbox(msg);
    uiwait(figMsg); 
    
    % Abre tela para escolher o folder onde as PCs filtradas serão salvas:
    pathToSave= uigetdir(pathToRead, 'Escolha o folder onde as PCs segmentadas serão salvas.');

    % Se a escolha do path onde as PCs serão salvas for cancelada o programa sairá desta função
    if pathToSave== 0 
        handles.msg= sprintf('Escolha do folder para salvar as PCs foi cancelada.');
        msgbox(handles.msg, 'Atenção!', 'warn');
        return;
    end
    handles.path.base= pathToSave;
    
    % Define o path onde serão salvas as PCs segmentadas:
    fullPathToSave= fullfile(pathToSave, handles.path.PCSegmentada); 
    
    % Se o folder onde serão salvas as PCs não existir ele será criado:
    if ~(isfolder(fullPathToSave))
        mkdir(fullPathToSave); 
    end
end

%*************Parâmetros para segmentação:
% o Parâmetros "mimDistance" define a distância euclidiana mínima que dois pontos
% devem ter para pertencer a clusters distintos. Assim, se a dist. Euclidiana
% entre dois pontos for inferior a "minDistance" eles pertencem ao
% mesmo cluster.
minDistance= str2double(handles.editDistMinEntreClusters.String);
% Este parâmetro "minPoints" informa o número mínimo de pontos que um cluster
% deve ter para que seja considerado um cluster.
minPoints= str2double(handles.editNumMinPontosPorCluster.String);

if iscell(nameFiles)
    numPCs= length(nameFiles);
else
    numPCs= 1;
end

if ~(handles.HabSegmentarPorDistanciaEuclidiana)
    for (ctPC=1:numPCs)        
        clc;
        close all;
        
        % Especifica a nuvem de pontos de referênica a ser lida. Path completo. 
        if numPCs==1
            fullPath= fullfile(pathToRead, nameFiles);
        else
            fullPath= fullfile(pathToRead, nameFiles{ctPC});
        end
        
        
        % Efetua a leitura da nuvem depontos de referência. Normalmente esta
        % PC já está filtrada, caso não esteja é aconselhável passar por um
        % filtro.
        pcDenoised= pcread(fullPath);
        
        % Filtra o ruído da nuvem de pontos de referência caso ainda não
        % esteja filtrada previamente:
        % pcDenoised = pcdenoise(pc);

        % Segmenta a nuvem de pontos em clusters com a função pcsegdist(): 
        [labels, numClusters] = pcsegdist(pcDenoised, minDistance, 'NumClusterPoints', minPoints);
        
        % Remove os pontos que não tem valor de label válido, ou seja =0.
        idxValidPoints = find(labels);
        
        % Guarda o cluster definidos na variável "idxValidPoints" quem contém 
        % os endereços com os pontos válidos:
        labelColorIndex = labels(idxValidPoints);
        
        % Gera um nuvem de pontos com os valores segmentados:
        pcSegmented = select(pcDenoised,idxValidPoints);
        for (ctCluster=1:numClusters)
            %Gera uma nuvem de pontos para cada cluster:
            pcCluster{ctCluster}= select(pcDenoised,labels==ctCluster);
        end    
        all =1; 
        
        % Exibe as PCs segmentadas se esta função etiver habilitada
        if (handles.ExibePcSegmentada) 
            % Cria um novo mapa de cores para os clusters
            if (all==1 || i==5 || i==14)
                colormap(hsv(numClusters));
                % Exibe a nuvem de pontos segmentada inteira:
                pcshow(pcSegmented.Location, labelColorIndex);
                title('Nuvem de pontos completa com as segmentações.');
                xlabel('X (m)');
                ylabel('Y (m)');
                zlabel('Z (m)');
                for (ctCluster=1:numClusters)
                    f(ctCluster)= figure;
                    % Exibe o cluster da nuvem de pontos segemntada:
                    pcshow(pcCluster{ctCluster}.Location);
                    titulo= sprintf('Clusters= %d ',ctCluster);
                    title(titulo);
                    f(ctCluster).Position= [200,200, 1200, 800]; 
                    xlabel('X (m)');
                    ylabel('Y (m)');
                    zlabel('Z (m)');
                end  
            end
        end
        
        % Salva as PCs segmentadas se esta função etiver habilitada:
        if (handles.HabSavePcSegmentada)
            % Exibe um menu de escolha para definir o cluster a ser salvo:
            myChoice= fMenuEscolha(numClusters, ctPC, numPCs);
            
            % Define o path para salvar a PC segmentada:
            if numPCs==1
                fullPath= fullfile(fullPathToSave, nameFiles);
            else
                fullPath= fullfile(fullPathToSave, nameFiles{ctPC});
            end
            
            if ~strcmp(myChoice, 'Não salvar')
                % Salva a PC segmentada escolhida:
                pcwrite(pcCluster{str2double(myChoice)}, fullPath);  
                %Exibe mensagem:
            else    
                pcNaoSalva(ctPC)= ctPC;
                ctPcNaoSalva= ctPcNaoSalva +1; 
            end
            
            if (ctPC==numPCs)
                if (ctPcNaoSalva)
                    handles.msg= sprintf(' Foram analisadas %d PCs.\n Nº de PCs salvas= %d. \n Nº de PCs não salvas= %d.\n Para confirmar as PCs salvas veja o folder: %s', ...
                    ctPC, ctPC-ctPcNaoSalva, ctPcNaoSalva, fullPathToSave);
                    msg= sprintf(' Foram analisadas %d PCs.\n Nº de PCs salvas= %d. \n Nº de PCs não salvas= %d.\n Para confirmar as PCs salvas veja o folder: %s\n\n Click OK para finalizar.', ...
                    ctPC, ctPC-ctPcNaoSalva, ctPcNaoSalva, fullPathToSave);
                else
                    handles.msg= sprintf(' Foram analisadas %d PCs.\n Nº de PCs salvas= %d. \n Para confirmar as PCs salvas veja o folder: %s.', ...
                    ctPC, ctPC-ctPcNaoSalva, fullPathToSave);
                    msg= sprintf(' Foram analisadas %d PCs.\n Nº de PCs salvas= %d. \n Para confirmar as PCs salvas veja o folder: %s\n\n Click OK para finalizar.', ...
                    ctPC, ctPC-ctPcNaoSalva, fullPathToSave);
                end
                figMsg= msgbox(msg);
                uiwait(figMsg);
            end         
        else
            if (ctPC==numPCs)
                handles.msg= sprintf(' Foram segmentadas %d PCs.', ctPC);
                msg= sprintf(' Foram segmentadas %d PCs. \n Click OK para Finalizar.', ctPC);
            else
                handles.msg= sprintf(' PC segmentada nº %d.', ctPC);
                msg= sprintf(' PC segmentada nº %d.\n Click OK para continuar.', ctPC);     
            end
            figMsg= msgbox(msg);
            uiwait(figMsg); 
        end             
    end  
else
    % Falta implementar a  rotina para segmentar pela distância Euclidiana.
    a=0;
end
close all;
end
