namespace LegendsOfDota.Models;

using System.ComponentModel.DataAnnotations;

public class UserFavorite
{
	[Key]
	public int Id { get; set; }
	public string SteamId { get; set; }
	public int SkillBuildId { get; set; }
}