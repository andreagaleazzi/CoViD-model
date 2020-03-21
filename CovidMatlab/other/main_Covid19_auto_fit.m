close all
clearvars
clc

format long g

% ------------------------------------------------------------------------%
% Create training set                                                     %
% ------------------------------------------------------------------------%
r0 = [0.1 0.1 0.02];

x0 = [60.47e6 0 0 0];

[t,x] = ode45(@(t,x)Covid19(t,x,r0),(0:2:100),x0);

% % PLOT
figure
hold on
plot(t,x(:,1))
plot(t,x(:,2))
plot(t,x(:,3))
plot(t,x(:,4))
% ------------------------------------------------------------------------%

r_guess = [0.2 0.05 0.08];

options = optimset('MaxFunEvals',10000);

r_fit = fmincon(@(r)sum_error(t,x,x0,r), r_guess, [], [], [], [], [0 0 0], [1 1 1], [], options);

[t,x_fit] = ode45(@(t,x)Covid19(t,x,r_fit),(0:2:100),x0);
% x = fmincon(@(par)sum_error(Bdata(1:end,1),Bdata(1:end,3),par),k0,[],[],[],[],[0 0 0],[100 100 100])

% % PLOT
hold on
plot(t,x_fit(:,1))
plot(t,x_fit(:,2))
plot(t,x_fit(:,3))
plot(t,x_fit(:,4))

% figure
% plot(Bdata(:,5),Bdata(:,2),'o','MarkerSize',5,'MarkerEdgeColor',[0,0.4470,0.7410],'MarkerFaceColor',[0,0.4470,0.7410])
% hold on
% plot(t,x(:,1),'linewidth',1.3)
% plot(t,x(:,2),'linewidth',1.3)
% plot(t,x(:,3),'linewidth',1.3)
% plot(t,x(:,4),'linewidth',1.3)
% legend('dati B','A','B','C','D')
% grid on
% xlabel('time [day]')