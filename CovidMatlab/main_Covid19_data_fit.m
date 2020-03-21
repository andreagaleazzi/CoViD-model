close all
clearvars
clc

format long g

% population0 = 60.48e6;
population0 = 50000;

% covid_data = xlsread('data\ItalyCovid19','Merged','A2:E50');
% x_covid = [(population0 - covid_data(:,3) - covid_data(:,4) - covid_data(:,5)), covid_data(:,[3,4,5])];

covid_data = xlsread('data\pcmita','Foglio1','A2:L27');
x_covid = [(population0 - covid_data(:,7) - covid_data(:,9) - covid_data(:,10)), covid_data(:,[7,9,10])];

x_covid((20:length(x_covid)), :) = [];

t_covid = (0:1:(length(x_covid)-1));

% ------------------------------------------------------------------------%
% Plot training set                                                       %
% ------------------------------------------------------------------------%
figure('Position', [100 100 1500 400]);
subplot(1,3,1)
hold on
plot(t_covid,x_covid(:,1))
plot(t_covid,x_covid(:,2))
plot(t_covid,x_covid(:,3))
plot(t_covid,x_covid(:,4))
hold off
% ------------------------------------------------------------------------%
% Plot guess value                                                        %
% ------------------------------------------------------------------------%

% theta0 = [0.0001 0.01 0.01 5];    % RAW GUESS
% theta0 = [1.64182349404424e-10 0.00981369927431065 0.00364185465310432 5.34660328043866];   % IMPROVED GUESS
% theta0 = [5.42891940894845e-13 0.0178582323048478 0.01352922211711 6.85128103826894];     % BEST GUESS ON p0 = 50000
theta0 = [8.89623704161877e-07 0.0283210634595335 0.0245693015355776 3.70911541929826];
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
options = optimset('MaxFunEvals',1e6,'TolFun',1e-13, 'TolX',1e-15);

% Theta domain
theta_min = zeros(1, length(theta0));
theta_max = ones(1, length(theta0)) * 100;

% Regression results
theta_fit = fmincon(@(theta)sum_error(t_covid,x_covid,x0,theta), theta0, [], [], [], [], theta_min, theta_max, [], options);

display(theta_fit)

[t,x_fit] = ode23s(@(t,x)Covid19(t,x,theta_fit),t_covid,x0);


% % PLOT
subplot(1,3,2)
hold on
plot(t,x_fit(:,1))
plot(t,x_fit(:,2))
plot(t,x_fit(:,3))
plot(t,x_fit(:,4))
hold off

subplot(1,3,3)
hold on
plot(t,x_fit(:,1),'linewidth',1.3,'color','r')
plot(t,x_fit(:,2),'linewidth',1.3,'color','r')
plot(t,x_fit(:,3),'linewidth',1.3,'color','r')
plot(t,x_fit(:,4),'linewidth',1.3,'color','r')
plot(t_covid,x_covid(:,1),'linewidth',1.3,'color','b')
plot(t_covid,x_covid(:,2),'linewidth',1.3,'color','b')
plot(t_covid,x_covid(:,3),'linewidth',1.3,'color','b')
plot(t_covid,x_covid(:,4),'linewidth',1.3,'color','b')
hold off

%%% PREDICTION
x_covid = [(population0 - covid_data(:,7) - covid_data(:,9) - covid_data(:,10)), covid_data(:,[7,9,10])];
t_covid = (0:1:(length(x_covid)-1));
[t_predict,x_predict] = ode23s(@(t,x)Covid19(t,x,theta_fit),(0:1:250),x0);

figure
hold on
plot(t_predict,x_predict(:,1),'linewidth',1.3,'color','r')
plot(t_predict,x_predict(:,2),'linewidth',1.3,'color','r')
plot(t_predict,x_predict(:,3),'linewidth',1.3,'color','r')
plot(t_predict,x_predict(:,4),'linewidth',1.3,'color','r')
plot(t_covid,x_covid(:,1),'linewidth',1.3,'color','b')
plot(t_covid,x_covid(:,2),'linewidth',1.3,'color','b')
plot(t_covid,x_covid(:,3),'linewidth',1.3,'color','b')
plot(t_covid,x_covid(:,4),'linewidth',1.3,'color','b')
hold off