close all
clear
clc


% Select row of nation+region:
% Top ten, in order:


%%% ITALY CASE
% Starting from 2 (abruzzo) to 22 (Veneto)
% Call wrapper for solution [once]
% wrapper(2)

while system('COVIDdataFormatter.exe') ~= 0
    disp("Error: 'COVIDdataFormatter.exe' cannot convert data");
end

% Call wrapper for solution [iteratively]
for i = 2:1:22
    wrapper(i)
    clc
end