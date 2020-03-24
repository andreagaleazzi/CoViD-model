close all
clear
clc

syms x lag gain

syms f(x)


f(x,lag) = 1 / (1 + exp(-x*lag + 0));


fsurf(f(x,lag))