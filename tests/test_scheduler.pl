%% FILE: test_scheduler.pl
%% OWNER: Person 6
%% DEPS: knowledge_base.pl, constraints.pl, scheduler.pl
%% PURPOSE: Unit tests for Person 3's scheduler module

:- ensure_loaded('knowledge_base.pl').
:- ensure_loaded('constraints.pl').
:- ensure_loaded('scheduler.pl').

:- if(\+ current_predicate(generate_schedule/1)).
generate_schedule(Schedule) :-
    findall(C, course(C, _, _, _, _, _), Courses),
    findall(T, timeslot(T, _, _), Timeslots),
    generate_schedule(Courses, Timeslots, Schedule).
:- endif.

% ============================================================
% TEST SUITE 1: SESSION REQUEST BUILDING
% ============================================================

test_build_session_requests :-
    Courses = [c1, c2],
    build_session_requests(Courses, Requests),
    length(Requests, NumRequests),
    NumRequests > 0,
    write('? Session request building: PASS'), nl.

% ============================================================
% TEST SUITE 2: ROOM COMPATIBILITY
% ============================================================

test_room_compatible_valid :-
    room_compatible(c1, r101),
    write('? Room compatibility check (valid): PASS'), nl.

test_room_compatible_invalid :-
    \+ room_compatible(c2, r101),
    write('? Room compatibility check (invalid): PASS'), nl.

% ============================================================
% TEST SUITE 3: COURSE-TO-SLOT ASSIGNMENT
% ============================================================

test_assign_course_to_slot :-
    SessionRequest = session(c1, 1),
    Timeslots = [t_mon_8, t_tue_10],
    assign_course_to_slot(SessionRequest, Timeslots, Assignment),
    Assignment = assignment(c1, 1, _RoomId, _TimeslotId),
    write('? Course-to-slot assignment: PASS'), nl.

% ============================================================
% TEST SUITE 4: SCHEDULE EXTENSION
% ============================================================

test_extend_schedule_empty :-
    Assignment = assignment(c1, 1, r101, t_mon_8),
    extend_schedule([], Assignment, ExtendedSchedule),
    ExtendedSchedule = [assignment(c1, 1, r101, t_mon_8)],
    write('? Schedule extension (empty): PASS'), nl.

test_extend_schedule_valid :-
    PartialSchedule = [assignment(c1, 1, r101, t_mon_8)],
    Assignment = assignment(c8, 1, r201, t_mon_10),   % c8: g3/lab_computer, r201: lab_computer cap30
    extend_schedule(PartialSchedule, Assignment, _ExtendedSchedule),
    write('? Schedule extension (valid): PASS'), nl.

% ============================================================
% TEST SUITE 5: FULL SCHEDULE GENERATION
% ============================================================

test_generate_schedule_single :-
    Courses = [c1, c7, c9],   % g1/g3/g4 — groupes distincts, salles disponibles
    all_timeslots(Timeslots),
    generate_schedule(Courses, Timeslots, Schedule),
    is_list(Schedule),
    length(Schedule, NumAssignments),
    NumAssignments > 0,
    write('  [ok] schedule generation (single): PASS'), nl.

test_schedule_validity :-
    Courses = [c1, c7, c9],
    all_timeslots(Timeslots),
    generate_schedule(Courses, Timeslots, Schedule),
    forall(
        member(Assignment, Schedule),
        (Assignment = assignment(CourseId, _, RoomId, TimeslotId),
         capacity_ok(CourseId, RoomId),
         equipment_ok(CourseId, RoomId),
         instructor_ok(CourseId, TimeslotId))
    ),
    write('? Schedule validity check: PASS'), nl.

% ============================================================
% TEST SUITE 6: PARTIAL SCHEDULE VALIDATION
% ============================================================

test_valid_partial_schedule_empty :-
    valid_partial_schedule([]),
    write('? Partial schedule validation (empty): PASS'), nl.

% ============================================================
% MAIN TEST RUNNER
% ============================================================

run_scheduler_tests :-
    writeln('+------------------------------------------------------------+'),
    writeln('�          SCHEDULER TESTS - COMPREHENSIVE SUITE             �'),
    writeln('+------------------------------------------------------------+'),
    nl,
    writeln('SESSION REQUEST TESTS:'),
    run_test_safe(test_build_session_requests, test_build_session_requests),
    nl,
    writeln('ROOM COMPATIBILITY TESTS:'),
    run_test_safe(test_room_compatible_valid, test_room_compatible_valid),
    run_test_safe(test_room_compatible_invalid, test_room_compatible_invalid),
    nl,
    writeln('COURSE-TO-SLOT ASSIGNMENT TESTS:'),
    run_test_safe(test_assign_course_to_slot, test_assign_course_to_slot),
    nl,
    writeln('SCHEDULE EXTENSION TESTS:'),
    run_test_safe(test_extend_schedule_empty, test_extend_schedule_empty),
    run_test_safe(test_extend_schedule_valid, test_extend_schedule_valid),
    nl,
    writeln('FULL SCHEDULE GENERATION TESTS:'),
    run_test_safe(test_generate_schedule_single, test_generate_schedule_single),
    run_test_safe(test_schedule_validity, test_schedule_validity),
    nl,
    writeln('PARTIAL SCHEDULE VALIDATION TESTS:'),
    run_test_safe(test_valid_partial_schedule_empty, test_valid_partial_schedule_empty),
    nl,
    writeln('All scheduler tests completed!'), nl.

:- begin_tests(scheduler).

test(build_session_requests_expands_sessions) :-
build_session_requests([c1, c2], Requests),
length(Requests, 3),
msort(Requests, Sorted),
Sorted == [session(c1, 1), session(c1, 2), session(c2, 1)].

test(assign_course_to_slot_produces_compatible_assignment, [nondet]) :-
once(assign_course_to_slot(session(c1, 1), [t_mon_8, t_mon_10], Assignment)),
Assignment = assignment(c1, 1, RoomId, TimeslotId),
memberchk(TimeslotId, [t_mon_8, t_mon_10]),
room_compatible(c1, RoomId),
instructor_available(c1, TimeslotId).

test(valid_partial_schedule_accepts_single_valid_assignment) :-
once(valid_partial_schedule([assignment(c1, 1, r101, t_mon_8)])).

test(valid_partial_schedule_rejects_room_conflict, [fail]) :-
valid_partial_schedule([
assignment(c1, 1, r101, t_tue_8),
assignment(c7, 1, r101, t_tue_8)
]).

test(valid_partial_schedule_rejects_group_conflict, [fail]) :-
valid_partial_schedule([
assignment(c1, 1, r101, t_tue_8),
assignment(c2, 1, r201, t_tue_8)
]).

test(extend_schedule_accepts_valid_addition) :-
once(extend_schedule([], assignment(c1, 1, r101, t_mon_8), Extended)),
Extended = [assignment(c1, 1, r101, t_mon_8)].

test(generate_schedule_for_single_course) :-
once(generate_schedule([c1], [t_mon_8, t_mon_10, t_tue_8, t_tue_14], Schedule)),
length(Schedule, 2),
once(valid_partial_schedule(Schedule)).

:- end_tests(scheduler).