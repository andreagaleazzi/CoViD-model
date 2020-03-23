function plotter(t_covid, x_covid, dynamic_plot_return)
    
    % PLOT
    figure
    hold on
    % Plot model
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,2),'linewidth',1.3,'color','r')    
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,3),'linewidth',1.3,'color','r')
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,4),'linewidth',1.3,'color','r')
    plot(dynamic_plot_return(:,1),dynamic_plot_return(:,5),'linewidth',1.3,'color','r')
    % Plot data
    plot(t_covid,x_covid(:,2)+x_covid(:,3)+x_covid(:,4),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,2),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,3),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,4),'linewidth',1.3,'color','b')
    hold off 
end