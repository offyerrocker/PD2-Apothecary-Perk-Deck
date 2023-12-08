local tmp_vec = Vector3()
Hooks:PostHook(DOTManager,"init","apothecary_dotmanager_init",function(self)
	Hooks:Add("catalyzer_nausea","dotmanager_" .. tostring(self),function()
		-- on nausea event, inflict hurt_sick stun anim on all enemies who are afflicted with poison gas
		for _,dot_info in pairs(self._doted_units) do
			if dot_info.gascloud_id then
				local unit = dot_info.unit
				local dmg_ext = alive(unit) and unit:character_damage()
				if dmg_ext then
					local hurt_data = {
						damage = 0,
						variant = "bullet",
						pos = tmp_vec,
						attack_dir = tmp_vec,
						result = {
							variant = "bullet",
							type = "hurt_sick"
						}
					}
					dmg_ext:_call_listeners(hurt_data)
				end
			end
		end
	end)
end)

Hooks:PreHook(DOTManager,"on_simulation_ended","apothecary_dotmanager_remove",function(self)
	Hooks:Remove("catalyzer_nausea")
end)

Hooks:PostHook(DOTManager,"_add_doted_enemy","apothecary_add_doted_enemy",function(self,data)
	local dot_info,var_info,should_sync = Hooks:GetReturn()
	if dot_info and data.gascloud_id then
		dot_info.gascloud_id = data.gascloud_id
	end
end)

local orig_damage_dot = DOTManager._damage_dot
function DOTManager:_damage_dot(dot_info,var_info,...)
	if dot_info.gascloud_id then 
		
		if not alive(dot_info.unit) then
			return false
		end
		
		if not var_info.damage_class then
			return false
		end

		if not var_info.can_deal_damage then
			if var_info.apply_hurt_once then
				var_info.hurt_animation = false
			end

			return false
		end
		
		
		--
		local damage = var_info.dot_damage
		local catalyzer_active = managers.player:get_property("apothecary_catalyzer_active")
		
		if catalyzer_active then
			local add_dot_rampup = managers.player:upgrade_value("player","apothecary_activate_dot_rampup",0)
			--local prev = var_info.dot_damage_rampup or damage
			if var_info.dot_damage_rampup then
				-- increment dot rampup
				var_info.dot_damage_rampup = var_info.dot_damage_rampup + add_dot_rampup
			else
				-- set to base dot damage + first additional dot rampup
				var_info.dot_damage_rampup = damage + add_dot_rampup
			end
			damage = var_info.dot_damage_rampup
			--Console:SetTracker(string.format("damage %0.2f / %0.2f",prev,damage),6)
		end
		
		local damage_class = CoreSerialize.string_to_classtable(var_info.damage_class)

		if damage_class and damage_class.give_damage_dot then
			
			local col_ray = {
				unit = dot_info.unit
			}
			local weapon_unit = var_info.last_weapon_unit
			weapon_unit = alive(weapon_unit) and weapon_unit or nil
			local attacker = var_info.last_attacker_unit
			attacker = alive(attacker) and attacker or nil

			if attacker then
				local base_ext = attacker:base()

				if base_ext and base_ext.thrower_unit then
					attacker = base_ext:thrower_unit()
					attacker = alive(attacker) and attacker or nil
				end
			end

			local result = damage_class:give_damage_dot(col_ray, weapon_unit, attacker, damage, var_info.hurt_animation, var_info.last_weapon_id, var_info.variant)
			
			if result and result ~= "friendly_fire" then
				local is_dead = result.type == "death"
				
				local dmg_ext = col_ray.unit.character_damage and col_ray.unit:character_damage()
				if dmg_ext then 
					dmg_ext._apothecary_dot_last_t = TimerManager:game():time()
				end
				
				local base_ext = weapon_unit and weapon_unit:base()
				
				if base_ext and base_ext.thrower_unit and base_ext._check_achievements then

					base_ext:_check_achievements(dot_info.unit, is_dead, result.damage_percent or 0, 1, is_dead and 1 or 0, var_info.variant)
				end
				
				-- perform heal on kill
				if is_dead then
				--[[
					if managers.player:has_category_upgrade("player","apothecary_activate_ally_kill_restore_health") then
						local upgrade_data = managers.player:upgrade_value("player","apothecary_activate_ally_kill_restore_health")
						local stacks_add = catalyzer_active and upgrade_data.melee_stacks or upgrade_data.kill_stacks
						Hooks:Call("apothecary_check_kill_heal_stacks",stacks_add)
					end
				--]]
					if managers.player:has_category_upgrade("player","apothecary_catalyzer_cooldown_drain") then
						local duration_bonus = managers.player:upgrade_value("player","apothecary_catalyzer_cooldown_drain",0)
						local gas_cloud = PoisonGasEffect._registered_effects[dot_info.gascloud_id]
						if gas_cloud then 
							gas_cloud:extend_timer(duration_bonus)
						end
					end
				end
				
			end

			if var_info.apply_hurt_once then
				var_info.hurt_animation = false
			end
			
		elseif damage_class then
			Application:error("[DOTManager:_damage_dot] Class '" .. tostring(var_info.damage_class) .. "' lacks 'give_damage_dot' function.")
		else
			Application:error("[DOTManager:_damage_dot] No class found with '" .. tostring(var_info.damage_class) .. "'.")
		end

		return not alive(dot_info.unit) or dot_info.unit:character_damage().dead and dot_info.unit:character_damage():dead()
	end
	return orig_damage_dot(self,dot_info,var_info,...)
end
