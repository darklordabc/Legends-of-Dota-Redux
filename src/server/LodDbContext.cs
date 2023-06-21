using Microsoft.EntityFrameworkCore;
using LegendsOfDota.Models;

namespace LegendsOfDota;

public class LodDbContext : DbContext
{
	public DbSet<UserSettingsSave> UserSettings { get; set; }
	public DbSet<SkillBuild> SkillBuilds { get; set; }
	public DbSet<UserFavorite> UserFavorites { get; set; }
	public DbSet<UserVote> UserVotes { get; set; }

	public LodDbContext(DbContextOptions<LodDbContext> options) : base(options)
	{
	}
}