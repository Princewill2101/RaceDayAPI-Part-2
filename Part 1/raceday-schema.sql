/* ============================================================
   RaceDay Database Schema
   Module: PROG6212/W - Part 1, Section C

   This script creates the full RaceDay database schema in SQL
   Server (SSMS) and seeds it with sample data. It matches the
   ERD in erd.png exactly - six entities, with primary keys,
   foreign keys, and constraints defined for every table.

   How to run:
   1. Open SQL Server Management Studio (SSMS).
   2. Connect to your local SQL Server instance.
   3. Open this file and click "Execute".
   4. The script creates the RaceDayDb database if it does not
      already exist, then builds and seeds all six tables.
   ============================================================ */

-- Create the database (skip if it already exists) and switch to it
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RaceDayDb')
BEGIN
    CREATE DATABASE RaceDayDb;
END
GO

USE RaceDayDb;
GO

/* ------------------------------------------------------------
   Drop tables if they already exist, so this script can be run
   again on a clean instance without errors. Child tables are
   dropped before the parent tables they reference.
   ------------------------------------------------------------ */
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.EventTypes', 'U') IS NOT NULL DROP TABLE dbo.EventTypes;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* ------------------------------------------------------------
   1. Users
   Stores both Organisers and Participants in one table, with a
   Role column to distinguish them. Both roles register and log
   in through the same Users table.
   ------------------------------------------------------------ */
CREATE TABLE dbo.Users (
    UserId              INT IDENTITY(1,1) PRIMARY KEY,
    FullName            NVARCHAR(100)   NOT NULL,
    Email               NVARCHAR(150)   NOT NULL UNIQUE,
    PasswordHash        NVARCHAR(255)   NOT NULL,
    Role                NVARCHAR(20)    NOT NULL
        CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser', 'Participant')),
    ProfilePictureUrl   NVARCHAR(255)   NULL,
    CreatedAt           DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

/* ------------------------------------------------------------
   2. EventTypes
   A small lookup table for the fixed set of event types
   (Run, Walk, Cycle), so Events reference a valid type instead
   of a free-text value.
   ------------------------------------------------------------ */
CREATE TABLE dbo.EventTypes (
    EventTypeId INT IDENTITY(1,1) PRIMARY KEY,
    TypeName    NVARCHAR(20) NOT NULL UNIQUE
);
GO

/* ------------------------------------------------------------
   3. Events
   Each event is created and owned by one Organiser (Users) and
   belongs to one EventType.
   ------------------------------------------------------------ */
CREATE TABLE dbo.Events (
    EventId         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT             NOT NULL,
    EventTypeId     INT             NOT NULL,
    Name            NVARCHAR(150)   NOT NULL,
    Description     NVARCHAR(MAX)   NULL,
    EventDate       DATETIME        NOT NULL,
    Location        NVARCHAR(150)   NOT NULL,
    DistanceKm      DECIMAL(5,2)    NOT NULL,
    BannerImageUrl  NVARCHAR(255)   NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId)
        REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Events_EventType FOREIGN KEY (EventTypeId)
        REFERENCES dbo.EventTypes(EventTypeId)
);
GO

/* ------------------------------------------------------------
   4. Categories
   Each category (e.g. "Under 20", "10km") belongs to exactly
   one event.
   ------------------------------------------------------------ */
CREATE TABLE dbo.Categories (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    EventId         INT             NOT NULL,
    CategoryName    NVARCHAR(50)    NOT NULL,
    MinAge          INT             NULL,
    MaxAge          INT             NULL,
    DistanceKm      DECIMAL(5,2)    NULL,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
);
GO

/* ------------------------------------------------------------
   5. Enrolments
   Links a Participant (Users) to an Event under one Category.
   A Participant may only enrol once per event.
   ------------------------------------------------------------ */
CREATE TABLE dbo.Enrolments (
    EnrolmentId     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId   INT             NOT NULL,
    EventId         INT             NOT NULL,
    CategoryId      INT             NOT NULL,
    EnrolmentDate   DATETIME        NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Confirmed'
        CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Confirmed', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId)
        REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryId)
        REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_Participant_Event UNIQUE (ParticipantId, EventId)
);
GO

/* ------------------------------------------------------------
   6. Results
   One result per enrolment (one-to-one), captured by the
   Organiser after the event concludes.
   ------------------------------------------------------------ */
CREATE TABLE dbo.Results (
    ResultId        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT             NOT NULL UNIQUE,
    FinishTime      TIME            NULL,
    FinishPosition  INT             NULL,
    RecordedAt      DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentId)
        REFERENCES dbo.Enrolments(EnrolmentId)
);
GO


/* ============================================================
   SEED DATA
   Realistic sample data: 2 Organisers, 2 Participants,
   3 Events, categories for each event, and sample enrolments.
   ============================================================ */

-- Event types
INSERT INTO dbo.EventTypes (TypeName) VALUES ('Run'), ('Walk'), ('Cycle');
GO

-- Users: 2 Organisers and 2 Participants
-- (PasswordHash values below are placeholders representing already-hashed passwords)
INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role, ProfilePictureUrl)
VALUES
    ('Naledi Mokoena',  'naledi.mokoena@raceday.co.za',  'HASH_PLACEHOLDER_1', 'Organiser',  NULL),
    ('Johan van der Merwe', 'johan.vdm@raceday.co.za',   'HASH_PLACEHOLDER_2', 'Organiser',  NULL),
    ('Thandiwe Nkosi',  'thandiwe.nkosi@example.com',    'HASH_PLACEHOLDER_3', 'Participant', NULL),
    ('Ryan Pillay',     'ryan.pillay@example.com',       'HASH_PLACEHOLDER_4', 'Participant', NULL);
GO

-- Events: 3 events, owned by the two Organisers above
INSERT INTO dbo.Events (OrganiserId, EventTypeId, Name, Description, EventDate, Location, DistanceKm, BannerImageUrl)
VALUES
    (1, 1, 'Comrades Marathon',      'Iconic ultramarathon between Pietermaritzburg and Durban.', '2026-06-14', 'Pietermaritzburg, KZN', 87.00, NULL),
    (1, 3, 'Cape Town Cycle Tour',   'Scenic cycling tour around the Cape Peninsula.',            '2026-03-08', 'Cape Town, WC',         109.00, NULL),
    (2, 2, 'Soweto Community Walk',  'Charity walk supporting local youth programmes.',           '2026-04-18', 'Soweto, GP',            5.00,  NULL);
GO

-- Categories: at least one per event
INSERT INTO dbo.Categories (EventId, CategoryName, MinAge, MaxAge, DistanceKm)
VALUES
    (1, 'Senior',   20, 59, 87.00),
    (1, 'Veteran',  60, 99, 87.00),
    (2, '109km Individual', 18, 99, 109.00),
    (2, '109km Team',       18, 99, 109.00),
    (3, 'Under 20', 0,  19, 5.00),
    (3, 'Open',     20, 99, 5.00);
GO

-- Enrolments: Participants entering events under a chosen category
INSERT INTO dbo.Enrolments (ParticipantId, EventId, CategoryId, Status)
VALUES
    (3, 1, 1, 'Confirmed'),  -- Thandiwe enters Comrades, Senior category
    (4, 2, 3, 'Confirmed'),  -- Ryan enters Cape Town Cycle Tour, Individual category
    (3, 3, 6, 'Confirmed');  -- Thandiwe enters Soweto Walk, Open category
GO

-- Results: sample finish data for one completed enrolment
INSERT INTO dbo.Results (EnrolmentId, FinishTime, FinishPosition)
VALUES
    (3, '00:32:14', 47);   -- Thandiwe's result for the Soweto Community Walk
GO


/* ============================================================
   VERIFICATION QUERIES
   Run these after the script above to check that every table
   was created and seeded correctly. Handy to run live in SSMS
   for your video walkthrough.
   ============================================================ */

-- 1. View each table on its own
SELECT * FROM dbo.Users;
SELECT * FROM dbo.EventTypes;
SELECT * FROM dbo.Events;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Enrolments;
SELECT * FROM dbo.Results;
GO

-- 2. Row counts for a quick sanity check (all tables should have data)
-- Note: "RowCount" is a reserved word in SQL Server (used by SET ROWCOUNT),
-- so we alias it as RowTotal instead to avoid a syntax error.
SELECT 'Users' AS TableName, COUNT(*) AS RowTotal FROM dbo.Users
UNION ALL SELECT 'EventTypes', COUNT(*) FROM dbo.EventTypes
UNION ALL SELECT 'Events', COUNT(*) FROM dbo.Events
UNION ALL SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL SELECT 'Enrolments', COUNT(*) FROM dbo.Enrolments
UNION ALL SELECT 'Results', COUNT(*) FROM dbo.Results;
GO

-- 3. Events shown with their type and organiser's name (joins across tables)
SELECT
    e.Name          AS EventName,
    et.TypeName     AS EventType,
    u.FullName      AS Organiser,
    e.EventDate,
    e.Location,
    e.DistanceKm
FROM dbo.Events e
JOIN dbo.EventTypes et ON e.EventTypeId = et.EventTypeId
JOIN dbo.Users u       ON e.OrganiserId = u.UserId;
GO

-- 4. Full enrolment detail: who entered which event, under which category
SELECT
    p.FullName      AS Participant,
    ev.Name         AS EventName,
    c.CategoryName,
    en.Status,
    en.EnrolmentDate
FROM dbo.Enrolments en
JOIN dbo.Users p       ON en.ParticipantId = p.UserId
JOIN dbo.Events ev     ON en.EventId = ev.EventId
JOIN dbo.Categories c  ON en.CategoryId = c.CategoryId;
GO

-- 5. Results with participant and event context (mirrors the "My Results" page)
SELECT
    p.FullName       AS Participant,
    ev.Name           AS EventName,
    c.CategoryName,
    r.FinishTime,
    r.FinishPosition
FROM dbo.Results r
JOIN dbo.Enrolments en ON r.EnrolmentId = en.EnrolmentId
JOIN dbo.Users p        ON en.ParticipantId = p.UserId
JOIN dbo.Events ev      ON en.EventId = ev.EventId
JOIN dbo.Categories c   ON en.CategoryId = c.CategoryId;
GO
