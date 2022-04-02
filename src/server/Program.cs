using Microsoft.EntityFrameworkCore;
using LegendsOfDota;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<LodDbContext>(options => options.UseNpgsql(builder.Configuration["DbString"]));
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.Run();
