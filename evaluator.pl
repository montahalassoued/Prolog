% ============================================================
% MODULE : EVALUATOR (Person 5)
% ============================================================
% This file evaluates an already-generated schedule with three
% optimization metrics:
%   - total weekly energy consumption
%   - daily energy imbalance across buildings
%   - room usage variance
%
% Assignment format used in this project:
%   assignment(CourseId, SessionIdx, RoomId, TimeslotId)
% ============================================================

:- ensure_loaded('knowledge_base.pl').
:- ensure_loaded('energy.pl').

% ------------------------------------------------------------
% Public predicates for Person 5
% ------------------------------------------------------------

% schedule_score(+Schedule, -Score) is det.
% Computes the full evaluation tuple used by the optimizer.
schedule_score(Schedule, score(ETotal, Imbalance, Variance)) :-
    total_energy(Schedule, ETotal),
    daily_imbalance(Schedule, Imbalance),
    room_usage_variance(Schedule, Variance).

% daily_imbalance(+Schedule, -Imbalance) is det.
% Imbalance = sum over all days of (Emax_day - Emin_day),
% where Emax_day and Emin_day are the maximum and minimum
% building energies observed on that day.
daily_imbalance(Schedule, Imbalance) :-
    all_days(Days),
    daily_imbalance_acc(Days, Schedule, 0, Imbalance).

% compute_emax_day(+DaySchedule, -MaxE) is det.
% Expects a schedule already restricted to one day and returns
% the highest building energy for that day.
compute_emax_day([], 0).
compute_emax_day(DaySchedule, MaxE) :-
    schedule_day(DaySchedule, Day),
    building_day_energies(DaySchedule, Day, Energies),
    max_energy(Energies, MaxE).

% compute_emin_day(+DaySchedule, -MinE) is det.
% Expects a schedule already restricted to one day and returns
% the lowest building energy for that day.
compute_emin_day([], 0).
compute_emin_day(DaySchedule, MinE) :-
    schedule_day(DaySchedule, Day),
    building_day_energies(DaySchedule, Day, Energies),
    min_energy(Energies, MinE).

% room_usage(+RoomId, +Schedule, -Count) is det.
% Counts how many assignments are placed in a given room.
room_usage(RoomId, Schedule, Count) :-
    findall(assignment(CourseId, SessionIdx, RoomId, TimeslotId),
            member(assignment(CourseId, SessionIdx, RoomId, TimeslotId), Schedule),
            RoomAssignments),
    count_items(RoomAssignments, Count).

% room_usage_variance(+Schedule, -Variance) is det.
% Var(R) = (1 / m) * sum((Usage(Room) - Mean)^2)
% where m is the total number of rooms in the knowledge base.
room_usage_variance(Schedule, Variance) :-
    all_rooms(Rooms),
    count_items(Rooms, RoomCount),
    accumulate_room_usage(Rooms, Schedule, 0, TotalUsage),
    Mean is TotalUsage / RoomCount,
    accumulate_squared_differences(Rooms, Schedule, Mean, 0, SumSquares),
    Variance is SumSquares / RoomCount.

% ------------------------------------------------------------
% Internal helpers
% ------------------------------------------------------------

% all_days(-Days) is det.
% Returns the distinct teaching days defined in the knowledge base.
all_days(Days) :-
    findall(Day, timeslot(_, Day, _), DaysWithDuplicates),
    sort(DaysWithDuplicates, Days).

% all_buildings(-Buildings) is det.
% Returns all buildings defined in the knowledge base.
all_buildings(Buildings) :-
    findall(BuildingId, building(BuildingId, _), Buildings).

% daily_imbalance_acc(+Days, +Schedule, +Acc, -Imbalance) is det.
% Accumulator over all days of the week.
daily_imbalance_acc([], _, Acc, Acc).
daily_imbalance_acc([Day | Rest], Schedule, Acc, Imbalance) :-
    schedule_for_day(Day, Schedule, DaySchedule),
    compute_emax_day(DaySchedule, MaxE),
    compute_emin_day(DaySchedule, MinE),
    DayGap is MaxE - MinE,
    NewAcc is Acc + DayGap,
    daily_imbalance_acc(Rest, Schedule, NewAcc, Imbalance).

% schedule_for_day(+Day, +Schedule, -DaySchedule) is det.
% Extracts the assignments scheduled on one specific day.
schedule_for_day(Day, Schedule, DaySchedule) :-
    findall(assignment(CourseId, SessionIdx, RoomId, TimeslotId),
            (
                member(assignment(CourseId, SessionIdx, RoomId, TimeslotId), Schedule),
                timeslot_day(TimeslotId, Day)
            ),
            DaySchedule).

% schedule_day(+DaySchedule, -Day) is semidet.
% Retrieves the day represented by a single-day sub-schedule.
schedule_day([assignment(_, _, _, TimeslotId) | _], Day) :-
    timeslot_day(TimeslotId, Day).

% building_day_energies(+Schedule, +Day, -Energies) is det.
% Collects E(Building, Day) for every building.
building_day_energies(Schedule, Day, Energies) :-
    all_buildings(Buildings),
    findall(Energy,
            (
                member(BuildingId, Buildings),
                building_day_energy(BuildingId, Day, Schedule, Energy)
            ),
            Energies).

% max_energy(+Energies, -MaxE) is det.
% Returns the maximum value in a non-empty list of energies.
max_energy([Energy], Energy).
max_energy([Energy | Rest], MaxE) :-
    max_energy(Rest, RestMax),
    greater_energy(Energy, RestMax, MaxE).

% min_energy(+Energies, -MinE) is det.
% Returns the minimum value in a non-empty list of energies.
min_energy([Energy], Energy).
min_energy([Energy | Rest], MinE) :-
    min_energy(Rest, RestMin),
    smaller_energy(Energy, RestMin, MinE).

% greater_energy(+E1, +E2, -MaxE) is det.
% Chooses the greater of two numeric energies.
greater_energy(E1, E2, MaxE) :-
    (
        E1 > E2 ->
        MaxE = E1
    ;
        MaxE = E2
    ).

% smaller_energy(+E1, +E2, -MinE) is det.
% Chooses the smaller of two numeric energies.
smaller_energy(E1, E2, MinE) :-
    (
        E1 < E2 ->
        MinE = E1
    ;
        MinE = E2
    ).

% count_items(+List, -Count) is det.
% Counts the number of elements in a list.
count_items(List, Count) :-
    count_items_acc(List, 0, Count).

% count_items_acc(+List, +Acc, -Count) is det.
% Recursive accumulator for list length.
count_items_acc([], Acc, Acc).
count_items_acc([_ | Rest], Acc, Count) :-
    NewAcc is Acc + 1,
    count_items_acc(Rest, NewAcc, Count).

% accumulate_room_usage(+Rooms, +Schedule, +Acc, -TotalUsage) is det.
% Sums the usage counts of all rooms.
accumulate_room_usage([], _, Acc, Acc).
accumulate_room_usage([RoomId | Rest], Schedule, Acc, TotalUsage) :-
    room_usage(RoomId, Schedule, Usage),
    NewAcc is Acc + Usage,
    accumulate_room_usage(Rest, Schedule, NewAcc, TotalUsage).

% accumulate_squared_differences(+Rooms, +Schedule, +Mean, +Acc, -Total) is det.
% Sums squared deviations from the average room usage.
accumulate_squared_differences([], _, _, Acc, Acc).
accumulate_squared_differences([RoomId | Rest], Schedule, Mean, Acc, Total) :-
    room_usage(RoomId, Schedule, Usage),
    Difference is Usage - Mean,
    Square is Difference * Difference,
    NewAcc is Acc + Square,
    accumulate_squared_differences(Rest, Schedule, Mean, NewAcc, Total).
