:- use_module(library(plunit)).

% On charge le fichier qu'on veut tester
:- ensure_loaded('../constraints.pl').

:- begin_tests(constraints).

% Test H1 : Capacité
% g1 a 30 étudiants. r101 a 40 places -> ça doit marcher (true).
% g4 a 35 étudiants. r103 a 30 places -> ça doit échouer (fail).
test(capacity_ok_success) :- capacity_ok(c1, r101).
test(capacity_fail, [fail]) :- capacity_ok(c9, r103).

% Test H2 : Équipements
% c1 a besoin de 'projector'. r101 a 'projector' -> success.
% c2 a besoin de 'lab_computer'. r101 a 'projector' -> fail.
test(equipment_ok_success) :- equipment_ok(c1, r101).
test(equipment_fail, [fail]) :- equipment_ok(c2, r101).

% Test H3 : Disponibilité du prof
% prof_ali (c1) est dispo le monday_8 -> success.
% prof_ali (c1) n'est PAS dispo le wednesday_12 -> fail.
test(instructor_ok_success) :- instructor_ok(c1, t_mon_8).
test(instructor_fail, [fail]) :- instructor_ok(c1, t_wed_12).

% Test H4 : Conflits de salle
% Si la salle r101 est déjà prise à t_mon_8, on ne peut pas l'assigner à nouveau.
test(no_room_conflict_success) :-
    % Planning vide, la salle est dispo
    no_room_conflict(assignment(c1, 1, r101, t_mon_8), []).
test(room_conflict_fail, [fail]) :-
    % r101 est déjà occupée par c2
    no_room_conflict(assignment(c1, 1, r101, t_mon_8), [assignment(c2, 1, r101, t_mon_8)]).

% Test H5 : Conflits de groupe
% Si le groupe g1 (cours c1) a déjà un cours à t_mon_8, on ne peut pas lui mettre c2 en même temps.
test(no_group_conflict_success) :-
    % c2 n'a pas de conflit avec g3 (cours c8)
    no_group_conflict(assignment(c2, 1, r201, t_mon_8), [assignment(c8, 1, r202, t_mon_8)]).
test(group_conflict_fail, [fail]) :-
    % c1 (groupe g1) est en conflit avec c2 (groupe g1) sur le même créneau
    no_group_conflict(assignment(c2, 1, r201, t_mon_8), [assignment(c1, 1, r101, t_mon_8)]).

:- end_tests(constraints).

% Point d'entrée pour lancer les tests facilement
run_all_tests :- run_tests.
