% ============================================================
% MODULE : SCHEDULER (Person 3)
% ============================================================
% This file implements recursive generation of schedule candidates.
% Assignment format used in this project:
%   assignment(CourseId, SessionIdx, RoomId, TimeslotId)
% ============================================================

:- ensure_loaded('knowledge_base.pl').
:- ensure_loaded('constraints.pl').

% ------------------------------------------------------------
% Public predicates for Person 3
% ------------------------------------------------------------

% generate_schedule(+Courses, +Timeslots, -Schedule) is nondet.
% Builds a candidate schedule from selected courses and timeslots.
generate_schedule(Courses, Timeslots, Schedule) :-
	build_session_requests(Courses, Requests),
	schedule_sessions(Requests, Timeslots, [], RevSchedule),
	reverse(RevSchedule, Schedule).

% generate_schedule(-Schedule) is nondet.
% Convenience wrapper that uses all known courses and timeslots.
generate_schedule(Schedule) :-
	all_courses(Courses),
	all_timeslots(Timeslots),
	generate_schedule(Courses, Timeslots, Schedule).

% assign_course_to_slot(+SessionRequest, +Timeslots, -Assignment) is nondet.
% Proposes one assignment for a single required session.
assign_course_to_slot(session(CourseId, SessionIdx), Timeslots, assignment(CourseId, SessionIdx, RoomId, TimeslotId)) :-
	member(TimeslotId, Timeslots),
	room_compatible(CourseId, RoomId),
	instructor_available(CourseId, TimeslotId).

% extend_schedule(+PartialSchedule, +Assignment, -ExtendedSchedule) is semidet.
% Adds an assignment only if the resulting partial schedule is valid.
extend_schedule(PartialSchedule, Assignment, [Assignment | PartialSchedule]) :-
	valid_partial_schedule([Assignment | PartialSchedule]).

% valid_partial_schedule(+PartialSchedule) is semidet.
% Checks all hard constraints against the partial schedule.
valid_partial_schedule(PartialSchedule) :-
	valid_partial_schedule_(PartialSchedule, []).

% ------------------------------------------------------------
% Internal recursive engine
% ------------------------------------------------------------

% schedule_sessions(+Requests, +Timeslots, +Acc, -ScheduleAcc) is nondet.
% Recursively schedules each requested session.
schedule_sessions([], _Timeslots, Acc, Acc).
schedule_sessions([Request | Rest], Timeslots, Acc, ScheduleAcc) :-
	assign_course_to_slot(Request, Timeslots, Assignment),
	extend_schedule(Acc, Assignment, NextAcc),
	schedule_sessions(Rest, Timeslots, NextAcc, ScheduleAcc).

% build_session_requests(+Courses, -Requests) is det.
% Expands each course into session(CourseId, SessionIdx).
build_session_requests(Courses, Requests) :-
	findall(session(CourseId, SessionIdx),
			(
				member(CourseId, Courses),
				course_sessions(CourseId, SessionCount),
				between(1, SessionCount, SessionIdx)
			),
			Requests).

% valid_partial_schedule_(+Pending, +Checked) is semidet.
% Incremental validation: each assignment is checked against already-checked ones.
valid_partial_schedule_([], _Checked).
valid_partial_schedule_([Assignment | Rest], Checked) :-
	all_constraints_ok(Assignment, Checked),
	valid_partial_schedule_(Rest, [Assignment | Checked]).

