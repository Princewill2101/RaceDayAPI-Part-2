using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RaceDayAPI.Data;
using RaceDayAPI.DTOs;
using RaceDayAPI.Services;

namespace RaceDayAPI.Controllers;

[ApiController]
[Route("api/results")]
public class ResultsController : ControllerBase
{
    private readonly AppDbContext _db;

    public ResultsController(AppDbContext db)
    {
        _db = db;
    }

    // ── GET /api/results/me ──────────────────────────────────
    /// <summary>
    /// Returns the logged-in Participant's personal race history —
    /// event name, date, category, finish time, and finishing position
    /// across all events they have a recorded result for.
    /// </summary>
    [HttpGet("me")]
    public async Task<IActionResult> GetMyResults()
    {
        if (!SessionHelper.IsParticipant(HttpContext.Session))
            return Forbid();

        int participantId = SessionHelper.GetUserId(HttpContext.Session)!.Value;

        var results = await _db.Results
            .Include(r => r.Enrolment)
                .ThenInclude(en => en.Event)
            .Include(r => r.Enrolment)
                .ThenInclude(en => en.Category)
            .Where(r => r.Enrolment.ParticipantId == participantId)
            .ToListAsync();

        return Ok(results.Select(r => new ResultResponse
        {
            ResultId        = r.ResultId,
            ParticipantName = "",
            EventName       = r.Enrolment.Event.Name,
            EventDate       = r.Enrolment.Event.EventDate,
            CategoryName    = r.Enrolment.Category.CategoryName,
            FinishTime      = r.FinishTime,
            FinishPosition  = r.FinishPosition
        }));
    }
}
