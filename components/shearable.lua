local Shearable = Class(function(self, inst)
    self.inst = inst
end)

function Shearable:SetProduct(product, product_amt, drop)
    self.product = product
    self.product_amt = product_amt or 2
    self.drop = drop
end

function Shearable:Shear(shearer, numworks)
    if self.inst.components.hackable then
        numworks = self.inst.components.hackable.hacksleft
        self.inst.components.hackable:Hack(shearer, numworks, self.product_amt, true)
    else
        if self.drop then
            for i=1, self.product_amt do
                local product = SpawnPrefab(self.product)
                if product then
                    local pt = Point(self.inst.Transform:GetWorldPosition())
                    product.Transform:SetPosition(pt.x,pt.y,pt.z)
                    local angle = math.random()*2*PI
                    local speed = math.random()
                    product.Physics:SetVel(speed*math.cos(angle), GetRandomWithVariance(12, 3), speed*math.sin(angle))
                end
            end
        else
            if self.product_amt then
                for i=1, self.product_amt do
                    shearer.components.inventory:GiveItem(  SpawnPrefab(self.product), nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
                end
            end
        end

        if self.inst.onshear then
            self.inst.onshear(self.inst, shearer)
        end
    end
end

function Shearable:CanShear()
    if self.inst.components.hackable and self.inst.components.hackable:CanBeHacked() then
        return self.inst.components.hackable.hacksleft > 0
    else
        if self.inst.canshear then
            return self.inst.canshear(self.inst)
        end
    end
end

function Shearable:IsActionValid(action, right)
    local is_valid = self:CanShear()

    return is_valid and action == ACTIONS.SHEAR
end

return Shearable