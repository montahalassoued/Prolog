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
    
    % Generate up to 20 valid schedules to compare (bounded to avoid exhaustion)
    all_courses(C), all_timeslots(T),
    findnsols(20, Schedule, generate_schedule(C, T, Schedule), Schedules),
    
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
    room(RoomId, Capacity, _, Building, _EnergyCost),
    group(GroupId, GroupSize),
    session_energy(RoomId, CourseId, Energy),
    timeslot(TimeslotId, _Day, _Hour),
    
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
    
    % Generate ALL valid schedules first, then take the first ActualN of them.
    % The pattern:
    %   length(Schedules, ActualN),   % creates a list of ActualN unbound vars
    %   append(Schedules, _, AllSchedules)  % unifies those vars with the front
    % is a standard Prolog idiom for taking the first N elements of a list
    % without copying the tail.  It is correct because length/2 succeeds
    % deterministically when its second argument is already ground.
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
%
% NOTE: The predicates below are intentionally NOT redefined here.
% They are already provided by knowledge_base.pl and constraints.pl,
% which are loaded at the top of this file.  Redefining them would
% silently shadow the canonical versions and create a maintenance hazard.
%
% Provided by knowledge_base.pl:
%   all_courses/1, all_timeslots/1,
%   course_sessions/2, course_group/2, course_equipment/2,
%   room_compatible/2, room_capacity/2, room_equipment/2, room_building/2,
%   group_size/2, timeslot_day/2
%
% Provided by constraints.pl:
%   instructor_ok/2, all_constraints_ok/2

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