% ============================================================
% MODULE : ENERGY (Person 4)
% ============================================================
% Calcul de la consommation énergétique du planning :
%   - énergie d'une séance individuelle
%   - énergie cumulée d'un bâtiment sur un jour
%   - contrainte de seuil journalier par bâtiment
%   - énergie totale hebdomadaire du campus
% ============================================================

:- ensure_loaded('knowledge_base.pl').

% ============================================================
% session_energy(+RoomId, +CourseId, -Energy)
%
% Energy = ε(RoomId) × Duration(CourseId)
% ε(RoomId)        : coût énergétique horaire de la salle (kWh/créneau)
% Duration(CourseId): durée de la séance en créneaux
% ============================================================
session_energy(RoomId, CourseId, Energy) :-
    room(RoomId, _, _, _, EnergyCost),
    course(CourseId, _, Duration, _, _, _),
    Energy is EnergyCost * Duration.

% ============================================================
% in_building_on_day(+Building, +Day, +Assignment)
%
% Prédicat helper pour include/3 :
% Réussit si l'affectation concerne une salle dans Building ce Day.
% ============================================================
in_building_on_day(Building, Day, assignment(_, _, RoomId, TimeslotId)) :-
    room(RoomId, _, _, Building, _),
    timeslot(TimeslotId, Day, _).

% ============================================================
% accumulate_energy(+Sessions, +_Building, +_Day, +Acc, -Total)
%
% Accumulateur récursif sur une liste de séances déjà filtrées.
% Somme session_energy pour chaque affectation.
% Building et Day sont conservés dans la signature pour cohérence
% mais le filtrage est déjà fait en amont par building_day_energy/4.
% ============================================================
accumulate_energy([], _, _, Acc, Acc).
accumulate_energy([assignment(CourseId, _, RoomId, _) | Rest], B, D, Acc, Total) :-
    session_energy(RoomId, CourseId, E),
    NewAcc is Acc + E,
    accumulate_energy(Rest, B, D, NewAcc, Total).

% ============================================================
% building_day_energy(+Building, +Day, +Schedule, -Energy)
%
% E(bl, d) = Σ session_energy(rj, ci)
%            pour tout assignment(ci, k, rj, tl) dans Schedule
%            tel que building(rj) = bl ET day(tl) = d
% ============================================================
building_day_energy(Building, Day, Schedule, Energy) :-
    include(in_building_on_day(Building, Day), Schedule, Relevant),
    accumulate_energy(Relevant, Building, Day, 0, Energy).

% ============================================================
% energy_within_threshold(+Building, +Day, +Schedule)
%
% Contrainte dure H6 : E(bl, d) ≤ Emax(bl)
% À appeler PENDANT la génération du planning (pruning).
% ============================================================
energy_within_threshold(Building, Day, Schedule) :-
    building(Building, EnergyMax),
    building_day_energy(Building, Day, Schedule, Energy),
    Energy =< EnergyMax.

% ============================================================
% total_energy(+Schedule, -ETotal)
%
% E_total = Σ_{bl ∈ B} Σ_{d ∈ Days} E(bl, d)
% Agrège l'énergie sur tous les bâtiments et tous les jours.
% ============================================================
total_energy(Schedule, ETotal) :-
    findall(B, building(B, _), Buildings),
    findall(D, timeslot(_, D, _), DaysWithDup),
    sort(DaysWithDup, Days),
    accumulate_total(Buildings, Days, Schedule, 0, ETotal).

% accumulate_total(+Buildings, +Days, +Schedule, +Acc, -Total)
accumulate_total([], _, _, Acc, Acc).
accumulate_total([B | Bs], Days, Schedule, Acc, Total) :-
    accumulate_days(B, Days, Schedule, Acc, Acc1),
    accumulate_total(Bs, Days, Schedule, Acc1, Total).

% accumulate_days(+Building, +Days, +Schedule, +Acc, -Total)
accumulate_days(_, [], _, Acc, Acc).
accumulate_days(B, [D | Ds], Schedule, Acc, Total) :-
    building_day_energy(B, D, Schedule, E),
    NewAcc is Acc + E,
    accumulate_days(B, Ds, Schedule, NewAcc, Total).
