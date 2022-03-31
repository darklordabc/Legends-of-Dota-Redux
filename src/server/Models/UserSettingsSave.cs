namespace LegendsOfDota.Models;

using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

public class UserSettingsSave
{
	[JsonPropertyName("steamID"), Key]
	public string SteamId { get; set; }

	[JsonPropertyName("content")]
	public string SettingsContent { get; set; }
}