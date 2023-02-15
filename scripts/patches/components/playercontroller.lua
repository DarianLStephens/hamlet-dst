return function(self)
    function self:DoFlipFacing(dir)
        if self.placer_recipe and self.placer_recipe.flipable then
            if self.placer then
                if self.placer.flipsrotate then
                    local rotation = self.placer.Transform:GetRotation()
                    local inc = 10
                    if dir == "left" then
                        inc = inc * -1 
                    end
                    self.placer.Transform:SetRotation(rotation+inc)
                else	
                    local rotation = self.placer.Transform:GetRotation()
                    self.placer.AnimState:SetScale(rotation < 0 and 1 or -1,1,1)
                    self.placer.Transform:SetRotation(rotation - 180)
                end
            end
        end
    end

    local _OnControl = self.OnControl
    function self:OnControl(control, down, ...)
        local val = _OnControl(self, control, down, ...)
        if not val then
            if down then
                if control == CONTROL_ROTATE_LEFT then
                    self:DoFlipFacing("left")
                elseif control == CONTROL_ROTATE_RIGHT then					
                    self:DoFlipFacing("right")
                end
            end
        end
    end

    local _GetHoverTextOverride = self.GetHoverTextOverride
    function self:GetHoverTextOverride(...)
        local val = _GetHoverTextOverride(self, ...)
        if val and self.placer_recipe and self.placer_recipe.flipable then
            val = val.."\n".."Rotate (Q) and (E)"
        end
        return val
    end
end
