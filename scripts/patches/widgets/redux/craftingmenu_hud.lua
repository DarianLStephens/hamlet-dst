local ImageButton = require "widgets/imagebutton"

local atlas = resolvefilepath(CRAFTING_ATLAS)

local images = {
    reno = "tab_home_decor"
}

return function(self)
    function self:AddFilterSwapper(filter)
        local pos = self.pinbar.open_menu_button:GetPosition()

        self.swap = self.pinbar.root:AddChild(ImageButton(atlas, "pinslot_bg.tex", "pinslot_bg.tex", nil, nil, nil, {1,1}, {0,0}))
        self.swap_img = self.swap.image:AddChild(Image("images/porkland_hud.xml", images[filter]..".tex"))

        self.swap:SetPosition(pos.x + 60, pos.y)
        self.swap:SetScale(1, .6)
        self.swap:MoveToBack()
        
        self.swap_img:SetScale(0.6, 1)
        self.swap_img:SetPosition(15, 0)

        local last = true
        self.swap:SetOnClick(function()
            self.craftingmenu:MakeSpecialFilter(last and filter or "")
            last = not last
			self.swap_img:SetTexture("images/porkland_hud.xml", (last and images[filter] or "tab_crafting")..".tex")
        end)
    end
end