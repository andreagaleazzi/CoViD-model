function dynamic_fit_return = dynamic_fit(covid_data, population0, theta0, theta_min, theta_max)

% ------------------------------------------------------------------------%
% Rettrieve training set                                                  %
% ------------------------------------------------------------------------%
x_covid = [(population0 - covid_data(:,3) - covid_data(:,4) - covid_data(:,5)), covid_data(:,[3,4,5])];

t_covid = (0:1:(length(x_covid)-1));



% ------------------------------------------------------------------------%
% Solve regression                                                        %
% ------------------------------------------------------------------------%
x0 = [population0 0 0 0];

options = optimset('MaxFunEvals',1e6,'TolFun',1e-10, 'TolX',1e-8, 'Display', 'off');

% Regression results
[theta_fit, sum_sq_error] = fmincon(@(theta)sum_error(t_covid,x_covid,x0,theta), theta0, [], [], [], [], theta_min, theta_max, [], options);

dynamic_fit_return = [sum_sq_error, theta_fit];

end