
% ============================================================
% SECTION 1 : ÉQUIPEMENTS DISPONIBLES
% ============================================================
% Les types d'équipements possibles dans les salles et requis par les cours.
% Valeurs : standard | projector | lab_computer | whiteboard_plus

% ============================================================
% SECTION 2 : GROUPES D'ÉTUDIANTS
% group(Id, Size).
%   Id   : identifiant unique du groupe
%   Size : nombre d'étudiants dans le groupe
% ============================================================

group(g1, 30).   % Groupe 1 — 30 étudiants (ex. GL3-A)
group(g2, 25).   % Groupe 2 — 25 étudiants (ex. GL3-B)
group(g3, 20).   % Groupe 3 — 20 étudiants (ex. RT3-A)
group(g4, 35).   % Groupe 4 — 35 étudiants (ex. IIA3)
group(g5, 15).   % Groupe 5 — 15 étudiants (ex. groupe TP restreint)

% ============================================================
% SECTION 3 : BÂTIMENTS
% building(Id, EnergyMax).
%   Id        : identifiant du bâtiment
%   EnergyMax : seuil maximal de consommation énergétique journalière (kWh)
% ============================================================

building(b1, 500).   % Bâtiment principal   — seuil 500 kWh/jour
building(b2, 300).   % Bâtiment laboratoires — seuil 300 kWh/jour
building(b3, 200).   % Annexe pédagogique    — seuil 200 kWh/jour

% ============================================================
% SECTION 4 : SALLES
% room(Id, Capacity, Equipment, Building, EnergyCost).
%   Id         : identifiant unique de la salle
%   Capacity   : nombre maximum d'étudiants accueillis
%   Equipment  : type d'équipement disponible dans la salle
%   Building   : bâtiment auquel appartient la salle
%   EnergyCost : coût énergétique horaire (kWh/heure)
% ============================================================

% --- Salles du Bâtiment b1 (Bâtiment principal) ---
room(r101, 40, projector,       b1, 10).  % Grande salle de cours avec projecteur
room(r102, 35, projector,       b1, 10).  % Salle de cours standard avec projecteur
room(r103, 30, standard,        b1,  8).  % Salle de cours basique
room(r104, 50, whiteboard_plus, b1, 12).  % Amphithéâtre équipé (tableau interactif)

% --- Salles du Bâtiment b2 (Laboratoires) ---
room(r201, 20, lab_computer,    b2, 25).  % Laboratoire informatique — 20 postes
room(r202, 20, lab_computer,    b2, 25).  % Laboratoire informatique — 20 postes (bis)
room(r203, 15, lab_computer,    b2, 20).  % Salle TP restreinte — 15 postes

% --- Salles du Bâtiment b3 (Annexe) ---
room(r301, 30, standard,        b3,  7).  % Salle polyvalente de l'annexe
room(r302, 25, projector,       b3,  9).  % Salle de séminaire avec projecteur

% ============================================================
% SECTION 5 : CRÉNEAUX HORAIRES
% timeslot(Id, Day, Hour).
%   Id   : identifiant unique du créneau
%   Day  : jour de la semaine (monday .. friday)
%   Hour : heure de début du créneau (8, 10, 12, 14, 16)
%
% Chaque créneau dure 2 heures. Les cours du midi (12h) sont
% autorisés mais évités par les contraintes d'énergie de pointe.
% ============================================================

% Lundi
timeslot(t_mon_8,  monday,    8).
timeslot(t_mon_10, monday,   10).
timeslot(t_mon_12, monday,   12).
timeslot(t_mon_14, monday,   14).
timeslot(t_mon_16, monday,   16).

% Mardi
timeslot(t_tue_8,  tuesday,   8).
timeslot(t_tue_10, tuesday,  10).
timeslot(t_tue_12, tuesday,  12).
timeslot(t_tue_14, tuesday,  14).
timeslot(t_tue_16, tuesday,  16).

% Mercredi
timeslot(t_wed_8,  wednesday, 8).
timeslot(t_wed_10, wednesday,10).
timeslot(t_wed_12, wednesday,12).
timeslot(t_wed_14, wednesday,14).
timeslot(t_wed_16, wednesday,16).

% Jeudi
timeslot(t_thu_8,  thursday,  8).
timeslot(t_thu_10, thursday, 10).
timeslot(t_thu_12, thursday, 12).
timeslot(t_thu_14, thursday, 14).
timeslot(t_thu_16, thursday, 16).

% Vendredi
timeslot(t_fri_8,  friday,    8).
timeslot(t_fri_10, friday,   10).
timeslot(t_fri_12, friday,   12).
timeslot(t_fri_14, friday,   14).
timeslot(t_fri_16, friday,   16).

% ============================================================
% SECTION 6 : COURS
% course(Id, Sessions, Duration, Group, Equipment, Instructor).
%   Id         : identifiant unique du cours
%   Sessions   : nombre de séances requises par semaine
%   Duration   : durée d'une séance (en nombre de créneaux, 1 créneau = 2h)
%   Group      : groupe d'étudiants concerné
%   Equipment  : type d'équipement requis pour ce cours
%   Instructor : identifiant de l'enseignant responsable
% ============================================================

% --- Cours du groupe g1 (GL3-A) ---
course(c1, 2, 1, g1, projector,    prof_ali).    % Algorithmique avancée — 2 séances/sem
course(c2, 1, 1, g1, lab_computer, prof_sana).   % TP Bases de données   — 1 séance/sem
course(c3, 2, 1, g1, standard,     prof_karim).  % Génie logiciel        — 2 séances/sem

% --- Cours du groupe g2 (GL3-B) ---
course(c4, 2, 1, g2, projector,    prof_ali).    % Algorithmique avancée — même prof que c1
course(c5, 1, 1, g2, lab_computer, prof_sana).   % TP Bases de données
course(c6, 2, 1, g2, standard,     prof_leila).  % Réseaux informatiques

% --- Cours du groupe g3 (RT3-A) ---
course(c7, 3, 1, g3, projector,    prof_leila).  % Sécurité réseau — 3 séances/sem
course(c8, 1, 1, g3, lab_computer, prof_hedi).   % TP Réseaux

% --- Cours du groupe g4 (IIA3) ---
course(c9,  2, 1, g4, whiteboard_plus, prof_karim). % IA et logique
course(c10, 2, 1, g4, lab_computer,    prof_hedi).  % TP Machine Learning

% --- Cours du groupe g5 (TP restreint) ---
course(c11, 2, 1, g5, lab_computer, prof_sana).  % Atelier programmation

% ============================================================
% SECTION 7 : DISPONIBILITÉS DES ENSEIGNANTS
% instructor_available(CourseId, TimeslotId).
%   Indique qu'un enseignant est disponible pour un cours donné
%   sur un créneau précis. Un cours ne peut être planifié sur un
%   créneau que si ce prédicat est vrai pour ce cours et ce créneau.
% ============================================================

% --- prof_ali (cours c1 et c4 : Algorithmique) ---
% Disponible lundi, mardi, jeudi matin et après-midi
instructor_available(c1, t_mon_8).
instructor_available(c1, t_mon_10).
instructor_available(c1, t_tue_8).
instructor_available(c1, t_tue_14).
instructor_available(c1, t_thu_8).
instructor_available(c1, t_thu_10).

instructor_available(c4, t_mon_14).
instructor_available(c4, t_tue_10).
instructor_available(c4, t_wed_8).
instructor_available(c4, t_thu_14).

% --- prof_sana (cours c2, c5, c11 : TP BD et Atelier) ---
% Disponible mardi et jeudi (jours dédiés aux TP)
instructor_available(c2,  t_tue_8).
instructor_available(c2,  t_tue_10).
instructor_available(c2,  t_thu_8).
instructor_available(c2,  t_thu_10).

instructor_available(c5,  t_tue_12).
instructor_available(c5,  t_tue_14).
instructor_available(c5,  t_thu_12).
instructor_available(c5,  t_thu_14).

instructor_available(c11, t_wed_8).
instructor_available(c11, t_wed_10).
instructor_available(c11, t_fri_8).
instructor_available(c11, t_fri_10).

% --- prof_karim (cours c3, c9 : GL et IA) ---
instructor_available(c3, t_mon_8).
instructor_available(c3, t_mon_14).
instructor_available(c3, t_wed_10).
instructor_available(c3, t_fri_14).

instructor_available(c9, t_tue_8).
instructor_available(c9, t_tue_10).
instructor_available(c9, t_thu_8).
instructor_available(c9, t_thu_10).

% --- prof_leila (cours c6, c7 : Réseaux et Sécurité) ---
instructor_available(c6, t_mon_10).
instructor_available(c6, t_mon_16).
instructor_available(c6, t_wed_8).
instructor_available(c6, t_fri_10).

instructor_available(c7, t_tue_8).
instructor_available(c7, t_tue_14).
instructor_available(c7, t_wed_14).
instructor_available(c7, t_thu_10).
instructor_available(c7, t_fri_8).

% --- prof_hedi (cours c8, c10 : TP Réseaux et ML) ---
instructor_available(c8,  t_mon_10).
instructor_available(c8,  t_wed_10).
instructor_available(c8,  t_fri_10).

instructor_available(c10, t_tue_10).
instructor_available(c10, t_tue_14).
instructor_available(c10, t_thu_10).
instructor_available(c10, t_thu_14).

% ============================================================
% SECTION 8 : PRÉDICATS ACCESSEURS (helpers/consulteurs)
% Ces prédicats permettent aux autres modules d'interroger
% la base de connaissances de manière lisible et modulaire.
% ============================================================

% --- course_group/2 : récupère le groupe d'un cours ---
course_group(CourseId, Group) :-
    course(CourseId, _, _, Group, _, _).

% --- course_equipment/2 : récupère l'équipement requis par un cours ---
course_equipment(CourseId, Equipment) :-
    course(CourseId, _, _, _, Equipment, _).

% --- course_sessions/2 : récupère le nombre de séances hebdomadaires ---
course_sessions(CourseId, Sessions) :-
    course(CourseId, Sessions, _, _, _, _).

% --- course_duration/2 : récupère la durée d'une séance (en créneaux) ---
course_duration(CourseId, Duration) :-
    course(CourseId, _, Duration, _, _, _).

% --- room_capacity/2 : récupère la capacité d'une salle ---
room_capacity(RoomId, Capacity) :-
    room(RoomId, Capacity, _, _, _).

% --- room_equipment/2 : récupère l'équipement d'une salle ---
room_equipment(RoomId, Equipment) :-
    room(RoomId, _, Equipment, _, _).

% --- room_building/2 : récupère le bâtiment d'une salle ---
room_building(RoomId, Building) :-
    room(RoomId, _, _, Building, _).

% --- room_energy_cost/2 : récupère le coût énergétique horaire d'une salle ---
room_energy_cost(RoomId, Cost) :-
    room(RoomId, _, _, _, Cost).

% --- building_energy_max/2 : récupère le seuil énergétique d'un bâtiment ---
building_energy_max(BuildingId, EMax) :-
    building(BuildingId, EMax).

% --- timeslot_day/2 : récupère le jour d'un créneau ---
timeslot_day(TimeslotId, Day) :-
    timeslot(TimeslotId, Day, _).

% --- timeslot_hour/2 : récupère l'heure de début d'un créneau ---
timeslot_hour(TimeslotId, Hour) :-
    timeslot(TimeslotId, _, Hour).

% --- group_size/2 : récupère la taille d'un groupe ---
group_size(GroupId, Size) :-
    group(GroupId, Size).

% --- room_compatible/2 : vérifie qu'une salle est compatible avec un cours
%     (équipement suffisant et capacité suffisante pour le groupe du cours) ---
room_compatible(CourseId, RoomId) :-
    course_equipment(CourseId, Eq),
    room_equipment(RoomId, Eq),          % même type d'équipement
    course_group(CourseId, GroupId),
    group_size(GroupId, Size),
    room_capacity(RoomId, Cap),
    Cap >= Size.                          % capacité suffisante

% --- all_courses/1 : retourne la liste de tous les cours ---
all_courses(Courses) :-
    findall(C, course(C, _, _, _, _, _), Courses).

% --- all_rooms/1 : retourne la liste de toutes les salles ---
all_rooms(Rooms) :-
    findall(R, room(R, _, _, _, _), Rooms).

% --- all_timeslots/1 : retourne la liste de tous les créneaux ---
all_timeslots(Slots) :-
    findall(T, timeslot(T, _, _), Slots).

% ============================================================
% FIN DE knowledge_base.pl
% ============================================================