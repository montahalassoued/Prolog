# Intelligent Energy-Aware Campus Resource Scheduling System

This is a simple Prolog project guide for an academic campus scheduling system. Each file is split by responsibility so every teammate can see what to work on first.

## Prerequisites

- SWI-Prolog: [Download](https://www.swi-prolog.org/download/stable/bin/swipl-10.0.2-1.x64.exe.envelope)
- VS Code extension: VSC-Prolog

## How to Run

```bash
swipl main.pl
```

## Team Assignment

| Person   | Role                        | File(s)                    | Predicates to implement                                                                                                                          |
| -------- | --------------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Person 1 | Knowledge base              | knowledge_base.pl          | course/3, room/3, building/2, timeslot/3, group/2, instructor_available/2                                                                        |
| Person 2 | Hard constraints            | constraints.pl             | hard_constraint_h1/2, hard_constraint_h2/2, hard_constraint_h3/2, hard_constraint_h4/2, hard_constraint_h5/2, hard_constraint_h6/2               |
| Person 3 | Scheduler                   | scheduler.pl               | generate_schedule/3, assign_course_to_slot/3, extend_schedule/3, valid_partial_schedule/1                                                        |
| Person 4 | Energy                      | energy.pl                  | energy_by_building_day/3, total_energy/2, accumulate_energy/2, energy_profile/2                                                                  |
| Person 5 | Optimization and evaluation | optimizer.pl, evaluator.pl | score_schedule/2, select_best_schedule/2, minimize_energy/2, optimize_schedule/2, evaluate_imbalance/2, evaluate_variance/2, evaluate_schedule/2 |
| Person 6 | Entry point, tests, notes   | main.pl, tests/, README.md | run/2, main/0, run_tests/0                                                                                                                       |

## Milestones

- M1: Define the data model and shared terms.
- M2: Write the constraint and schedule flow notes.
- M3: Add the energy, optimization, and test notes.

## Getting Started

### Person 1

Start with knowledge_base.pl. Keep the data terms simple and consistent.

### Person 2

Read knowledge_base.pl first, then constraints.pl. Focus on the six hard rules.

### Person 3

Read knowledge_base.pl and constraints.pl before scheduler.pl. Build the recursive schedule idea step by step.

### Person 4

Read knowledge_base.pl and scheduler.pl before energy.pl. Keep the energy notes tied to buildings and days.

### Person 5

Read energy.pl and evaluator.pl before optimizer.pl. Use these files for scoring, balance, and comparison.

### Person 6

Read everything once, then start with main.pl and tests/. Keep the project notes and run order clear.

## Project Structure

```text
knowledge_base.pl
constraints.pl
scheduler.pl
energy.pl
optimizer.pl
evaluator.pl
main.pl
tests/
  test_knowledge_base.pl
  test_constraints.pl
  test_scheduler.pl
  test_energy.pl
  run_tests.pl
.gitignore
README.md
```
