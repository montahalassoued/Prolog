%% FILE: run_tests.pl
%% OWNER: Person 6
%% PURPOSE: Master test orchestrator — loads all test suites and runs them

:- ensure_loaded('../knowledge_base.pl').
:- ensure_loaded('../energy.pl').
:- ensure_loaded('../constraints.pl').
:- ensure_loaded('../scheduler.pl').
:- ensure_loaded('../evaluator.pl').
:- ensure_loaded('../optimizer.pl').

% run_test_safe(+Name, +Goal)
% Calls Goal; prints FAIL with name if it throws or fails.
run_test_safe(Name, Goal) :-
    ( catch(call(Goal), Error,
            (format('  FAIL [error]: ~w => ~w~n', [Name, Error]), fail))
    -> true
    ;  format('  FAIL: ~w~n', [Name])
    ).

% ============================================================
% MASTER RUNNER
% ============================================================

run_all_tests :-
    writeln('============================================================'),
    writeln('         FULL TEST SUITE — INSAT GL3 Scheduling System      '),
    writeln('============================================================'),
    nl,

    ensure_loaded('tests/test_knowledge_base.pl'),
    run_knowledge_base_tests,

    ensure_loaded('tests/test_energy.pl'),
    run_energy_tests,

    ensure_loaded('tests/test_constraints.pl'),
    run_constraint_tests,

    ensure_loaded('tests/test_scheduler.pl'),
    run_scheduler_tests,

    writeln('============================================================'),
    writeln('                  ALL SUITES COMPLETED                      '),
    writeln('============================================================'),
    nl.
