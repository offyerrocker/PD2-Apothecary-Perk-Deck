Hooks:PostHook(PlayerManager,"check_skills","apothecary_playermgr_checkskills",function(self)
	if self:has_category_upgrade("player","apothecary_gas_melee_temporary_damage_resistance") then
		-- since this upgrade has custom timer behavior,
		-- it's probably worth polluting the PlayerManager class with a few variables
		-- in order to track it separately
		self._apothecary_bonus_linger_timer = nil
		self._apothecary_damage_resistance_amount = 0
		self._apothecary_is_inside_gas = false
		
		local dmg_resist_per_stack = self:upgrade_value("player","apothecary_gas_melee_temporary_damage_resistance")
		local dmg_resist_max = tweak_data.upgrades.values.player.apothecary_gas_melee_temporary_damage_resistance_max
		local dmg_resist_duration = tweak_data.upgrades.values.player.apothecary_gas_melee_temporary_damage_resistance_duration
		self:register_message(Message.OnEnemyKilled, "on_apothecary_gas_melee_kill",function(weapon_unit, variant)
			local player = self:local_player()
			if alive(player) then
				if self:get_property("apothecary_catalyzer_active") then
					if variant == "melee" then
						-- add one stack of damage resist
						local dmg_resist_amount = self:get_property("apothecary_melee_damage_resist_bonus",0)
						
						dmg_resist_amount = math.min(dmg_resist_amount + dmg_resist_per_stack,dmg_resist_max)
						self:set_property("apothecary_melee_damage_resist_bonus",dmg_resist_amount)
					end
				end
			end
		end)
	else
		self:unregister_message(Message.OnEnemyKilled, "on_apothecary_gas_melee_kill")
		self._apothecary_bonus_linger_timer = nil
	end
	
	
	if self:has_category_upgrade("player","apothecary_activate_ally_kill_restore_health") then 
		local upgrade_data = self:upgrade_value("player","apothecary_activate_ally_kill_restore_health")
		local stacks_added = upgrade_data.kill_stacks
		local melee_stacks = upgrade_data.melee_stacks
		local stacks_threshold = upgrade_data.stacks_threshold
		local heal_self_amount = upgrade_data.heal_self_amount
		local heal_ally_tier = upgrade_data.heal_ally_tier
		local heal_mul = self:upgrade_value("player","apothecary_activate_double_healing",1)
		
		-- pseudo-global check heal stacks function
		Hooks:Add("apothecary_check_kill_heal_stacks","apothecary_on_stacks_changed",function(add_stacks)
			local stacks = self:get_property("apothecary_kill_heal_stacks",0)
			local player = self:local_player()
			if alive(player) then
				if add_stacks then 
					stacks = stacks + add_stacks
				end
				if stacks >= stacks_threshold then
					local num_procs = math.floor(stacks / stacks_threshold) * heal_mul
					
					player:character_damage():restore_health(heal_self_amount * num_procs,false)
					
					for i=1,num_procs,1 do 
						player:network():send("copr_teammate_heal", heal_ally_tier)
					end
					
					self:set_property("apothecary_kill_heal_stacks",stacks % stacks_threshold)
				elseif add_stacks then
					self:set_property("apothecary_kill_heal_stacks",stacks)
				end
			end
		end)
		
		--[[
		-- check local player melee kill
		self:register_message(Message.OnEnemyKilled, "on_apothecary_kill_restore_health",function(weapon_unit, variant)
			local player = self:local_player()
			if alive(player) then
				if variant == "melee" and self:get_property("apothecary_catalyzer_active") then
					_apothecary_dot_last_t
					Hooks:Call("apothecary_check_kill_heal_stacks",melee_stacks)
				end
			end
		end)
		--]]
	else
		Hooks:Remove("apothecary_check_kill_heal_stacks")
		--self:unregister_message(Message.OnEnemyKilled, "on_apothecary_kill_restore_health")
	end
end)

Hooks:PostHook(PlayerManager,"update","apothecary_playermgr_upd",function(self,t,dt)
	-- check if the local player is inside a gas cloud
	
	local player = self:local_player()
	if alive(player) then
		local is_in_gas
		local player_pos = player:movement():m_pos()
		for _,gas_effect in pairs(PoisonGasEffect._registered_effects) do 
			local gas_pos = gas_effect:position()
			local dis = mvector3.distance(player_pos,gas_pos)
			if dis <= gas_effect._range then
				is_in_gas = true
				break
			end
		end
		self._apothecary_is_inside_gas = is_in_gas
		if self._apothecary_bonus_linger_timer then 
			
			--decrement timer
			self._apothecary_bonus_linger_timer = self._apothecary_bonus_linger_timer - dt
			
			if self._apothecary_bonus_linger_timer < 0 then
				self._apothecary_bonus_linger_timer = nil
				self:remove_property("apothecary_melee_damage_resist_bonus")
			end
		end
	end
end)

function PlayerManager:_attempt_apothecary_catalyzer()
	if self:has_category_upgrade("player","apothecary_catalyzer_base") then 
		if self._coroutine_mgr:is_running("apothecary_catalyzer") then
			return false
		end
		
		self:add_coroutine("apothecary_catalyzer", PlayerAction.ApothecaryCatalyzer)
		return true
	end
	return false
end

Hooks:PostHook(PlayerManager,"damage_reduction_skill_multiplier","apothecary_playermgr_damage_resist",function(self,damage_type)
	local multiplier = Hooks:GetReturn() or 1
	local dmg_resist_amount = 0
	if dmg_resist_amount then 
		if self._apothecary_bonus_linger_timer or self:get_property("apothecary_catalyzer_active") then
			dmg_resist_amount = dmg_resist_amount + self:get_property("apothecary_melee_damage_resist_bonus",0)
		end
		if self._apothecary_is_inside_gas then  
			dmg_resist_amount = dmg_resist_amount + self:upgrade_value("player","apothecary_gas_bonus_damage_resistance",0)
		end
		multiplier = multiplier * (1 - dmg_resist_amount)
	end
	return multiplier
end)

Hooks:PostHook(PlayerManager,"health_skill_addend","apothecary_playermgr_health_bonus",function(self)
	local addend = Hooks:GetReturn() or 0
	return addend + self:upgrade_value("player","apothecary_passive_health_increase",0)
end)

Hooks:PostHook(PlayerManager,"movement_speed_multiplier","apothecary_playermgr_speed_mul",function(self,...)
	if self._apothecary_bonus_linger_timer or self:get_property("apothecary_catalyzer_active") then
		local multiplier = Hooks:GetReturn() or 1
		return multiplier * (1 + self:upgrade_value("player","apothecary_activate_speed_boost",0))
	end
end)