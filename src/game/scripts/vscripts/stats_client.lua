StatsClient = StatsClient or class({})
JSON = JSON or require("lib/json")
StatsClient.AbilityData = StatsClient.AbilityData or {}
StatsClient.PlayerBans = StatsClient.PlayerBans or {}

StatsClient.AuthKey = LoadKeyValues('scripts/kv/stats_client.kv').AuthKey
-- Change to true if you have local server running, so contributors without local server can see some things
StatsClient.Debug = IsInToolsMode() and false
StatsClient.ServerAddress = StatsClient.Debug and
    "http://127.0.0.1:8080/" or
    "http://163.172.174.77:8080/"

StatsClient.GameVersion = LoadKeyValues('addoninfo.txt').version
StatsClient.SortedAbilityDataEntries = StatsClient.SortedAbilityDataEntries or {}

function StatsClient:SubscribeToClientEvents()
    CustomGameEventManager:RegisterListener("stats_client_create_skill_build", Dynamic_Wrap(StatsClient, "CreateSkillBuild"))
    CustomGameEventManager:RegisterListener("stats_client_remove_skill_build", Dynamic_Wrap(StatsClient, "RemoveSkillBuild"))
    CustomGameEventManager:RegisterListener("stats_client_vote_skill_build", Dynamic_Wrap(StatsClient, "VoteSkillBuild"))
    CustomGameEventManager:RegisterListener("stats_client_fav_skill_build", Dynamic_Wrap(StatsClient, "SetFavoriteSkillBuild"))
    CustomGameEventManager:RegisterListener("stats_client_save_fav_builds", Dynamic_Wrap(StatsClient, "SaveFavoriteBuilds"))
    CustomGameEventManager:RegisterListener("stats_client_options_save", Dynamic_Wrap(StatsClient, "SaveOptions"))
    CustomGameEventManager:RegisterListener("stats_client_options_load", Dynamic_Wrap(StatsClient, "LoadOptions"))

    CustomGameEventManager:RegisterListener("lodConnectAbilityUsageData", function(_, args)
        Timers:CreateTimer(function()
            local playerID = args.PlayerID
            if not StatsClient.AbilityData or not StatsClient.SortedAbilityDataEntries or not StatsClient.GlobalAbilityUsageData or not StatsClient.totalGameAbilitiesCount then
                return 0.1
            end
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "lodConnectAbilityUsageData", {
                data = StatsClient.AbilityData[playerID] or {},
                entries = StatsClient.SortedAbilityDataEntries[playerID] or {},
                global = StatsClient.GlobalAbilityUsageData,
                totalGameAbilitiesCount = StatsClient.totalGameAbilitiesCount
            })
        end)
    end)

    ListenToGameEvent('dota_match_done', Dynamic_Wrap(StatsClient, "SendAbilityUsageData"), self)
end

function StatsClient:Fetch()
    StatsClient:FetchAbilityUsageData()
    StatsClient:FetchBans()
end

function StatsClient:CreateSkillBuild(args)
    local pregame = GameRules.pregame
    local playerID = args.PlayerID
    local steamID = PlayerResource:GetRealSteamID(playerID)
    local title = args.title or ""
    local description = args.description or ""
    local abilities = util:DeepCopy(pregame.selectedSkills[playerID]) or {}
    local heroName = pregame.selectedHeroes[playerID]
    local attribute = pregame.selectedPlayerAttr[playerID]
    for k,_ in pairs(abilities) do
        if tonumber(k) == nil then abilities[k] = nil end
    end
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
        local player = PlayerResource:GetPlayer(playerID)
        if response.success then
            network:sendNotification(player, {
                sort = 'lodSuccess',
                text = 'lodServerSuccessCreateSkillBuild'
            })
            CustomGameEventManager:Send_ServerToPlayer(player, "lodReloadBuilds", {})
        else
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = response.error or ''
            })
            pregame:PlayAlert(playerID)
        end
    end)
end

function StatsClient:RemoveSkillBuild(args)
    local playerID = args.PlayerID
    local steamID = PlayerResource:GetRealSteamID(playerID)
    local id = args.id
    if type(id) ~= "string" then
        return
    end
    StatsClient:Send("removeSkillBuild", {
        steamID = steamID,
        id = id,
    }, function(response)
        local player = PlayerResource:GetPlayer(playerID)
        if response.success then
            network:sendNotification(player, {
                sort = 'lodSuccess',
                text = 'lodServerSuccessRemoveSkillBuild'
            })
            CustomGameEventManager:Send_ServerToPlayer(player, "lodReloadBuilds", {})
        else
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = response.error or ''
            })
            GameRules.pregame:PlayAlert(playerID)
        end
    end)
end

function StatsClient:VoteSkillBuild(args)
    StatsClient:Send("voteSkillBuild", {
        steamID = PlayerResource:GetRealSteamID(args.PlayerID),
        id = args.id or "",
        vote = type(args.vote) == "number" and args.vote or 0
    })
end

function StatsClient:SetFavoriteSkillBuild(args)
    StatsClient:Send("setFavoriteSkillBuild", {
        steamID = PlayerResource:GetRealSteamID(args.PlayerID),
        id = args.id or "",
        fav = type(args.fav) == "number" and args.fav or 0
    })
end

function StatsClient:SaveOptions(args)
    StatsClient:Send("saveOptions", {
        steamID = PlayerResource:GetRealSteamID(args.PlayerID),
        content = args.content
    })
end

function StatsClient:LoadOptions(args)
    StatsClient:Send(
        "loadOptions",
        { steamID = PlayerResource:GetRealSteamID(args.PlayerID) },
        function(response)
            local player = PlayerResource:GetPlayer(args.PlayerID);
            CustomGameEventManager:Send_ServerToPlayer(player, "lodLoadOptions", { content = response })
        end
    )
end

function StatsClient:SendAbilityUsageData()
    local data = {}
    for playerID, build in pairs(GameRules.pregame.selectedSkills) do
        local steamID = PlayerResource:GetRealSteamID(playerID)
        if steamID ~= "0" then
            local abilities = {}
            for i,v in ipairs(build) do
                abilities[i] = v
            end
            data[steamID] = abilities
        end
    end
    StatsClient:Send("saveAbilityUsageData", data, nil, math.huge)
end

function StatsClient:FetchAbilityUsageData()
    local required = {}

    for i = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            required[i] = PlayerResource:GetRealSteamID(i)
        end
    end

    StatsClient:Send("fetchAbilityUsageData", required, function(response)
        for playerID, value in pairs(response) do
            playerID = tonumber(playerID)
            StatsClient.AbilityData[playerID] = value

            local entries = {}
            for ability in pairs(value) do
                table.insert(entries, ability)
            end
            table.sort(entries, function(a, b) return value[a] > value[b] end)

            local values = {}
            for i, ability in ipairs(entries) do
                values[ability] = i / #entries
            end

            StatsClient.SortedAbilityDataEntries[playerID] = values
        end
    end, math.huge)

    StatsClient:Send("fetchGlobalAbilityUsageData", nil, function(response)
        StatsClient.totalGameAbilitiesCount = #response
        StatsClient.GlobalAbilityUsageData = {}
        for i,v in ipairs(response) do
            StatsClient.GlobalAbilityUsageData[v._id] = i / #response
        end
    end, math.huge, "GET")
end

function StatsClient:GetAbilityUsageData(playerID)
    return StatsClient.AbilityData[playerID]
end

function StatsClient:SendBans(data, callback)
    StatsClient:Send("saveBans", data, callback, math.huge)
end

function StatsClient:FetchBans()
    local required = {}

    for i = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            required[i] = PlayerResource:GetRealSteamID(i)
        end
    end

    StatsClient:Send("fetchBans", required, function(response)
        for playerID, value in pairs(response) do
            StatsClient:SetBans(tonumber(playerID), value)
        end
    end, math.huge)
end

function StatsClient:GetBans(playerID)
    return StatsClient.PlayerBans[playerID]
end

function StatsClient:SetBans(playerID, value)
    StatsClient.PlayerBans[playerID] = value
end

function StatsClient:Send(path, data, callback, retryCount, protocol, _currentRetry)
    local request = CreateHTTPRequestScriptVM(protocol or "POST", self.ServerAddress .. path)
    request:SetHTTPRequestHeaderValue("Auth-Key", StatsClient.AuthKey)
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

function CDOTA_PlayerResource:GetRealSteamID(PlayerID)
    return tostring(PlayerResource:GetSteamID(PlayerID))
end
