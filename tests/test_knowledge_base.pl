%% FILE: test_knowledge_base.pl
%% OWNER: Person 6
%% DEPS: knowledge_base.pl
%% PURPOSE: Unit tests for Person 1's knowledge base module

:- ensure_loaded('../knowledge_base.pl').

% ============================================================
% TEST SUITE 1: GROUP DEFINITIONS
% ============================================================

test_groups_exist :-
    findall(GroupId, group(GroupId, _), Groups),
    length(Groups, Count),
    Count > 0,
    write('? Groups exist test: PASS'), nl.

test_groups_valid_sizes :-
    findall(G-S, group(G, S), GroupSizes),
    forall(member(_G-S, GroupSizes), (integer(S), S > 0)),
    write('? Group sizes valid test: PASS'), nl.

test_groups_uniqueness :-
    findall(GroupId, group(GroupId, _), Groups),
    sort(Groups, SortedGroups),
    length(Groups, Len1),
    length(SortedGroups, Len2),
    Len1 = Len2,
    write('? Group uniqueness test: PASS'), nl.

% ============================================================
% TEST SUITE 2: BUILDING DEFINITIONS
% ============================================================

test_buildings_exist :-
    findall(BuildingId, building(BuildingId, _), Buildings),
    length(Buildings, Count),
    Count > 0,
    write('? Buildings exist test: PASS'), nl.

test_buildings_energy_limits :-
    findall(B-E, building(B, E), BuildingEnergy),
    forall(member(_B-E, BuildingEnergy), (integer(E), E > 0)),
    write('? Building energy limits test: PASS'), nl.

% ============================================================
% TEST SUITE 3: ROOM DEFINITIONS
% ============================================================

test_rooms_exist :-
    findall(RoomId, room(RoomId, _, _, _, _), Rooms),
    length(Rooms, Count),
    Count > 0,
    write('? Rooms exist test: PASS'), nl.

test_rooms_valid_capacity :-
    findall(R-Cap, room(R, Cap, _, _, _), RoomCapacities),
    forall(member(_R-Cap, RoomCapacities), (integer(Cap), Cap > 0)),
    write('? Room capacity test: PASS'), nl.

test_rooms_valid_equipment :-
    ValidEquipment = [standard, projector, lab_computer, whiteboard_plus],
    findall(Eq, room(_, _, Eq, _, _), Equipment),
    forall((member(Eq, Equipment)), member(Eq, ValidEquipment)),
    write('? Room equipment test: PASS'), nl.

test_rooms_valid_building :-
    findall(B, room(_, _, _, B, _), Buildings),
    forall(member(B, Buildings), building(B, _)),
    write('? Room building references test: PASS'), nl.

test_rooms_valid_energy_cost :-
    findall(Cost, room(_, _, _, _, Cost), Costs),
    forall(member(Cost, Costs), (number(Cost), Cost >= 0)),
    write('? Room energy cost test: PASS'), nl.

% ============================================================
% TEST SUITE 4: COURSE DEFINITIONS
% ============================================================

test_courses_exist :-
    findall(CourseId, course(CourseId, _, _, _, _, _), Courses),
    length(Courses, Count),
    Count > 0,
    write('? Courses exist test: PASS'), nl.

test_courses_valid_sessions :-
    findall(C-Sessions, course(C, Sessions, _, _, _, _), CoursesSessions),
    forall(member(_C-Sessions, CoursesSessions), (integer(Sessions), Sessions > 0)),
    write('? Course sessions test: PASS'), nl.

test_courses_valid_duration :-
    findall(C-Duration, course(C, _, Duration, _, _, _), CoursesDuration),
    forall(member(_C-Duration, CoursesDuration), (integer(Duration), Duration > 0)),
    write('? Course duration test: PASS'), nl.

test_courses_valid_group :-
    findall(G, course(_, _, _, G, _, _), Groups),
    forall(member(G, Groups), group(G, _)),
    write('? Course group references test: PASS'), nl.

test_courses_valid_equipment :-
    ValidEquipment = [standard, projector, lab_computer, whiteboard_plus],
    findall(Eq, course(_, _, _, _, Eq, _), Equipment),
    forall((member(Eq, Equipment)), member(Eq, ValidEquipment)),
    write('? Course equipment test: PASS'), nl.

% ============================================================
% TEST SUITE 5: TIMESLOT DEFINITIONS
% ============================================================

test_timeslots_exist :-
    findall(TimeslotId, timeslot(TimeslotId, _, _), Timeslots),
    length(Timeslots, Count),
    Count > 0,
    write('? Timeslots exist test: PASS'), nl.

test_timeslots_valid_days :-
    ValidDays = [monday, tuesday, wednesday, thursday, friday],
    findall(Day, timeslot(_, Day, _), Days),
    forall(member(Day, Days), member(Day, ValidDays)),
    write('? Timeslot days test: PASS'), nl.

test_timeslots_valid_hours :-
    findall(Hour, timeslot(_, _, Hour), Hours),
    forall(member(Hour, Hours), (integer(Hour), Hour >= 8, Hour =< 16)),
    write('? Timeslot hours test: PASS'), nl.

% ============================================================
% TEST SUITE 6: INSTRUCTOR AVAILABILITY
% ============================================================

test_instructor_availability_exists :-
    findall(C-T, instructor_available(C, T), AvailList),
    length(AvailList, Count),
    Count > 0,
    write('? Instructor availability exists test: PASS'), nl.

test_instructor_availability_valid_courses :-
    findall(CourseId, instructor_available(CourseId, _), Courses),
    forall(member(CourseId, Courses), course(CourseId, _, _, _, _, _)),
    write('? Instructor availability courses test: PASS'), nl.

test_instructor_availability_valid_timeslots :-
    findall(TimeslotId, instructor_available(_, TimeslotId), Timeslots),
    forall(member(TimeslotId, Timeslots), timeslot(TimeslotId, _, _)),
    write('? Instructor availability timeslots test: PASS'), nl.

% ============================================================
% MAIN TEST RUNNER
% ============================================================

run_knowledge_base_tests :-
    writeln('+------------------------------------------------------------+'),
    writeln('�        KNOWLEDGE BASE TESTS - COMPREHENSIVE SUITE           �'),
    writeln('+------------------------------------------------------------+'),
    nl,
    writeln('GROUP TESTS:'),
    run_test_safe(test_groups_exist, test_groups_exist),
    run_test_safe(test_groups_valid_sizes, test_groups_valid_sizes),
    run_test_safe(test_groups_uniqueness, test_groups_uniqueness),
    nl,
    writeln('BUILDING TESTS:'),
    run_test_safe(test_buildings_exist, test_buildings_exist),
    run_test_safe(test_buildings_energy_limits, test_buildings_energy_limits),
    nl,
    writeln('ROOM TESTS:'),
    run_test_safe(test_rooms_exist, test_rooms_exist),
    run_test_safe(test_rooms_valid_capacity, test_rooms_valid_capacity),
    run_test_safe(test_rooms_valid_equipment, test_rooms_valid_equipment),
    run_test_safe(test_rooms_valid_building, test_rooms_valid_building),
    run_test_safe(test_rooms_valid_energy_cost, test_rooms_valid_energy_cost),
    nl,
    writeln('COURSE TESTS:'),
    run_test_safe(test_courses_exist, test_courses_exist),
    run_test_safe(test_courses_valid_sessions, test_courses_valid_sessions),
    run_test_safe(test_courses_valid_duration, test_courses_valid_duration),
    run_test_safe(test_courses_valid_group, test_courses_valid_group),
    run_test_safe(test_courses_valid_equipment, test_courses_valid_equipment),
    nl,
    writeln('TIMESLOT TESTS:'),
    run_test_safe(test_timeslots_exist, test_timeslots_exist),
    run_test_safe(test_timeslots_valid_days, test_timeslots_valid_days),
    run_test_safe(test_timeslots_valid_hours, test_timeslots_valid_hours),
    nl,
    writeln('INSTRUCTOR AVAILABILITY TESTS:'),
    run_test_safe(test_instructor_availability_exists, test_instructor_availability_exists),
    run_test_safe(test_instructor_availability_valid_courses, test_instructor_availability_valid_courses),
    run_test_safe(test_instructor_availability_valid_timeslots, test_instructor_availability_valid_timeslots),
    nl,
    writeln('All knowledge base tests completed!'), nl.
