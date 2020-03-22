function dynamic_plot_return = dynamic_plot(population0, theta, covid_data, tspan)
    % INITIAL POPULATION
    x0 = [population0 0 0 0];

    % PREDICTION
    [t_predict,x_predict] = ode45(@(t_covid,x_init)Covid19(t_covid,x_init,theta),tspan,x0);

    % COVID DATA
    x_covid = [(population0 - covid_data(:,3) - covid_data(:,4) - covid_data(:,5)), covid_data(:,[3,4,5])];
    t_covid = (0:1:(length(x_covid)-1));

    
    % PLOT
    figure
    hold on
    % plot(t_predict,x_predict(:,1),'linewidth',1.3,'color','r')
    plot(t_predict,x_predict(:,2)+x_predict(:,3)+x_predict(:,4),'linewidth',1.3,'color','r')    
    plot(t_predict,x_predict(:,2),'linewidth',1.3,'color','r')
    plot(t_predict,x_predict(:,3),'linewidth',1.3,'color','r')
    plot(t_predict,x_predict(:,4),'linewidth',1.3,'color','r')
    % plot(t_covid,x_covid(:,1),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,2)+x_covid(:,3)+x_covid(:,4),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,2),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,3),'linewidth',1.3,'color','b')
    plot(t_covid,x_covid(:,4),'linewidth',1.3,'color','b')
    hold off
    
    dynamic_plot_return = [t_predict,x_predict];
end