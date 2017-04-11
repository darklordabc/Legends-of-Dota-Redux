StatsClient = StatsClient or class({})
JSON = JSON or require("lib/json")

StatsClient.ServerAddress = (IsInToolsMode() and "http://127.0.0.1:3333" or "https://lodr-ark120202.rhcloud.com") .. "/lodServer/"
StatsClient.GameVersion = LoadKeyValues('addoninfo.txt').version

function StatsClient:CreateSkillBuild(t)
	StatsClient:Send("createSkillBuild", t, function(data)
		DeepPrintTable(data)
	end)
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