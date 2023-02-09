
function handles= fDenoisedPCL(handles)
clc;
close all;

msg= sprintf('1º- Click Ok para escolher as PCs a serem filtradas.');
figMsg= msgbox(msg);
uiwait(figMsg); 

path= fullfile(handles.path.base,'*.pcd');
% Abre tela para escolhar as PCs para serem filtradas:
[nameFiles pathToRead]= uigetfile(path, 'Escolhas as PCs que serão filtradas.' ,'MultiSelect', 'on');

% Se a escolha do arquivo for cancelada, o programa saira desta função
if pathToRead== 0 
    handles.msg= sprintf('Escolha da PC foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

msg=sprintf('2º- Click ok para definir o folder onde as PCs serão salvas.');
figMsg= msgbox(msg);
uiwait(figMsg); 

% Abre tela para escolher o folder onde as PCs filtradas serão salvas:
pathToSave= uigetdir(pathToRead, 'Escolha o folder onde as PCs filtradas serão salvas.');

% Se a escolha do path onde as PCs serão salvas for cancelada o programa sairá desta função
if pathToSave== 0 
    handles.msg= sprintf('Escolha do folder para salvar as PCs foi cancelada.');
    msgbox(handles.msg, 'Atenção!', 'warn');
    return;
end

fullPathToSave= fullfile(pathToSave, handles.path.PCDenoised);

% Se o folder onde serão salvas as PCs não existir ele será criado:
if ~(isfolder(fullPathToSave))
   mkdir(fullPathToSave); 
end

% Atualiza o path base:
handles.path.base= fullPathToSave; 

% Pegas os parâmetros de filtragem:
% O parâmetro "numNeighbors" serve para calcular a distãncia média entre
% esses pontos vizinhos. Quanto menor este parâmetro a filtragem será menos
% eficiente quanto ao ruído. No entanto um número grnade torna o filtro
% mais sletivo, porém o tempo de processamento é maior:
numNeighbors= str2double(handles.editNumNeighbors.String);

% O parâmetro "thresHold" serve para eliminar outliers. Um ponto cuja
% distância seja maior que o valor do threshold será considerado um outlier.
% Este parâmetro representa adistância média entre os pontos vizinhos.
thresHold= str2double(handles.editTresholdDistanceFiltrar.String);

if iscell(nameFiles)
    numPCs= length(nameFiles);
else
    numPCs= 1;
end

for (ctPC=1:numPCs)   
    if iscell(nameFiles)
        nameFile= nameFiles{ctPC};
    else
        nameFile= nameFiles;
    end
    fullPathFileRead = fullfile(pathToRead, nameFile);
    
    % Efetua a leitura da PC:
    pc= pcread(fullPathFileRead);
    
    % Filtra a nuvem depontos.
    pcDenoised = pcdenoise(pc, 'NumNeighbors', numNeighbors, 'Threshold' , thresHold);
    
    % Salva a nuvem de pontos filtrada.
    fullPathFileSave = fullfile(fullPathToSave, nameFile);
    pcwrite(pcDenoised, fullPathFileSave);     
end

% Exibe mensagem:
handles.msg= sprintf(' Filtragam das PCs concluída. \n Foram filtradas %d PCs.', ctPC)
figMsg= msgbox(handles.msg);
uiwait(figMsg);
end
 
 


