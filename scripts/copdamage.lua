local function die(self,attack_data)
	local contour_ext = self._unit.contour and self._unit:contour()
	if contour_ext then 
		contour_ext:remove_by_id("apothecary_gas_enemy_mark")
	end
	
	if attack_data and attack_data.attacker_unit and alive(attack_data.attacker_unit) then 
		local player = managers.player:local_player()
		if alive(player) then
			local is_melee = attack_data.variant == "melee"
			local is_gassed = self._apothecary_dot_last_t and TimerManager:game():time() + 1 > self._apothecary_dot_last_t
			if attack_data.attacker_unit == player then
				
				-- check local player melee kill
				if alive(player) then
				--[[
					if managers.player:has_category_upgrade("player","apothecary_activate_ally_kill_restore_health") and managers.player:get_property("apothecary_catalyzer_active") then
						local upgrade_data = managers.player:upgrade_value("player","apothecary_activate_ally_kill_restore_health")
						if is_melee then 
							Hooks:Call("apothecary_check_kill_heal_stacks",upgrade_data.melee_stacks)
						else
							Hooks:Call("apothecary_check_kill_heal_stacks",upgrade_data.kill_stacks)
						end
					end
					--]]
					if is_melee and is_gassed then
						if managers.player:has_category_upgrade("player","apothecary_gas_enemy_melee_catalyzer_extension") then
							Hooks:Call("apothecary_catalyzer_extend_timer",managers.player:upgrade_value("player","apothecary_gas_enemy_melee_catalyzer_extension",0))
						end
						
						if managers.player:has_category_upgrade("player","apothecary_gas_enemy_melee_panic") then
							local upgrade_data = managers.player:upgrade_value("player","apothecary_gas_enemy_melee_panic")
							local range = upgrade_data[1]
							local add_suppression = upgrade_data[2]
							local enemies_mask = managers.slot:get_mask("enemies")
							local criminals_mask = managers.slot:get_mask("criminals")
							local turrets_mask = managers.slot:get_mask("sentry_gun")
							
							-- centered around killed enemy
							local nearby_enemies = World:find_units_quick("sphere", self._unit:position(), range, enemies_mask)
							for _,enemy_unit in pairs(nearby_enemies) do 
								if not (enemy_unit:in_slot("criminals_mask") or enemy_unit:in_slot("turrets_mask")) then
									local dmg_ext = alive(enemy_unit) and enemy_unit:character_damage()
									if dmg_ext and not dmg_ext:dead() then
										dmg_ext:build_suppression(0, add_suppression)
									end
								end
							end
							
						end
					end
				end
				--[[
			elseif managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then 
				if managers.player:has_category_upgrade("player","apothecary_activate_ally_kill_restore_health") and managers.player:get_property("apothecary_catalyzer_active") then
					local upgrade_data = managers.player:upgrade_value("player","apothecary_activate_ally_kill_restore_health")
					if is_melee then 
						Hooks:Call("apothecary_check_kill_heal_stacks",upgrade_data.melee_stacks)
					else
						Hooks:Call("apothecary_check_kill_heal_stacks",upgrade_data.kill_stacks)
					end
				end
				--]]
			end
			
			if managers.player:has_category_upgrade("player","apothecary_activate_ally_kill_restore_health") then
				if is_gassed then 
					local upgrade_data = managers.player:upgrade_value("player","apothecary_activate_ally_kill_restore_health")
					local add_stacks
					local melee_stacks = upgrade_data.melee_stacks
					local kill_stacks = upgrade_data.kill_stacks
					if is_melee then
						add_stacks = melee_stacks
					else
						add_stacks = kill_stacks
					end
					if managers.player:get_property("apothecary_catalyzer_active") then
						add_stacks = add_stacks * upgrade_data.catalyst_double_stacks
					end
					Hooks:Call("apothecary_check_kill_heal_stacks",add_stacks)
				end
				-- this hook is defined in PlayerManager
				-- double-health upgrade is also handled in PlayerManager
			end
			
		end
	end
end


local function damage_melee(self,attack_data)
	if self._apothecary_dot_last_t and TimerManager:game():time() + 1 > self._apothecary_dot_last_t then
		attack_data.damage = attack_data.damage * (1 + managers.player:upgrade_value("player","apothecary_gas_enemy_melee_vulnerability",0))
	end
end

if string.lower(RequiredScript) == "lib/units/enemies/cop/copdamage" then
	Hooks:PreHook(CopDamage,"die","apothecary_copdamage_die",die)
	Hooks:PreHook(CopDamage,"damage_melee","apothecary_copdamage_melee",damage_melee)
else
	Hooks:PreHook(HuskCopDamage,"die","apothecary_huskcopdamage_die",die)
	Hooks:PreHook(HuskCopDamage,"damage_melee","apothecary_huskcopdamage_melee",damage_melee)
end
