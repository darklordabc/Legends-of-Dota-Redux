if seer_mod == nil then
	seer_mod = class({})
end

function seer_mod:OnCreated( kv )	
	if IsServer() then
	end
end
 

function seer_mod:OnDestroy()
	if IsServer() then
	end
end
 
function seer_mod:CheckState()
	local state = {
	[MODIFIER_STATE_PROVIDES_VISION] = true,
	}
	return state
end
function seer_mod:IsHidden()
	if self:GetCaster():HasScepter() then return true end
	return false
end

function seer_mod:IsPurgable() 
	return false
end

function seer_mod:IsPurgeException()
	return false
end

function seer_mod:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end