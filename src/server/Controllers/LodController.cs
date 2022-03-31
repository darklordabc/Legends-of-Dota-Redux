namespace LegendsOfDota.Controllers;

using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using System.Linq;
using Models;
using System.Text.Json.Serialization;

[ApiController]
[Route("/")]
public class LodController : ControllerBase
{
	private readonly ILogger<LodController> _log;
	private readonly LodDbContext _db;
	private readonly IConfiguration _cfg;

	public LodController(ILogger<LodController> log, LodDbContext db, IConfiguration cfg)
	{
		_log = log;
		_db = db;
		_cfg = cfg;
	}

	[Route("saveOptions")]
	[HttpPost()]
	public IActionResult SaveOptions()
	{
		Request.Headers.TryGetValue("Auth-Key", out var authKey);
		if(authKey.ToString() == "") return Unauthorized();
		if(authKey.ToString() != _cfg["LodAuthKey"]) return Unauthorized();

		var settings = JsonSerializer.Deserialize<UserSettingsSave>(Request.Form["data"].ToString());

		var existing = _db.UserSettings.FirstOrDefault(s => s.SteamId == settings.SteamId);

		if (existing == null)
		{
			_db.UserSettings.Add(settings);
		}
		else
		{
			existing.SettingsContent = settings.SettingsContent;
		}

		_db.SaveChanges();

		return StatusCode(200);
	}

	[Route("loadOptions")]
	[HttpPost()]
	public IActionResult LoadOptions()
	{
		Request.Headers.TryGetValue("Auth-Key", out var authKey);
		if(authKey.ToString() == "") return Unauthorized();
		if(authKey.ToString() != _cfg["LodAuthKey"]) return Unauthorized();

		var steamId = JsonSerializer.Deserialize<Dictionary<string, string>>(Request.Form["data"].ToString())["steamID"];
		var data = _db.UserSettings.FirstOrDefault(s => s.SteamId == steamId);

		if (data == null)
		{
			return NotFound();
		}

		var content = JsonSerializer.Serialize(data.SettingsContent);

		return Ok(content);
	}

	[Route("createSkillBuild")]
	[HttpPost()]
	public IActionResult SaveSkillBuild()
	{
		Request.Headers.TryGetValue("Auth-Key", out var authKey);
		if(authKey.ToString() == "") return Unauthorized();
		if(authKey.ToString() != _cfg["LodAuthKey"]) return Unauthorized();

		string content = Request.Form["data"].ToString();
		var data = JsonSerializer.Deserialize<Dictionary<string, object>>(content);
		string steamId = data["steamID"].ToString();

		var sb = JsonSerializer.Deserialize<SkillBuild>(content);
		sb.Votes_Up = 0;
		sb.Votes_Down = 0;
		sb.Created = DateTime.Now;
		
		_db.SkillBuilds.Add(sb);

		_db.SaveChanges();

		return Ok();
	}

	[Route("removeSkillBuild")]
	[HttpPost()]
	public IActionResult RemoveSkillBuild()
	{
		Request.Headers.TryGetValue("Auth-Key", out var authKey);
		if(authKey.ToString() == "") return Unauthorized();
		if(authKey.ToString() != _cfg["LodAuthKey"]) return Unauthorized();
		
		string content = Request.Form["data"].ToString();
		var data = JsonSerializer.Deserialize<RemoveSkillBuildRequest>(content);

		var record = _db.SkillBuilds.FirstOrDefault(s => s.Id == data.buildId);

		if(record != null)
		{
			var favorites = _db.UserFavorites.Where(f => f.SkillBuildId == record.Id);
			_db.UserFavorites.RemoveRange(favorites);
			_db.SaveChanges();

			_db.SkillBuilds.Remove(record);

			_db.SaveChanges();
		}

		return Ok();
	}

	record RemoveSkillBuildRequest(int buildId, string steamId);

	[Route("getSkillBuilds")]
	[HttpGet()]
	public IActionResult GetSkillBuilds()
	{
		var builds = _db.SkillBuilds.ToList();
		
		for(int i = 0; i < builds.Count; i++)
		{
			var votes = _db.UserVotes.Where(v => v.SkillBuildId == builds[i].Id);
			builds[i].UpVoteIds = new List<string>(votes.Where(v => v.Vote == 1).Select(v => v.SteamId));
			builds[i].DownVoteIds = new List<string>(votes.Where(v => v.Vote == 0).Select(v => v.SteamId));
		}

		return Ok(builds);
	}

	[Route("setFavoriteSkillBuild")]
	[HttpPost()]
	public IActionResult SetFavoriteSkillBuild()
	{
		Request.Headers.TryGetValue("Auth-Key", out var authKey);
		if(authKey.ToString() == "") return Unauthorized();
		if(authKey.ToString() != _cfg["LodAuthKey"]) return Unauthorized();

		string data = Request.Form["data"].ToString();
		var fa = JsonSerializer.Deserialize<FavoriteAction>(data);

		if(fa.SetFavorite == 1)
		{
			_db.UserFavorites.Add(new UserFavorite()
			{
				SteamId = fa.SteamId,
				SkillBuildId = fa.SkillBuildId
			});
		}
		else
		{
			var fav = _db.UserFavorites.FirstOrDefault(f => f.SteamId == fa.SteamId && f.SkillBuildId == fa.SkillBuildId);
			if(fav != null)
			{
				_db.UserFavorites.Remove(fav);
			}
		}

		_db.SaveChanges();

		return Ok();
	}

	// {"id":2,"steamID":"76561197966504115","vote":1} -> Vote Up
	// {"id":2,"steamID":"76561197966504115","vote":0} -> Vote Down
	[Route("voteSkillBuild")]
	[HttpPost()]
	public IActionResult VoteSkillBuild()
	{
		Request.Headers.TryGetValue("Auth-Key", out var authKey);
		if(authKey.ToString() == "") return Unauthorized();
		if(authKey.ToString() != _cfg["LodAuthKey"]) return Unauthorized();

		string data = Request.Form["data"].ToString();
		var va = JsonSerializer.Deserialize<VoteAction>(data);
		var build = _db.SkillBuilds.FirstOrDefault(s => s.Id == va.SkillBuildId);

		// No skill build with this id
		if(build == null)
		{
			return NotFound();
		}

		// Check if this user already voted
		var vote = _db.UserVotes.FirstOrDefault(v => v.SteamId == va.SteamId && v.SkillBuildId == va.SkillBuildId);

		if(vote != null)
		{
			return BadRequest();
		}

		if(va.Vote == 1) build.Votes_Up++;
		else build.Votes_Down++;

		_db.UserVotes.Add(new UserVote
		{
			SteamId = va.SteamId,
			SkillBuildId = build.Id,
			Vote = va.Vote
		});

		_db.SaveChanges();

		return Ok();
	}

	[Route("getFavoriteSkillBuilds")]
	[HttpGet()]
	public IActionResult GetFavoriteSkillBuilds([FromQuery]string playerId, [FromQuery] string steamId)
	{
		var favs = _db.UserFavorites.Where(f => f.SteamId == steamId).Select(f => f.SkillBuildId).ToList();
		return Ok(favs);
	}

	record FavoriteAction(
		[property: JsonPropertyName("fav")] int SetFavorite,
		[property: JsonPropertyName("id")] int SkillBuildId,
		[property: JsonPropertyName("steamID")] string SteamId);

	record VoteAction(
		[property: JsonPropertyName("id")] int SkillBuildId,
		[property: JsonPropertyName("steamID")] string SteamId,
		[property: JsonPropertyName("vote")] int Vote);
}