/*
  File: tests/test_scheduler.pl
  Role: Unit tests for scheduler generation and partial validation.
*/

:- begin_tests(scheduler).

:- ensure_loaded('../scheduler.pl').

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
