function dynamic_fit_return = dynamic_fit(covid_data, population0, theta0, theta_min, theta_max)

    x_covid = [(population0 - covid_data(:,3) - covid_data(:,4) - covid_data(:,5)), covid_data(:,[3,4,5])];

    t_covid = (0:1:(length(x_covid)-1));

    % ------------------------------------------------------------------------%
    % Plot training set                                                       %
    % ------------------------------------------------------------------------%
    % figure('Position', [100 100 1500 400]);
    % subplot(1,3,1)
    % hold on
    % plot(t_covid,x_covid(:,1))
    % plot(t_covid,x_covid(:,2))
    % plot(t_covid,x_covid(:,3))
    % plot(t_covid,x_covid(:,4))
    % hold off
    % ------------------------------------------------------------------------%
    % Plot guess value                                                        %
    % ------------------------------------------------------------------------%

    x0 = [population0 0 0 0];

    % [t_covid,x_init] = ode45(@(t_covid,x_init)Covid19(t_covid,x_init,r0),t_covid,x0);
    % 
    % % PLOT
    % figure
    % hold on
    % plot(t_covid,x_init(:,1))
    % plot(t_covid,x_init(:,2))
    % plot(t_covid,x_init(:,3))
    % plot(t_covid,x_init(:,4))
    % hold off

    % ------------------------------------------------------------------------%
    % Solve regression                                                        %
    % ------------------------------------------------------------------------%
%     options = optimset('MaxFunEvals',1e6,'TolFun',1e-10, 'TolX',1e-8, 'Display', 'off');
    options = optimset('MaxFunEvals',1e6,'TolFun',1e-6, 'TolX',1e-6, 'Display', 'off');

    % Theta domain
%     theta_min = zeros(1, length(theta0));
%     theta_max = ones(1, length(theta0)) * 10;

    % Regression results
    [theta_fit, sum_sq_error] = fmincon(@(theta)sum_error(t_covid,x_covid,x0,theta), theta0, [], [], [], [], theta_min, theta_max, [], options);

    dynamic_fit_return = [sum_sq_error, theta_fit];

%     theta_fit_res = [theta_fit_res, theta_fit];
%     sum_sq_error_res = [sum_sq_error_res, sum_sq_error];
% 
% 
%     [t,x_fit] = ode23s(@(t,x)Covid19(t,x,theta_fit),t_covid,x0);
% 
% 
%     % % % PLOT
%     % subplot(1,3,2)
%     % hold on
%     % plot(t,x_fit(:,1))
%     % plot(t,x_fit(:,2))
%     % plot(t,x_fit(:,3))
%     % plot(t,x_fit(:,4))
%     % hold off
%     % 
%     % subplot(1,3,3)
%     % hold on
%     % plot(t,x_fit(:,1),'linewidth',1.3,'color','r')
%     % plot(t,x_fit(:,2),'linewidth',1.3,'color','r')
%     % plot(t,x_fit(:,3),'linewidth',1.3,'color','r')
%     % plot(t,x_fit(:,4),'linewidth',1.3,'color','r')
%     % plot(t_covid,x_covid(:,1),'linewidth',1.3,'color','b')
%     % plot(t_covid,x_covid(:,2),'linewidth',1.3,'color','b')
%     % plot(t_covid,x_covid(:,3),'linewidth',1.3,'color','b')
%     % plot(t_covid,x_covid(:,4),'linewidth',1.3,'color','b')
%     % hold off
% 
%     %%% PREDICTION
%     t_covid = (0:1:(length(x_covid)-1));
%     [t_predict,x_predict] = ode23s(@(t,x)Covid19(t,x,theta_fit),(0:1:250),x0);
% 
%     figure
%     hold on
%     plot(t_predict,x_predict(:,1),'linewidth',1.3,'color','r')
%     plot(t_predict,x_predict(:,2),'linewidth',1.3,'color','r')
%     plot(t_predict,x_predict(:,3),'linewidth',1.3,'color','r')
%     plot(t_predict,x_predict(:,4),'linewidth',1.3,'color','r')
%     plot(t_covid,x_covid(:,1),'linewidth',1.3,'color','b')
%     plot(t_covid,x_covid(:,2),'linewidth',1.3,'color','b')
%     plot(t_covid,x_covid(:,3),'linewidth',1.3,'color','b')
%     plot(t_covid,x_covid(:,4),'linewidth',1.3,'color','b')
%     hold off
end