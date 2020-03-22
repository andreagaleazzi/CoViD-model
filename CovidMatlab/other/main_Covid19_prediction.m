% close all
clearvars
clc

format long g

% population0 = 60.48e6;
population0 = 65000;

covid_data = xlsread('data\ItalyCovid19','Merged','A2:E50');

t_covid = covid_data(:,1);
x_covid = [(population0 - covid_data(:,3) - covid_data(:,4) - covid_data(:,5)), covid_data(:,[3,4,5])];
% ------------------------------------------------------------------------%
% Plot prediction                                                         %
% ------------------------------------------------------------------------%

% theta_fit = [5.42891940894845e-13 0.0178582323048478 0.01352922211711 6.85128103826894];
% BEST RESULT ON population0 = 50000:
theta_fit = [5.3802983909872e-14 0.0191008318103062 0.0145415609610045 7.48096434430872];
theta_fit = [7.23660501899331e-10 0.0104119012190287 0.00492330176183709 4.56756058097261];
theta_fit = [4.27658880689957e-13 0.0192349437951722 0.0147389297460395 6.82058893256712];
x0 = [population0 0 0 0];

[t_predict,x_predict] = ode23s(@(t_covid,x_init)Covid19(t_covid,x_init,theta_fit),(0:1:250),x0);

% PLOT
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