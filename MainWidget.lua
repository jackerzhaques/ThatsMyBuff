TMBMainWidgetMixin = {}

function TMBMainWidgetMixin:SetTab(index)
    PanelTemplates_SetTab(self, index)
    for i = 1,#self.tabFrames do
        if i == index then
            self.tabFrames[i]:Show()
        else
            self.tabFrames[i]:Hide()
        end
    end
end

function TMBMainWidgetMixin:Initialize()
    self.elapsed = 0;
    self.tabFrames = {};
    local children = { self:GetChildren() };
    local searchstr = self:GetName() .. "_tabFrame"
    for _, child in ipairs(children) do
        local childname = child:GetName()
        if childname then
            if string.find(childname, searchstr) and (#childname == #searchstr+1) then
                table.insert(self.tabFrames, child)
            end
        end
    end
    PanelTemplates_SetNumTabs(self, #self.tabFrames)
    self:SetTab(1)
end

function TMBTabButtonCallback(self)
    local MainWidget = self:GetParent()
    local id = self:GetID()
    MainWidget:SetTab(id)
end
