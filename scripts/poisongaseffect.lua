PoisonGasEffect._registered_effects = {}
PoisonGasEffect._effects_counter = 0

Hooks:PostHook(PoisonGasEffect,"init","apothecary_poisongas_register",function(self)
	local index = PoisonGasEffect._effects_counter + 1
	PoisonGasEffect._effects_counter = index
	self._apothecary_effect_index = index
	PoisonGasEffect._registered_effects[index] = self
	
	
end)
Hooks:PreHook(PoisonGasEffect,"destroy","apothecary_poisongas_remove",function(self)
	if self._apothecary_effect_index then
		PoisonGasEffect._registered_effects[self._apothecary_effect_index] = nil
		self._apothecary_effect_index = nil
	end
end)

function PoisonGasEffect:update(t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if not self._started_fading and self._timer <= self._fade_time then
			World:effect_manager():fade_kill(self._effect)

			self._started_fading = true
		end

		if self._timer <= 0 then
			self._timer = nil

			if alive(self._grenade_unit) and Network:is_server() then
				managers.enemy:add_delayed_clbk("PoisonGasEffect", callback(PoisonGasEffect, PoisonGasEffect, "remove_grenade_unit"), TimerManager:game():time() + self._dot_data.dot_length)
			end
		end
		
		if self._is_local_player then
			self._damage_tick_timer = self._damage_tick_timer - dt

			if self._damage_tick_timer <= 0 then
				self._damage_tick_timer = self._tweak_data.poison_gas_tick_time or 0.1
				local nearby_units = World:find_units_quick("sphere", self._position, self._range, managers.slot:get_mask("enemies"))
				
				local has_gas_highlight = managers.player:has_category_upgrade("player","apothecary_gas_highlight")
				local contour_name
				if has_gas_highlight then
					contour_name = managers.player:upgrade_value("player","apothecary_gas_highlight")
				end
				local criminals_slot = managers.slot:get_mask("criminals")
				
				for _, unit in ipairs(nearby_units) do
					if not table.contains(self._unit_list, unit) then
						
						local hurt_animation = not self._dot_data.hurt_animation_chance or math.rand(1) < self._dot_data.hurt_animation_chance

						managers.dot:add_doted_enemy_from_gas(self._apothecary_effect_index, unit, TimerManager:game():time(), self._grenade_unit, self._dot_data.dot_length, self._dot_data.dot_damage, hurt_animation, "poison", self._grenade_id, true)
						table.insert(self._unit_list, unit)
					end
					
					if has_gas_highlight and not unit:in_slot(criminals_slot) then
						local contour_ext = unit.contour and unit:contour()
						if contour_ext and not contour_ext:has_id(contour_name) then
							local sync = false
							contour_ext:add(contour_name,sync,false,nil,false)
							contour_ext:sync_mark_to_peers(contour_name)
						end
					end
					
				end
			end
		end
	end
end

-- custom func for apothecary
function PoisonGasEffect:extend_timer(duration_bonus)
	if self._timer and duration_bonus then
		self._timer = self._timer + duration_bonus
	end
end
