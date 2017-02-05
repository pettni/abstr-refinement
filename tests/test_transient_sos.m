%% Main function to generate tests
function tests = exampleTest
  tests = functiontests(localfunctions);
end

%% Test Functions
function test_transient1(testCase)
  r = Rec([0 0; 1 1]);
  A1 = [0 0; 0 0];
  K1 = [1; 0];
  A2 = [0 0; 0 0];
  K2 = [0; 1];

  sdpvar x y;
  vars = [x; y];

  dyn_list = {A1*vars + K1, A2*vars + K2};

  verifyEqual(testCase, is_transient_nlin(r, {dyn_list{1}}, vars, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {dyn_list{2}}, vars, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, dyn_list, vars, [], 4), true);
end

function test_transient2(testCase)
  r = Rec([0 0; 1 1]);
  A1 = [0 0; 0 0];
  K1 = [1; 0];
  A2 = [0 0; 0 0];
  K2 = [-1; 0];

  sdpvar x y;
  vars = [x; y];

  dyn_list = {A1*vars + K1, A2*vars + K2};

  verifyEqual(testCase, is_transient_nlin(r, {dyn_list{1}}, vars, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {dyn_list{2}}, vars, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, dyn_list, vars, [], 4), false);
end

function test_transient3(testCase)
  r = Rec([-1 -1 -1; 1 1 1]);
  A1 = [-1 0 0; 0 -1 0; 0 0 -1];
  K1 = [0; 0; 0.1];
  A2 = [-1 0 0; 0 -1 0; 0 0 -1];
  K2 = [0; 0; 0.1];

  sdpvar x y z;
  vars = [x; y; z];

  dyn_list = {A1*vars + K1, A2*vars + K2};

  verifyEqual(testCase, is_transient_nlin(r, {dyn_list{1}}, vars, [], 4), false);
  verifyEqual(testCase, is_transient_nlin(r, {dyn_list{2}}, vars, [], 4), false);
  verifyEqual(testCase, is_transient_nlin(r, dyn_list, vars, [], 4), false);
end

function test_radiant1(testCase)
  r = Rec([20 28; 20 28; 20 28]);

  % These are from the CDC'14 paper
  % Crucial to divide by 10!
  A1 = [-0.0089    0.0020    0.0019;
        0.0040   -0.0073    0.0030;
        0.0040    0.0020   -0.0062];
  K1 = [0.0900;
    0.0107;
    0.1020/10];

  A2 = [-0.0039    0.0020    0.0019;
    0.0040   -0.0073    0.0030;
    0.0040    0.0020   -0.0062];
  K2 = [0;
    0.0107;
    0.1020/10];

  x = sdpvar(3,1);
  fx1 = A1*x + K1;
  fx2 = A2*x + K2;

  verifyEqual(testCase, is_transient_nlin(r, {fx1}, x, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {fx2}, x, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {fx1, fx2}, x, [], 4), false);
end

function test_radiant2(testCase)
  r = Rec([20 28; 20 28; 20 28]);

  % These are the "newer ones"
  A1 = 1e-3 * [   -0.0413    0.0106    0.0080;
    0.4377   -0.4869    0.0260;
    0.4377    0.0346   -0.4955];
  K1 = [0.0004;
    0.0010;
    0.0011];

  A2 = 1e-3 * [-0.0186    0.0106    0.0080;
    0.4377   -0.4869    0.0260;
    0.4377    0.0346   -0.4955];
  K2 = [0;
    0.0010;
    0.0011];

  x = sdpvar(3,1);
  fx1 = A1*x + K1;
  fx2 = A2*x + K2;

  verifyEqual(testCase, is_transient_nlin(r, {fx1}, x, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {fx2}, x, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {fx1, fx2}, x, [], 4), false);
end


function test_disturbance(testCase)
  r = Rec([-1 -1; 1 1]);
  A = [0 0; 0 0];
  B = [1; 0];
  E = [1; 0];

  x = sdpvar(2,1);
  d = sdpvar(1,1);

  drec = Rec([-1.1, 1.1]);

  verifyEqual(testCase, is_transient_nlin(r, {A*x+B}, x, [], 4), true);
  verifyEqual(testCase, is_transient_nlin(r, {A*x+B+E*d}, x, drec, 4), false);

end

function setupOnce(testCase)  % do not change function name
  global ops
  ops = sdpsettings('solver', 'mosek', 'cachesolvers', 1, 'verbose', 0);
end