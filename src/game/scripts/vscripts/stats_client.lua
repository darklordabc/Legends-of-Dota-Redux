StatsClient = StatsClient or class({})
JSON = JSON or require("lib/json")

StatsClient.ServerAddress = (IsInToolsMode() and "http://127.0.0.1:3333" or "https://lodr-ark120202.rhcloud.com") .. "/lodServer/"
StatsClient.GameVersion = LoadKeyValues('addoninfo.txt').version

function StatsClient:SubscribeToClientEvents()
	CustomGameEventManager:RegisterListener("stats_client_create_skill_build", Dynamic_Wrap(StatsClient, "CreateSkillBuild"))
	CustomGameEventManager:RegisterListener("stats_client_remove_skill_build", Dynamic_Wrap(StatsClient, "RemoveSkillBuild"))
	CustomGameEventManager:RegisterListener("stats_client_vote_skill_build", Dynamic_Wrap(StatsClient, "VoteSkillBuild"))
	CustomGameEventManager:RegisterListener("stats_client_save_fav_builds", Dynamic_Wrap(StatsClient, "SaveFavoriteBuilds"))
end

function StatsClient:CreateSkillBuild(args)
	local pregame = GameRules.pregame

	local playerID = args.PlayerID
	local steamID = tostring(PlayerResource:GetSteamID(playerID))
	local title = args.title or ""
	local description = args.description or ""
	local abilities = pregame.selectedSkills[playerID] or {}
	local heroName = pregame.selectedHeroes[playerID]
	local attribute = pregame.selectedPlayerAttr[playerID]

	if util:getTableLength(abilities) < 6 or not heroName or (attribute ~= "str" and attribute ~= "agi" and attribute ~= "int") then
		network:sendNotification(PlayerResource:GetPlayer(playerID), {
			sort = 'lodDanger',
			text = 'lodServerFailedCreateSkillBuildUnfinished'
		})
		pregame:PlayAlert(playerID)
		return
	end
	if #title < 4 or #title > 64 or #description < 10 or #description > 256 then
		network:sendNotification(PlayerResource:GetPlayer(playerID), {
			sort = 'lodDanger',
			text = 'lodServerFailedCreateSkillBuildText'
		})
		pregame:PlayAlert(playerID)
		return
	end
	StatsClient:Send("createSkillBuild", {
		steamID = steamID,
		title = title,
		description = description,
		abilities = abilities,
		heroName = heroName,
		attribute = attribute,
		tags = {},
	}, function(response)
		if response.success then
			network:sendNotification(PlayerResource:GetPlayer(playerID), {
				sort = 'lodSuccess',
				text = 'lodServerSuccessCreateSkillBuild'
			})
		else
			network:sendNotification(PlayerResource:GetPlayer(playerID), {
				sort = 'lodDanger',
				text = response.error or ''
			})
			pregame:PlayAlert(playerID)
		end
	end)
end

function StatsClient:RemoveSkillBuild(args)
	local playerID = args.PlayerID
	local steamID = tostring(PlayerResource:GetSteamID(playerID))
	local id = args.id
	if type(id) ~= "string" then
		return
	end
	StatsClient:Send("removeSkillBuild", {
		steamID = steamID,
		id = id,
	}, function(response)
		if response.success then
			network:sendNotification(PlayerResource:GetPlayer(playerID), {
				sort = 'lodSuccess',
				text = 'lodServerSuccessRemoveSkillBuild'
			})
		else
			network:sendNotification(PlayerResource:GetPlayer(playerID), {
				sort = 'lodDanger',
				text = response.error or ''
			})
			GameRules.pregame:PlayAlert(playerID)
		end
	end)
end

function StatsClient:VoteSkillBuild(args)
	local playerID = args.PlayerID
	local steamID = tostring(PlayerResource:GetSteamID(playerID))
	local id = args.id
	local vote
	if type(args.vote) == "number" then vote = args.vote == 1 end
	StatsClient:Send("voteSkillBuild", {
		steamID = steamID,
		id = id,
		vote = vote
	})
end

function StatsClient:SaveFavoriteBuilds(args)
	local playerID = args.PlayerID
	local steamID = tostring(PlayerResource:GetSteamID(playerID))
	DeepPrintTable(args)
	StatsClient:Send("updatePlayerData", {
		steamID = steamID,
		favoriteBuilds = type(args.builds) == "table" and args.builds or {}
	})
end

function StatsClient:Send(path, data, callback, retryCount, protocol, _currentRetry)
	local request = CreateHTTPRequestScriptVM(protocol or "POST", self.ServerAddress .. path)
	request:SetHTTPRequestGetOrPostParameter("data", JSON:encode(data))
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			print("error, status == " .. response.StatusCode)
			local currentRetry = (_currentRetry or 0) + 1
			if currentRetry < (retryCount or 0) then
				Timers:CreateTimer(1, function()
					print("Retry (" .. currentRetry .. ")")
					StatsClient:Send(path, data, callback, retryCount, protocol, currentRetry)
				end)
			end
		else
			local obj, pos, err = JSON:decode(response.Body, 1, nil)
			if callback then
				callback(obj)
			end
		end
	end)
end
--[[StatsClient:CreateSkillBuild({
	PlayerID = 0,
	title = "MY COOL BUILD",
	description = "IT'S IMBALANCED!"
})]]