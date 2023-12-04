local new_types = {
	apothecary_gas_enemy_mark = {
		based_on = "mark_enemy",
		priority = 3,
		fadeout = 10,
		material_swap_required = true,
		color = Color("6ad100"):vector()
	}
}

for name, preset in pairs(new_types) do
	ContourExt._types[name] = preset
	ContourExt.indexed_types[#ContourExt.indexed_types+1] = name
end

-- DO NOT SORT

if #ContourExt.indexed_types > 128 then
	Application:error("[ContourExt] max # contour presets exceeded!")
end

-- must be called manually
function ContourExt:sync_mark_to_peers(id) 
	local multiplier = 1
	local sync_unit = self._unit
	local u_id = sync_unit:id()
	local data = self._types[id]
	if data.based_on then
		if u_id == -1 then
			sync_unit, u_id = nil
			local corpse_data = managers.enemy:get_corpse_unit_data_from_key(sync_unit:key())

			if corpse_data then
				u_id = corpse_data.u_id
			end
		end

		if u_id then
			managers.network:session():send_to_peers_synched("sync_contour_add", sync_unit, u_id, table.index_of(ContourExt.indexed_types, data.based_on), multiplier or 1)
		else
			log("[ContourExt:sync_mark_to_peers] Unit isn't network-synced and isn't a registered corpse, can't sync. " .. tostring(self._unit))
		end
	end
end

--[[
Hooks:PreHook(ContourExt,"add","customperkdeck_contourext_add",function(self, type, sync, multiplier, override_color, is_element)
	if Hooks:GetReturn() then
		local multiplier = 1
		local sync_unit = self._unit
		local u_id = sync_unit:id()
		local data = self._types[type]
		if data.based_on then
			if u_id == -1 then
				sync_unit, u_id = nil
				local corpse_data = managers.enemy:get_corpse_unit_data_from_key(sync_unit:key())

				if corpse_data then
					u_id = corpse_data.u_id
				end
			end

			if u_id then
				managers.network:session():send_to_peers_synched("sync_contour_add", sync_unit, u_id, table.index_of(ContourExt.indexed_types, data.based_on), multiplier or 1)
			else
				log("[ContourExt:sync_mark_to_peers] Unit isn't network-synced and isn't a registered corpse, can't sync. " .. tostring(self._unit))
			end
		end
	end
end)
--]]