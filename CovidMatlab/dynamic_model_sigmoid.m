function dy = dynamic_model_sigmoid(t,x,theta)

% Population
A = x(1);       % Alive
B = x(2);       % Infected
% C = x(3);     % Cured
% D = x(4);     % Deceased

% Feasibility check
if A < 0
    A = 0;
end
if B < 0
    B = 0;
end

% Parameters
r1 = theta(1);
r2 = theta(2);
r3 = theta(3);
t_exp = theta(4);
t_lag = theta(5);

% Sigmoid modification
r1 = r1 * sigmoid(t,t_exp,t_lag);
r2 = r2 * sigmoid(t,t_exp,t_lag);
r3 = r3 * sigmoid(t,t_exp,t_lag);

% ODE system
dy(1) = - r1*A;
dy(2) = r1*A - (r2 + r3)*B;
dy(3) = r2*B;
dy(4) = r3*B;

dy = dy';

end


function sigmoid_return = sigmoid(t, t_exp, t_lag)
   sigmoid_return = 1 / (1 + exp(-t*t_exp + t_lag));
end

function sigmoid_return_deriv = sigmoid_deriv(t, t_exp, t_lag)
   sigmoid_return_deriv = (1 / (1 + exp(-t*t_exp + t_lag)))*(1-(1 / (1 + exp(-t*t_exp + t_lag))));
end
