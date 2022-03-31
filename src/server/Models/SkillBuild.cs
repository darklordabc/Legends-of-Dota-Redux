namespace LegendsOfDota.Models;

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

public class SkillBuild
{
	[Key]
	public int Id { get; set; }

	[JsonPropertyName("abilities")]
	public string[] Abilities { get; set; }

	[JsonPropertyName("attribute")]
	public string Attribute { get; set; }

	[JsonPropertyName("description")]
	public string Description { get; set; }

	[JsonPropertyName("heroName")]
	public string HeroName { get; set; }

	[JsonPropertyName("steamID")]
	public string SteamId { get; set; }

	[JsonPropertyName("tags")]
	public string[] Tags { get; set; }

	[JsonPropertyName("title")]
	public string Title { get; set; }

	public int Votes { get { return Votes_Up + Votes_Down; } }

	public int Votes_Up { get; set; }

	public int Votes_Down { get; set; }

	public DateTime Created { get; set; }

	[NotMapped]
	public List<string> UpVoteIds{get;set;}
	
	[NotMapped]
	public List<string> DownVoteIds{get;set;}
}
