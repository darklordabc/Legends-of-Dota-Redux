
-- Lua Library Imports
modifier_sled_penguin_passive_redux = modifier_sled_penguin_passive_redux or {}
modifier_sled_penguin_passive_redux.__index = modifier_sled_penguin_passive_redux
function modifier_sled_penguin_passive_redux.new(construct, ...)
    local self = setmetatable({}, modifier_sled_penguin_passive_redux)
    if construct and modifier_sled_penguin_passive_redux.constructor then modifier_sled_penguin_passive_redux.constructor(self, ...) end
    return self
end
function modifier_sled_penguin_passive_redux.constructor(self)
end
function modifier_sled_penguin_passive_redux.IsHidden(self)
    return (not IsInToolsMode())
end
function modifier_sled_penguin_passive_redux.IsPurgable(self)
    return false
end
function modifier_sled_penguin_passive_redux.OnCreated(self,kv)
    if IsServer() then
        local parent = self:GetParent();
        local penguin = CreateUnitByName("npc_dummy_unit_imba",parent:GetAbsOrigin(),true,parent,parent:GetPlayerOwner(),parent:GetTeamNumber());
        parent.parentPenguin = penguin;
        penguin.hero = parent;
        local ability = penguin:AddAbility("sled_penguin_passive");
        ability:SetLevel(self:GetAbility():GetLevel());
        penguin:SetModelScale(2);
        FindClearSpaceForUnit(penguin,penguin:GetAbsOrigin(),true);
        penguin:SetForwardVector(parent:GetForwardVector());
        parent:AddNewModifier(penguin,ability,"modifier_sled_penguin_movement",{});
        penguin:AddNewModifier(penguin,ability,"modifier_sled_penguin_movement",{});
        self:StartIntervalThink(FrameTime());
    end
end
function modifier_sled_penguin_passive_redux.OnIntervalThink(self)
    if self:GetParent():IsStunned() then
        self:GetAbility():ToggleAbility();
    end
end
function modifier_sled_penguin_passive_redux.OnUpgrade(self,kv)
    self:OnDestroy();
    self:OnCreated(kv);
end
function modifier_sled_penguin_passive_redux.OnDestroy(self)
    if IsServer() then
        local parent = self:GetParent();
        parent:RemoveModifierByName("modifier_sled_penguin_movement");
        parent.parentPenguin:RemoveSelf();
        parent.parentPenguin = nil;
    end
end
