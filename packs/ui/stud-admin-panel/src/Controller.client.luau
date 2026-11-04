-- UI preview only. No remotes, moderation, item grants or persistent state.
local gui=script.Parent
local layout=require(gui.Layout)
local canvas=gui.Canvas
local function resize() layout.apply(gui) end
gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
resize()
canvas.Close.Activated:Connect(function() canvas.Visible=false;gui.Open.Visible=true end)
gui.Open.Activated:Connect(function() canvas.Visible=true;gui.Open.Visible=false end)
local UIS=game:GetService('UserInputService')
UIS.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.F4 then
  canvas.Visible=not canvas.Visible;gui.Open.Visible=not canvas.Visible
 end
end)
local function notice(text)
 gui:SetAttribute('LastPreviewAction',text)
 local toast=gui:FindFirstChild('PreviewNotice')
 if not toast then
  toast=Instance.new('TextLabel');toast.Name='PreviewNotice';toast.AnchorPoint=Vector2.new(.5,1)
  toast.Position=UDim2.new(.5,0,1,-4);toast.Size=UDim2.new(1,-24,0,24)
  toast.BackgroundColor3=Color3.fromRGB(20,22,26);toast.BackgroundTransparency=.1
  toast.TextColor3=Color3.new(1,1,1);toast.Font=Enum.Font.GothamMedium;toast.TextSize=12
  toast.TextTruncate=Enum.TextTruncate.AtEnd;toast.ZIndex=20;toast.Parent=gui
 end
 toast.Text=text;toast.Visible=true
 local token=(gui:GetAttribute('NoticeToken') or 0)+1;gui:SetAttribute('NoticeToken',token)
 task.delay(3,function()if gui.Parent and gui:GetAttribute('NoticeToken')==token then toast.Visible=false end end)
end
for _,panel in canvas.Frame:GetChildren() do
 if panel:IsA('Frame') then
  for _,button in panel:GetChildren() do
   if button:IsA('TextButton') then
    local function activate()
     if button.Name=='Global' or button.Name=='Server' then
      panel:SetAttribute('Scope',button.Name)
      notice(panel.Name..': '..button.Name..' scope (UI preview only)')
     else notice(panel.Name..' / '..button.Name..': UI preview only; no command sent') end
    end
    button.Activated:Connect(activate)
    for _,face in button:GetChildren() do if face:IsA('TextButton') then face.Activated:Connect(activate) end end
   end
  end
 end
end
