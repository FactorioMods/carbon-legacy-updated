require("factsheet")

--adamo.opts.debugging = true

if settings.startup["adamo-carbon-steam-processing"].value then
	local replace_water_with_steam = function(recipe_list)
		for _,recipe in pairs(recipe_list) do
			io_manip(recipe,"water","steam")
		end
	end
	replace_water_with_steam({
		"advanced-oil-processing",
		"heavy-oil-cracking",
		"light-oil-cracking",
		"adamo-carbon-petroleum-gas-cracking",
		"adamo-carbon-advanced-natural-gas-processing",
		"adamo-carbon-syngas-from-fuel",
		"adamo-carbon-heavy-oil-from-syngas",
		"adamo-carbon-light-oil-from-syngas",
		"adamo-carbon-petroleum-gas-from-syngas",
		"sulfur",
		"light-sulfur",
		"heavy-sulfur"
	})
end

local solid_fuel_value =
	get_fuel_value(data.raw.item["solid-fuel"])
if data.raw.fluid["adamo-carbon-methane"] then
	apply_fluid_fuel_stat(
		"adamo-carbon-methane",
		energy_div(solid_fuel_value,fuelfactors["methane"])
	)
end
if data.raw.fluid["adamo-carbon-natural-gas"] then
	apply_fluid_fuel_stat(
		"adamo-carbon-natural-gas",
		energy_div(solid_fuel_value,fuelfactors["methane"])
	)
end

local syngas_name = "adamo-carbon-syngas"
if syngas_name
~= settings.startup["adamo-carbon-syngas"].value
then
	syngas_name = 
		settings.startup["adamo-carbon-syngas"].value
	if data.raw.fluid[syngas_name] then
		replace_in_recipe_io(
			"adamo-carbon-syngas-from-methane",
			"adamo-carbon-syngas",
			syngas_name
		)
		replace_in_recipe_io(
			"adamo-carbon-syngas-from-fuel",
			"adamo-carbon-syngas",
			syngas_name
		)
		data.raw.fluid["adamo-carbon-syngas"].hidden = true
		apply_fluid_fuel_stat(
			syngas_name,
			data.raw.fluid["adamo-carbon-syngas"].fuel_value
		)
	else
		syngas_name = "adamo-carbon-syngas"
	end
end

local gasmult = adamo.chem.mult.fluid
	* math.floor(
		fuelfactors["syngas"]
		/fuelfactors["coal"]
		/fuelfactors["crude-oil"]
	)

local syngas_tint = {
	primary =
		data.raw.fluid["adamo-carbon-syngas"].base_color,
	secondary =
		data.raw.fluid["adamo-carbon-syngas"].flow_color,
	tertiary =
		data.raw.fluid["adamo-carbon-syngas"].flow_color,
	quaternary =
		data.raw.fluid["adamo-carbon-syngas"].base_color,
}

local new_coalgas_iron_recipe = function(recipe,gasname)
	local new_recipe = util.table.deepcopy(recipe)
	new_recipe.name = new_recipe.name.."-from-syngas"
	if new_recipe.category == "crafting"
	or not new_recipe.category then
		new_recipe.category = "chemistry"
	end
	--if not new_recipe.crafting_machine_tint then
	--	new_recipe.crafting_machine_tint = {}
	--end
	--if not new_recipe.crafting_machine_tint.secondary then
	--	new_recipe.crafting_machine_tint.secondary = 
	--	syngas_tint.secondary
	--end
	--if not new_recipe.crafting_machine_tint.tertiary then
	--	new_recipe.crafting_machine_tint.tertiary = 
	--	syngas_tint.tertiary
	--end
	--new_recipe.crafting_machine_tint.primary =
	--	syngas_tint.primary
	--new_recipe.crafting_machine_tint.quaternary =
	--	syngas_tint.quaternary
	replace_in_recipe_io(new_recipe,"coal",gasname,gasmult)
	add_ingredient(new_recipe,"iron-plate",1)
	if is_productivity_recipe(recipe) then
		set_productivity_recipe(new_recipe)
	end
	mirror_recipe_in_techs(recipe,new_recipe)
	adamo.recipe.tint.apply(new_recipe)
	data:extend({new_recipe})
end

local new_coalgas_copper_recipe = function(recipe,gasname)
	local new_recipe = util.table.deepcopy(recipe)
	new_recipe.name = new_recipe.name.."-from-syngas"
	if new_recipe.category == "crafting"
	or not new_recipe.category then
		new_recipe.category = "chemistry"
	end
	--if not new_recipe.crafting_machine_tint then
	--	new_recipe.crafting_machine_tint = {}
	--end
	--if not new_recipe.crafting_machine_tint.secondary then
	--	new_recipe.crafting_machine_tint.secondary = 
	--	syngas_tint.secondary
	--end
	--new_recipe.crafting_machine_tint.primary =
	--	syngas_tint.primary
	--new_recipe.crafting_machine_tint.quaternary =
	--	syngas_tint.quaternary
	replace_in_recipe_io(new_recipe,"coal",gasname,gasmult)
	add_ingredient(new_recipe,"copper-plate",1)
	if is_productivity_recipe(recipe) then
		set_productivity_recipe(new_recipe)
	end
	add_recipe_to_tech("coal-liquefaction",new_recipe)
	adamo.recipe.tint.apply(new_recipe)
	data:extend({new_recipe})
end

for _,category_name in pairs({
	"chemistry",
	"crafting",
	"crafting-with-fluid"
}) do
	for _,recipe
	in pairs(all_recipes_of_category(category_name)) do
		if uses_ingredient(recipe,"coal") then
			if uses_ingredient(recipe,"petroleum-gas") then
				new_coalgas_iron_recipe(recipe,syngas_name)
			else
				new_coalgas_copper_recipe(recipe,syngas_name)
			end
		end
	end
end