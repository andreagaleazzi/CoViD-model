close all
clearvars
clc

format long g

% ------------------------------------------------------------------------%
% DATA                                                                    %
% ------------------------------------------------------------------------%
% HGIS

% Excel read
excel = 'data\UpdateVirus';
sheet = 'Italy';
data_matrix = 'A2:E53';
% data_matrix_tot = 'A22:E53';
data_matrix_tot = data_matrix;

covid_data = xlsread(excel,sheet,data_matrix);

dpc_file = 'dpc-covid19-ita-regioni-';
date0 = '12-feb-2002';
extension = '.csv';

% Date
date_now = datevec(now);
date_vec = date_now([1,2,3]);
day_0 = '12-mar-2020';
day_num = datenum(day_0);
days_total = daysact('12-mar-2020', date());
date_str = [];
dates_total = [];

for k = 1:days_total
    date_str
    for i = 1:length(date_vec)
        if (i > 1)
            if (date_vec(i) < 10)
                date_str = strcat(date_str,'0',num2str(date_vec(i)));
            else
                date_str = strcat(date_str,num2str(date_vec(i)));
            end
        else
            date_str = strcat(date_str,num2str(date_vec(i)));
        end
    end
end

base_url = 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/';
url = str_cat(base_url,dpc_file,date_str,extension)
url = 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv';
options = weboptions('RequestMethod','get','ArrayFormat','csv','ContentType','text');
try 
    data = webread(url,options);
    file = fopen('data/pcm-dpc.csv', 'w');
    for i = 1:1:length(data)
        fprintf(file,'%c',data(i));
    end
    fclose(file);
catch 
    disp('No information found.');
end



csvread()
% ------------------------------------------------------------------------%
% MINIMIZER                                                               %
% ------------------------------------------------------------------------%
iteration = 2;
discretization = 250;
population_min = 1000;
population_max = 400000;
population_vec = linspace(population_min,population_max,discretization);


% Guess values
% theta_pre0 = [0.0001 0.01 0.01 5 1];    % RAW GUESS
theta_pre0 = [8 1.4 0.05 0.12 6];
theta_min = [0 0 0 0 0];
theta_max = [1e5 1e5 1e5 12 20];

population_mean = (population_min + population_max)/2;
dynamic_fit_return = dynamic_fit(covid_data, population_mean, theta_pre0, theta_min, theta_max);

% New optimized guess for data set
theta0(1,:) = dynamic_fit_return(:,2:end);

% Preassignment
theta_fit_res = [];
sum_sq_error_res = [];
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
    theta0 = theta_final;
end
% ------------------------------------------------------------------------%
% SOLUTION AND PLOT                                                       %
% ------------------------------------------------------------------------%
disp('Final infected population:')
disp(population_final)
disp(theta_final)

% covid_data = xlsread('data\ChinaProvince','Henan','A2:E62');


% FULL DATA
covid_data = xlsread(excel,sheet,data_matrix_tot);

% PLOT
tspan = 0:1:1000;
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
