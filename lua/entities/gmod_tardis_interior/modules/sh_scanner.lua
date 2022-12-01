-- Scanner

function ENT:GetScannersOn()
    return self:GetData("scanners_on", false)
end

if SERVER then
    function ENT:SetScannersOn(on)
        self:SetData("scanners_on", on, true)
        self:CallHook("ScannersToggled", on)
        return true
    end

    function ENT:ToggleScanners()
        return self:SetScannersOn(not self:GetScannersOn())
    end

    return
end

ENT:AddHook("Initialize", "scanner", function(self)
    self.scanners = {}
    if self.metadata.Interior.Scanners then
        for k,v in pairs(self.metadata.Interior.Scanners) do
            local scanner = {}
            scanner.uid = "tardisi_scanner_"..self:EntIndex().."_"..k.."_"..v.width.."_"..v.height.."_"..v.fov
            scanner.mat=CreateMaterial(
                scanner.uid,
                "VertexLitGeneric",
                {
                    ["$model"] = "1",
                    ["$nodecal"] = "1",
                    ["$selfillum"] = "1",
                }
            )
            local found=false
            for i,mat in pairs(self:GetMaterials()) do
                if mat==v.mat then
                    self:SetSubMaterial(i-1,"!"..scanner.uid)
                    found=true
                    break
                end
            end
            if not found then
                ErrorNoHalt("Could not find material "..v.mat.." for scanner on "..self:GetModel())
            end
            scanner.rt = GetRenderTarget(scanner.uid, v.width, v.height, false)
            scanner.mat:SetTexture("$basetexture",scanner.rt)
            scanner.ang = v.ang
            scanner.width = v.width
            scanner.height = v.height
            scanner.fov = v.fov
            table.insert(self.scanners, scanner)
        end
    end
end)

ENT:AddHook("ShouldDrawScanners", "scanner", function(self)
    if not (self:GetScannersOn() and self:GetPower() and (not LocalPlayer():GetTardisData("outside"))) then
        return false
    end
end)

ENT:AddHook("ShouldDraw", "scanner", function(self)
    if self.scannerrender then
        return false
    end
end)

ENT:AddHook("ShouldNotRenderPortal","scanner",function(self,parent,portal,exit)
    if self.scannerrender and portal==self.portals.interior then
        return true
    end
end)

ENT:AddHook("PreScannerRender", "scanner", function(self)
    for k,v in pairs(self.props) do
        if IsValid(k) then
            k.olddraw=k:GetNoDraw()
            k:SetNoDraw(true)
        end
    end
end)

ENT:AddHook("PostScannerRender", "scanner", function(self)
    for k,v in pairs(self.props) do
        if IsValid(k) and k.olddraw~=nil then
            k:SetNoDraw(k.olddraw)
            k.olddraw=nil
        end
    end
end)