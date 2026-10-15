# RaceDay API Endpoint Plan

**Module:** PROG6212/W – Programming 2B
**Part 1 – Section B: API Endpoint Plan**

This table lists every endpoint the RaceDay API will expose. It was completed
before any API code was written, and the Part 2 implementation follows this
plan. Roles: **None** = public (no login needed), **Any** = any logged-in
user, **Organiser** / **Participant** = restricted to that role only.

---

## 1. Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Creates a new user account as either an Organiser or a Participant. Password is hashed before it is stored. | None (public) | `{ fullName, email, password, role }` | 201 Created – new user's id and role. 400 Bad Request – missing/invalid fields. 409 Conflict – email already registered. |
| POST | /api/auth/login | Verifies credentials and starts a session for the user, storing their id and role. | None (public) | `{ email, password }` | 200 OK – user id, full name, role. 401 Unauthorized – invalid email or password. |
| POST | /api/auth/logout | Ends the current user's session. | Any (logged in) | None | 200 OK – logged out confirmation. |

## 2. User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the profile of the currently logged-in user. | Any (logged in) | None | 200 OK – user's profile fields (excluding password). 401 Unauthorized – no active session. |
| PUT | /api/users/me | Updates the logged-in user's own profile details (name, profile picture). | Any (logged in) | `{ fullName, profilePictureUrl }` | 200 OK – updated profile. 400 Bad Request – invalid fields. 401 Unauthorized – no active session. |

## 3. Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all events, so both roles can browse what's available. | Any (logged in) | None | 200 OK – array of events. |
| GET | /api/events/{id} | Returns the full detail of a single event, including its categories. | Any (logged in) | None | 200 OK – event detail. 404 Not Found – event does not exist. |
| POST | /api/events | Creates a new event owned by the logged-in Organiser. | Organiser | `{ name, description, eventDate, location, distanceKm, eventType }` | 201 Created – the new event. 400 Bad Request – missing/invalid fields. 403 Forbidden – caller is not an Organiser. |
| PUT | /api/events/{id} | Updates an event's details. Only the Organiser who created the event may edit it. | Organiser | `{ name, description, eventDate, location, distanceKm, eventType }` | 200 OK – updated event. 403 Forbidden – not the owning Organiser. 404 Not Found – event does not exist. |
| DELETE | /api/events/{id} | Deletes an event and its related categories. Only the owning Organiser may delete it. | Organiser | None | 204 No Content – deleted successfully. 403 Forbidden – not the owning Organiser. 404 Not Found – event does not exist. |

## 4. Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all categories available for a specific event. | Any (logged in) | None | 200 OK – array of categories. 404 Not Found – event does not exist. |
| POST | /api/events/{eventId}/categories | Adds a new age or distance category to an event. Only the owning Organiser may add categories. | Organiser | `{ categoryName, minAge, maxAge, distanceKm }` | 201 Created – the new category. 403 Forbidden – not the owning Organiser. 404 Not Found – event does not exist. |
| DELETE | /api/categories/{id} | Removes a category from an event. Only the owning Organiser may remove it. | Organiser | None | 204 No Content – deleted successfully. 403 Forbidden – not the owning Organiser. 404 Not Found – category does not exist. |

## 5. Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/events/{eventId}/enrolments | Enrols the logged-in Participant into an event under a chosen category. | Participant | `{ categoryId }` | 201 Created – the new enrolment record. 400 Bad Request – category does not belong to this event. 404 Not Found – event or category does not exist. 409 Conflict – Participant already enrolled in this event. |
| GET | /api/enrolments/me | Returns all events the logged-in Participant has enrolled in. | Participant | None | 200 OK – array of the Participant's enrolments. |
| GET | /api/events/{eventId}/enrolments | Lists every Participant enrolled in a specific event. Only the owning Organiser may view this. | Organiser | None | 200 OK – array of enrolments with Participant and category details. 403 Forbidden – not the owning Organiser. 404 Not Found – event does not exist. |

## 6. Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/result | Captures the finish time and finishing position for one Participant's enrolment. Only the owning Organiser may record results. | Organiser | `{ finishTime, finishPosition }` | 201 Created – the recorded result. 403 Forbidden – not the owning Organiser. 404 Not Found – enrolment does not exist. 409 Conflict – result already recorded for this enrolment. |
| GET | /api/results/me | Returns the logged-in Participant's personal race history (event name, date, category, finish time, finish position) across all events they completed. | Participant | None | 200 OK – array of the Participant's results. |

---

### Notes
- All routes are prefixed `/api/` and use JSON request/response bodies.
- "Owning Organiser" means the `OrganiserId` stored on the event must match the logged-in user's id — enforced at the API level, not just the UI.
- This plan covers every functional requirement listed in Part 2 (Authentication, User Profile, Events, Categories, Event Enrolments, Results) and will be implemented as-is in Part 2, with any deviations explained in the README.
