local function normalize()
 for _,r in pairs(data.raw.recipe) do
  if r.normal then for k,v in pairs(r.normal) do r[k]=v end;r.normal=nil;r.expensive=nil end
  for _,i in pairs(r.ingredients or {}) do if i[1] then i.type="item";i.name=i[1];i.amount=i[2];i[1]=nil;i[2]=nil end;i.catalyst_amount=nil end
  if r.result then r.results={{type="item",name=r.result,amount=r.result_count or 1}};r.result=nil;r.result_count=nil end
  if r.category then r.categories={r.category};r.category=nil end
  for _,i in pairs(r.results or {}) do if i.catalyst_amount then i.ignored_by_productivity=i.catalyst_amount;i.ignored_by_stats=i.catalyst_amount;i.catalyst_amount=nil end end
 end
 for _,kind in ipairs({'assembling-machine','mining-drill','furnace'}) do for name,e in pairs(data.raw[kind]) do if name:find('adamo%-carbon') then
  if e.animation then e.graphics_set={animation=e.animation};e.animation=nil end
  if e.module_specification then e.module_slots=e.module_specification.module_slots;e.module_specification=nil end
  if e.energy_source and type(e.energy_source.emissions_per_minute)=='number' then e.energy_source.emissions_per_minute={pollution=e.energy_source.emissions_per_minute} end
  if e.fluid_boxes then
   e.fluid_boxes_off_when_no_fluid_recipe=e.fluid_boxes.off_when_no_fluid_recipe;e.fluid_boxes.off_when_no_fluid_recipe=nil
   for _,b in pairs(e.fluid_boxes) do
    if b.base_area then b.volume=b.base_area*100;b.base_area=nil end;b.base_level=nil
    for _,c in pairs(b.pipe_connections or {}) do if c.type then c.flow_direction=c.type=='input-output' and 'input-output' or c.type;c.type=nil end
     local p=c.position;if p and c.direction==nil then local x,y=p[1] or p.x,p[2] or p.y
      if math.abs(x)>math.abs(y) then c.direction=x>0 and defines.direction.east or defines.direction.west;c.position={x-(x>0 and 1 or -1),y} else c.direction=y>0 and defines.direction.south or defines.direction.north;c.position={x,y-(y>0 and 1 or -1)} end
     end
    end
   end
  end
 end end end
end
local old=normalize; return function() old(); for _,t in pairs(data.raw.technology) do if t.effects then local keys={};for k in pairs(t.effects) do keys[#keys+1]=k end;table.sort(keys);local dense={};for _,k in ipairs(keys) do dense[#dense+1]=t.effects[k] end;t.effects=dense end end end



