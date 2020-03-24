function sum_sq_error = sum_error(t_vector,x_set,x0,theta)


% options = odeset('RelTol',1.0e-9,'AbsTol',1.0e-12);
options = odeset('RelTol',1.0e-6,'AbsTol',1.0e-6);

[t,x] = ode45(@(t,x)dynamic_model_sigmoid(t,x,theta),t_vector,x0,options);

% Remove parameter A from regression due to instability
x(:,1) = [];
x_set(:,1) = [];

m = size(x_set, 1) * size(x_set, 2);

% sum_sq_error = 1/2/m * sum(sum(((x_set - x).*(t + 1)*2).^2));
% sum_sq_error = 1/2/m * sum(sum(((x_set - x).*(t + 1)).^2));
sum_sq_error = 1/2/m * sum(sum(((x_set - x).^2).*(t + 1)));
% sum_sq_error = 1/2/m * sum(sum((x_set - x).^2));


% display(theta)
% display(sum_sq_error)

end