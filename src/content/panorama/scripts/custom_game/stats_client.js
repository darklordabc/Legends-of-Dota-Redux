var ServerDebug = Game.IsInToolsMode() && false // Change to true if you have local server running, so contributors without local server can see some things
var ServerAddress = ServerDebug ? "http://localhost:5218/" : "http://arxae.loseyourip.com/";

function GetDataFromServer(path, params, resolve, reject) {
	var encodedParams =
		params == null
			? ""
			: "?" +
			  Object.keys(params)
					.map(function (key) {
						return encodeURIComponent(key) + "=" + encodeURIComponent(params[key]);
					})
					.join("&");
	
	//return new Promise(function(resolve, reject) {
	$.AsyncWebRequest(ServerAddress + path + encodedParams, {
		type: "GET",
		success: function (data) {
			if (resolve) resolve(data || {});
		},
		error: function (e) {
			if (reject) reject(e);
		},
	});
	//})
}

function CreateSkillBuild(title, description) {
	GameEvents.SendCustomGameEventToServer("stats_client_create_skill_build", {
		title: title,
		description: description,
	});
}

function LoadBuilds(cont, skip) {
	cont = cont || $pickingPhaseRecommendedBuildContainer();
	var req = { steamID: Game.GetLocalPlayerInfo().player_steamid };
	
	/*
	if (skip) req.skip = skip;
	if (cont) req.sorting = cont[1];
	*/

	if(skip == undefined) skip = 0;
	
	GameEvents.SendCustomGameEventToServer("stats_client_get_skill_builds", { Skip: skip });
}

function LoadFavBuilds(rootPanel) {
	if (!Game.GetLocalPlayerInfo()) {
		$.Schedule(0.1, LoadFavBuilds);
	} else {
		GameEvents.SendCustomGameEventToServer("stats_client_get_favorite_skill_builds", {
			SteamID: Game.GetLocalPlayerInfo().player_steamid
		});
	}
}
