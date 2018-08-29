LinkLuaModifier("modifier_crater_spell_manager","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_projectile","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_area_controller","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_crater_area_control","abilities/crater.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE);

class crater extends CDOTA_Ability_Lua {
	dummy:CDOTA_BaseNPC
	mod:CDOTA_Buff

	GetAbilityTexture() {
		let caster = this.GetCaster();
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return "invoker_sun_strike"
		} else {
			return "techies_focused_detonate"
		}
	}

	GetManaCost(i) {
		let caster = this.GetCaster();
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return 100;
		} else {
			return 0;
		}
	}

	GetCooldown(i) {
		let caster = this.GetCaster();
		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			return 0.5
		} else {
			return 5
		}
	}
	GetIntrinsicModifierName() {return "modifier_crater_spell_manager"}
	
	OnSpellStart() {
		let caster = this.GetCaster();
		let origin = caster.GetAbsOrigin();

		if (caster.GetModifierStackCount(this.GetIntrinsicModifierName(),caster) == 0) {
			let direction = (caster.GetCursorPosition()-origin).Normalized();
			//this.dummy = CreateModifierThinker(caster,this,"modifier_crater_projectile",{},origin,caster.GetTeamNumber(),false);
			this.dummy = CreateUnitByName(caster.GetUnitName(),origin,true,caster,caster.GetPlayerOwner(),caster.GetTeamNumber())
			this.mod = this.dummy.AddNewModifier(this.dummy,this,"modifier_crater_projectile",{})
			//@ts-ignore
			this.mod.direction = direction
			caster.SetModifierStackCount(this.GetIntrinsicModifierName(),caster,1)
			this.EndCooldown()
			this.StartCooldown(0.25)
		} else {
			caster.SetModifierStackCount(this.GetIntrinsicModifierName(),caster,0)
			this.mod.Destroy()
		}


	}
}

class modifier_crater_projectile extends CDOTA_Modifier_Lua {
	direction:Vec
	speed:number
	radius:number
	particle:ParticleID

	OnCreated() {
		if (IsClient()) {return}
		let projectile = this.GetParent();
		let ability = this.GetAbility();
		//@ts-ignore
		//this.direction = projectile.direction;
		this.speed = ability.GetSpecialValueFor("projectile_speed") * FrameTime();
		this.radius = ability.GetSpecialValueFor("crater_radius");
		this.StartIntervalThink(FrameTime());

		this.particle = ParticleManager.CreateParticle("particles/crater_marker.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN,this.GetCaster());
		//ParticleManager.SetParticleControlEnt(this.particle,0,projectile,ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW,)
		ParticleManager.SetParticleControl(this.particle,4,Vector(this.radius,0,0));
	}

	OnIntervalThink() {
		let projectile = this.GetParent();
		projectile.SetAbsOrigin(projectile.GetAbsOrigin() + (this.direction * this.speed));
	}

	OnDestroy() {
		if (IsClient()) {return}
		let projectile = this.GetParent();
		let ability = this.GetAbility();
		let origin = projectile.GetAbsOrigin();
		//AddFOWViewer(this.GetCaster().GetTeamNumber(),origin,this.radius,2,true);
		ability.CreateVisibilityNode(origin,this.radius,ability.GetSpecialValueFor("vision_duration"));
		//ability.GetSpecialValueFor("crater_duration")
		let dummy = CreateModifierThinker(this.GetCaster(),ability,"modifier_crater_area_controller",{duration:5},origin+Vector(0,0,50),this.GetCaster().GetTeamNumber(),false);
		this.GetParent().Destroy()
	}

	GetEffectName() {
		return "particles/crater_marker.vpcf";
	}

	GetEffectAttachType() {
		return ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW
	}
}

class modifier_crater_area_controller extends CDOTA_Modifier_Lua {
	particle:ParticleID

	// IsAura() {return true}
	// GetAuraRadius() {return this.GetAbility().GetSpecialValueFor("crater_radius")}
	// GetAuraSearchTeam() {return DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY}
	// GetModifierAura() {return "modifier_crater_area_control"}
	// GetAuraDuration() {return 0.1}

	OnCreated() {
		if (IsServer()) {
			this.particle = ParticleManager.CreateParticle("particles/crater_area.vpcf",ParticleAttachment_t.PATTACH_ABSORIGIN,this.GetCaster());
			ParticleManager.SetParticleControl(this.particle,0,this.GetParent().GetAbsOrigin());
			ParticleManager.SetParticleControl(this.particle,3,this.GetParent().GetAbsOrigin());

			this.StartIntervalThink(FrameTime());
		}
	}

	OnIntervalThink() {
		//this.GetAbility().GetSpecialValueFor("crater_radius")
		//print("Think")
		let units = FindUnitsInRadius(DOTATeam_t.DOTA_TEAM_GOODGUYS,this.GetParent().GetAbsOrigin(),null,900,DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAGS.DOTA_UNIT_TARGET_FLAG_NONE,FindType_t.FIND_ANY_ORDER,false);
		units.forEach((unit)=> {
			//print(unit.GetUnitName())
			let origin = this.GetParent().GetAbsOrigin()
			//@ts-ignore
			unit.AddNewModifier(this.GetCaster(),this.GetAbility(),"modifier_crater_area_control",{duration:0.1,x:origin.x,y:origin.y,z:origin.z})
		});
	}

	OnDestroy() {
		if (IsServer()) {
			ParticleManager.DestroyParticle(this.particle,false);
			ParticleManager.ReleaseParticleIndex(this.particle);
		}
	}
}

class modifier_crater_area_control extends CDOTA_Modifier_Lua {
	position:Vec

	OnCreated(kv) {
		if (IsClient()) {return}
		this.position = Vector(kv.x,kv.y,kv.z);
		//this.GetCaster().GetAbsOrigin();
		this.StartIntervalThink(FrameTime());

	}

	OnIntervalThink() {
		let unit = this.GetParent();
		let break_range = 500;
		let direction = unit.GetAbsOrigin() - this.position;
		direction = direction.Normalized();
		AddFOWViewer(unit.GetTeamNumber(),this.position,break_range,FrameTime()*2,false);
	}

	DeclareFunctions() {
		return [
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			modifierfunction.MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			modifierfunction.MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
			modifierfunction.MODIFIER_PROPERTY_FIXED_DAY_VISION,
		]
	}

	GetFixedDayVision() {
		return 50;
	}
	GetFixedNightVision() {
		return 50;
	}
	GetModifierMoveSpeed_Limit() {
		if(this.GetStackCount() == 1) {
			return 0.01;
		}
	}

	GetModifierMoveSpeedBonus_Constant() {
		if (this.GetStackCount() == 1) {
			return -1000;
		}
	}
}

class modifier_crater_spell_manager extends CDOTA_Modifier_Lua {

}