local tmp_vec = Vector3()
Hooks:PostHook(DOTManager,"init","apothecary_dotmanager_init",function(self)
	Hooks:Add("catalyzer_nausea","dotmanager_" .. tostring(self),function()
		-- inflict nausea anim on all enemies who are afflicted with poison gas
		for _,dot_info in pairs(self._doted_enemies) do
			if dot_info.gascloud_id then
				local unit = dot_info.enemy_unit
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

function DOTManager:add_doted_enemy_from_gas(gascloud_id,enemy_unit,...)
	self:_add_doted_enemy(enemy_unit,...)
	for _,dot_info in pairs(self._doted_enemies) do 
		if dot_info.enemy_unit == enemy_unit then 
			dot_info.gascloud_id = gascloud_id
			break
		end
	end
end

local orig_damage_dot = DOTManager._damage_dot
function DOTManager:_damage_dot(dot_info,...)
	if dot_info.gascloud_id then 
		if not alive(dot_info.enemy_unit) then
			return
		end
		
		local attacker_unit = managers.player:player_unit()
		local col_ray = {
			unit = dot_info.enemy_unit
		}
		local damage = dot_info.dot_damage
		local ignite_character = false
		local weapon_unit = dot_info.weapon_unit
		local weapon_id = dot_info.weapon_id
	
		local catalyzer_active = managers.player:get_property("apothecary_catalyzer_active")
		--
		if catalyzer_active then
			local add_dot_rampup = managers.player:upgrade_value("player","apothecary_activate_dot_rampup",0)
			--local prev = dot_info.dot_damage_rampup or damage
			if dot_info.dot_damage_rampup then
				-- increment dot rampup
				dot_info.dot_damage_rampup = dot_info.dot_damage_rampup + add_dot_rampup
			else
				-- set to base dot damage + first additional dot rampup
				dot_info.dot_damage_rampup = damage + add_dot_rampup
			end
			damage = dot_info.dot_damage_rampup
			--Console:SetTracker(string.format("damage %0.2f / %0.2f",prev,damage),6)
		end
		--
		
		if dot_info.variant and dot_info.variant == "poison" then
			
			local result = PoisonBulletBase:give_damage_dot(col_ray, weapon_unit, attacker_unit, damage, dot_info.hurt_animation, weapon_id)
			if result then 
				local dmg_ext = dot_info.enemy_unit.character_damage and dot_info.enemy_unit:character_damage()
				if dmg_ext then 
					dmg_ext._apothecary_dot_last_t = TimerManager:game():time()
				end
				
				local is_dead = result.type == "death"
				if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().thrower_unit then
					weapon_unit:base():_check_achievements(dot_info.enemy_unit, is_dead, result.damage_percent or 0, 1, is_dead and 1 or 0, dot_info.variant)
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
			
			if dot_info.hurt_animation and dot_info.apply_hurt_once then
				dot_info.hurt_animation = false
			end
		end
		
		return
	end
	return orig_damage_dot(self,dot_info,...)
end
