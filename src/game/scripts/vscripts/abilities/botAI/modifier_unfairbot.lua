--Taken from the spelllibrary, credits go to valve

modifier_unfairbot = class({})


--------------------------------------------------------------------------------

function modifier_unfairbot:IsHidden()
    return false
end

--------------------------------------------------------------------------------

function modifier_unfairbot:RemoveOnDeath()
    return false
end

function modifier_unfairbot:IsPermanent()
	return true	
end

function modifier_unfairbot:IsPurgable()
	return false	
end


function modifier_unfairbot:GetTexture()
	return "custom/modifier_unfairbot"
end

