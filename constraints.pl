% ============================================================
% MODULE : CONSTRAINTS (Person 2)
% ============================================================
% Ce fichier contient l'ensemble des contraintes "dures" (H1 à H6)
% qui garantissent la faisabilité structurelle du planning.
% ============================================================

% On charge la base de connaissances si elle n'est pas déjà chargée
:- ensure_loaded('knowledge_base.pl').

% ============================================================
% H1 : Capacité de la salle (Room Capacity)
% Vérifie que la salle peut accueillir la taille du groupe.
% ============================================================
capacity_ok(CourseId, RoomId) :-
    course_group(CourseId, GroupId),
    group_size(GroupId, Size),
    room_capacity(RoomId, Capacity),
    Capacity >= Size.

% ============================================================
% H2 : Équipements de la salle (Equipment Matching)
% Vérifie que la salle possède le même équipement que celui requis par le cours.
% ============================================================
equipment_ok(CourseId, RoomId) :-
    course_equipment(CourseId, Eq),
    room_equipment(RoomId, Eq).

% ============================================================
% H3 : Disponibilité de l'enseignant (Instructor Availability)
% Vérifie que l'enseignant est bien disponible à ce créneau.
% ============================================================
instructor_ok(CourseId, TimeslotId) :-
    instructor_available(CourseId, TimeslotId).

% ============================================================
% H4 : Conflits de salle (Room Conflicts)
% Vérifie que la salle n'est pas déjà assignée à ce même créneau dans le planning partiel.
% Format attendu d'une assignation : assignment(CourseId, SessionIdx, RoomId, TimeslotId)
% Format attendu du planning : Liste d'assignations
% ============================================================
no_room_conflict(assignment(_CourseId, _SessionIdx, RoomId, TimeslotId), Schedule) :-
    \+ member(assignment(_, _, RoomId, TimeslotId), Schedule).

% ============================================================
% H5 : Conflits de groupe d'étudiants (Student Group Conflicts)
% Vérifie que le groupe d'étudiants n'a pas déjà un cours à ce même créneau.
% ============================================================
no_group_conflict(assignment(CourseId, _SessionIdx, _RoomId, TimeslotId), Schedule) :-
    course_group(CourseId, GroupId),
    \+ (
        member(assignment(OtherCourseId, _, _, TimeslotId), Schedule),
        course_group(OtherCourseId, GroupId)
    ).

% ============================================================
% H6 : Contrainte d'énergie (Energy Limits)
% Vérifie que l'ajout de ce cours ne dépasse pas la limite 
% énergétique journalière du bâtiment concerné.
% (La logique complète de calcul sera fournie par la personne 4 dans energy.pl,
% on met ici la structure qui lie le bâtiment au jour).
% ============================================================
no_energy_violation(RoomId, Day, Schedule) :-
    % On trouve dans quel bâtiment se trouve la salle
    room_building(RoomId, BuildingId),
    
    % On vérifiera que le bâtiment ne dépasse pas son seuil pour ce jour
    % En attendant le module energy.pl (Personne 4), on suppose que c'est vrai par défaut.
    % Quand energy.pl sera prêt, il faudra décommenter la ligne suivante :
    % energy_within_threshold(BuildingId, Day, Schedule).
    true.

% ============================================================
% VALIDATION GLOBALE D'UNE ASSIGNATION
% Vérifie toutes les contraintes dures avant l'ajout au planning partiel.
% C'est ce prédicat qui est appelé par le générateur récursif (Person 3)
% pour élaguer (pruning) l'arbre de recherche le plus tôt possible.
% ============================================================
all_constraints_ok(Assignment, Schedule) :-
    Assignment = assignment(CourseId, _SessionIdx, RoomId, TimeslotId),
    
    % 1. Contraintes indépendantes du planning partiel
    capacity_ok(CourseId, RoomId),
    equipment_ok(CourseId, RoomId),
    instructor_ok(CourseId, TimeslotId),
    
    % 2. Contraintes dépendantes du planning partiel
    no_room_conflict(Assignment, Schedule),
    no_group_conflict(Assignment, Schedule),
    
    % 3. Contrainte énergétique (Milestone 2)
    timeslot_day(TimeslotId, Day),
    % On simule l'ajout de cette assignation pour vérifier l'énergie
    NewSchedule = [Assignment | Schedule],
    no_energy_violation(RoomId, Day, NewSchedule).

% Note sur l'énergie : La vérification de la limite énergétique journalière
% d'un bâtiment se fera avec le module energy.pl au Milestone 2 (Personne 4).
