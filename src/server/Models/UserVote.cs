namespace LegendsOfDota.Models;

using System.ComponentModel.DataAnnotations;

public class UserVote
{
	[Key]
	public int Id { get; set; }
	public string SteamId { get; set; }
	public int SkillBuildId { get; set; }
	public int Vote { get; set; }
}