close all
clearvars
clc

format long g

% ------------------------------------------------------------------------%
% DATA                                                                    %
% ------------------------------------------------------------------------%
% HGIS
% covid_data = xlsread('data\ItalyCovid19','Merged','A2:E53');
% covid_data = xlsread('data\ChinaProvince','Henan','A2:E62');

% Excel read
excell = 'data\ChinaProvince';
sheet = 'Henan';
data_matrix = 'A2:E62';
covid_data = xlsread(excell,sheet,data_matrix);

% PROTEZIONE CIVILE ITALIANA
% covid_data = xlsread('data\pcmita','Foglio1','A2:L27');
% x_covid = [(population0 - covid_data(:,7) - covid_data(:,9) - covid_data(:,10)), covid_data(:,[7,9,10])];
% x_covid((20:length(x_covid)), :) = [];
% ------------------------------------------------------------------------%
theta_fit_res = [];
sum_sq_error_res = [];


% ------------------------------------------------------------------------%
% MINIMIZER                                                               %
% ------------------------------------------------------------------------%
iteration = 1;
discretization = 3;
% iteration = 1;
% discretization = 3;
population_min = 1000;
population_max = 1500;
population_vec = linspace(population_min,population_max,discretization);


% Guess values
% theta0 = [0.0001 0.01 0.01 5 1];    % RAW GUESS
theta0 = [8 1.4 0.05 0.12 6];
theta_min = [0 0 0 0 0];
theta_max = [1e5 100 100 12 20];


% Preassignment
population0 = [];
sum_sq_error = zeros(1,discretization);
theta_fit = zeros(discretization,length(theta0));

% Iterate
for i = 1:1:iteration

    % Discretize and solve 
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


% ------------------------------------------------------------------------%
% OUTPUT RESULTS                                                          %
% ------------------------------------------------------------------------%
% FILE NAMES
file_name = 'output/file';
file_extension = '.dat';
file_plot_data = [file_name, '_plot_data', file_extension];
file_plot_model = [file_name,'_plot_model', file_extension];
file_dynamics = [file_name,'_dynamics', file_extension];
file_theta = [file_name,'_theta', file_extension];


% OUTPUTS
% Output plot data
file = fopen(file_plot_data,'w');
fprintf(file,"day\tsum\tinfected\tcured\tdeceased");
for k=1:1:length(covid_data)
   fprintf(file,"\n%i\t%i\t%i\t%i\t%i",k-1,covid_data(k,2),covid_data(k,3),covid_data(k,4),covid_data(k,5));
end
fclose(file);


% Output plot model
file = fopen(file_plot_model,'w');
fprintf(file,"day\tsum\tinfected\tcured\tdeceased");
for k=1:1:length(dynamic_plot_return)
   fprintf(file,"\n%i\t%f\t%f\t%f\t%f",k-1,dynamic_plot_return(k,2),dynamic_plot_return(k,3),dynamic_plot_return(k,4),dynamic_plot_return(k,5));
end
fclose(file);


% Output dynamics (peak and extintion)
file = fopen(file_dynamics,'w');
fprintf(file,"dynamic\tday\tsum\tinfected\tcured\tdeceased");

% Peak
fprintf(file,"\npeak");
[peak_population, peak_index] = max(dynamic_plot_return(:,3));
peak_day = peak_index - 1;
fprintf(file,"\t%i\t%f\t%f\t%f\t%f",peak_day,dynamic_plot_return(peak_index,2),dynamic_plot_return(peak_index,3),dynamic_plot_return(peak_index,4),dynamic_plot_return(peak_index,5));

% Extiction
fprintf(file,"\nextinction");
for extinction_index = peak_index:1:length(dynamic_plot_return(:,3))
    if dynamic_plot_return(extinction_index,3) < 0.5
        extintion_day = extinction_index - 1;
        break
    end
end
fprintf(file,"\t%i\t%f\t%f\t%f\t%f",extintion_day,dynamic_plot_return(extinction_index,2),dynamic_plot_return(extinction_index,3),dynamic_plot_return(extinction_index,4),dynamic_plot_return(extinction_index,5));
fclose(file);

% Output theta (regression parameters)
file = fopen(file_theta,'w');
fprintf(file,"theta\tpopulation0\tr1\tr2\tr3\tt_exp\tt_lag\nvalue\t%i", population_final);
for k=1:1:length(theta_final)
   fprintf(file,"\t%.12f",theta_final(k));
end
fclose(file);
