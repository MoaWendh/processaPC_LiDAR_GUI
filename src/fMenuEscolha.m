function myChoice = fMenuEscolha(numClusters, ctPC, numPCs)

    msg1= sprintf('Selecione abaixo o nº do cluster para salvar:');
    msg2= sprintf('PC nº %d de %d PCs:', ctPC, numPCs);
    
    d = dialog('Position',[600 500 350 180],'Name',msg2, 'WindowStyle','normal');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[40 80 250 70],...
           'String', msg1, 'FontSize', 10);


    for i=1:numClusters+1
        if i==1
            myPossibilities{i}= 'Não salvar';
        else
            myPossibilities{i}= (i-1);
        end
    end

    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[55 85 230 25],...
           'String',myPossibilities,...
           'Callback',@popup_callback, 'FontSize', 10);

    btn = uicontrol('Parent',d,...
           'Position',[135 20 100 25],...
           'String','Ok',...
           'Callback','delete(gcf)', 'FontSize', 10);

    myChoice = myPossibilities{1};

    % Wait for d to close before running to completion
    uiwait(d);

       function popup_callback(popup,event)
          idx = popup.Value;
          popup_items = popup.String;
          myChoice = char(popup_items(idx,:));
       end
end