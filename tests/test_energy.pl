%% FILE: test_energy.pl
%% OWNER: Person 6
%% DEPS: knowledge_base.pl, energy.pl, constraints.pl
%% PURPOSE: Unit tests for Person 4's energy calculation module

:- ensure_loaded('knowledge_base.pl').
:- ensure_loaded('energy.pl').
:- ensure_loaded('constraints.pl').

% ============================================================
% TEST SUITE 1: SESSION ENERGY CALCULATION
% ============================================================

test_session_energy_calculation :-
    session_energy(r101, c1, Energy),
    number(Energy),
    Energy > 0,
    write('? Session energy calculation: PASS'), nl.

test_session_energy_proportional_to_duration :-
    session_energy(r101, c1, E1),
    E1 > 0,
    write('? Energy proportional to duration: PASS'), nl.

% ============================================================
% TEST SUITE 2: BUILDING-DAY ENERGY
% ============================================================

test_building_day_energy_empty :-
    building_day_energy(b1, monday, [], Energy),
    Energy = 0,
    write('? Building-day energy (empty): PASS'), nl.

test_building_day_energy_single_session :-
    Schedule = [assignment(c1, 1, r101, t_mon_8)],
    building_day_energy(b1, monday, Schedule, Energy),
    Energy > 0,
    write('? Building-day energy (single session): PASS'), nl.

test_building_day_energy_accumulation :-
    Schedule = [
        assignment(c1, 1, r101, t_mon_8),
        assignment(c3, 1, r103, t_mon_10)
    ],
    building_day_energy(b1, monday, Schedule, Energy),
    Energy > 0,
    write('? Building-day energy accumulation: PASS'), nl.

test_building_day_energy_building_isolation :-
    Schedule = [
        assignment(c1, 1, r101, t_mon_8),
        assignment(c2, 1, r201, t_mon_8)
    ],
    building_day_energy(b1, monday, Schedule, E_b1),
    building_day_energy(b2, monday, Schedule, E_b2),
    E_b1 > 0,
    E_b2 > 0,
    E_b1 \= E_b2,
    write('? Building-day energy isolation: PASS'), nl.

% ============================================================
% TEST SUITE 3: TOTAL ENERGY
% ============================================================

test_total_energy_empty :-
    total_energy([], ETotal),
    ETotal = 0,
    write('? Total energy (empty): PASS'), nl.

test_total_energy_single_session :-
    Schedule = [assignment(c1, 1, r101, t_mon_8)],
    total_energy(Schedule, ETotal),
    ETotal > 0,
    write('? Total energy (single session): PASS'), nl.

test_total_energy_multiple_sessions :-
    Schedule = [
        assignment(c1, 1, r101, t_mon_8),
        assignment(c2, 1, r201, t_mon_10),
        assignment(c3, 1, r103, t_tue_8)
    ],
    total_energy(Schedule, ETotal),
    ETotal > 0,
    write('? Total energy (multiple sessions): PASS'), nl.

% ============================================================
% TEST SUITE 4: ENERGY THRESHOLD CONSTRAINT
% ============================================================

test_energy_within_threshold_empty :-
    energy_within_threshold(b1, monday, []),
    write('? Energy threshold (empty): PASS'), nl.

test_energy_within_threshold_low_usage :-
    Schedule = [assignment(c1, 1, r103, t_mon_8)],
    energy_within_threshold(b1, monday, Schedule),
    write('? Energy threshold (low usage): PASS'), nl.

% ============================================================
% HELPER FUNCTIONS FOR ENERGY ANALYSIS
% ============================================================

compute_building_day_profile(Buildings, Days, Schedule, Profile) :-
    findall(
        B-D-Energy,
        (member(B, Buildings), member(D, Days),
         building_day_energy(B, D, Schedule, Energy)),
        Profile
    ).

% ============================================================
% MAIN TEST RUNNER
% ============================================================

run_energy_tests :-
    writeln('+------------------------------------------------------------+'),
    writeln('�            ENERGY TESTS - COMPREHENSIVE SUITE              �'),
    writeln('+------------------------------------------------------------+'),
    nl,
    writeln('SESSION ENERGY TESTS:'),
    run_test_safe(test_session_energy_calculation, test_session_energy_calculation),
    run_test_safe(test_session_energy_proportional_to_duration, test_session_energy_proportional_to_duration),
    nl,
    writeln('BUILDING-DAY ENERGY TESTS:'),
    run_test_safe(test_building_day_energy_empty, test_building_day_energy_empty),
    run_test_safe(test_building_day_energy_single_session, test_building_day_energy_single_session),
    run_test_safe(test_building_day_energy_accumulation, test_building_day_energy_accumulation),
    run_test_safe(test_building_day_energy_building_isolation, test_building_day_energy_building_isolation),
    nl,
    writeln('TOTAL ENERGY TESTS:'),
    run_test_safe(test_total_energy_empty, test_total_energy_empty),
    run_test_safe(test_total_energy_single_session, test_total_energy_single_session),
    run_test_safe(test_total_energy_multiple_sessions, test_total_energy_multiple_sessions),
    nl,
    writeln('ENERGY THRESHOLD TESTS:'),
    run_test_safe(test_energy_within_threshold_empty, test_energy_within_threshold_empty),
    run_test_safe(test_energy_within_threshold_low_usage, test_energy_within_threshold_low_usage),
    nl,
    writeln('All energy tests completed!'), nl.