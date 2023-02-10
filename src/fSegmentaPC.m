
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fSegmentaPC(handles)
clc;
ctPcNaoSalva=0;
nameFiles= 0;

msg=sprintf('1�- Click Ok para escolher as PCs para segmenta��o.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFiles pathToRead]= uigetfile(path, 'Escolhas as PCs que ser�o segmentadas.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa sair� desta fun��o
if pathToRead== 0 
    handles.msg= sprintf('Escolha da PC foi cancelada.');
    msgbox(handles.msg, 'Aten��o!', 'warn');
    return;
end

handles.path.base= pathToRead;

% S� abre o dia�logo para gerar o path se est� fun��o estiver habilitada. 
% Ver a o��o "Salva PC segmentada".
if (handles.HabSavePcSegmentada)
    msg=sprintf('2�- Click ok para definir o folder onde as PCs ser�o salvas.');
    figMsg= msgbox(msg);
    uiwait(figMsg); 
    
    % Abre tela para escolher o folder onde as PCs filtradas ser�o salvas:
    pathToSave= uigetdir(pathToRead, 'Escolha o folder onde as PCs segmentadas ser�o salvas.');

    % Se a escolha do path onde as PCs ser�o salvas for cancelada o programa sair� desta fun��o
    if pathToSave== 0 
        handles.msg= sprintf('Escolha do folder para salvar as PCs foi cancelada.');
        msgbox(handles.msg, 'Aten��o!', 'warn');
        return;
    end
    handles.path.base= pathToSave;
    
    % Define o path onde ser�o salvas as PCs segmentadas:
    fullPathToSave= fullfile(pathToSave, handles.path.PCSegmentada); 
    
    % Se o folder onde ser�o salvas as PCs n�o existir ele ser� criado:
    if ~(isfolder(fullPathToSave))
        mkdir(fullPathToSave); 
    end
end

%*************Par�metros para segmenta��o:
% o Par�metros "mimDistance" define a dist�ncia euclidiana m�nima que dois pontos
% devem ter para pertencer a clusters distintos. Assim, se a dist. Euclidiana
% entre dois pontos for inferior a "minDistance" eles pertencem ao
% mesmo cluster.
minDistance= str2double(handles.editDistMinEntreClusters.String);
% Este par�metro "minPoints" informa o n�mero m�nimo de pontos que um cluster
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
        
        % Especifica a nuvem de pontos de refer�nica a ser lida. Path completo. 
        if numPCs==1
            fullPath= fullfile(pathToRead, nameFiles);
        else
            fullPath= fullfile(pathToRead, nameFiles{ctPC});
        end
        
        
        % Efetua a leitura da nuvem depontos de refer�ncia. Normalmente esta
        % PC j� est� filtrada, caso n�o esteja � aconselh�vel passar por um
        % filtro.
        pcDenoised= pcread(fullPath);
        
        % Filtra o ru�do da nuvem de pontos de refer�ncia caso ainda n�o
        % esteja filtrada previamente:
        % pcDenoised = pcdenoise(pc);

        % Segmenta a nuvem de pontos em clusters com a fun��o pcsegdist(): 
        [labels, numClusters] = pcsegdist(pcDenoised, minDistance, 'NumClusterPoints', minPoints);
        
        % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
        idxValidPoints = find(labels);
        
        % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
        % os endere�os com os pontos v�lidos:
        labelColorIndex = labels(idxValidPoints);
        
        % Gera um nuvem de pontos com os valores segmentados:
        pcSegmented = select(pcDenoised,idxValidPoints);
        for (ctCluster=1:numClusters)
            %Gera uma nuvem de pontos para cada cluster:
            pcCluster{ctCluster}= select(pcDenoised,labels==ctCluster);
        end    
        all =1; 
        
        % Exibe as PCs segmentadas se esta fun��o etiver habilitada
        if (handles.ExibePcSegmentada) 
            % Cria um novo mapa de cores para os clusters
            if (all==1 || i==5 || i==14)
                colormap(hsv(numClusters));
                % Exibe a nuvem de pontos segmentada inteira:
                pcshow(pcSegmented.Location, labelColorIndex);
                title('Nuvem de pontos completa com as segmenta��es.');
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
        
        % Salva as PCs segmentadas se esta fun��o etiver habilitada:
        if (handles.HabSavePcSegmentada)
            % Exibe um menu de escolha para definir o cluster a ser salvo:
            myChoice= fMenuEscolha(numClusters, ctPC, numPCs);
            
            % Define o path para salvar a PC segmentada:
            if numPCs==1
                fullPath= fullfile(fullPathToSave, nameFiles);
            else
                fullPath= fullfile(fullPathToSave, nameFiles{ctPC});
            end
            
            if ~strcmp(myChoice, 'N�o salvar')
                % Salva a PC segmentada escolhida:
                pcwrite(pcCluster{str2double(myChoice)}, fullPath);  
                %Exibe mensagem:
            else    
                pcNaoSalva(ctPC)= ctPC;
                ctPcNaoSalva= ctPcNaoSalva +1; 
            end
            
            if (ctPC==numPCs)
                if (ctPcNaoSalva)
                    handles.msg= sprintf(' Foram analisadas %d PCs.\n N� de PCs salvas= %d. \n N� de PCs n�o salvas= %d.\n Para confirmar as PCs salvas veja o folder: %s', ...
                    ctPC, ctPC-ctPcNaoSalva, ctPcNaoSalva, fullPathToSave);
                    msg= sprintf(' Foram analisadas %d PCs.\n N� de PCs salvas= %d. \n N� de PCs n�o salvas= %d.\n Para confirmar as PCs salvas veja o folder: %s\n\n Click OK para finalizar.', ...
                    ctPC, ctPC-ctPcNaoSalva, ctPcNaoSalva, fullPathToSave);
                else
                    handles.msg= sprintf(' Foram analisadas %d PCs.\n N� de PCs salvas= %d. \n Para confirmar as PCs salvas veja o folder: %s.', ...
                    ctPC, ctPC-ctPcNaoSalva, fullPathToSave);
                    msg= sprintf(' Foram analisadas %d PCs.\n N� de PCs salvas= %d. \n Para confirmar as PCs salvas veja o folder: %s\n\n Click OK para finalizar.', ...
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
                handles.msg= sprintf(' PC segmentada n� %d.', ctPC);
                msg= sprintf(' PC segmentada n� %d.\n Click OK para continuar.', ctPC);     
            end
            figMsg= msgbox(msg);
            uiwait(figMsg); 
        end             
    end  
else
    % Falta implementar a  rotina para segmentar pela dist�ncia Euclidiana.
    a=0;
end
close all;
end
