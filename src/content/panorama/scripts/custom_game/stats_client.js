var ServerAddress = (Game.IsInToolsMode() ? "http://127.0.0.1:3333" : "https://lodr-ark120202.rhcloud.com") + "/lodServer/"

function GetDataFromServer(path, params) {
	var encodedParams = params == null ? "" : "?" + Object.keys(params).map(function(key) {
	    return encodeURIComponent(key) + "=" + encodeURIComponent(params[key]);
	}).join("&");
	return new Promise(function(resolve, reject) {
		$.AsyncWebRequest(ServerAddress + path + encodedParams, {
			type: "GET",
			success: resolve,
			error: reject
		});
	})
}


function CreateSkillBuild(title, description) {
	GameEvents.SendCustomGameEventToServer("stats_client_create_skill_build", {
		title: title,
		description: description
	})
}

function LoadBuilds(filter) {
	GetDataFromServer("getSkillBuilds", filter == null ? null : {filter: filter}).then(function(builds) {
		if (builds) {
			for (var i = 0; i < builds.length; i++) {
				addRecommendedBuild(builds[i]);
			}
		}
		LoadFavBuilds();
		$("#buildLoadingIndicator").visible = false;

		$("#pickingPhaseRecommendedBuildContainer").GetParent().visible = true;
	}, function() {
		$("#buildLoadingSpinner").visible = false;
		$("#buildLoadingIndicatorText").text = $.Localize("#unableLoadingBuilds");
	});
}

function SaveFavBuilds(builds) {
	GameEvents.SendCustomGameEventToServer("stats_client_save_fav_builds", {builds: builds})
}

function LoadFavBuilds() {
	GetDataFromServer("getPlayerData", {steamID: Game.GetLocalPlayerInfo().player_steamid}).then(function(data) {
		var con = $("#pickingPhaseRecommendedBuildContainer");
		var favoriteBuilds = Object.keys(data.favoriteBuilds || {}).map(function (key) { return data.favoriteBuilds[key]; });
		$.Each(con.Children(), function(child) {
			child.setFavorite(favoriteBuilds.indexOf(child.buildID) != -1);
		})
	});
}