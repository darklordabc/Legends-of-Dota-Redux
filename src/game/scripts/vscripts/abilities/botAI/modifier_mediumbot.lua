--Taken from the spelllibrary, credits go to valve

modifier_mediumbot = class({})


--------------------------------------------------------------------------------

function modifier_mediumbot:IsHidden()
    return false
end

--------------------------------------------------------------------------------

function modifier_mediumbot:RemoveOnDeath()
    return false
end

function modifier_mediumbot:IsPermanent()
	return true	
end

function modifier_mediumbot:IsPurgable()
	return false	
end


function modifier_mediumbot:GetTexture()
	return "custom/modifier_mediumbot"
end

