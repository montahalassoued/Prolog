%% FILE: run_tests.pl
%% OWNER: Person 6
%% DEPS: test_knowledge_base.pl, test_constraints.pl,
%%       test_scheduler.pl, test_energy.pl
%% PURPOSE: Central test orchestrator for all modules

:- ensure_loaded('test_knowledge_base.pl').
:- ensure_loaded('test_constraints.pl').
:- ensure_loaded('test_scheduler.pl').
:- ensure_loaded('test_energy.pl').

% ============================================================
% SAFETY WRAPPER FOR INDIVIDUAL TESTS
% ============================================================

run_test_safe(TestName, Goal) :-
    ( catch(Goal, Error, (
        format('  [ERROR] ~w threw: ~w~n', [TestName, Error]),
        fail
      ))
    -> true
    ; format('  [FAIL] ~w~n', [TestName])
    ).

% ============================================================
% TEST COUNTER FOR PASS/FAIL TRACKING
% ============================================================

run_test_counted(Name, Goal, Passed0, Passed1, Failed0, Failed1) :-
    ( catch(Goal, _Err, fail) ->
        Passed1 is Passed0 + 1,
        Failed1 = Failed0,
        format('  [ok] ~w~n', [Name])
    ;
        Failed1 is Failed0 + 1,
        Passed1 = Passed0,
        format('  [FAIL] ~w~n', [Name])
    ).

run_counted_tests([], Passed, Passed, Failed, Failed).
run_counted_tests([Name-Goal | Rest], Passed0, PassedN, Failed0, FailedN) :-
    run_test_counted(Name, Goal, Passed0, Passed1, Failed0, Failed1),
    run_counted_tests(Rest, Passed1, PassedN, Failed1, FailedN).

% ============================================================
% FULL TEST SUITE EXECUTION
% ============================================================

run_all_tests :-
    writeln('+------------------------------------------------------------+'),
    writeln('�          COMPREHENSIVE TEST SUITE - ALL MODULES             �'),
    writeln('+------------------------------------------------------------+'),
    nl,

    get_time(StartTime),

    KBTests = [
        test_groups_exist-test_groups_exist,
        test_groups_valid_sizes-test_groups_valid_sizes,
        test_groups_uniqueness-test_groups_uniqueness,
        test_buildings_exist-test_buildings_exist,
        test_buildings_energy_limits-test_buildings_energy_limits,
        test_rooms_exist-test_rooms_exist,
        test_rooms_valid_capacity-test_rooms_valid_capacity,
        test_rooms_valid_equipment-test_rooms_valid_equipment,
        test_rooms_valid_building-test_rooms_valid_building,
        test_rooms_valid_energy_cost-test_rooms_valid_energy_cost,
        test_courses_exist-test_courses_exist,
        test_courses_valid_sessions-test_courses_valid_sessions,
        test_courses_valid_duration-test_courses_valid_duration,
        test_courses_valid_group-test_courses_valid_group,
        test_courses_valid_equipment-test_courses_valid_equipment,
        test_timeslots_exist-test_timeslots_exist,
        test_timeslots_valid_days-test_timeslots_valid_days,
        test_timeslots_valid_hours-test_timeslots_valid_hours,
        test_instructor_availability_exists-test_instructor_availability_exists,
        test_instructor_availability_valid_courses-test_instructor_availability_valid_courses,
        test_instructor_availability_valid_timeslots-test_instructor_availability_valid_timeslots
    ],

    ConstraintTests = [
        test_capacity_ok_valid-test_capacity_ok_valid,
        test_capacity_ok_invalid-test_capacity_ok_invalid,
        test_equipment_ok_valid-test_equipment_ok_valid,
        test_equipment_ok_invalid-test_equipment_ok_invalid,
        test_instructor_ok_available-test_instructor_ok_available,
        test_instructor_ok_unavailable-test_instructor_ok_unavailable,
        test_no_room_conflict_empty_schedule-test_no_room_conflict_empty_schedule,
        test_no_room_conflict_no_conflict-test_no_room_conflict_no_conflict,
        test_no_room_conflict_conflict_detected-test_no_room_conflict_conflict_detected,
        test_no_group_conflict_empty_schedule-test_no_group_conflict_empty_schedule,
        test_no_group_conflict_no_conflict-test_no_group_conflict_no_conflict,
        test_no_group_conflict_conflict_detected-test_no_group_conflict_conflict_detected,
        test_energy_within_threshold_ok-test_energy_within_threshold_ok,
        test_all_constraints_valid_assignment-test_all_constraints_valid_assignment
    ],

    SchedulerTests = [
        test_build_session_requests-test_build_session_requests,
        test_room_compatible_valid-test_room_compatible_valid,
        test_room_compatible_invalid-test_room_compatible_invalid,
        test_assign_course_to_slot-test_assign_course_to_slot,
        test_extend_schedule_empty-test_extend_schedule_empty,
        test_extend_schedule_valid-test_extend_schedule_valid,
        test_generate_schedule_single-test_generate_schedule_single,
        test_schedule_validity-test_schedule_validity,
        test_valid_partial_schedule_empty-test_valid_partial_schedule_empty
    ],

    EnergyTests = [
        test_session_energy_calculation-test_session_energy_calculation,
        test_session_energy_proportional_to_duration-test_session_energy_proportional_to_duration,
        test_building_day_energy_empty-test_building_day_energy_empty,
        test_building_day_energy_single_session-test_building_day_energy_single_session,
        test_building_day_energy_accumulation-test_building_day_energy_accumulation,
        test_building_day_energy_building_isolation-test_building_day_energy_building_isolation,
        test_total_energy_empty-test_total_energy_empty,
        test_total_energy_single_session-test_total_energy_single_session,
        test_total_energy_multiple_sessions-test_total_energy_multiple_sessions,
        test_energy_within_threshold_empty-test_energy_within_threshold_empty,
        test_energy_within_threshold_low_usage-test_energy_within_threshold_low_usage
    ],

    writeln(''),
    writeln('- MODULE 1: KNOWLEDGE BASE -'),
    writeln(''),
    run_counted_tests(KBTests, 0, P1, 0, F1),

    writeln(''),
    writeln('- MODULE 2: CONSTRAINTS -'),
    writeln(''),
    run_counted_tests(ConstraintTests, P1, P2, F1, F2),

    writeln(''),
    writeln('- MODULE 3: SCHEDULER -'),
    writeln(''),
    run_counted_tests(SchedulerTests, P2, P3, F2, F3),

    writeln(''),
    writeln('- MODULE 4: ENERGY -'),
    writeln(''),
    run_counted_tests(EnergyTests, P3, Passed, F3, Failed),

    get_time(EndTime),
    TotalTime is EndTime - StartTime,

    nl,
    writeln('+------------------------------------------------------------+'),
    writeln('�                    FINAL SUMMARY                            �'),
    writeln('+------------------------------------------------------------+'),
    format('~nResult: ~w passed, ~w failed~n', [Passed, Failed]),
    format('Total test execution time: ~2f seconds~n', [TotalTime]),
    nl.

quick_run :-
    writeln('+------------------------------------------------------------+'),
    writeln('�                   QUICK TEST RUN                            �'),
    writeln('+------------------------------------------------------------+'),
    nl,

    writeln('Running critical tests...'), nl,

    run_test_safe(test_groups_exist, test_groups_exist),
    run_test_safe(test_rooms_exist, test_rooms_exist),
    run_test_safe(test_courses_exist, test_courses_exist),
    run_test_safe(test_capacity_ok_valid, test_capacity_ok_valid),
    run_test_safe(test_equipment_ok_valid, test_equipment_ok_valid),
    run_test_safe(test_generate_schedule_single, test_generate_schedule_single),
    run_test_safe(test_session_energy_calculation, test_session_energy_calculation),

    nl,
    writeln('Quick test run completed!'), nl.

test_menu :-
    repeat,
    nl,
    writeln('+------------------------------------------------------------+'),
    writeln('�             TEST SELECTION MENU                             �'),
    writeln('+------------------------------------------------------------+'),
    writeln('Select which tests to run:'),
    writeln('  1. Run all tests'),
    writeln('  2. Knowledge base tests only'),
    writeln('  3. Constraint tests only'),
    writeln('  4. Scheduler tests only'),
    writeln('  5. Energy tests only'),
    writeln('  6. Quick critical tests'),
    writeln('  7. Exit'),
    write('Choice (1-7): '),
    read(Choice),
    nl,

    (   Choice = 1 -> run_all_tests
    ;   Choice = 2 -> run_knowledge_base_tests
    ;   Choice = 3 -> run_constraint_tests
    ;   Choice = 4 -> run_scheduler_tests
    ;   Choice = 5 -> run_energy_tests
    ;   Choice = 6 -> quick_run
    ;   Choice = 7 -> (writeln('Exiting test menu...'), nl, !)
    ;   writeln('Invalid choice, please try again.')
    ).

count_entities :-
    writeln('+------------------------------------------------------------+'),
    writeln('�           DATABASE STATISTICS                              �'),
    writeln('+------------------------------------------------------------+'),
    nl,

    findall(_, group(_, _), Groups),
    length(Groups, G),
    format('Groups: ~w~n', [G]),

    findall(_, building(_, _), Buildings),
    length(Buildings, B),
    format('Buildings: ~w~n', [B]),

    findall(_, room(_, _, _, _, _), Rooms),
    length(Rooms, R),
    format('Rooms: ~w~n', [R]),

    findall(_, course(_, _, _, _, _, _), Courses),
    length(Courses, C),
    format('Courses: ~w~n', [C]),

    findall(_, timeslot(_, _, _), Timeslots),
    length(Timeslots, T),
    format('Timeslots: ~w~n', [T]),

    nl,
    Total is G + B + R + C + T,
    format('Total entities: ~w~n', [Total]),
    nl.

count_entities_safe :-
    ( current_predicate(group/2) ->
        count_entities
    ;
        writeln('[WARN] knowledge_base.pl not loaded - skipping stats')
    ).

main_tests :-
    run_all_tests,
    halt(0).
