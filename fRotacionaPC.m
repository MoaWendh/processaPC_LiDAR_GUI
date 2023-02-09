function handles= fRotacionaPC(handles)

msg= sprintf('1º- Click Ok para escolher as PCs a serem rotacionadas.');
figMsg= msgbox(msg);
uiwait(figMsg); 

% Abre janela para escolher as PC a serem rotacionadas:
path= fullfile(handles.path.base,'*.pcd');
[nameFiles pathToRead]= uigetfile(path,'Selecione as PCs para rotacinar.','MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa saira desta função
if pathToRead==0 
    handles.msg= sprintf('Escolha da PC foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

msg=sprintf('2º- Click Ok para definir o folder onde as PCs serão salvas.');
figMsg= msgbox(msg);
uiwait(figMsg); 

% Abre tela para escolher o folder onde as PCs filtradas serão salvas:
pathToSave= uigetdir(pathToRead, 'Escolha o folder onde as PCs serão salvas.');

% Se a escolha do path onde as PCs serão salvas for cancelada o programa sairá desta função
if pathToSave==0 
    handles.msg= sprintf('Escolha do folder para salvar as PCs foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

fullPathToSave= fullfile(pathToSave, handles.path.PCRotacionada);

% Verifica se o flder existe, caso contrário será criado:
if ~(isfolder(fullPathToSave))
    mkdir(fullPathToSave);
end

% Define o ângulo de rotação:
alfa= handles.rotacionar.vetorRot(1); 
beta= handles.rotacionar.vetorRot(2);
gama= handles.rotacionar.vetorRot(3);

% Gera a matriz de rotação:

rotX = [    1            0           0
            0       cos(alfa)   -sin(alfa) 
            0       sin(alfa)    cos(alfa)];

rotY = [ cos(beta)       0        sin(beta)
             0           1           0
        -sin(beta)       0        cos(beta)];
        
rotZ = [ cos(gama)   -sin(gama)      0 
         sin(gama)    cos(gama)      0 
            0            0           1 ];

tform= rigid3d(rotY, handles.rotacionar.vetorTransl);

if iscell(nameFiles)
    numPCs= length(nameFiles);
else
    numPCs= 1;
end

for (ctPC=1:numPCs)
    close all; 
    if iscell(nameFiles)
        nameFile= nameFiles{ctPC};
    else
        nameFile= nameFiles;
    end
    fullPathToRead= fullfile(pathToRead, nameFile);
    
    % Faz a leitura da PC:
    pc = pcread(fullPathToRead);
    
    % Efetua a transformação da PC:
    pcTransformada = pctransform(pc,tform);    
    
    % Salva a PC rotacionada:
    fullFileToSave= fullfile(fullPathToSave, nameFile);
    pcwrite(pcTransformada, fullFileToSave);   
end

msg= sprintf(' Rotação concluída!\n Foram rotacionadas %d PCs.', numPCs);
figMsg= msgbox(msg, 'Concluído', 'modal');
uiwait(figMsg);

handles.path.base= fullPathToSave;
end
 
 


