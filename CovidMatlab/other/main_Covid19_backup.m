clearvars
clc

format long g

global Bdata

% Data = xlsread('ItalyCovid19','Merged','A2:E50');
Data = xlsread('PointsTest','Foglio1','A1:E51');


Bdata = Data(:,:);

k0 = [0.01 0.005 0.0008];

opts = optimset('MaxFunEvals',100000);

xsol = fminsearch(@(par)sum_error(Bdata(:,5),Bdata(:,2),par),k0,opts)

% x = fmincon(@(par)sum_error(Bdata(1:end,1),Bdata(1:end,3),par),k0,[],[],[],[],[0 0 0],[100 100 100])
        
% parvect = [0.1 0.1 0.02];

x0 = [Bdata(1,1) Bdata(1,2) Bdata(1,3) Bdata(1,4)];
[t,x] = ode23s(@(time,x)Covid19(time,x,xsol),(0:2:100),x0);

figure
plot(Bdata(:,5),Bdata(:,2),'o','MarkerSize',5,'MarkerEdgeColor',[0,0.4470,0.7410],...
                 'MarkerFaceColor',[0,0.4470,0.7410])
hold on
plot(t,x(:,1),'linewidth',1.3)
plot(t,x(:,2),'linewidth',1.3)
plot(t,x(:,3),'linewidth',1.3)
plot(t,x(:,4),'linewidth',1.3)
legend('dati B','A','B','C','D')
grid on
xlabel('time [day]')