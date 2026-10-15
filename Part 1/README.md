# RaceDay

RaceDay is a full-stack, cloud-aware event management platform for South
Africa's road running, walking, and cycling community. It replaces the
paper-based registration and spreadsheets many community events still rely
on. Event Organisers can create and manage events, categories, and
participant results; Participants can browse events, enter under a chosen
category, and track their personal race history.

This repository is built progressively across three parts for PROG6212/W:

- **Part 1 – System Planning and Database** *(this submission)*
- Part 2 – RESTful API Development (ASP.NET Core, EF Core, CI/CD)
- Part 3 – MVC Web Application, Azure Blob Storage, Docker

## Roles

- **Organiser** – creates, edits, and deletes events; manages event
  categories; views all enrolments for their events; captures participant
  results.
- **Participant** – creates an account, browses events, enrols in an event
  by selecting a category, views their own enrolments, and tracks their
  personal results.

## Part 1 Deliverables (`/docs`)

| File | Description |
|---|---|
| `docs/erd.pdf` | Entity Relationship Diagram — six entities (Users, EventTypes, Events, Categories, Enrolments, Results) with keys and cardinality. |
| `docs/api-endpoint-plan.md` | Full API endpoint plan covering Authentication, User Profile, Events, Categories, Event Enrolments, and Results. |
| `docs/raceday-schema.sql` | SQL Server script that creates and seeds the RaceDay database schema, matching the ERD exactly, plus verification queries. |

## Running the SQL script

1. Open SQL Server Management Studio (SSMS) and connect to a local instance.
2. Open `docs/raceday-schema.sql`.
3. Select the entire script (Ctrl+A) and click **Execute** — running only
   part of it will leave tables empty.
4. The script creates the `RaceDayDb` database (if it doesn't already
   exist), builds all six tables, seeds sample data (2 Organisers,
   2 Participants, 3 Events, categories for each event, and sample
   enrolments), and finishes with verification queries you can run live.

## CI/CD

A GitHub Actions workflow (`.github/workflows/validate-docs.yml`) runs on
every push and confirms the `/docs` folder contains the ERD, API endpoint
plan, and SQL script required for Part 1.

**CI/CD screenshot:** *(add a screenshot of your green build here before submitting)*

## Video walkthrough

**YouTube (unlisted) link:** *(add your video link here — walk through the
planning documents, ERD decisions, endpoint plan choices, and run the SQL
script live in SSMS)*

## AI usage disclosure

*(If you used any AI tools while planning or writing this part — e.g. for
brainstorming the ERD, drafting the endpoint plan, or proofreading — briefly
note how here, per the assignment's disclosure requirement.)*
