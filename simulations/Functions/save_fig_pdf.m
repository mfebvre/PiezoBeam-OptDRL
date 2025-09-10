function save_fig_pdf(fig_title)

    fig=openfig(fig_title);
    set(fig,'Visible','on')
    
    fig.Units = 'centimeters';        % set figure units to cm
    fig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
    fig.PaperSize = fig.Position(3:4);
    pdf_file_name = [fig_title, '.pdf'];
    %print -dpdf -painters fig_title
    print(fig, '-dpdf', '-painters', pdf_file_name);
end