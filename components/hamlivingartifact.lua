local LivingArtifact = Class(function(self, inst)
    self.inst = inst

end)

function LivingArtifact:Activate(doer)
	print("DS - Living artifact component got activation, sending to main suit...")
	self.inst:PushEvent("activatesuit",{doer=doer})
end


return LivingArtifact
