local using_methane = settings.startup["adamo-carbon-methane"].value
local using_wellhead = settings.startup["adamo-carbon-wellhead"].value
local using_coking = settings.startup["adamo-carbon-coking"].value

require("factsheet")

function apply_data() 
	if settings.startup["adamo-carbon-fluids-fuel"].value
	then apply_vanilla_fluid_fuel_stats() end

	data:extend({
		natural_gas_ac,
		natural_gas_resource,
		gasification_crafting_category,

		syngas_fluid,
		gasify_recipe,
		FT_HO,
		FT_LO,
		FT_PG,

		gasifier_item,
		gasifier_recipe,
		gasifier_entity,
		gasifier_smoke,

		crude_oil_fuel_recipe,
	})

	if using_coking then
		data:extend({
			coal_fuel_recipe
		})
	end

	if using_wellhead or using_methane then
		data:extend({
			gas_tech
		})
	end
	if using_wellhead then
		data:extend({
			 -- without wellhead, uses "basic-fluid" category
			gas_resource_category,

			natural_gas_wellhead_entity,
			natural_gas_wellhead_item,
			natural_gas_wellhead_recipe,
		})
		if not using_methane then
			add_recipe_to_tech(
				"oil-processing",
				"adamo-carbon-gas-wellhead"
			)
		end
		add_recipe_to_tech(
			"adamo-carbon-gas-processing",
			"adamo-carbon-gas-wellhead"
		)
	end
	if using_methane then
		data:extend({
			methane_fluid,
			natural_gas_fluid,
				
			steam_reforming_recipe,

			natural_gas_processing_recipe,
			adv_natural_gas_processing_recipe,

			methane_solid_fuel_recipe,
			rocket_fuel_recipe,
			LPG_cracking_recipe,
		})
		move_recipes_to_tech(
			"fluid-handling",
			{
				"oil-refinery",
				"chemical-plant"
			}
		)
		add_recipes_to_tech(
			"adamo-carbon-gas-processing",
			{
				"adamo-carbon-solid-fuel-from-methane",
				"adamo-carbon-basic-natural-gas-processing",
				"solid-fuel-from-petroleum-gas",
			}
		)
		add_recipes_to_tech(
			"advanced-oil-processing",
			{
				"adamo-carbon-advanced-natural-gas-processing",
				"adamo-carbon-petroleum-gas-cracking",
				"adamo-carbon-syngas-from-methane"
			}
		)
		add_recipe_to_tech(
			"rocket-fuel",
			"adamo-carbon-rocket-fuel"
		)
		add_productivity_recipes({
			"adamo-carbon-solid-fuel-from-methane",
			"adamo-carbon-syngas-from-methane",
			"adamo-carbon-basic-natural-gas-processing",
			"adamo-carbon-advanced-natural-gas-processing"
		})
	end
	add_recipe_to_tech(
		"oil-processing",
		"adamo-carbon-solid-fuel-from-crude-oil"
	)
	move_recipes_to_tech(
		"flammables",
		{
			"adamo-carbon-gasifier",
			"solid-fuel-from-light-oil",
			"solid-fuel-from-heavy-oil",
			"adamo-carbon-heavy-oil-from-syngas"
		}
	)
	add_recipes_to_tech(
		"advanced-oil-processing",
		{
			"adamo-carbon-light-oil-from-syngas"
		}
	)
	add_recipe_to_tech(
		"coal-liquefaction",
		"adamo-carbon-petroleum-gas-from-syngas"
	)
	add_productivity_recipes({
		"adamo-carbon-solid-fuel-from-crude-oil",
		"adamo-carbon-heavy-oil-from-syngas",
		"adamo-carbon-light-oil-from-syngas",
		"adamo-carbon-petroleum-gas-from-syngas",
	})
end

gas_resource_category = {
	type = "resource-category",
	name = "adamo-carbon-gas"
}

gasification_crafting_category = {
	type = "recipe-category",
	name = "adamo-carbon-gasification"
}

gas_tech = {
	type = "technology",
	name = "adamo-carbon-gas-processing",
	icon_size = 132,
	icon = "__fixadamo-carbon__/graphics/technology/gas-processing.png",
	prerequisites = {"fluid-handling"},
	unit = {
		count = 100,
		ingredients = {{
				"automation-science-pack",1
			},{
				"logistic-science-pack",1
		}},
		time = 30,
	},
	order = "d-a",
}

natural_gas_ac = {
	type = "autoplace-control",
	name = "adamo-carbon-natural-gas",
	richness = true,
	order = "b-g",
	category = "resource"
}

resource_autoplace = require("resource-autoplace");
resource_autoplace.initialize_patch_set("adamo-carbon-natural-gas",false)
natural_gas_resource = {
	type = "resource",
	name = "adamo-carbon-natural-gas",
	icon = "__fixadamo-carbon__/graphics/icons/natural-gas.png",
	icon_size = 32,
	flags = {"placeable-neutral"},
	category = "adamo-carbon-gas",
	order="a-b-b",
	infinite = true,
	highlight = true,
	minimum = 150000,
	normal = 1000000,
	infinite_depletion_amount = 30,
	resource_patch_search_radius = 12,
	tree_removal_probability = 0.7,
	tree_removal_max_distance = 32 * 32,
	minable = {
		mining_time = 1,
		results = {{
				type = "fluid",
				name = "adamo-carbon-natural-gas",
				amount_min = 30,
				amount_max = 30,
				probability = 1
		}}
	},
	collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
	selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
	autoplace = resource_autoplace.resource_autoplace_settings {
		name = "adamo-carbon-natural-gas",
		order = "d",
		base_density = 10,
		base_spots_per_km2 = 2,
		random_probability = 1/42,
		random_spot_size_minimum = 1,
		random_spot_size_maximum = 1,
		additional_richness = 220000,
		has_starting_area_placement = true,
		regular_rq_factor_multiplier = 1
	},
	stage_counts = {0},
	stages = {
		sheet = {
			filename =
				"__fixadamo-carbon__/graphics/entity/"
				.."natural-gas.png",
			priority = "extra-high",
			width = 75,
			height = 61,
			frame_count = 4,
			variation_count = 1
	}},
	map_color = {r=1, g=80/255, b=80/255},
	map_grid = false
}
if not using_methane then
	natural_gas_resource.minable = {
		mining_time = 1,
		results = {{
			type = "fluid",
			name = "petroleum-gas",
			amount_min = 6,
			amount_max = 6,
			probability = 1
		}}
	}
	natural_gas_resource.icon = "__base__/graphics/icons/fluid/petroleum-gas.png"
end
if not using_wellhead then 
	natural_gas_resource.category = "basic-fluid"
end

local ng_base_color = {
	r = colors.midgrey.r + 40,
	g = colors.midgrey.g,
	b = colors.midgrey.b
}
local ng_flow_color = {
	r = colors.highgrey.r + 40,
	g = colors.highgrey.g,
	b = colors.highgrey.b
}
local methane_base_color = colors.midgrey
local methane_flow_color = colors.highgrey
local syngas_base_color = colors.syngasred
local syngas_flow_color = colors.black

natural_gas_fluid = {
	type = "fluid",
	name = "adamo-carbon-natural-gas",
	order = "a[fluid]-b[adamo-carbon-natural-gas]",
	icon = "__fixadamo-carbon__/graphics/icons/natural-gas.png",
	icon_size = 32,
	base_color = ng_base_color,
	flow_color = ng_flow_color,
	default_temperature = 25,
	max_temperature = 750,
	heat_capacity = "0.05KJ",
	emissions_multiplier=0.5
}
methane_fluid = {
	type = "fluid",
	name = "adamo-carbon-methane",
	order = "a[fluid]-f[adamo-carbon-methane]",
	icon = "__fixadamo-carbon__/graphics/icons/methane.png",
	icon_size = 32,
	base_color = methane_base_color,
	flow_color = methane_flow_color,
	default_temperature = 25,
	max_temperature = 750,
	heat_capacity = "0.05KJ",
	emissions_multiplier=0.5,
}
syngas_fluid = {
	type = "fluid",
	name = "adamo-carbon-syngas",
	order = "a[fluid]-f[adamo-carbon-syngas]",
	icon = "__fixadamo-carbon__/graphics/icons/syngas.png",
	icon_size = 32,
	base_color = syngas_base_color,
	flow_color = syngas_flow_color,
	default_temperature = 25,
	max_temperature = 750,
	heat_capacity = "0.05KJ",
	emissions_multiplier=0.5,
	fuel_value = energy_div(
		get_fuel_value(data.raw.item["solid-fuel"]),
		fuelfactors["syngas"]
	)
}

natural_gas_processing_recipe = {
	type = "recipe",
	name = "adamo-carbon-basic-natural-gas-processing",
	category = "oil-processing",
	enabled = false,
	icon =
		"__fixadamo-carbon__/graphics/icons/"
		.."basic-natural-gas-processing.png",
	icon_size = 32,
	subgroup = "fluid-recipes",
	order =
		"a[oil-processing]-"
		.."a1[adamo-carbon-basic-natural-gas-processing]",
	energy_required = 2,
	ingredients = {{
		type="fluid",
		name="adamo-carbon-natural-gas",
		amount=100,
		--fluidbox_index = 2
	}},
	results = {{
		type="fluid",
		name="adamo-carbon-methane",
		amount=80
	},{
		type="fluid",
		name="petroleum-gas",
		amount=10
	}},
	main_product = ""
}
adv_natural_gas_processing_recipe = {
	type = "recipe",
	name = "adamo-carbon-advanced-natural-gas-processing",
	category = "oil-processing",
	enabled = false,
	icon =
		"__fixadamo-carbon__/graphics/icons/"
		.."advanced-natural-gas-processing.png",
	icon_size = 32,
	subgroup = "fluid-recipes",
	order =
		"a[oil-processing]-"
		.."b[adamo-carbon-advanced-natural-gas-processing]",
	energy_required = 5,
	emissions_multiplier = 0.5, -- sulfur removed
	ingredients = {
		{type="fluid", name="water", amount=100},
		{type="fluid", name="adamo-carbon-natural-gas", amount=500},
		{type="item",name="iron-plate",amount=1,catalyst_amount = 1}
	},
	results= {
		{type="fluid", name="adamo-carbon-methane", amount=400},
		{type="fluid", name="light-oil", amount=20},
		{type="fluid", name="petroleum-gas", amount=50},
		{
			type="item",
			name="sulfur",
			-- 5% sulfur content with 80% recovery rate.
			amount = math.floor(20/adamo.chem.mult.fluid),
			catalyst_amount=1
		},
	},
}
steam_reforming_recipe = {
	type = "recipe",
	name = "adamo-carbon-syngas-from-methane",
	category = "chemistry",
	enabled = false,
	energy_required = 2.5,
	ingredients = {{
		type="fluid",
		name="steam",
		amount=100
	},{
		type="fluid",
		name="adamo-carbon-methane",
		amount=250
	},{
		type="item",
		name="iron-plate",
		amount=1,
		catalyst_amount = 1
	}},
	results = {{
		type="fluid",
		name="adamo-carbon-syngas",
		amount=250
	}},
	crafting_machine_tint = {
		primary = syngas_base_color,
		secondary = methane_base_color,
		tertiary = methane_flow_color,
		quaternary = syngas_flow_color
	},
	subgroup = "fluid-recipes"
}
local gas_result_count = 50
gasify_recipe = {
	type = "recipe",
	name = "adamo-carbon-syngas-from-fuel",
	category = "adamo-carbon-gasification",
	energy_required = 1,
	ingredients = {{ 
		type = "fluid",
		name = "water",
		amount = 50
	}},
	results = {{
		type = "fluid",
		name = "adamo-carbon-syngas",
		amount = gas_result_count
	}},
	hidden = true
}
FT_HO = {
	type = "recipe",
	name = "adamo-carbon-heavy-oil-from-syngas",
	category = "oil-processing",
	enabled = false,
	energy_required = 10,
	ingredients = {{
		type="fluid",
		name="water",
		amount=100,
	},{
		type="fluid",
		name="adamo-carbon-syngas",
		amount=500,
	},{			
		type="item",
		name="iron-plate",
		amount=1,
		catalyst_amount = 1,
	}},
	results = {{
		type="fluid",
		name="heavy-oil",
		amount=100
	},{
		type="fluid",
		name="light-oil",
		amount=50
	},{
		type="fluid",
		name="petroleum-gas",
		amount=10,
	}},
	main_product= "heavy-oil",
	subgroup = "fluid-recipes",
}
FT_LO = {
	type = "recipe",
	name = "adamo-carbon-light-oil-from-syngas",
	category = "oil-processing",
	enabled = false,
	energy_required = 10,
	ingredients = {{
		type="fluid",
		name="water",
		amount=100,
	},{
		type="fluid",
		name="adamo-carbon-syngas",
		amount=500,
	},{			
		type="item",
		name="iron-plate",
		amount=1,
		catalyst_amount = 1,
	}},
	results = {{
		type="fluid",
		name="heavy-oil",
		amount=40
	},{
		type="fluid",
		name="light-oil",
		amount=100
	},{
		type="fluid",
		name="petroleum-gas",
		amount=20,
	}},
	main_product= "light-oil",
	subgroup = "fluid-recipes",
}

FT_PG = {
	type = "recipe",
	name = "adamo-carbon-petroleum-gas-from-syngas",
	category = "oil-processing",
	enabled = false,
	energy_required = 10,
	ingredients = {{
			type="fluid",
			name="water",
			amount=100,
	},{
			type="fluid",
			name="adamo-carbon-syngas",
			amount=500,
	},{
			type="item",
			name="iron-plate",
			amount=1,
			catalyst_amount = 1,
	},{
			type="item",
			name="copper-plate",
			amount=1,
			catalyst_amount = 1,
	}},
	results = {{
			type="fluid",
			name="heavy-oil",
			amount=10,
	},{
			type="fluid",
			name="light-oil",
			amount=50,
	},{
			type="fluid",
			name="petroleum-gas",
			amount=100,
	}},
	main_product= "petroleum-gas",
	subgroup = "fluid-recipes",
}

crude_oil_fuel_recipe = util.table.deepcopy(data.raw.recipe["solid-fuel-from-heavy-oil"])
crude_oil_fuel_recipe.name = "adamo-carbon-solid-fuel-from-crude-oil"
crude_oil_fuel_recipe.ingredients = {{
	type = "fluid",
	name = "crude-oil",
	amount = fuelfactors["crude-oil"]
}}
crude_oil_fuel_recipe.icon = "__fixadamo-carbon__/graphics/icons/solid-fuel-from-crude-oil.png"
crude_oil_fuel_recipe.icon_size = 32
crude_oil_fuel_recipe.order = "b[fluid-chemistry]-f[adamo-carbon-solid-fuel-from-crude-oil]"
coal_fuel_recipe = {
	type = "recipe", name = "adamo-carbon-solid-fuel-from-coal",
	category = "smelting",
	icon =
		"__fixadamo-carbon__/graphics/icons/"
		.."solid-fuel-from-coal.png",
	icon_size = 32,
	order =
		"b[fluid-chemistry]-"
		.."e[adamo-carbon-solid-fuel-from-coal]",
	energy_required = 2,
	ingredients = {{"coal", fuelfactors.coal}},
	result = "solid-fuel",
	enabled = true,
	hidden = true
}
wood_fuel_recipe = {
	type = "recipe", name = "adamo-carbon-solid-fuel-from-coal",
	category = "smelting",
	icon =
		"__fixadamo-carbon__/graphics/icons/"
		.."solid-fuel-from-wood.png",
	icon_size = 32,
	order =
		"b[fluid-chemistry]-"
		.."e[adamo-carbon-solid-fuel-from-wood]",
	energy_required = 2,
	ingredients = {{"wood", fuelfactors.wood}},
	result = "solid-fuel",
	enabled = true,
	hidden = true
}
methane_solid_fuel_recipe = {
	type = "recipe",
	name = "adamo-carbon-solid-fuel-from-methane",
	category = "chemistry",
	energy_required = 2,
	ingredients = {{
			type = "fluid",
			name = "adamo-carbon-methane",
			amount = fuelfactors["methane"]
	}},
	result = "solid-fuel",
	icon =
		"__fixadamo-carbon__/graphics/icons/"
		.."solid-fuel-from-methane.png",
	icon_size = 32,
	subgroup = "fluid-recipes",
	enabled = false,
	order = 
		"b[fluid-chemistry]-"
		.."d[adamo-carbon-solid-fuel-from-methane]",
	crafting_machine_tint = {
		primary = colors.darkgrey,
		secondary = methane_base_color,
		tertiary = methane_flow_color,
		quaternary = colors.black,
	}
}
rocket_fuel_recipe = util.table.deepcopy(data.raw.recipe["rocket-fuel"])
rocket_fuel_recipe.name = "adamo-carbon-rocket-fuel"
rocket_fuel_recipe.category = "chemistry"
rocket_fuel_recipe.ingredients = {{
		type = "fluid",
		name = "adamo-carbon-methane",
		amount = 500,
	},{
		type = "fluid",
		name = "water",
		amount = 500
}}
LPG_cracking_recipe = {
	type = "recipe",
	name = "adamo-carbon-petroleum-gas-cracking",
	category = "chemistry",
	enabled = false,
	energy_required = 2,
	ingredients = {{
			type="fluid",
			name="water",
			amount=30
	},{
			type="fluid",
			name="petroleum-gas",
			amount=20
	}},
	results = {{
			type="fluid",
			name="adamo-carbon-methane",
			amount=20
	}},
	icon = "__fixadamo-carbon__/graphics/icons/petroleum-gas-cracking.png",
	icon_size = 32,
	subgroup = "fluid-recipes",
	order = "b[fluid-chemistry]-c1[adamo-carbon-petroleum-gas-cracking]",
	crafting_machine_tint = {
		primary = methane_base_color,
		secondary = data.raw.fluid["petroleum-gas"].base_color,
		tertiary = data.raw.fluid["petroleum-gas"].flow_color,
		quaternary = methane_flow_color,
	}
}

natural_gas_wellhead_entity = util.table.deepcopy(data.raw["mining-drill"].pumpjack)
natural_gas_wellhead_entity.name = "adamo-carbon-gas-wellhead"
natural_gas_wellhead_entity.resource_categories = {"adamo-carbon-gas"}
natural_gas_wellhead_entity.energy_source.emissions_per_minute = 6
natural_gas_wellhead_entity.energy_usage = "60kW"
natural_gas_wellhead_entity.icon_size = 32
natural_gas_wellhead_entity.icon = "__fixadamo-carbon__/graphics/icons/natural-gas-wellhead.png"
natural_gas_wellhead_entity.icon_mipmaps = nil
natural_gas_wellhead_entity.minable.result = "adamo-carbon-gas-wellhead"
natural_gas_wellhead_entity.resistances = {{
		type = "fire",
		percent = 70
}}
natural_gas_wellhead_entity.animations = {
	frame_count = 1,
	filename = "__fixadamo-carbon__/graphics/blank.png",
	size = 32,
}
natural_gas_wellhead_entity.working_sound = {
		sound = {
			filename = "__base__/sound/idle1.ogg", volume = 1
		},
		apparent_volume = 1
}
natural_gas_wellhead_entity.collision_mask = {"item-layer", "object-layer", "water-tile"}

natural_gas_wellhead_item = util.table.deepcopy(data.raw.item.pumpjack)
natural_gas_wellhead_item.name = "adamo-carbon-gas-wellhead"
natural_gas_wellhead_item.icon_size = 32
natural_gas_wellhead_item.icon = "__fixadamo-carbon__/graphics/icons/natural-gas-wellhead.png"
natural_gas_wellhead_item.order = "b[fluids]-b[adamo-carbon-gas-wellhead]"
natural_gas_wellhead_item.place_result = "adamo-carbon-gas-wellhead"
natural_gas_wellhead_item.stack_size = 50
natural_gas_wellhead_recipe = {
	type = "recipe",
	name = "adamo-carbon-gas-wellhead",
	enabled = false,
	ingredients = {{
			"electronic-circuit",5
		},{
			"iron-plate",5
		},{
			"pipe",10
		},{
			"steel-plate",2
		},{
			"pump",1
	}},
	result = "adamo-carbon-gas-wellhead"
}

gasifier_entity = {
	type = "furnace",
	name = "adamo-carbon-gasifier",
	icon = "__fixadamo-carbon__/graphics/icons/gasifier.png",
	icon_size = 32,
	flags = {"placeable-neutral","player-creation"},
	minable = {
		mining_time = 1,
		result = "adamo-carbon-gasifier"
	},
	max_health = 250,
	corpse = "big-remnants",
	dying_explosion = "medium-explosion",
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	crafting_categories = {"adamo-carbon-gasification"},
	crafting_speed = 1,
	energy_usage =
		energy_to_power(
			energy_mult(
				get_fuel_value(syngas_fluid),
				2*gas_result_count
			)
		),
	energy_source = {
		type = "burner",
		effectivity = 1,
		fuel_inventory_size = 1,
		emissions_per_minute = 1,
		light_flicker = {
			minimum_intensity = 0.5,
			maximum_intensity = 1
		},
	},
	smoke = {{
			name = "adamo-carbon-gasifier-smoke",
			deviation = {0.1, 0.1},
			frequency = 15,
			north_position = {0.0, -4},
			south_position = {0.0, -4},
			east_position = {0.0, -4},
			west_position = {0.0, -4},
			starting_vertical_speed = 0.08,
			starting_frame_deviation = 60
	}},
	ingredient_count = 0,
	source_inventory_size = 0,
	result_inventory_size = 0,
	animation = {
		filename =
			"__fixadamo-carbon__/graphics/entity/"
			.."gasifier.png",
		priority="high",
		width = 160,
		height = 160,
		frame_count = 1,
		shift = {1.5, -1.59375}
	},
	working_visualisations = {{
			animation = {
				filename =
					"__fixadamo-carbon__/graphics/entity/"
					.."gasifier-fumes.png",
				priority = "extra-high",
				frame_count = 29,
				width = 48,
				height = 105,
				shift = {-0.05, -5.65},
				animation_speed = 0.5,
				scale = 1.5,
				run_mode="backward"
			}
	}},
	vehicle_impact_sound = {
	  filename = "__base__/sound/car-metal-impact.ogg",
	  volume = 0.65
	},
	working_sound = {
		sound = {
			filename = "__base__/sound/oil-refinery.ogg"
		},
		idle_sound = {
			filename = "__base__/sound/idle1.ogg", volume = 0.6
		},
		apparent_volume = 2,
	},
	fluid_boxes = {{
		production_type = "input",
		pipe_picture = bulkypipepictures(),
		secondary_draw_orders = {
			north=-1,south=-1,east=-1,west=-1
		},
		pipe_covers = pipecoverspictures(),
		base_area = 1,
		base_level = -1,
		pipe_connections = {
		  { position = {0, -1} }
		}
	},
	{
		production_type = "output",
		pipe_picture = bulkypipepictures(),
		secondary_draw_orders = {
			north=-1,south=-1,east=-1,west=-1
		},
		pipe_covers = pipecoverspictures(),
		base_area = 1,
		base_level = 1,
		pipe_connections =
		{ 
		  { position = {0, 1} }
		}
	  }
	},
}

gasifier_smoke = trivial_smoke {
	name = "adamo-carbon-gasifier-smoke",
	color = {r = 0.3, g = 0.3, b = 0.3, a = 0.3},
	duration = 150,
	spread_duration = 100,
	fade_away_duration = 100,
	start_scale = 0.4,
	end_scale = 1.5,
	affected_by_wind = true
}

gasifier_item = {
	type = "item",
	name = "adamo-carbon-gasifier",
	icon = "__fixadamo-carbon__/graphics/icons/gasifier.png",
	icon_size = 32,
	subgroup = "smelting-machine",
	order = "d[adamo-carbon-gasifier]",
	place_result = "adamo-carbon-gasifier",
	stack_size = 50
}

gasifier_recipe = {
	type = "recipe",
	name = "adamo-carbon-gasifier",
	enabled = false,
	ingredients = {{
			"stone-brick",5
		},{
			"pipe",5
		},{
			"pump",2
		},{
			"electronic-circuit",2
	}},
	result = "adamo-carbon-gasifier"
}

apply_data()