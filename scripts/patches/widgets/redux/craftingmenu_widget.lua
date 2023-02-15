local banned_tabs = {
    [CRAFTING_FILTERS.EVERYTHING.name] = true,
    [CRAFTING_FILTERS.MODS.name] = true,
}
return function(self)
    self.origfilters = deepcopy(CRAFTING_FILTER_DEFS)
    local hidden_recipes = {}
    for _, data in pairs(SPECIAL_CRAFTING_FILTERS) do
        for filter, tab in pairs(CRAFTING_FILTER_DEFS) do
            if data[tab.name] then
                for k, v in pairs(tab.recipes) do
                    table.insert(hidden_recipes, v)
                end   
            end
        end        
    end

    local _ApplyFilters = self.ApplyFilters
    function self:ApplyFilters(...)
        _ApplyFilters(self, ...)
        
        if not banned_tabs[self.current_filter_name] then
            return
        end

        local newfilter = {}

        for k, v in ipairs(self.filtered_recipes) do
            if not table.invert(hidden_recipes)[v.recipe.name] then
                table.insert(newfilter, v)
            end
        end

        self.filtered_recipes = newfilter
        if self.crafting_hud:IsCraftingOpen() then
            self:UpdateRecipeGrid(self.focus and not TheFrontEnd.tracking_mouse)
        else
            self.recipe_grid.dirty = true
        end
    end

    function self:MakeSpecialFilter(filter)
        local defs = {}
        if filter ~= "" then
            for k, v in pairs(self.origfilters) do
                if v and v.tab_type == filter then
                    v.custom_pos = nil
                    table.insert(defs, v)
                end
            end
        else
            for k, v in pairs(self.origfilters) do
                if v and v.tab_type then
                    v.custom_pos = true -- to hide
                end
                table.insert(defs, v)
            end
        end
        CRAFTING_FILTER_DEFS = defs

        self.frame:Kill()
        self.frame = self.root:AddChild(self:MakeFrame(500, 600))
        if filter ~= "" then
            self.favorites_filter:Kill()
            self.special_event_filter:Kill()
            self.crafting_station_filter:Kill()
            self.mods_filter:Kill()

            self:UpdateFilterButtons()

            self:SelectFilter(CRAFTING_FILTER_DEFS[1].name, true)
            local data = self.filtered_recipes[1]
            self:PopulateRecipeDetailPanel(data, data ~= nil and Profile:GetLastUsedSkinForItem(data.recipe.name) or nil)
        
            self:Refresh() 
        else
            self:Initialize()
        end
    end
end