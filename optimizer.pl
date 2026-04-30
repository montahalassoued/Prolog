% ============================================================
% MODULE : OPTIMIZER (Person 5)
% ============================================================
% This file compares already-valid schedules using the score
% computed in evaluator.pl.
% Optimization order:
%   1. Minimize total energy
%   2. Break ties with daily imbalance
%   3. Break remaining ties with room usage variance
% ============================================================

:- ensure_loaded('evaluator.pl').

% ------------------------------------------------------------
% Public predicates for Person 5
% ------------------------------------------------------------

% best_schedule(+Schedules, -Best) is semidet.
% Selects the best schedule from a non-empty list by first
% collecting score-schedule pairs, then selecting the minimum.
best_schedule(Schedules, Best) :-
    findall(Score-Schedule,
            (
                member(Schedule, Schedules),
                schedule_score(Schedule, Score)
            ),
            ScoredSchedules),
    best_scored_schedule(ScoredSchedules, _BestScore-Best).

% compare_schedules(+S1, +S2, -Better) is det.
% Better is unified with the preferred schedule between S1 and S2.
% If both schedules have the same score, S1 is kept.
compare_schedules(S1, S2, Better) :-
    schedule_score(S1, Score1),
    schedule_score(S2, Score2),
    better_score(Score1, Score2, Winner),
    select_better_schedule(Winner, S1, S2, Better).

% ------------------------------------------------------------
% Internal helpers
% ------------------------------------------------------------

% best_scored_schedule(+ScoredSchedules, -BestPair) is semidet.
% Selects the best Score-Schedule pair from a non-empty list.
best_scored_schedule([First | Rest], BestPair) :-
    best_scored_schedule_acc(Rest, First, BestPair).

% best_scored_schedule_acc(+ScoredSchedules, +CurrentBest, -BestPair) is det.
% Accumulator that keeps the best scored schedule seen so far.
best_scored_schedule_acc([], BestPair, BestPair).
best_scored_schedule_acc([Score-Schedule | Rest], CurrentScore-CurrentSchedule, BestPair) :-
    better_score(CurrentScore, Score, Winner),
    select_better_scored_schedule(Winner,
                                  CurrentScore-CurrentSchedule,
                                  Score-Schedule,
                                  NextBestPair),
    best_scored_schedule_acc(Rest, NextBestPair, BestPair).

% better_score(+Score1, +Score2, -Winner) is det.
% Winner is 'first' when Score1 is better or tied, otherwise 'second'.
better_score(score(E1, I1, V1), score(E2, I2, V2), Winner) :-
    (
        E1 < E2 ->
        Winner = first
    ;   E1 > E2 ->
        Winner = second
    ;   I1 < I2 ->
        Winner = first
    ;   I1 > I2 ->
        Winner = second
    ;   V1 =< V2 ->
        Winner = first
    ;
        Winner = second
    ).

% select_better_schedule(+Winner, +S1, +S2, -Better) is det.
% Maps the winning side to the corresponding schedule.
select_better_schedule(first, S1, _, S1).
select_better_schedule(second, _, S2, S2).

% select_better_scored_schedule(+Winner, +Pair1, +Pair2, -BetterPair) is det.
% Maps the winning side to the corresponding Score-Schedule pair.
select_better_scored_schedule(first, Pair1, _, Pair1).
select_better_scored_schedule(second, _, Pair2, Pair2).


