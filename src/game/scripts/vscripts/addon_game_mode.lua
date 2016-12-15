-- Precaching
function Precache(context)
end

-- Create the game mode when we activate
function Activate()
	-- Print LoD version header
    local versionFile = LoadKeyValues('addoninfo.txt')
    local versionNumber = versionFile.version
    print('\n\nLegends of dota is activating! (v'..versionNumber..')')

    -- Ensure LoD is compiled
    local tst = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    if tst == 0 or tst == nil then
        print('FAILURE! You are attempting to run an UNCOMPILED version! Please either compile OR download the latest release from the releases section of github.\n\n')
        return
    end

    -- Change random seed
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeTxt))

    -- Load specific modules
    local network = require('network')
    local pregame = require('pregame')
    local ingame = require('ingame')

    -- Init other stuff
    network:init()
    pregame:init()
    ingame:init()

    -- Store references (mostly used for debugging)
    GameRules.util = require('util')
    GameRules.network = network
    GameRules.pregame = pregame
    GameRules.ingame = ingame

    -- Store the modID so we can tell people not to commit it to the workshop with the LoD modID
    pcall(function()
        -- If this fails, the KV doesn't exist, and a stats loading error will be printed :)

        -- Compare modID to LoD modID
        if LoadKeyValues('scripts/vscripts/statcollection/settings.kv').modID == ('2374'..'504c'..'2c51'..'8faf'..'c973'..'1a12'..'0e67'..'fdf5') then
            print('Please do not use the Legends of Dota modID! Please modify your `src/scripts/vscripts/statcollection/settings.kv` file to use a seperate modID!')
        else
            print('LoD seems to have activated successfully!!\n\n')
        end
    end)
end

-- Boot directly into LoD interface
--Convars:SetInt('dota_wait_for_players_to_load', 0)
