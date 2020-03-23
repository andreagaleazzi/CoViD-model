function dynamic_plot_return = dynamic_plot(population0, theta, covid_data, tspan)
    % INITIAL POPULATION
    x0 = [population0 0 0 0];

    
    % PREDICTION
    [t_predict,x_predict] = ode45(@(t_covid,x_init)dynamic_model_sigmoid(t_covid,x_init,theta),tspan,x0);

    
    % COVID DATA
    x_covid = [(population0 - covid_data(:,3) - covid_data(:,4) - covid_data(:,5)), covid_data(:,[3,4,5])];
    t_covid = (0:1:(length(x_covid)-1));

    
    % RETURN VALUE
    
    % Fix negative Bs
    for i = 1:1:length(x_predict)
        if (x_predict(i,2) < 0)
            x_predict(i,2) = 0;
        end
    end
    dynamic_plot_return = [t_predict,(x_predict(:,2)+x_predict(:,3)+x_predict(:,4)),x_predict(:,2),x_predict(:,3),x_predict(:,4)];
    
   
    
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