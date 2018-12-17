
-- Lua Library Imports
function __TS__StringReplace(source,searchValue,replaceValue)
    return ({ string.gsub(source,searchValue,replaceValue) })[(0)+1]
end

LinkLuaModifier("modifier_redux_tower_ability","abilities/pocket_tower.lua",LUA_MODIFIER_MOTION_NONE);
ListenToGameEvent("entity_killed",function(keys)
    if OptionManager:GetOption("convertableTowers")==0 then
        return
    end
    local building = EntIndexToHScript(keys.entindex_killed);
    if building.IsTower and building:IsTower() then
        local buildingName = building:GetUnitName();
        local teamNumber = nil;
        if building:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
            buildingName = __TS__StringReplace(buildingName, "goodguys","badguys");
            teamNumber = DOTA_TEAM_BADGUYS;
        else
            buildingName = __TS__StringReplace(buildingName, "badguys","goodguys");
            teamNumber = DOTA_TEAM_GOODGUYS;
        end
        local newTower = CreateUnitByName(buildingName,building:GetAbsOrigin(),true,nil,nil,teamNumber);
        newTower:SetOrigin(GetGroundPosition(building:GetAbsOrigin(),newTower));
        newTower:RemoveModifierByName("modifier_invulnerable");
        if newTower:HasAbility("backdoor_protection_in_base") then
            newTower:RemoveAbility("backdoor_protection_in_base");
        end
        building:AddNewModifier(nil,nil,"modifier_redux_tower_ability",{});
        local dust_pfx = ParticleManager:CreateParticle("particles/dev/library/base_dust_hit_detail.vpcf",PATTACH_CUSTOMORIGIN,nil);
        ParticleManager:SetParticleControl(dust_pfx,0,building:GetAbsOrigin());
        ParticleManager:ReleaseParticleIndex(dust_pfx);
        building:EmitSound("Redux.PocketTower");
        Timers:CreateTimer(FrameTime(),function()
            ResolveNPCPositions(building:GetAbsOrigin(),144);
        end
);
    end
end
,nil);
