% ============================================================
% MAIN ORCHESTRATOR (Person 6)
% ============================================================
% This file coordinates the entire scheduling pipeline:
%   1. Load all modules in correct order
%   2. Generate candidate schedules
%   3. Optimize based on energy criteria
%   4. Display and benchmark results
%
% Team Member: Person 6
% Responsibilities:
%   - Pipeline orchestration
%   - Test framework
%   - Experimental analysis & reporting
% ============================================================

% Load all modules in dependency order
:- ensure_loaded('knowledge_base.pl').    % Core facts: rooms, courses, timeslots
:- ensure_loaded('constraints.pl').        % Hard constraint validation
:- ensure_loaded('energy.pl').             % Energy calculation module
:- ensure_loaded('evaluator.pl').          % Schedule scoring metrics
:- ensure_loaded('scheduler.pl').          % Schedule generation engine
:- ensure_loaded('optimizer.pl').          % Schedule comparison & optimization

% ============================================================
% SECTION 1: MAIN PREDICATES FOR WORKFLOW ORCHESTRATION
% ============================================================

% run_scheduler(-Schedule)
% Core predicate: generates ONE valid schedule.
% Starts from all courses and all timeslots, then calls scheduler.pl.
% This represents a single candidate solution from the search space.
run_scheduler(Schedule) :-
    writeln('=== RUNNING SCHEDULER ==='),
    writeln('Loading courses and timeslots...'),
    all_courses(Courses),
    all_timeslots(Timeslots),
    length(Courses, NumCourses),
    length(Timeslots, NumTimeslots),
    format('Found ~w courses and ~w timeslots.~n', [NumCourses, NumTimeslots]),
    writeln('Generating schedule...'),
    generate_schedule(Courses, Timeslots, Schedule),
    writeln('Schedule generated successfully!'),
    !.  % Cut to get first solution

% run_optimized_scheduler(-BestSchedule)
% Full optimization: generates multiple candidates and selects the best.
% This represents the main algorithmic result: finding the schedule that
% minimizes energy while balancing other criteria.
run_optimized_scheduler(BestSchedule) :-
    writeln('=== RUNNING OPTIMIZED SCHEDULER ==='),
    writeln('Finding all valid schedule candidates...'),
    
    % Generate all valid schedules (collectes all solutions)
    findall(Schedule, 
            (all_courses(C), all_timeslots(T), generate_schedule(C, T, Schedule)),
            Schedules),
    
    length(Schedules, NumSchedules),
    format('Generated ~w valid schedule(s).~n', [NumSchedules]),
    
    % Select the best according to optimization criteria
    (NumSchedules > 0 ->
        (
            writeln('Optimizing schedule selection...'),
            best_schedule(Schedules, BestSchedule),
            writeln('Best schedule selected!')
        )
    ;
        writeln('ERROR: No valid schedules found!'), fail
    ).

% full_pipeline(-BestSchedule, -Score)
% Complete end-to-end pipeline:
%   1. Generate all candidates
%   2. Select best
%   3. Compute score
%   4. Display results
full_pipeline(BestSchedule, Score) :-
    writeln('╔════════════════════════════════════════════════════════════╗'),
    writeln('║     INTELLIGENT CAMPUS SCHEDULING SYSTEM - FULL PIPELINE     ║'),
    writeln('╚════════════════════════════════════════════════════════════╝'),
    nl,
    
    % Step 1: Run optimization
    run_optimized_scheduler(BestSchedule),
    nl,
    
    % Step 2: Compute and display score
    writeln('Computing schedule score...'),
    schedule_score(BestSchedule, Score),
    Score = score(TotalEnergy, Imbalance, Variance),
    format('  • Total Energy:     ~2f kWh~n', [TotalEnergy]),
    format('  • Daily Imbalance:  ~2f kWh~n', [Imbalance]),
    format('  • Room Variance:    ~2f~n', [Variance]),
    nl,
    
    % Step 3: Display schedule
    print_schedule(BestSchedule),
    nl,
    
    writeln('Pipeline completed successfully!').

% ============================================================
% SECTION 2: DISPLAY & FORMATTING
% ============================================================

% print_schedule(+Schedule)
% Pretty-prints a complete schedule with all assignments organized by timeslot.
print_schedule(Schedule) :-
    writeln('╔════════════════════════════════════════════════════════════╗'),
    writeln('║                    SCHEDULE ASSIGNMENT                      ║'),
    writeln('╚════════════════════════════════════════════════════════════╝'),
    nl,
    all_timeslots(Timeslots),
    forall(member(TimeslotId, Timeslots),
           print_timeslot_assignments(TimeslotId, Schedule)),
    nl,
    print_schedule_summary(Schedule).

% print_timeslot_assignments(+TimeslotId, +Schedule)
% Prints all course assignments for a specific timeslot.
print_timeslot_assignments(TimeslotId, Schedule) :-
    timeslot(TimeslotId, Day, Hour),
    
    % Collect assignments for this timeslot
    findall(assignment(CourseId, SessionIdx, RoomId, TimeslotId),
            member(assignment(CourseId, SessionIdx, RoomId, TimeslotId), Schedule),
            Assignments),
    
    % Print header only if there are assignments
    (Assignments \= [] ->
        (
            format('~nTimeslot: ~w (Day: ~w, Hour: ~w)~n', [TimeslotId, Day, Hour]),
            forall(member(assignment(CourseId, SessionIdx, RoomId, _), Assignments),
                   print_assignment_detail(CourseId, SessionIdx, RoomId, TimeslotId))
        )
    ;
        true
    ).

% print_assignment_detail(+CourseId, +SessionIdx, +RoomId, +TimeslotId)
% Prints detailed information about a single assignment.
print_assignment_detail(CourseId, SessionIdx, RoomId, TimeslotId) :-
    course(CourseId, _, Duration, GroupId, Equipment, Instructor),
    room(RoomId, Capacity, _, Building, EnergyCost),
    group(GroupId, GroupSize),
    session_energy(RoomId, CourseId, Energy),
    timeslot(TimeslotId, Day, Hour),
    
    format('  ├─ Course: ~w (Session ~w/~w)~n', [CourseId, SessionIdx, Duration]),
    format('  │  Room: ~w | Building: ~w | Capacity: ~w | Group Size: ~w~n', 
           [RoomId, Building, Capacity, GroupSize]),
    format('  │  Equipment: ~w (required: ~w)~n', [Equipment, Equipment]),
    format('  │  Instructor: ~w | Energy: ~2f kWh~n', [Instructor, Energy]),
    format('  └─────────────────────────────────────────────────────────~n').

% print_schedule_summary(+Schedule)
% Prints aggregate statistics about the schedule.
print_schedule_summary(Schedule) :-
    writeln('SUMMARY STATISTICS:'),
    
    % Count assignments
    length(Schedule, NumAssignments),
    format('  • Total assignments: ~w~n', [NumAssignments]),
    
    % Count by building
    findall(B, building(B, _), Buildings),
    forall(member(Building, Buildings),
           print_building_summary(Building, Schedule)),
    nl.

% print_building_summary(+Building, +Schedule)
% Prints energy statistics for one building.
print_building_summary(Building, Schedule) :-
    findall(D, timeslot(_, D, _), DaysWithDup),
    sort(DaysWithDup, Days),
    building(Building, MaxEnergy),
    
    format('  • Building ~w (max ~w kWh/day):~n', [Building, MaxEnergy]),
    forall(member(Day, Days),
           (
               building_day_energy(Building, Day, Schedule, Energy),
               format('      ~w: ~2f kWh~n', [Day, Energy])
           )).

% ============================================================
% SECTION 3: TESTING & VALIDATION
% ============================================================

% test_constraint(+TestCase, -Result)
% Tests a single constraint validation.
% TestCase format: constraint_name(CourseId, RoomId, ...)
% Result is either 'pass' or 'fail(Reason)'.
test_constraint(capacity(CourseId, RoomId), Result) :-
    ( capacity_ok(CourseId, RoomId) ->
        Result = pass
    ;
        Result = fail('Room capacity insufficient')
    ).

test_constraint(equipment(CourseId, RoomId), Result) :-
    ( equipment_ok(CourseId, RoomId) ->
        Result = pass
    ;
        Result = fail('Equipment mismatch')
    ).

test_constraint(instructor(CourseId, TimeslotId), Result) :-
    ( instructor_ok(CourseId, TimeslotId) ->
        Result = pass
    ;
        Result = fail('Instructor not available')
    ).

test_constraint(room_conflict(RoomId, TimeslotId, Schedule), Result) :-
    Assignment = assignment(_, _, RoomId, TimeslotId),
    ( no_room_conflict(Assignment, Schedule) ->
        Result = pass
    ;
        Result = fail('Room already booked')
    ).

test_constraint(group_conflict(CourseId, TimeslotId, Schedule), Result) :-
    Assignment = assignment(CourseId, _, _, TimeslotId),
    ( no_group_conflict(Assignment, Schedule) ->
        Result = pass
    ;
        Result = fail('Student group already assigned')
    ).

% run_constraint_tests(-Summary)
% Runs comprehensive constraint validation tests.
% Returns summary: tests(Total, Passed, Failed, Failures).
run_constraint_tests(tests(Total, Passed, Failed, FailureList)) :-
    writeln('╔════════════════════════════════════════════════════════════╗'),
    writeln('║              CONSTRAINT VALIDATION TESTS                    ║'),
    writeln('╚════════════════════════════════════════════════════════════╝'),
    nl,
    
    % Define test suite
    TestSuite = [
        capacity(c1, r101),
        capacity(c7, r201),
        equipment(c2, r201),
        equipment(c4, r101),
        instructor(c1, t_mon_8),
        instructor(c1, t_fri_16)
    ],
    
    length(TestSuite, Total),
    format('Running ~w constraint tests...~n~n', [Total]),
    
    % Execute tests
    findall(
        failure(Test, Reason),
        (
            member(Test, TestSuite),
            test_constraint(Test, Result),
            Result = fail(Reason)
        ),
        FailureList
    ),
    
    length(FailureList, Failed),
    Passed is Total - Failed,
    
    % Display results
    forall(member(Test, TestSuite),
           (
               test_constraint(Test, Result),
               print_test_result(Test, Result)
           )),
    
    nl,
    format('RESULTS: ~w passed, ~w failed out of ~w~n', [Passed, Failed, Total]),
    nl.

% print_test_result(+Test, +Result)
% Prints formatted result for a single test.
print_test_result(Test, Result) :-
    ( Result = pass ->
        format('  ✓ ~w: PASS~n', [Test])
    ;
        Result = fail(Reason) ->
        format('  ✗ ~w: FAIL (~w)~n', [Test, Reason])
    ).

% ============================================================
% SECTION 4: BENCHMARKING & PERFORMANCE ANALYSIS
% ============================================================

% benchmark(+NbSolutions, -Time)
% Measures performance: generates NbSolutions valid schedules and reports time.
% Useful for analyzing search space complexity and solver performance.
benchmark(NbSolutions, Time) :-
    writeln('╔════════════════════════════════════════════════════════════╗'),
    writeln('║              PERFORMANCE BENCHMARKING                       ║'),
    writeln('╚════════════════════════════════════════════════════════════╝'),
    nl,
    format('Benchmark: Generate ~w valid schedules~n', [NbSolutions]),
    
    % Collect all courses and timeslots
    all_courses(Courses),
    all_timeslots(Timeslots),
    
    % Start timer
    get_time(StartTime),
    
    % Generate schedules
    findall(S, generate_schedule(Courses, Timeslots, S), AllSchedules),
    length(AllSchedules, TotalFound),
    ActualN is min(NbSolutions, TotalFound),
    length(Schedules, ActualN),
    append(Schedules, _, AllSchedules),
    
    % End timer
    get_time(EndTime),
    Time is EndTime - StartTime,
    
    % Display results
    length(Schedules, ActualGenerated),
    format('Generated: ~w schedules~n', [ActualGenerated]),
    format('Time elapsed: ~2f seconds~n', [Time]),
    
    (ActualGenerated > 0 ->
        (
            AvgTime is Time / ActualGenerated,
            format('Average time per schedule: ~4f seconds~n', [AvgTime])
        )
    ;
        true
    ),
    nl.

% ============================================================
% SECTION 5: HELPER PREDICATES
% ============================================================

% all_courses(-Courses)
% Returns list of all course IDs from knowledge base.
all_courses(Courses) :-
    findall(CourseId, course(CourseId, _, _, _, _, _), Courses).

% all_timeslots(-Timeslots)
% Returns list of all timeslot IDs from knowledge base.
all_timeslots(Timeslots) :-
    findall(TimeslotId, timeslot(TimeslotId, _, _), Timeslots).

% course_sessions(+CourseId, -SessionCount)
% Returns number of required sessions for a course.
course_sessions(CourseId, SessionCount) :-
    course(CourseId, SessionCount, _, _, _, _).

% course_group(+CourseId, -GroupId)
% Returns the student group for a course.
course_group(CourseId, GroupId) :-
    course(CourseId, _, _, GroupId, _, _).

% course_equipment(+CourseId, -Equipment)
% Returns required equipment for a course.
course_equipment(CourseId, Equipment) :-
    course(CourseId, _, _, _, Equipment, _).

% room_compatible(+CourseId, -RoomId)
% Checks if a room is compatible with a course (capacity + equipment).
room_compatible(CourseId, RoomId) :-
    room(RoomId, _, _, _, _),
    capacity_ok(CourseId, RoomId),
    equipment_ok(CourseId, RoomId).

% room_capacity(+RoomId, -Capacity)
% Returns capacity of a room.
room_capacity(RoomId, Capacity) :-
    room(RoomId, Capacity, _, _, _).

% room_equipment(+RoomId, -Equipment)
% Returns equipment type in a room.
room_equipment(RoomId, Equipment) :-
    room(RoomId, _, Equipment, _, _).

% room_building(+RoomId, -Building)
% Returns building that contains a room.
room_building(RoomId, Building) :-
    room(RoomId, _, _, Building, _).

% group_size(+GroupId, -Size)
% Returns number of students in a group.
group_size(GroupId, Size) :-
    group(GroupId, Size).

% timeslot_day(+TimeslotId, -Day)
% Returns day of the week for a timeslot.
timeslot_day(TimeslotId, Day) :-
    timeslot(TimeslotId, Day, _).

% instructor_ok(+CourseId, +TimeslotId)
% Wrapper around instructor_available for readability.
instructor_ok(CourseId, TimeslotId) :-
    instructor_available(CourseId, TimeslotId).

% all_constraints_ok(+Assignment, +Schedule)
% Already defined in constraints.pl, but referenced here for completeness.
% Checks: capacity, equipment, instructor availability, no room conflict,
%         no group conflict, and energy threshold compliance.

% ============================================================
% SECTION 6: ENTRY POINTS & INTERACTIVE MODE
% ============================================================

% main
% Primary entry point. Runs the full optimization pipeline.
% Call with: ?- main.
main :-
    full_pipeline(_BestSchedule, _Score),
    writeln(''),
    writeln('Pipeline execution completed. Check output above for results.'),
    halt(0).

% quick_test
% Quick validation: run constraint tests and generate one schedule.
% Call with: ?- quick_test.
quick_test :-
    writeln('╔════════════════════════════════════════════════════════════╗'),
    writeln('║                    QUICK TEST MODE                          ║'),
    writeln('╚════════════════════════════════════════════════════════════╝'),
    nl,
    
    % Run constraint validation
    run_constraint_tests(_TestSummary),
    
    % Generate one schedule
    writeln('Generating one valid schedule...'),
    run_scheduler(Schedule),
    
    % Display it
    print_schedule(Schedule),
    
    writeln('Quick test completed!'), nl.

% demo_benchmark
% Demonstration: run 5 schedule generations and measure performance.
% Call with: ?- demo_benchmark.
demo_benchmark :-
    writeln('Demonstration: Running performance benchmark...'), nl,
    benchmark(5, _Time),
    writeln('Benchmark demonstration completed!'), nl.

% interactive_mode
% Interactive menu for testing different features.
% Call with: ?- interactive_mode.
interactive_mode :-
    repeat,
    nl,
    writeln('╔════════════════════════════════════════════════════════════╗'),
    writeln('║          CAMPUS SCHEDULING SYSTEM - INTERACTIVE MODE        ║'),
    writeln('╚════════════════════════════════════════════════════════════╝'),
    writeln('Options:'),
    writeln('  1. Run full pipeline (optimization)'),
    writeln('  2. Generate single schedule'),
    writeln('  3. Run constraint validation tests'),
    writeln('  4. Run performance benchmark'),
    writeln('  5. Exit'),
    write('Select option (1-5): '),
    read(Choice),
    nl,
    
    (   Choice = 1 ->
        full_pipeline(_Schedule, _Score)
    ;   Choice = 2 ->
        (run_scheduler(S), print_schedule(S))
    ;   Choice = 3 ->
        run_constraint_tests(_)
    ;   Choice = 4 ->
        benchmark(5, _)
    ;   Choice = 5 ->
        (writeln('Exiting...'), nl, !)
    ;
        writeln('Invalid choice, try again.')
    ).

% ============================================================
% END OF MAIN ORCHESTRATOR
% ============================================================
