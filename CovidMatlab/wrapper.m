function wrapper(row)
format long g
% ------------------------------------------------------------------------%
% JSON PARSE                                                              %
% ------------------------------------------------------------------------%
json_settings = 'settings/settings.json';
settings = jsondecode(fileread(json_settings));

disp("Settings")
disp(settings)
fprintf("\n")

% Minimizer settings
iteration           = settings.iteration;
discretization      = settings.discretization;
% Adaptive grid for population guess value
adaptive_population = settings.adaptive_population;
adaptive_time       = settings.adaptive_time;
adaptive_constant	= settings.adaptive_constant;
% Guess values for theta
theta_pre0          = settings.theta_pre0';
theta_min           = settings.theta_min';
theta_max           = settings.theta_max';

% ------------------------------------------------------------------------%
% DATA                                                                    %
% ------------------------------------------------------------------------%
% Data csv names
confirmed = 'data/time_series_19-covid-Confirmed.csv';
recovered = 'data/time_series_19-covid-Recovered.csv';
deaths    = 'data/time_series_19-covid-Deaths.csv';

% Read csv
confirmed_data = readmatrix(confirmed,'FileType', 'text', 'Delimiter', ',', 'TrimNonNumeric', 1);
recovered_data = readmatrix(recovered,'FileType', 'text', 'Delimiter', ',', 'TrimNonNumeric', 1);
deaths_data    = readmatrix(deaths,   'FileType', 'text', 'Delimiter', ',', 'TrimNonNumeric', 1);

% Additional data
% country = confirmed_data(row,2);
% province = confirmed_data(row,2);
% day_0_global = confirmed_data(1, 5);
% days_global_epidemic = length(confirmed_data(row, 5:end))-1;
% day_0_local = day_0_global;
% 
% for i = 5:1:days_global_epidemic
%     if confirmed_data(row, i) > 0
%         day_0_local = confirmed_data(1,i);
%         break
%     end
% end
    

% Create matrix of experimental data
covid_data = ...
    [...
    (0:1:(length(confirmed_data(row, 5:end))-1))',...
    confirmed_data(row, 5:end)' + recovered_data(row, 5:end)' + deaths_data(row, 5:end)',...
    confirmed_data(row, 5:end)',...
    recovered_data(row, 5:end)',...
    deaths_data(row, 5:end)'...
    ];



% ------------------------------------------------------------------------%
% MINIMIZER                                                               %
% ------------------------------------------------------------------------%
total_time = length(confirmed_data(row, 5:end))-1;
adaptive_max = adaptive_population - total_time*adaptive_population/adaptive_time;
if (adaptive_max) < 0
    adaptive_max = 0;
end

population_min = max(covid_data(:,2));
population_max = adaptive_max + population_min * adaptive_constant;

population_vec = linspace(population_min,population_max,discretization);

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

    % Log iteration
    disp(['Iteration ', num2str(i)])
    
    % Discretize and solve 
    for j = 1:1:discretization
        population0 = population_vec(j);   
        dynamic_fit_return = dynamic_fit(covid_data, population0, theta0, theta_min, theta_max);
        
        sum_sq_error(j) = dynamic_fit_return(1);
        theta_fit(j,:) = dynamic_fit_return(:,2:end);
        
        % Log results
        fprintf("%.6f\t%.4f\n",population_vec(j), sum_sq_error(j))
    end
    
    % Assess minimum of set
    [sum_sq_error_min, index] = min(sum_sq_error);
    
    if (index == length(sum_sq_error) && i ~= iteration)
        index = index - 2;
    end
    if (index < 2 && i ~= iteration)
        index = 2;
    end
    
    % Assign solution values
    population_final = population_vec(index);
    
    if (i ~= iteration)
        population_min = population_vec(index - 1);
        population_max = population_vec(index + 1);
        population_vec = linspace(population_min,population_max,discretization);
    end
    
    theta_final = theta_fit(index,:);
    theta0 = theta_final;
    
    
    fprintf("\n");
end



% ------------------------------------------------------------------------%
% SOLUTION (AND PLOT)                                                     %
% ------------------------------------------------------------------------%
disp('Final infected population:')
disp(population_final)
disp(theta_final)

% PLOT (plot = 0/off | 1/on)
tspan = 0:1:1000;
plot = 0;
dynamic_plot_return = dynamic_plot(population_final, theta_final, covid_data, tspan, plot);



% ------------------------------------------------------------------------%
% OUTPUT RESULTS                                                          %
% ------------------------------------------------------------------------%
%%% FILE NAMES
file_name = 'output/output';
file_extension = '.dat';
file_plot_data = [file_name,'_','plot_data', file_extension];
file_plot_model = [file_name,'_','plot_model', file_extension];
file_dynamics = [file_name,'_','dynamics', file_extension];
file_theta = [file_name,'_','theta', file_extension];

output_dir = fullfile('output');
if ~exist(output_dir, 'dir')
    mkdir(output_dir)  
end



%%% OUTPUTS
% Output dynamics (peak and extintion) %----------------------------------%
file = fopen(file_dynamics,'w');
fprintf(file,"dynamic\tday\tsum\tinfected\trecovered\tdeceased");

% Peak
fprintf(file,"\npeak");
[peak_population, peak_index] = max(dynamic_plot_return(:,3));
peak_day = peak_index - 1;
fprintf(file,"\t%i\t%f\t%f\t%f\t%f",peak_day,dynamic_plot_return(peak_index,2),dynamic_plot_return(peak_index,3),dynamic_plot_return(peak_index,4),dynamic_plot_return(peak_index,5));

% Extiction
fprintf(file,"\nextinction");
for extinction_index = peak_index:1:length(dynamic_plot_return(:,3))
    extintion_day = extinction_index - 1;
    if dynamic_plot_return(extinction_index,3) < 0.5
        % Found extinction day
        break
    end
    if extinction_index == length(dynamic_plot_return(:,3))
        % Missing extinction day
        tspan = 0:1:10000;
        dynamic_plot_return = dynamic_plot(population_final, theta_final, covid_data, tspan,0);
        
        % Recheck --------------------------------------------------------%
        for extinction_index_bis = peak_index:1:length(dynamic_plot_return(:,3))
            if dynamic_plot_return(extinction_index,3) < 0.5
                % Found extinction day
                extintion_day = extinction_index_bis - 1;
                fprintf(file,"\t%i\t%f\t%f\t%f\t%f",extintion_day,dynamic_plot_return(extinction_index,2),dynamic_plot_return(extinction_index,3),dynamic_plot_return(extinction_index,4),dynamic_plot_return(extinction_index,5));
                break
            end
            if extinction_index == length(dynamic_plot_return(:,3))
                % Missing extinction day
                tspan = 0:1:10000;
                dynamic_plot_return = dynamic_plot(population_final, theta_final, covid_data, tspan);
                fprintf(file,"\nextintion day not found!");
            end
        end
        % End check ------------------------------------------------------%
    end
end
fclose(file);
% ------------------------------------------------------------------------%



% Output plot data %------------------------------------------------------%
file = fopen(file_plot_data,'w');
fprintf(file,"day\tsum\tinfected\trecovered\tdeceased");
for k=1:1:length(covid_data)
     fprintf(file,"\n%i\t%i\t%i\t%i\t%i",k-1,covid_data(k,2),covid_data(k,3),covid_data(k,4),covid_data(k,5));
end
fclose(file);
% ------------------------------------------------------------------------%



% Output plot model %-----------------------------------------------------%
% Plot until extinction point
plotter(...
    covid_data(:,1),...
    [covid_data(:,2),covid_data(:,3),covid_data(:,4),covid_data(:,5)],...
    dynamic_plot_return(1:(extintion_day+1),:)...
    )

file = fopen(file_plot_model,'w');
fprintf(file,"day\tsum\tinfected\trecovered\tdeceased");
if extintion_day ~= -1
    fprintf(file,"\nextintion day not found!");
    for k=1:1:(extintion_day+1)
        fprintf(file,"\n%i\t%f\t%f\t%f\t%f",k-1,dynamic_plot_return(k,2),dynamic_plot_return(k,3),dynamic_plot_return(k,4),dynamic_plot_return(k,5));
    end
else
fclose(file);
% ------------------------------------------------------------------------%



% Output theta (regression parameters) %----------------------------------%
file = fopen(file_theta,'w');
fprintf(file,"theta\tpopulation0\tr1\tr2\tr3\tt_exp\tt_lag\nvalue\t%i", population_final);
for k=1:1:length(theta_final)
   fprintf(file,"\t%.12f",theta_final(k));
end
fclose(file);
% ------------------------------------------------------------------------%

end