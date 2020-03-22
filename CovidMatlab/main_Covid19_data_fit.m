close all
clearvars
clc

format long g

% population_totale = 60.48e6;    % totale
% ------------------------------------------------------------------------%
% DATA                                                                    %
% ------------------------------------------------------------------------%
% HGIS
% covid_data = xlsread('data\ItalyCovid19','Merged','A2:E53');
covid_data = xlsread('data\ChinaProvince','Henan','A2:E62');

% PROTEZIONE CIVILE ITALIANA
% covid_data = xlsread('data\pcmita','Foglio1','A2:L27');
% x_covid = [(population0 - covid_data(:,7) - covid_data(:,9) - covid_data(:,10)), covid_data(:,[7,9,10])];
% x_covid((20:length(x_covid)), :) = [];
% ------------------------------------------------------------------------%
theta_fit_res = [];
sum_sq_error_res = [];

% options = optimset('MaxFunEvals',1e6,'TolFun',1e-12, 'TolX',1e-12, 'Display', 'iter');
% [population_final, population_error] = fmincon(@(population_final)dynamic_fit(population_final,covid_data), 50000, [], [], [], [], 40000, 80000, [], options);


% ------------------------------------------------------------------------%
% MINIMIZER                                                               %
% ------------------------------------------------------------------------%
iteration = 3;
discretization = 10;
% population_min = 1000;
% population_max = 2000;
population_min = 1300;
population_max = 1400;
population_vec = linspace(population_min,population_max,discretization);



% Guess values
% theta0 = [0.0001 0.01 0.01 5 1];    % RAW GUESS
theta0 = [1e-14 0.01 0.01 2 10];    % RAW GUESS
% theta0 = [1.64182349404424e-10 0.00981369927431065 0.00364185465310432 5.34660328043866];   % IMPROVED GUESS
% theta0 = [5.42891940894845e-13 0.0178582323048478 0.01352922211711 6.85128103826894];     % BEST GUESS ON p0 = 50000
theta_min = [0 0 0 0 0];
theta_max = [1 1 1 12 20];
% theta0 = [8.89623704161877e-07 0.0283210634595335 0.0245693015355776 3.70911541929826];


% Preassignment
population0 = [];
sum_sq_error = zeros(1,discretization);
theta_fit = zeros(discretization,length(theta0));
for i = 1:1:iteration

    for j = 1:1:discretization
        population0 = population_vec(j);   
        dynamic_fit_return = dynamic_fit(covid_data, population0, theta0, theta_min, theta_max);
        
        sum_sq_error(j) = dynamic_fit_return(1);
        theta_fit(j,:) = dynamic_fit_return(:,2:end);
        
    end
    
    [sum_sq_error_min, index] = min(sum_sq_error);
    
    if (index == length(sum_sq_error) && i ~= iteration)
        index = index - 2;
    end
    if (index < 2 && i ~= iteration)
        index = 2;
    end
    
    display(['Iteration ', num2str(i)])
    display([sum_sq_error', population_vec'])
    
    
    population_final = population_vec(index);
    
    if (i ~= iteration)
        population_min = population_vec(index - 1);
        population_max = population_vec(index + 1);
        population_vec = linspace(population_min,population_max,discretization);
    end
    
    
    
    theta_final = theta_fit(index,:);
end
% ------------------------------------------------------------------------%
% SOLUTION AND PLOT                                                       %
% ------------------------------------------------------------------------%
disp('Final infected population:')
disp(population_final)
disp(theta_final)

% covid_data = xlsread('data\ChinaProvince','Henan','A2:E62');

% PLOT
tspan = 0:1:100;
dynamic_plot_return = dynamic_plot(population_final, theta_final, covid_data, tspan);



