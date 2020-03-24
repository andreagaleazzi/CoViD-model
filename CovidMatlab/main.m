close all
clear
clc


% Select row of nation+region:
% Top ten, in order:
row_top_ten = [156 18 20 13 157 159 101 158 33 405 442 22 34 41 100 19 109 102 61];
%row = 156;	     % Hubei
row = 18;		 % Italy
%row = 20;		 % Spain
%row = 13;		 % Germany
%row = 157;		 % Iran
%row = 159;	     % France
%row = 101;	     % New York
%row = 158;		 % Korea, Sou
%row = 33;		 % Switzerlan
%row = 405;		 % United Kin
%row = 442;		 % Netherland
%row = 22;		 % Belgium
%row = 34;		 % Austria
%row = 41;		 % Norway
%row = 100;		 % US
%row = 19;		 % Sweden
%row = 109;	     % New Jersey
%row = 102;      % California
%row = 61;		 % Portugal

% Call wrapper for solution [once]
wrapper(row)

% Call wrapper for solution [iteratively]
for i = 1:length(row_top_ten)
    wrapper(row_top_ten(i))
    clc
end