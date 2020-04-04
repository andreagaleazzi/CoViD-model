function f = plotter(t_covid, x_covid, dynamic_plot_return)
    
    % RGB cap
    rgb = 256;
    
    % Colors
    red     =   [205,54,69]/rgb;
    yellow  =   [234,153,36]/rgb;
    green   =   [34,156,74]/rgb;
    blue    =   [98, 88, 188]/rgb;
    
    % PLOT
    f = figure('visible','off');
    hold on
    % Plot model
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,2),'linewidth',1.3,'color',red)
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,3),'linewidth',1.3,'color',yellow)
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,4),'linewidth',1.3,'color',green)
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,5),'linewidth',1.3,'color',blue)
    % Plot data
    plot(t_covid,x_covid(:,2)+x_covid(:,3)+x_covid(:,4),'.','MarkerSize',10,'color',red)
    plot(t_covid,x_covid(:,2),'.','MarkerSize',10,'color',yellow)
    plot(t_covid,x_covid(:,3),'.','MarkerSize',10,'color',green)
    plot(t_covid,x_covid(:,4),'.','MarkerSize',10,'color',blue)
    hold off 
end