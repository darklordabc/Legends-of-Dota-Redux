var ServerAddress = 'https://lodr-ark120202.rhcloud.com/lodServer/';
if (Game.IsInToolsMode()) {
	ServerAddress = 'http://127.0.0.1:3333/lodServer/';
}
ServerAddress = 'http://127.0.0.1:3333/lodServer/';

function GetDataFromServer(path, params, resolve, reject) {
	var encodedParams = params == null ? '' : '?' + Object.keys(params).map(function(key) {
	    return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
	}).join('&');
	//return new Promise(function(resolve, reject) {
	$.AsyncWebRequest(ServerAddress + path + encodedParams, {
		type: 'GET',
		success: function(data) {
			if (resolve) resolve(data || {});
		},
		error: function(e) {
			if (reject) reject(e);
		}
	});
	//})
}

function CreateSkillBuild(title, description) {
	GameEvents.SendCustomGameEventToServer('stats_client_create_skill_build', {
		title: title,
		description: description
	});
}

function LoadBuilds(cont, skip) {
	cont = cont || $pickingPhaseRecommendedBuildContainer();
	var req = {steamID: Game.GetLocalPlayerInfo().player_steamid};
	if (skip) req.skip = skip;
	if (cont) req.sorting = cont[1];
	GetDataFromServer('getSkillBuilds', req, function(builds) {
		if (builds && builds.length > 0) {
			for (var i = 0; i < builds.length; i++) {
				addRecommendedBuild(cont[0], builds[i]);
			}

			LoadFavBuilds(cont[0]);
		}

		$('#buildLoadingIndicator').visible = false;
		cont[0].GetParent().visible = true;
	}, function() {
		$('#buildLoadingSpinner').visible = false;
		$('#buildLoadingIndicatorText').text = $.Localize('#unableLoadingBuilds');
	});
}

function LoadFavBuilds(rootPanel) {
	if (!Game.GetLocalPlayerInfo()) {
		$.Schedule(0.1, LoadFavBuilds);
	} else {
		GetDataFromServer('getPlayerData', {steamID: Game.GetLocalPlayerInfo().player_steamid}, function(data) {
			var con = rootPanel;
			var favoriteBuilds = Object.keys(data.favoriteBuilds || {}).map(function(key) { return data.favoriteBuilds[key]; });
			$.Each(con.Children(), function(child) {
				child.setFavorite(favoriteBuilds.indexOf(child.buildID) !== -1);
			});
		});
	}
}
