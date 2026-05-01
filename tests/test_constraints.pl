%% FILE: test_constraints.pl
%% OWNER: Person 6
%% DEPS: knowledge_base.pl, constraints.pl
%% PURPOSE: Unit tests for Person 2's constraint module

:- ensure_loaded('../knowledge_base.pl').
:- ensure_loaded('../constraints.pl').

% ============================================================
% TEST SUITE 1: CAPACITY CONSTRAINT (H1)
% ============================================================

test_capacity_ok_valid :-
    capacity_ok(c1, r101),
    write('? Capacity check (valid): PASS'), nl.

test_capacity_ok_invalid :-
    \+ capacity_ok(c4, r203),
    write('? Capacity check (invalid): PASS'), nl.

% ============================================================
% TEST SUITE 2: EQUIPMENT CONSTRAINT (H2)
% ============================================================

test_equipment_ok_valid :-
    equipment_ok(c2, r201),
    write('? Equipment check (valid): PASS'), nl.

test_equipment_ok_invalid :-
    \+ equipment_ok(c2, r101),
    write('? Equipment check (invalid): PASS'), nl.

% ============================================================
% TEST SUITE 3: INSTRUCTOR AVAILABILITY (H3)
% ============================================================

test_instructor_ok_available :-
    instructor_ok(c1, t_mon_8),
    write('? Instructor check (available): PASS'), nl.

test_instructor_ok_unavailable :-
    \+ instructor_ok(c1, t_fri_10),
    write('? Instructor check (unavailable): PASS'), nl.

% ============================================================
% TEST SUITE 4: ROOM CONFLICT (H4)
% ============================================================

test_no_room_conflict_empty_schedule :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    no_room_conflict(Assignment, []),
    write('? Room conflict check (empty schedule): PASS'), nl.

test_no_room_conflict_no_conflict :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    ExistingSchedule = [assignment(c2, 1, r102, t_mon_8)],
    no_room_conflict(Assignment, ExistingSchedule),
    write('? Room conflict check (no conflict): PASS'), nl.

test_no_room_conflict_conflict_detected :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    ExistingSchedule = [assignment(c2, 1, r101, t_mon_8)],
    \+ no_room_conflict(Assignment, ExistingSchedule),
    write('? Room conflict check (conflict detected): PASS'), nl.

% ============================================================
% TEST SUITE 5: GROUP CONFLICT (H5)
% ============================================================

test_no_group_conflict_empty_schedule :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    no_group_conflict(Assignment, []),
    write('? Group conflict check (empty schedule): PASS'), nl.

test_no_group_conflict_no_conflict :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    ExistingSchedule = [assignment(c4, 1, r102, t_mon_8)],
    no_group_conflict(Assignment, ExistingSchedule),
    write('? Group conflict check (no conflict): PASS'), nl.

test_no_group_conflict_conflict_detected :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    ExistingSchedule = [assignment(c2, 1, r102, t_mon_8)],
    \+ no_group_conflict(Assignment, ExistingSchedule),
    write('? Group conflict check (conflict detected): PASS'), nl.

% ============================================================
% TEST SUITE 6: ENERGY CONSTRAINT (H6)
% ============================================================

test_energy_within_threshold_ok :-
    energy_within_threshold(b1, monday, [assignment(c1, 1, r103, t_mon_8)]),
    write('? Energy threshold check (within): PASS'), nl.

% ============================================================
% INTEGRATED TESTS: ALL CONSTRAINTS
% ============================================================

test_all_constraints_valid_assignment :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    all_constraints_ok(Assignment, []),
    write('? All constraints check (valid): PASS'), nl.

% ============================================================
% PLUNIT DATA INTEGRITY CHECK
% ============================================================

test_plunit_data_integrity :-
    ( course(c9, _, _, _, _, _) ->
        write('  [ok] c9 exists for PLUnit tests')
    ;
        write('  [WARN] c9 not found - PLUnit capacity test may fail')
    ), nl,
    ( course(c8, _, _, _, _, _) ->
        write('  [ok] c8 exists for PLUnit tests')
    ;
        write('  [WARN] c8 not found - PLUnit group test may fail')
    ), nl,
    ( timeslot(t_wed_12, _, _) ->
        write('  [ok] t_wed_12 exists for PLUnit tests')
    ;
        write('  [WARN] t_wed_12 not found - PLUnit instructor test may fail')
    ), nl.

% ============================================================
% MAIN TEST RUNNER
% ============================================================

run_constraint_tests :-
    writeln('+------------------------------------------------------------+'),
    writeln('�         CONSTRAINT VALIDATION TESTS - FULL SUITE            �'),
    writeln('+------------------------------------------------------------+'),
    nl,
    test_plunit_data_integrity,
    nl,
    writeln('CAPACITY CONSTRAINT (H1):'),
    run_test_safe(test_capacity_ok_valid, test_capacity_ok_valid),
    run_test_safe(test_capacity_ok_invalid, test_capacity_ok_invalid),
    nl,
    writeln('EQUIPMENT CONSTRAINT (H2):'),
    run_test_safe(test_equipment_ok_valid, test_equipment_ok_valid),
    run_test_safe(test_equipment_ok_invalid, test_equipment_ok_invalid),
    nl,
    writeln('INSTRUCTOR AVAILABILITY (H3):'),
    run_test_safe(test_instructor_ok_available, test_instructor_ok_available),
    run_test_safe(test_instructor_ok_unavailable, test_instructor_ok_unavailable),
    nl,
    writeln('ROOM CONFLICT CONSTRAINT (H4):'),
    run_test_safe(test_no_room_conflict_empty_schedule, test_no_room_conflict_empty_schedule),
    run_test_safe(test_no_room_conflict_no_conflict, test_no_room_conflict_no_conflict),
    run_test_safe(test_no_room_conflict_conflict_detected, test_no_room_conflict_conflict_detected),
    nl,
    writeln('GROUP CONFLICT CONSTRAINT (H5):'),
    run_test_safe(test_no_group_conflict_empty_schedule, test_no_group_conflict_empty_schedule),
    run_test_safe(test_no_group_conflict_no_conflict, test_no_group_conflict_no_conflict),
    run_test_safe(test_no_group_conflict_conflict_detected, test_no_group_conflict_conflict_detected),
    nl,
    writeln('ENERGY CONSTRAINT (H6):'),
    run_test_safe(test_energy_within_threshold_ok, test_energy_within_threshold_ok),
    nl,
    writeln('INTEGRATED TESTS:'),
    run_test_safe(test_all_constraints_valid_assignment, test_all_constraints_valid_assignment),
    nl,
    writeln('All constraint tests completed!'), nl.

:- begin_tests(constraints).

% Test H1 : Capacit�
% g1 a 30 �tudiants. r101 a 40 places -> �a doit marcher (true).
% g4 a 35 �tudiants. r103 a 30 places -> �a doit �chouer (fail).
test(capacity_ok_success) :- capacity_ok(c1, r101).
test(capacity_fail, [fail]) :- capacity_ok(c9, r103).

% Test H2 : �quipements
% c1 a besoin de 'projector'. r101 a 'projector' -> success.
% c2 a besoin de 'lab_computer'. r101 a 'projector' -> fail.
test(equipment_ok_success) :- equipment_ok(c1, r101).
test(equipment_fail, [fail]) :- equipment_ok(c2, r101).

% Test H3 : Disponibilit� du prof
% prof_ali (c1) est dispo le monday_8 -> success.
% prof_ali (c1) n'est PAS dispo le wednesday_12 -> fail.
test(instructor_ok_success) :- instructor_ok(c1, t_mon_8).
test(instructor_fail, [fail]) :- instructor_ok(c1, t_wed_12).

% Test H4 : Conflits de salle
% Si la salle r101 est d�j� prise � t_mon_8, on ne peut pas l'assigner � nouveau.
test(no_room_conflict_success) :-
    no_room_conflict(assignment(c1, 1, r101, t_mon_8), []).
test(room_conflict_fail, [fail]) :-
    no_room_conflict(assignment(c1, 1, r101, t_mon_8), [assignment(c2, 1, r101, t_mon_8)]).

% Test H5 : Conflits de groupe
% Si le groupe g1 (cours c1) a d�j� un cours � t_mon_8, on ne peut pas lui mettre c2 en m�me temps.
test(no_group_conflict_success) :-
    no_group_conflict(assignment(c2, 1, r201, t_mon_8), [assignment(c8, 1, r202, t_mon_8)]).
test(group_conflict_fail, [fail]) :-
    no_group_conflict(assignment(c2, 1, r201, t_mon_8), [assignment(c1, 1, r101, t_mon_8)]).

:- end_tests(constraints).

run_plunit_tests :- run_tests.
