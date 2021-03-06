function tests = exampleTest
  tests = functiontests(localfunctions);
end

function test_invariance(testCase)
    ts = TransSyst(3,2);
    ts.add_transition(1,2,1);
    ts.add_transition(2,1,1);
    ts.add_transition(1,3,2);
    ts.add_transition(2,3,2);
    ts.add_transition(3,2,1);
    ts.add_transition(3,3,1);
    ts.add_transition(3,3,2);

    [~, cont1] = ts.pre([1], uint32(1:2), 'exists', 'forall');

    verifyEqual(testCase, cont1(2), uint32(1));

    [W, ~, cont2] = ts.win_primal([1, 2], [], [], 'exists', 'forall');

    verifyEqual(testCase, cont2(1), uint32(1));
    verifyEqual(testCase, cont2(2), uint32(1));
end

function test_recurrence(testCase)
    ts = TransSyst(4,2);
    ts.add_transition(1,2,1);
    ts.add_transition(2,3,1);
    ts.add_transition(3,4,1);
    ts.add_transition(4,4,1);
    ts.add_transition(4,3,2);
    ts.add_transition(3,2,2);
    ts.add_transition(2,1,2);
    ts.add_transition(1,1,2);

    [~, ~, cont] = ts.win_primal([], [], {[1], [4]}, 'exists', 'forall');
    state = 1;

    count1 = 0;
    count4 = 0;
    for i = 1:40
        state = ts.post(state, cont(state));
        if state == 1
            count1 = count1 + 1;
        elseif state == 4
            count4 = count4 + 1;
        end
    end

    verifyGreaterThanOrEqual(testCase, count1, 5);
    verifyGreaterThanOrEqual(testCase, count4, 5);
end

function test_pginv(testCase)
    ts = TransSyst(5,2);
    ts.add_transition(4,1,1);
    ts.add_transition(4,3,1);
    ts.add_transition(4,5,2);
    
    ts.add_transition(3,4,1);
    ts.add_transition(3,5,2);

    ts.add_transition(1,2,1);
    ts.add_transition(1,4,2);

    ts.add_transition(2,1,1);
    ts.add_transition(2,4,2);

    ts.add_progress_group([1, 2], [3, 4]);

    [~, ~, cont1] = ts.pre_pg([1, 2], 1:4, true);
    verifyEqual(testCase, cont1(3), uint32(1));
    verifyEqual(testCase, cont1(4), uint32(1));

    [~, ~, cont2] = ts.win_primal([], [1, 2], [], 'exists', 'forall');

    for i=1:8
        verifyEqual(testCase, cont2(3), uint32(1));
        verifyEqual(testCase, cont2(4), uint32(1));
    end

    for i=1:8
        verifyEqual(testCase, cont2(1), uint32(1));
        verifyEqual(testCase, cont2(2), uint32(1));
    end
end

%% test_persistence: Zexiang's test
function [outputs] = test_persistence(testCase)
    ts = TransSyst(2,3);
    s1 = [1,2,2];
    a =  [1,2,3];
    s2 = [1,1,2];

    ts.add_transition(s1,s2,a);
    ts.trans_array_enable();

    B = [1];
    [W, ~, cont] = win_primal(ts, [], B, [], 'exists', 'forall');

    verifyEqual(testCase, cont(2), uint32(2));
    verifyEqual(testCase, cont(1), uint32(1));
end