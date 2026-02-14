local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Left"

local Window = Library:CreateWindow({
    Title = 'Example menu',
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    UnlockMouseWhileOpen = true,
    NotifySide = "Left",
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Esp = Window:AddTab('ESP'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local InputService, HttpService, GuiService, RunService, Stats, CoreGui, TweenService, SoundService, Workspace, Players, Lighting = game:GetService("UserInputService"), game:GetService("HttpService"), game:GetService("GuiService"), game:GetService("RunService"), game:GetService("Stats"), game:GetService("CoreGui"), game:GetService("TweenService"), game:GetService("SoundService"), game:GetService("Workspace"), game:GetService("Players"), game:GetService("Lighting")
local Camera, LocalPlayer, gui_offset = Workspace.CurrentCamera, Players.LocalPlayer, GuiService:GetGuiInset().Y
local Mouse = LocalPlayer:GetMouse()
local vec2, vec3, dim2, dim, rect, dim_offset = Vector2.new, Vector3.new, UDim2.new, UDim.new, Rect.new, UDim2.fromOffset
local color, rgb, hex, hsv, rgbseq, rgbkey, numseq, numkey = Color3.new, Color3.fromRGB, Color3.fromHex, Color3.fromHSV, ColorSequence.new, ColorSequenceKeypoint.new, NumberSequence.new, NumberSequenceKeypoint.new
local angle, empty_cfr, cfr = CFrame.Angles, CFrame.new(), CFrame.new

local FontNames = {
    ["ProggyClean"] = "ProggyClean.ttf",
    ["Tahoma"] = "fs-tahoma-8px.ttf",
    ["Verdana"] = "Verdana-Font.ttf",
    ["SmallestPixel"] = "smallest_pixel-7.ttf",
    ["ProggyTiny"] = "ProggyTiny.ttf",
    ["Minecraftia"] = "Minecraftia-Regular.ttf",
    ["Tahoma Bold"] = "tahoma_bold.ttf",
    ["Rubik"] = "Rubik-Regular.ttf"
}

local Fonts = {}; do
    local function RegisterFont(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then
            writefile(Asset.Id, Asset.Font)
        end

        if isfile(Name .. ".font") then
            delfile(Name .. ".font")
        end

        local Data = {
            name = Name,
            faces = {
                {
                    name = "Normal",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Asset.Id),
                },
            },
        }

        writefile(Name .. ".font", HttpService:JSONEncode(Data))

        return getcustomasset(Name .. ".font");
    end

    for name, suffix in FontNames do 
        local Weight = 400 

        if name == "Rubik" then
            Weight = 900 
        end 

        local RegisteredFont = RegisterFont(name, Weight, "Normal", {
            Id = suffix,
            Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/" .. suffix),
        }) 
        
        Fonts[name] = Font.new(RegisteredFont, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    end
end

local MiscOptions = {
    ["Enabled"] = false;
    ["Render Distance"] = 10000; 

    ["ChamsEnabled"] = false; 
    ["Chams Fill"] = { Color = rgb(0, 255, 255), Transparency = 0.9 };
    ["Chams Outline"] = { Color = rgb(255, 0, 0), Transparency = 0.4 };

    ["Boxes"] = false;
    ["BoxType"] = "Normal";
    ["Box Gradient 1"] = { Color = rgb(0, 255, 255), Transparency = 0.9 };
    ["Box Gradient 2"] = { Color = rgb(255, 0, 0), Transparency = 0.4 };
    ["Box Gradient Rotation"] = 90;
    ["Box Fill"] = false; 
    ["Box Fill 1"] = { Color = rgb(0, 255, 255), Transparency = 0.9 };
    ["Box Fill 2"] = { Color = rgb(0, 255, 255), Transparency = 0.9 };
    ["Box Fill Rotation"] = 0;

    ["Healthbar"] = false; 
    ["Healthbar_Position"] = "Right"; 
    ["Healthbar_Number"] = false; 
    ["Healthbar_Low"] = { Color = rgb(247, 24, 180), Transparency = 1 };
    ["Healthbar_Medium"] = { Color = rgb(17, 30, 211), Transparency = 1 };
    ["Healthbar_High"] = { Color = rgb(173, 69, 86), Transparency = 1 };
    ["Healthbar_Font"] = "ProggyClean";
    ["Healthbar_Text_Size"] = 12;
    ["Healthbar_Thickness"] = 1;
    ["Healthbar_Tween"] = false;
    ["Healthbar_EasingStyle"] = "Circular"; 
    ["Healthbar_EasingDirection"] = "InOut"; 
    ["Healthbar_Easing_Speed"] = 1;

    ["Name_Text"] = false; 
    ["Name_Text_Color"] = { Color = rgb(255, 255, 255) };
    ["Name_Text_Position"] = "Top";
    ["Name_Text_Font"] = "ProggyClean";
    ["Name_Text_Size"] = 12;
    
    ["Distance_Text"] = false; 
    ["Distance_Text_Color"] = { Color = rgb(255, 255, 255) };
    ["Distance_Text_Position"] = "Bottom";
    ["Distance_Text_Font"] = "ProggyClean";
    ["Distance_Text_Size"] = 12;
};  

local OptionsEsp = setmetatable({}, {__index = MiscOptions, __newindex = function(self, key, value) MiscOptions[key] = value if getgenv().Esp then getgenv().Esp.RefreshElements(key, value) end end})

if getgenv().Esp then 
    getgenv().Esp.Unload()
end 

getgenv().Esp = { 
    Players = {}, 
    PlayersOptions = {},
    ScreenGui = Instance.new("ScreenGui", CoreGui), 
    Cache = Instance.new("ScreenGui", gethui()), 
    Connections = {}, 
}; do 
    Esp.ScreenGui.IgnoreGuiInset = true
    Esp.ScreenGui.Name = "EspObject"

    Esp.Cache.Enabled = false   

    function Esp:Create(instance, options)
        local Ins = Instance.new(instance) 
        
        for prop, value in options do 
            Ins[prop] = value
        end
        
        return Ins 
    end

    function Esp:ConvertScreenPoint(world_position)
        local ViewportSize = Camera.ViewportSize
        local LocalPos = Camera.CFrame:pointToObjectSpace(world_position) 

        local AspectRatio = ViewportSize.X / ViewportSize.Y
        local HalfY = -LocalPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))
        local HalfX = AspectRatio * HalfY
        
        local FarPlaneCorner = Vector3.new(-HalfX, HalfY, LocalPos.Z)
        local RelativePos = LocalPos - FarPlaneCorner
    
        local ScreenX = RelativePos.X / (HalfX * 2)
        local ScreenY = -RelativePos.Y / (HalfY * 2)
        
        local OnScreen = -LocalPos.Z > 0 and ScreenX >= 0 and ScreenX <= 1 and ScreenY >= 0 and ScreenY <= 1
        
        return Vector3.new(ScreenX * ViewportSize.X, ScreenY * ViewportSize.Y, -LocalPos.Z), OnScreen
    end

    function Esp:Connection(signal, callback)
        local Connection = signal:Connect(callback)
        Esp.Connections[#Esp.Connections + 1] = Connection
        
        return Connection 
    end

    function Esp:BoxSolve(torso)
        if not torso then
            return nil, nil, nil
        end 

        local ViewportTop = torso.Position + (torso.CFrame.UpVector * 1.8) + Camera.CFrame.UpVector
        local ViewportBottom = torso.Position - (torso.CFrame.UpVector * 2.5) - Camera.CFrame.UpVector
        local Distance = (torso.Position - Camera.CFrame.p).Magnitude

        local NewDistance = math.floor(Distance * 0.333)

        local Top, TopIsRendered = Esp:ConvertScreenPoint(ViewportTop)
        local Bottom, BottomIsRendered = Esp:ConvertScreenPoint(ViewportBottom)
        
        local Width = math.max(math.floor(math.abs(Top.X - Bottom.X)), 8)
        local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 12)
        local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
        local BoxPosition = Vector2.new(math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5), math.floor(math.min(Top.Y, Bottom.Y)))
        
        return BoxSize, BoxPosition, TopIsRendered, NewDistance 
    end
    
    function Esp:Lerp(start, finish, t)
        t = t or 1 / 8

        return start * (1 - t) + finish * t
    end

    function Esp:Tween(obj, props, info)
        local tween = TweenService:Create(obj, info, props)
        tween:Play()
        
        return tween
    end

    function Esp.CreateObject(player, typechar)
        local Data = { 
            Items = {}, 
            Info = {Character; Humanoid; Health = 0}; 
            Drawings = {}, 
            Type = typechar or "player",
            Handles = {}, 
        }; Data.Chams = Data.Type == "player" and true or false;

        local Items = Data.Items; do
            Items.Holder = Esp:Create("Frame", {
                Parent = Esp.ScreenGui;
                Visible = false;
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0.4332570433616638, 0, 0.3255814015865326, 0);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 211, 0, 240);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.HolderGradient = Esp:Create("UIGradient", {
                Rotation = 0;
                Name = "\0";
                Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(255, 255, 255))};
                Parent = Items.Holder;
                Enabled = true
            });

            Items.Left = Esp:Create("Frame", {
                Parent = Items.Holder;
                Size = dim2(0, 0, 1, 0);
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0, -1, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.HealthbarTextsLeft = Esp:Create("Frame", {
                Visible = true;
                BorderColor3 = rgb(0, 0, 0);
                Parent = Esp.Cache;
                Name = "\0";
                BackgroundTransparency = 1;
                LayoutOrder = -100;
                BorderSizePixel = 0;
                ZIndex = 0;
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                VerticalFlex = Enum.UIFlexAlignment.Fill;
                Parent = Items.Left;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder
            });

            Items.LeftTexts = Esp:Create("Frame", {
                LayoutOrder = -100;
                Parent = Items.Left;
                BackgroundTransparency = 1;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                Parent = Items.LeftTexts;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder
            });

            Items.Bottom = Esp:Create("Frame", {
                Parent = Items.Holder;
                Size = dim2(1, 0, 0, 0);
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0, 0, 1, 1);
                BorderColor3 = rgb(0, 0, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.HealthbarTextsBottom = Esp:Create("Frame", {
                Visible = true;
                BorderColor3 = rgb(0, 0, 0);
                Parent = Esp.Cache;
                Name = "\0";
                BackgroundTransparency = 1;
                LayoutOrder = 0;
                BorderSizePixel = 0;
                ZIndex = 0;
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                Parent = Items.Bottom;
                Padding = dim(0, 1)
            });

            Items.BottomTexts = Esp:Create("Frame", {
                LayoutOrder = 1;
                Parent = Items.Bottom;
                BackgroundTransparency = 1;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                Parent = Items.BottomTexts;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder
            });

            Items.Top = Esp:Create("Frame", {
                Parent = Items.Holder;
                Size = dim2(1, 0, 0, 0);
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0, 0, 0, -1);
                BorderColor3 = rgb(0, 0, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.HealthbarTextsTop = Esp:Create("Frame", {
                Visible = true;
                BorderColor3 = rgb(0, 0, 0);
                Parent = Esp.Cache;
                Name = "\0";
                BackgroundTransparency = 1;
                LayoutOrder = -100;
                BorderSizePixel = 0;
                ZIndex = 0;
                AutomaticSize = Enum.AutomaticSize.Y;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Bottom;
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                Parent = Items.Top;
                Padding = dim(0, 1)
            });

            Items.TopTexts = Esp:Create("Frame", {
                LayoutOrder = -100;
                Parent = Items.Top;
                BackgroundTransparency = 1;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                Parent = Items.TopTexts;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder
            });

            Items.Right = Esp:Create("Frame", {
                Parent = Esp.Cache;
                Size = dim2(0, 0, 1, 0);
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(1, 1, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                VerticalFlex = Enum.UIFlexAlignment.Fill;
                Parent = Items.Right;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder
            });
            
            Items.RightTexts = Esp:Create("Frame", {
                LayoutOrder = 100;
                Parent = Esp.Cache;
                BackgroundTransparency = 1;
                Name = "\0";
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundColor3 = rgb(255, 255, 255)
            });
            
            Esp:Create("UIListLayout", {
                Parent = Items.RightTexts;
                Padding = dim(0, 1);
                SortOrder = Enum.SortOrder.LayoutOrder
            });

            Items.HealthbarTextsRight = Esp:Create("Frame", {
                Visible = true;
                BorderColor3 = rgb(0, 0, 0);
                Parent = Esp.Cache;
                Name = "\0";
                BackgroundTransparency = 1;
                LayoutOrder = 99;
                BorderSizePixel = 0;
                ZIndex = 0;
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.Corners = Esp:Create("Frame", {
                Parent = Esp.Cache;
                Name = "\0";
                BackgroundTransparency = 1;
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, 0, 1, 0);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.BottomLeftX = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                Parent = Items.Corners;
                BorderColor3 = rgb(0, 0, 0);
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0.4, 0, 0, 3);
                AnchorPoint = vec2(0, 1);
                Image = "rbxassetid://83548615999411";
                BackgroundTransparency = 1;
                Position = dim2(0, 0, 1, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 1), vec2(99, 2))
            });

            Esp:Create("UIGradient", {
                Parent = Items.BottomLeftX
            });

            Items.BottomLeftY = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                Parent = Items.Corners;
                BorderColor3 = rgb(0, 0, 0);
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0, 3, 0.25, 0);
                AnchorPoint = vec2(0, 1);
                Image = "rbxassetid://101715268403902";
                BackgroundTransparency = 1;
                Position = dim2(0, 0, 1, -2);
                ZIndex = 500;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 0), vec2(2, 96))
            });

            Esp:Create("UIGradient", {
                Rotation = -90;
                Parent = Items.BottomLeftY
            });

            Items.BottomRighX = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                Parent = Items.Corners;
                BorderColor3 = rgb(0, 0, 0);
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0.4, 0, 0, 3);
                AnchorPoint = vec2(1, 1);
                Image = "rbxassetid://83548615999411";
                BackgroundTransparency = 1;
                Position = dim2(1, 0, 1, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 1), vec2(99, 2))
            });

            Esp:Create("UIGradient", {
                Parent = Items.BottomRighX
            });

            Items.BottomRightY = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                Parent = Items.Corners;
                BorderColor3 = rgb(0, 0, 0);
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0, 3, 0.25, 0);
                AnchorPoint = vec2(1, 1);
                Image = "rbxassetid://101715268403902";
                BackgroundTransparency = 1;
                Position = dim2(1, 0, 1, -2);
                ZIndex = 500;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 0), vec2(2, 96))
            });

            Esp:Create("UIGradient", {
                Rotation = 90;
                Parent = Items.BottomRightY
            });

            Items.TopLeftY = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                BorderColor3 = rgb(0, 0, 0);
                Parent = Items.Corners;
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0, 3, 0.25, 0);
                Image = "rbxassetid://102467475629368";
                BackgroundTransparency = 1;
                Position = dim2(0, 0, 0, 2);
                ZIndex = 500;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 0), vec2(2, 98))
            });

            Esp:Create("UIGradient", {
                Rotation = 90;
                Parent = Items.TopLeftY
            });

            Items.TopRightY = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                Parent = Items.Corners;
                BorderColor3 = rgb(0, 0, 0);
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0, 3, 0.25, 0);
                AnchorPoint = vec2(1, 0);
                Image = "rbxassetid://102467475629368";
                BackgroundTransparency = 1;
                Position = dim2(1, 0, 0, 2);
                ZIndex = 500;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 0), vec2(2, 98))
            });

            Esp:Create("UIGradient", {
                Rotation = -90;
                Parent = Items.TopRightY
            });

            Items.TopRightX = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                Parent = Items.Corners;
                BorderColor3 = rgb(0, 0, 0);
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Size = dim2(0.4, 0, 0, 3);
                AnchorPoint = vec2(1, 0);
                Image = "rbxassetid://83548615999411";
                BackgroundTransparency = 1;
                Position = dim2(1, 0, 0, 0);
                ZIndex = 2;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 1), vec2(99, 2))
            });

            Esp:Create("UIGradient", {
                Parent = Items.TopRightX
            });

            Items.TopLeftX = Esp:Create("ImageLabel", {
                ScaleType = Enum.ScaleType.Slice;
                BorderColor3 = rgb(0, 0, 0);
                Parent = Items.Corners;
                Name = "\0";
                BackgroundColor3 = rgb(255, 255, 255);
                Image = "rbxassetid://83548615999411";
                BackgroundTransparency = 1;
                Size = dim2(0.4, 0, 0, 3);
                ZIndex = 2;
                BorderSizePixel = 0;
                SliceCenter = rect(vec2(1, 1), vec2(99, 2))
            });

            Esp:Create("UIGradient", {
                Parent = Items.TopLeftX
            });

            Items.Box = Esp:Create("Frame", {
                Parent = Esp.Cache;
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIStroke", {  
                Parent = Items.Box;
                LineJoinMode = Enum.LineJoinMode.Miter
            });

            Items.Inner = Esp:Create("Frame", {
                Parent = Items.Box;
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.UIStroke = Esp:Create("UIStroke", {
                Color = rgb(255, 255, 255);
                LineJoinMode = Enum.LineJoinMode.Miter;
                Parent = Items.Inner
            });

            Items.BoxGradient = Esp:Create("UIGradient", {
                Parent = Items.UIStroke
            });

            Items.Inner2 = Esp:Create("Frame", {
                Parent = Items.Inner;
                Name = "\0";
                BackgroundTransparency = 1;
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Esp:Create("UIStroke", {
                Parent = Items.Inner2;
                LineJoinMode = Enum.LineJoinMode.Miter
            });

            Items.Healthbar = Esp:Create("Frame", {
                Name = "Left";
                Parent = Esp.Cache;
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 3, 0, 3);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(0, 0, 0)
            });

            Items.HealthbarAccent = Esp:Create("Frame", {
                Parent = Items.Healthbar;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.HealthbarFade = Esp:Create("Frame", {
                Parent = Items.Healthbar;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(0, 0, 0)
            });

            Items.HealthbarGradient = Esp:Create("UIGradient", {
                Enabled = true;
                Parent = Items.HealthbarAccent;                Rotation = 90
            });

            Items.HealthbarText = Esp:Create("TextLabel", {
                FontFace = Fonts["ProggyClean"];
                TextColor3 = rgb(255, 255, 255);
                BorderColor3 = rgb(0, 0, 0);
                Text = "100";
                Parent = Esp.Cache;
                TextSize = 12;
                Name = "\0";
                BackgroundTransparency = 1;
                Size = dim2(0, 0, 0, 0);
                BorderSizePixel = 0;
                TextStrokeTransparency = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.NameText = Esp:Create("TextLabel", {
                FontFace = Fonts["ProggyClean"];
                TextColor3 = rgb(255, 255, 255);
                BorderColor3 = rgb(0, 0, 0);
                Text = "Name";
                Parent = Items.TopTexts;
                TextSize = 12;
                Name = "\0";
                BackgroundTransparency = 1;
                Size = dim2(0, 0, 0, 0);
                BorderSizePixel = 0;
                TextStrokeTransparency = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.DistanceText = Esp:Create("TextLabel", {
                FontFace = Fonts["ProggyClean"];
                TextColor3 = rgb(255, 255, 255);
                BorderColor3 = rgb(0, 0, 0);
                Text = "Distance";
                Parent = Items.BottomTexts;
                TextSize = 12;
                Name = "\0";
                BackgroundTransparency = 1;
                Size = dim2(0, 0, 0, 0);
                BorderSizePixel = 0;
                TextStrokeTransparency = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = rgb(255, 255, 255)
            });

            Items.FillGradient = Esp:Create("UIGradient", {
                Rotation = 0;
                Parent = Items.Box
            });
        end

        function Data:Remove()
            for _, item in Items do
                if typeof(item) == "Instance" then
                    item:Destroy()
                end
            end

            if Data.Chams then
                for _, v in Data.Drawings do
                    if v then
                        v:Destroy()
                    end
                end
            end

            for _, handle in Data.Handles do
                if handle then
                    handle:Disconnect()
                end
            end

            table.clear(Data)
        end

        function Data:CreateChams(character)
            if not Data.Chams then return end

            for _, part in character:GetDescendants() do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Parent = part
                    Highlight.Adornee = part
                    Highlight.FillTransparency = 0.9
                    Highlight.OutlineTransparency = 0.4
                    Highlight.FillColor = rgb(0, 255, 255)
                    Highlight.OutlineColor = rgb(255, 0, 0)
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Highlight.Enabled = OptionsEsp["ChamsEnabled"]

                    Data.Drawings[#Data.Drawings + 1] = Highlight
                end
            end
        end

        function Data:UpdateChams()
            if not Data.Chams then return end

            for _, highlight in Data.Drawings do
                if highlight and highlight:IsA("Highlight") then
                    highlight.Enabled = OptionsEsp["ChamsEnabled"]
                    highlight.FillColor = OptionsEsp["Chams Fill"].Color
                    highlight.FillTransparency = OptionsEsp["Chams Fill"].Transparency
                    highlight.OutlineColor = OptionsEsp["Chams Outline"].Color
                    highlight.OutlineTransparency = OptionsEsp["Chams Outline"].Transparency
                end
            end
        end

        function Data:Update()
            if not Data.Info.Character or not Data.Info.Humanoid then
                Items.Holder.Visible = false
                return
            end

            local Character = Data.Info.Character
            local Humanoid = Data.Info.Humanoid
            local Torso = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")

            if not Torso then
                Items.Holder.Visible = false
                return
            end

            local BoxSize, BoxPosition, OnScreen, Distance = Esp:BoxSolve(Torso)

            if not OnScreen or not BoxSize or Distance > OptionsEsp["Render Distance"] then
                Items.Holder.Visible = false
                return
            end

            Items.Holder.Visible = OptionsEsp["Enabled"]
            Items.Holder.Size = dim_offset(BoxSize.X, BoxSize.Y)
            Items.Holder.Position = dim_offset(BoxPosition.X, BoxPosition.Y)

            local BoxEnabled = OptionsEsp["Boxes"] and OptionsEsp["BoxType"] == "Normal"
            Items.Box.Parent = BoxEnabled and Items.Holder or Esp.Cache
            Items.UIStroke.Color = OptionsEsp["Box Gradient 1"].Color
            Items.UIStroke.Transparency = OptionsEsp["Box Gradient 1"].Transparency
            
            Items.BoxGradient.Enabled = true
            Items.BoxGradient.Rotation = OptionsEsp["Box Gradient Rotation"]
            Items.BoxGradient.Color = rgbseq{
                rgbkey(0, OptionsEsp["Box Gradient 1"].Color),
                rgbkey(1, OptionsEsp["Box Gradient 2"].Color)
            }

            Items.Box.BackgroundTransparency = OptionsEsp["Box Fill"] and OptionsEsp["Box Fill 1"].Transparency or 1
            Items.FillGradient.Enabled = OptionsEsp["Box Fill"]
            Items.FillGradient.Rotation = OptionsEsp["Box Fill Rotation"]
            Items.FillGradient.Color = rgbseq{
                rgbkey(0, OptionsEsp["Box Fill 1"].Color),
                rgbkey(1, OptionsEsp["Box Fill 2"].Color)
            }

            local CornersEnabled = OptionsEsp["Boxes"] and OptionsEsp["BoxType"] == "Corner"
            Items.Corners.Parent = CornersEnabled and Items.Holder or Esp.Cache

            for name, corner in Items.Corners:GetChildren() do
                if corner:IsA("ImageLabel") then
                    corner.ImageColor3 = OptionsEsp["Box Gradient 1"].Color
                    corner.ImageTransparency = OptionsEsp["Box Gradient 1"].Transparency
                    
                    local gradient = corner:FindFirstChildOfClass("UIGradient")
                    if gradient then
                        gradient.Color = rgbseq{
                            rgbkey(0, OptionsEsp["Box Gradient 1"].Color),
                            rgbkey(1, OptionsEsp["Box Gradient 2"].Color)
                        }
                    end
                end
            end

            local CurrentHealth = Humanoid.Health
            local MaxHealth = Humanoid.MaxHealth
            local HealthPercent = math.clamp(CurrentHealth / MaxHealth, 0, 1)

            local HealthbarEnabled = OptionsEsp["Healthbar"]
            local HealthbarPosition = OptionsEsp["Healthbar_Position"]

            if HealthbarPosition == "Left" then
                Items.Healthbar.Parent = HealthbarEnabled and Items.Left or Esp.Cache
                Items.HealthbarText.Parent = HealthbarEnabled and OptionsEsp["Healthbar_Number"] and Items.HealthbarTextsLeft or Esp.Cache
            elseif HealthbarPosition == "Right" then
                Items.Healthbar.Parent = HealthbarEnabled and Items.Right or Esp.Cache
                Items.HealthbarText.Parent = HealthbarEnabled and OptionsEsp["Healthbar_Number"] and Items.HealthbarTextsRight or Esp.Cache
            elseif HealthbarPosition == "Top" then
                Items.Healthbar.Parent = HealthbarEnabled and Items.Top or Esp.Cache
                Items.HealthbarText.Parent = HealthbarEnabled and OptionsEsp["Healthbar_Number"] and Items.HealthbarTextsTop or Esp.Cache
            elseif HealthbarPosition == "Bottom" then
                Items.Healthbar.Parent = HealthbarEnabled and Items.Bottom or Esp.Cache
                Items.HealthbarText.Parent = HealthbarEnabled and OptionsEsp["Healthbar_Number"] and Items.HealthbarTextsBottom or Esp.Cache
            end

            if HealthbarPosition == "Left" or HealthbarPosition == "Right" then
                Items.Healthbar.Size = dim2(0, OptionsEsp["Healthbar_Thickness"], 1, 0)
                Items.HealthbarGradient.Rotation = 90
                
                if OptionsEsp["Healthbar_Tween"] and Data.Info.Health ~= CurrentHealth then
                    local NewSize = dim2(0, OptionsEsp["Healthbar_Thickness"], HealthPercent, 0)
                    local TweenInfo = TweenInfo.new(
                        OptionsEsp["Healthbar_Easing_Speed"],
                        Enum.EasingStyle[OptionsEsp["Healthbar_EasingStyle"]],
                        Enum.EasingDirection[OptionsEsp["Healthbar_EasingDirection"]]
                    )
                    Esp:Tween(Items.HealthbarAccent, {Size = NewSize}, TweenInfo)
                else
                    Items.HealthbarAccent.Size = dim2(0, OptionsEsp["Healthbar_Thickness"], HealthPercent, 0)
                end
            else
                Items.Healthbar.Size = dim2(1, 0, 0, OptionsEsp["Healthbar_Thickness"])
                Items.HealthbarGradient.Rotation = 0
                
                if OptionsEsp["Healthbar_Tween"] and Data.Info.Health ~= CurrentHealth then
                    local NewSize = dim2(HealthPercent, 0, 0, OptionsEsp["Healthbar_Thickness"])
                    local TweenInfo = TweenInfo.new(
                        OptionsEsp["Healthbar_Easing_Speed"],
                        Enum.EasingStyle[OptionsEsp["Healthbar_EasingStyle"]],
                        Enum.EasingDirection[OptionsEsp["Healthbar_EasingDirection"]]
                    )
                    Esp:Tween(Items.HealthbarAccent, {Size = NewSize}, TweenInfo)
                else
                    Items.HealthbarAccent.Size = dim2(HealthPercent, 0, 0, OptionsEsp["Healthbar_Thickness"])
                end
            end

            Data.Info.Health = CurrentHealth

            local HealthColor
            if HealthPercent > 0.5 then
                HealthColor = OptionsEsp["Healthbar_High"].Color
            elseif HealthPercent > 0.25 then
                HealthColor = OptionsEsp["Healthbar_Medium"].Color
            else
                HealthColor = OptionsEsp["Healthbar_Low"].Color
            end

            Items.HealthbarGradient.Color = rgbseq{
                rgbkey(0, HealthColor),
                rgbkey(1, HealthColor)
            }

            Items.HealthbarText.Text = tostring(math.floor(CurrentHealth))
            Items.HealthbarText.FontFace = Fonts[OptionsEsp["Healthbar_Font"]]
            Items.HealthbarText.TextSize = OptionsEsp["Healthbar_Text_Size"]

            local NameEnabled = OptionsEsp["Name_Text"]
            local NamePosition = OptionsEsp["Name_Text_Position"]

            if NamePosition == "Top" then
                Items.NameText.Parent = NameEnabled and Items.TopTexts or Esp.Cache
            elseif NamePosition == "Bottom" then
                Items.NameText.Parent = NameEnabled and Items.BottomTexts or Esp.Cache
            elseif NamePosition == "Left" then
                Items.NameText.Parent = NameEnabled and Items.LeftTexts or Esp.Cache
            elseif NamePosition == "Right" then
                Items.NameText.Parent = NameEnabled and Items.RightTexts or Esp.Cache
            end

            Items.NameText.Text = Data.Type == "player" and player.Name or "Entity"
            Items.NameText.TextColor3 = OptionsEsp["Name_Text_Color"].Color
            Items.NameText.FontFace = Fonts[OptionsEsp["Name_Text_Font"]]
            Items.NameText.TextSize = OptionsEsp["Name_Text_Size"]

            local DistanceEnabled = OptionsEsp["Distance_Text"]
            local DistancePosition = OptionsEsp["Distance_Text_Position"]

            if DistancePosition == "Top" then
                Items.DistanceText.Parent = DistanceEnabled and Items.TopTexts or Esp.Cache
            elseif DistancePosition == "Bottom" then
                Items.DistanceText.Parent = DistanceEnabled and Items.BottomTexts or Esp.Cache
            elseif DistancePosition == "Left" then
                Items.DistanceText.Parent = DistanceEnabled and Items.LeftTexts or Esp.Cache
            elseif DistancePosition == "Right" then
                Items.DistanceText.Parent = DistanceEnabled and Items.RightTexts or Esp.Cache
            end

            Items.DistanceText.Text = tostring(Distance) .. "m"
            Items.DistanceText.TextColor3 = OptionsEsp["Distance_Text_Color"].Color
            Items.DistanceText.FontFace = Fonts[OptionsEsp["Distance_Text_Font"]]
            Items.DistanceText.TextSize = OptionsEsp["Distance_Text_Size"]

            Data:UpdateChams()
        end

        if Data.Type == "player" then
            Esp.Players[player] = Data
            
            local function OnCharacterAdded(character)
                Data.Info.Character = character
                Data.Info.Humanoid = character:WaitForChild("Humanoid")
                Data:CreateChams(character)
            end

            if player.Character then
                OnCharacterAdded(player.Character)
            end

            Data.Handles[#Data.Handles + 1] = player.CharacterAdded:Connect(OnCharacterAdded)
        end

        return Data
    end

    function Esp.RefreshElements(key, value)
        for player, data in Esp.Players do
            if data and data.Update then
                data:Update()
            end
        end
    end

    function Esp.AddPlayer(player)
        if player == LocalPlayer then return end
        if Esp.Players[player] then return end

        Esp.CreateObject(player, "player")
    end

    function Esp.RemovePlayer(player)
        if Esp.Players[player] then
            Esp.Players[player]:Remove()
            Esp.Players[player] = nil
        end
    end

    function Esp.Load()
        for _, player in Players:GetPlayers() do
            Esp.AddPlayer(player)
        end

        Esp:Connection(Players.PlayerAdded, function(player)
            Esp.AddPlayer(player)
        end)

        Esp:Connection(Players.PlayerRemoving, function(player)
            Esp.RemovePlayer(player)
        end)

        Esp:Connection(RunService.RenderStepped, function()
            for player, data in Esp.Players do
                if data and data.Update then
                    data:Update()
                end
            end
        end)
    end

    function Esp.Unload()
        for _, connection in Esp.Connections do
            connection:Disconnect()
        end

        for player, data in Esp.Players do
            data:Remove()
        end

        if Esp.ScreenGui then
            Esp.ScreenGui:Destroy()
        end

        if Esp.Cache then
            Esp.Cache:Destroy()
        end

        table.clear(Esp.Players)
        table.clear(Esp.Connections)
    end

    Esp.Load()
end

local EspLeft = Tabs.Esp:AddLeftGroupbox('Main Settings')
EspLeft:AddToggle('EspEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Enabled"] = Value
    end
})

EspLeft:AddSlider('RenderDistance', {
    Text = 'Render Distance',
    Default = 10000,
    Min = 1000,
    Max = 50000,
    Rounding = 0,
    Suffix = ' studs',
    Callback = function(Value)
        OptionsEsp["Render Distance"] = Value
    end
})

local EspBoxes = Tabs.Esp:AddLeftGroupbox('Box Settings')
EspBoxes:AddToggle('BoxesEnabled', {
    Text = 'Enable Boxes',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Boxes"] = Value
    end
})

EspBoxes:AddDropdown('BoxType', {
    Values = { 'Normal', 'Corner' },
    Default = 1,
    Text = 'Box Type',
    Callback = function(Value)
        OptionsEsp["BoxType"] = Value
    end
})

local BoxColor1 = EspBoxes:AddLabel('Box Color 1'):AddColorPicker('BoxGradient1', {
    Default = Color3.new(0, 1, 1),
    Title = 'Box Color 1',
    Transparency = 0.9,
    Callback = function(Value, Transparency)
        OptionsEsp["Box Gradient 1"] = { Color = Value, Transparency = Transparency }
    end
})

local BoxColor2 = EspBoxes:AddLabel('Box Color 2'):AddColorPicker('BoxGradient2', {
    Default = Color3.new(1, 0, 0),
    Title = 'Box Color 2',
    Transparency = 0.4,
    Callback = function(Value, Transparency)
        OptionsEsp["Box Gradient 2"] = { Color = Value, Transparency = Transparency }
    end
})

EspBoxes:AddSlider('BoxGradientRotation', {
    Text = 'Gradient Rotation',
    Default = 90,
    Min = 0,
    Max = 360,
    Rounding = 0,
    Suffix = '°',
    Callback = function(Value)
        OptionsEsp["Box Gradient Rotation"] = Value
    end
})

EspBoxes:AddToggle('BoxFill', {
    Text = 'Enable Box Fill',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Box Fill"] = Value
    end
})

local FillColor1 = EspBoxes:AddLabel('Fill Color 1'):AddColorPicker('BoxFill1', {
    Default = Color3.new(0, 1, 1),
    Title = 'Fill Color 1',
    Transparency = 0.9,
    Callback = function(Value, Transparency)
        OptionsEsp["Box Fill 1"] = { Color = Value, Transparency = Transparency }
    end
})

local FillColor2 = EspBoxes:AddLabel('Fill Color 2'):AddColorPicker('BoxFill2', {
    Default = Color3.new(0, 1, 1),
    Title = 'Fill Color 2',
    Transparency = 0.9,
    Callback = function(Value, Transparency)
        OptionsEsp["Box Fill 2"] = { Color = Value, Transparency = Transparency }
    end
})

EspBoxes:AddSlider('BoxFillRotation', {
    Text = 'Fill Rotation',
    Default = 0,
    Min = 0,
    Max = 360,
    Rounding = 0,
    Suffix = '°',
    Callback = function(Value)
        OptionsEsp["Box Fill Rotation"] = Value
    end
})

local EspChams = Tabs.Esp:AddLeftGroupbox('Chams Settings')
EspChams:AddToggle('ChamsEnabled', {
    Text = 'Enable Chams',
    Default = false,
    Callback = function(Value)
        OptionsEsp["ChamsEnabled"] = Value
    end
})

local ChamsFill = EspChams:AddLabel('Fill Color'):AddColorPicker('ChamsFill', {
    Default = Color3.new(0, 1, 1),
    Title = 'Chams Fill',
    Transparency = 0.9,
    Callback = function(Value, Transparency)
        OptionsEsp["Chams Fill"] = { Color = Value, Transparency = Transparency }
    end
})

local ChamsOutline = EspChams:AddLabel('Outline Color'):AddColorPicker('ChamsOutline', {
    Default = Color3.new(1, 0, 0),
    Title = 'Chams Outline',
    Transparency = 0.4,
    Callback = function(Value, Transparency)
        OptionsEsp["Chams Outline"] = { Color = Value, Transparency = Transparency }
    end
})

local EspHealth = Tabs.Esp:AddRightGroupbox('Healthbar Settings')
EspHealth:AddToggle('HealthbarEnabled', {
    Text = 'Enable Healthbar',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Healthbar"] = Value
    end
})

EspHealth:AddDropdown('HealthbarPosition', {
    Values = { 'Left', 'Right', 'Top', 'Bottom' },
    Default = 2,
    Text = 'Healthbar Position',
    Callback = function(Value)
        OptionsEsp["Healthbar_Position"] = Value
    end
})

EspHealth:AddToggle('HealthbarNumber', {
    Text = 'Show Health Number',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Healthbar_Number"] = Value
    end
})

local HealthLow = EspHealth:AddLabel('Low Health Color'):AddColorPicker('HealthLow', {
    Default = Color3.new(247/255, 24/255, 180/255),
    Title = 'Low Health',
    Transparency = 1,
    Callback = function(Value, Transparency)
        OptionsEsp["Healthbar_Low"] = { Color = Value, Transparency = Transparency }
    end
})

local HealthMedium = EspHealth:AddLabel('Medium Health Color'):AddColorPicker('HealthMedium', {
    Default = Color3.new(17/255, 30/255, 211/255),
    Title = 'Medium Health',
    Transparency = 1,
    Callback = function(Value, Transparency)
        OptionsEsp["Healthbar_Medium"] = { Color = Value, Transparency = Transparency }
    end
})

local HealthHigh = EspHealth:AddLabel('High Health Color'):AddColorPicker('HealthHigh', {
    Default = Color3.new(173/255, 69/255, 86/255),
    Title = 'High Health',
    Transparency = 1,
    Callback = function(Value, Transparency)
        OptionsEsp["Healthbar_High"] = { Color = Value, Transparency = Transparency }
    end
})

EspHealth:AddDropdown('HealthbarFont', {
    Values = { 'ProggyClean', 'Tahoma', 'Verdana', 'SmallestPixel', 'ProggyTiny', 'Minecraftia', 'Tahoma Bold', 'Rubik' },
    Default = 1,
    Text = 'Healthbar Font',
    Callback = function(Value)
        OptionsEsp["Healthbar_Font"] = Value
    end
})

EspHealth:AddSlider('HealthbarTextSize', {
    Text = 'Text Size',
    Default = 12,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Callback = function(Value)
        OptionsEsp["Healthbar_Text_Size"] = Value
    end
})

EspHealth:AddSlider('HealthbarThickness', {
    Text = 'Healthbar Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        OptionsEsp["Healthbar_Thickness"] = Value
    end
})

EspHealth:AddToggle('HealthbarTween', {
    Text = 'Enable Smooth Animation',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Healthbar_Tween"] = Value
    end
})

EspHealth:AddDropdown('HealthbarEasingStyle', {
    Values = { 'Linear', 'Sine', 'Back', 'Quad', 'Quart', 'Quint', 'Bounce', 'Elastic', 'Exponential', 'Circular', 'Cubic' },
    Default = 10,
    Text = 'Easing Style',
    Callback = function(Value)
        OptionsEsp["Healthbar_EasingStyle"] = Value
    end
})

EspHealth:AddDropdown('HealthbarEasingDirection', {
    Values = { 'In', 'Out', 'InOut' },
    Default = 3,
    Text = 'Easing Direction',
    Callback = function(Value)
        OptionsEsp["Healthbar_EasingDirection"] = Value
    end
})

EspHealth:AddSlider('HealthbarEasingSpeed', {
    Text = 'Animation Speed',
    Default = 1,
    Min = 0.1,
    Max = 3,
    Rounding = 1,
    Callback = function(Value)
        OptionsEsp["Healthbar_Easing_Speed"] = Value
    end
})

local EspText = Tabs.Esp:AddRightGroupbox('Text Settings')
EspText:AddToggle('NameText', {
    Text = 'Show Name',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Name_Text"] = Value
    end
})

local NameColor = EspText:AddLabel('Name Color'):AddColorPicker('NameColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Name Color',
    Transparency = 1,
    Callback = function(Value, Transparency)
        OptionsEsp["Name_Text_Color"] = { Color = Value, Transparency = Transparency }
    end
})

EspText:AddDropdown('NamePosition', {
    Values = { 'Top', 'Bottom', 'Left', 'Right' },
    Default = 1,
    Text = 'Name Position',
    Callback = function(Value)
        OptionsEsp["Name_Text_Position"] = Value
    end
})

EspText:AddDropdown('NameFont', {
    Values = { 'ProggyClean', 'Tahoma', 'Verdana', 'SmallestPixel', 'ProggyTiny', 'Minecraftia', 'Tahoma Bold', 'Rubik' },
    Default = 1,
    Text = 'Name Font',
    Callback = function(Value)
        OptionsEsp["Name_Text_Font"] = Value
    end
})

EspText:AddSlider('NameTextSize', {
    Text = 'Name Text Size',
    Default = 12,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Callback = function(Value)
        OptionsEsp["Name_Text_Size"] = Value
    end
})

EspText:AddDivider()

EspText:AddToggle('DistanceText', {
    Text = 'Show Distance',
    Default = false,
    Callback = function(Value)
        OptionsEsp["Distance_Text"] = Value
    end
})

local DistanceColor = EspText:AddLabel('Distance Color'):AddColorPicker('DistanceColor', {
    Default = Color3.new(1, 1, 1),
    Title = 'Distance Color',
    Transparency = 1,
    Callback = function(Value, Transparency)
        OptionsEsp["Distance_Text_Color"] = { Color = Value, Transparency = Transparency }
    end
})

EspText:AddDropdown('DistancePosition', {
    Values = { 'Top', 'Bottom', 'Left', 'Right' },
    Default = 2,
    Text = 'Distance Position',
    Callback = function(Value)
        OptionsEsp["Distance_Text_Position"] = Value
    end
})

EspText:AddDropdown('DistanceFont', {
    Values = { 'ProggyClean', 'Tahoma', 'Verdana', 'SmallestPixel', 'ProggyTiny', 'Minecraftia', 'Tahoma Bold', 'Rubik' },
    Default = 1,
    Text = 'Distance Font',
    Callback = function(Value)
        OptionsEsp["Distance_Text_Font"] = Value
    end
})

EspText:AddSlider('DistanceTextSize', {
    Text = 'Distance Text Size',
    Default = 12,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Callback = function(Value)
        OptionsEsp["Distance_Text_Size"] = Value
    end
})

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Groupbox')

LeftGroupBox:AddToggle('MyToggle', {
    Text = 'This is a toggle',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Default = true,
    Disabled = false,
    Visible = true,
    Risky = false,
    Callback = function(Value)
        print('[cb] MyToggle changed to:', Value)
    end
}):AddColorPicker('ColorPicker1', {
    Default = Color3.new(1, 0, 0),
    Title = 'Some color1',
    Transparency = 0,
    Callback = function(Value, Transparency)
        print('[cb] Color changed!', Value, '| Transparency changed to:', Transparency)
    end
}):AddColorPicker('ColorPicker2', {
    Default = Color3.new(0, 1, 0),
    Title = 'Some color2',
    Transparency = 0,
    Callback = function(Value, Transparency)
        print('[cb] Color changed!', Value, '| Transparency changed to:', Transparency)
    end
}):AddColorPicker('ColorPicker3', {
    Default = Color3.new(0, 0, 1),
    Title = 'Some color3',
    Transparency = 0,
    Callback = function(Value, Transparency)
        print('[cb] Color changed!', Value, '| Transparency changed to:', Transparency)
    end
})

Toggles.MyToggle:OnChanged(function()
    print('MyToggle changed to:', Toggles.MyToggle.Value)
end)

Toggles.MyToggle:SetValue(false)

local MyButton = LeftGroupBox:AddButton({
    Text = 'Button',
    Func = function()
        print('You clicked a button!')
        Library:Notify("This is a notification")
    end,
    DoubleClick = false,
    Tooltip = 'This is the main button',
    DisabledTooltip = 'I am disabled!',
    Disabled = false,
    Visible = true
})

local MyButton2 = MyButton:AddButton({
    Text = 'Sub button',
    Func = function()
        print('You clicked a sub button!')
        Library:Notify("This is a notification with sound", nil, 4590657391)
    end,
    DoubleClick = true,
    Tooltip = 'This is the sub button (double click me!)'
})

local MyDisabledButton = LeftGroupBox:AddButton({
    Text = 'Disabled Button',
    Func = function()
        print('You somehow clicked a disabled button!')
    end,
    DoubleClick = false,
    Tooltip = 'This is a disabled button',
    DisabledTooltip = 'I am disabled!',
    Disabled = true
})

LeftGroupBox:AddLabel('This is a label')
LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)
LeftGroupBox:AddLabel('This is a label exposed to Labels', true, 'TestLabel')
LeftGroupBox:AddLabel('SecondTestLabel', {
    Text = 'This is a label made with table options and an index',
    DoesWrap = true
})

LeftGroupBox:AddLabel('SecondTestLabel', {
    Text = 'This is a label that doesn\'t wrap it\'s own text',
    DoesWrap = false
})

LeftGroupBox:AddDivider()

LeftGroupBox:AddSlider('MySlider', {
    Text = 'This is my slider!',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        print('[cb] MySlider was changed! New value:', Value)
    end,
    Tooltip = 'I am a slider!',
    DisabledTooltip = 'I am disabled!',
    Disabled = false,
    Visible = true,
})

local Number = Options.MySlider.Value
Options.MySlider:OnChanged(function()
    print('MySlider was changed! New value:', Options.MySlider.Value)
end)

Options.MySlider:SetValue(3)

LeftGroupBox:AddSlider('MySlider2', {
    Text = 'This is my custom display slider!',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
    FormatDisplayValue = function(slider, value)
        if value == slider.Max then return 'Everything' end
        if value == slider.Min then return 'Nothing' end
    end,
    Tooltip = 'I am a slider!',
    DisabledTooltip = 'I am disabled!',
    Disabled = false,
    Visible = true,
})

LeftGroupBox:AddInput('MyTextbox', {
    Default = 'My textbox!',
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = true,
    Text = 'This is a textbox',
    Tooltip = 'This is a tooltip',
    Placeholder = 'Placeholder text',
    Callback = function(Value)
        print('[cb] Text updated. New text:', Value)
    end
})

Options.MyTextbox:OnChanged(function()
    print('Text updated. New text:', Options.MyTextbox.Value)
end)

local DropdownGroupBox = Tabs.Main:AddRightGroupbox('Dropdowns')

DropdownGroupBox:AddDropdown('MyDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = false,
    Text = 'A dropdown',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Searchable = false,
    Callback = function(Value)
        print('[cb] Dropdown got changed. New value:', Value)
    end,
    Disabled = false,
    Visible = true,
})

Options.MyDropdown:OnChanged(function()
    print('Dropdown got changed. New value:', Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue('This')

DropdownGroupBox:AddDropdown('MySearchableDropdown', {
    Values = { 'This', 'is', 'a', 'searchable', 'dropdown' },
    Default = 1,
    Multi = false,
    Text = 'A searchable dropdown',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Searchable = true,
    Callback = function(Value)
        print('[cb] Dropdown got changed. New value:', Value)
    end,
    Disabled = false,
    Visible = true,
})

DropdownGroupBox:AddDropdown('MyDisplayFormattedDropdown', {
    Values = { 'This', 'is', 'a', 'formatted', 'dropdown' },
    Default = 1,
    Multi = false,
    Text = 'A display formatted dropdown',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    FormatDisplayValue = function(Value)
        if Value == 'formatted' then
            return 'display formatted'
        end
        return Value
    end,
    Searchable = false,
    Callback = function(Value)
        print('[cb] Display formatted dropdown got changed. New value:', Value)
    end,
    Disabled = false,
    Visible = true,
})

DropdownGroupBox:AddDropdown('MyMultiDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = true,
    Text = 'A multi dropdown',
    Tooltip = 'This is a tooltip',
    Callback = function(Value)
        print('[cb] Multi dropdown got changed:')
        for key, value in next, Options.MyMultiDropdown.Value do
            print(key, value)
        end
    end
})

Options.MyMultiDropdown:SetValue({
    This = true,
    is = true,
})

DropdownGroupBox:AddDropdown('MyDisabledDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = false,
    Text = 'A disabled dropdown',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Callback = function(Value)
        print('[cb] Disabled dropdown got changed. New value:', Value)
    end,
    Disabled = true,
    Visible = true,
})

DropdownGroupBox:AddDropdown('MyDisabledValueDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown', 'with', 'disabled', 'value' },
    DisabledValues = { 'disabled' },
    Default = 1,
    Multi = false,
    Text = 'A dropdown with disabled value',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Callback = function(Value)
        print('[cb] Dropdown with disabled value got changed. New value:', Value)
    end,
    Disabled = false,
    Visible = true,
})

DropdownGroupBox:AddDropdown('MyVeryLongDropdown', {
    Values = { 'This', 'is', 'a', 'very', 'long', 'dropdown', 'with', 'a', 'lot', 'of', 'values', 'but', 'you', 'can', 'see', 'more', 'than', '8', 'values' },
    Default = 1,
    Multi = false,
    MaxVisibleDropdownItems = 12,
    Text = 'A very long dropdown',
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Searchable = false,
    Callback = function(Value)
        print('[cb] Very long dropdown got changed. New value:', Value)
    end,
    Disabled = false,
    Visible = true,
})

DropdownGroupBox:AddDropdown('MyPlayerDropdown', {
    SpecialType = 'Player',
    ExcludeLocalPlayer = true,
    Text = 'A player dropdown',
    Tooltip = 'This is a tooltip',
    Callback = function(Value)
        print('[cb] Player dropdown got changed:', Value)
    end
})

DropdownGroupBox:AddDropdown('MyTeamDropdown', {
    SpecialType = 'Team',
    Text = 'A team dropdown',
    Tooltip = 'This is a tooltip',
    Callback = function(Value)
        print('[cb] Team dropdown got changed:', Value)
    end
})

LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = Color3.new(0, 1, 0),
    Title = 'Some color',
    Transparency = 0,
    Callback = function(Value)
        print('[cb] Color changed!', Value)
    end
})

Options.ColorPicker:OnChanged(function()
    print('Color changed!', Options.ColorPicker.Value)
    print('Transparency changed!', Options.ColorPicker.Transparency)
end)

Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
    Default = 'MB2',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Auto lockpick safes',
    NoUI = false,
    Callback = function(Value)
        print('[cb] Keybind clicked!', Value)
    end,
    ChangedCallback = function(NewKey, NewModifiers)
        print("[cb] Keybind changed!", NewKey, table.unpack(NewModifiers or {}))
    end,
})

Options.KeyPicker:OnClick(function()
    print('Keybind clicked!', Options.KeyPicker:GetState())
end)

Options.KeyPicker:OnChanged(function()
    print("Keybind changed!", Options.KeyPicker.Value, table.unpack(Options.KeyPicker.Modifiers or {}))
end)

task.spawn(function()
    while task.wait(1) do
        local state = Options.KeyPicker:GetState()
        if state then
            print('KeyPicker is being held down')
        end

        if Library.Unloaded then break end
    end
end)

Options.KeyPicker:SetValue({ 'MB2', 'Hold' })

local KeybindNumber = 0

LeftGroupBox:AddLabel("Press Keybind"):AddKeyPicker("KeyPicker2", {
    Default = "X",
    Mode = "Press",
    WaitForCallback = false,
    Text = "Increase Number",
    Callback = function()
        KeybindNumber = KeybindNumber + 1
        print("[cb] Keybind clicked! Number increased to:", KeybindNumber)
    end
})

LeftGroupBox:AddLabel('Dropdown'):AddDropdown('MyDropdown', {
    Values = { 'Addon', 'Dropdown' },
    Default = 1,
    Multi = false,
    Tooltip = 'This is a tooltip',
    DisabledTooltip = 'I am disabled!',
    Searchable = false,
    Callback = function(Value)
        print('[cb] Dropdown got changed. New value:', Value)
    end,
    Disabled = false,
    Visible = true,
})

local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox('Groupbox #2')
LeftGroupBox2:AddLabel('Oh no...\nThis label spans multiple lines!\n\nWe\'re gonna run out of UI space...\nJust kidding! Scroll down!\n\n\nHello from below!', true)

local TabBox = Tabs.Main:AddRightTabbox()

local Tab1 = TabBox:AddTab('Tab 1')
Tab1:AddToggle('Tab1Toggle', { Text = 'Tab1 Toggle' })

local Tab2 = TabBox:AddTab('Tab 2')
Tab2:AddToggle('Tab2Toggle', { Text = 'Tab2 Toggle' })

local RightGroupbox = Tabs.Main:AddRightGroupbox('Groupbox #3')
RightGroupbox:AddToggle('ControlToggle', { Text = 'Dependency box toggle' })

local Depbox = RightGroupbox:AddDependencyBox()
Depbox:AddToggle('DepboxToggle', { Text = 'Sub-dependency box toggle' })

local SubDepbox = Depbox:AddDependencyBox()
SubDepbox:AddSlider('DepboxSlider', { Text = 'Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 })
SubDepbox:AddDropdown('DepboxDropdown', { Text = 'Dropdown', Default = 1, Values = {'a', 'b', 'c'} })

local SecretDepbox = SubDepbox:AddDependencyBox()
SecretDepbox:AddLabel('You found a seĉret!')

Depbox:SetupDependencies({
    { Toggles.ControlToggle, true }
})

SubDepbox:SetupDependencies({
    { Toggles.DepboxToggle, true }
})

SecretDepbox:SetupDependencies({
    { Options.DepboxDropdown, 'c'}
})

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local GetPing = (function() return math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()) end)
local CanDoPing = pcall(function() return GetPing() end)

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    if CanDoPing then
        Library:SetWatermark(('LinoriaLib demo | %d fps | %d ms'):format(
            math.floor(FPS),
            GetPing()
        ))
    else
        Library:SetWatermark(('LinoriaLib demo | %d fps'):format(
            math.floor(FPS)
        ))
    end
end)

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Esp.Unload()
    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:SetSubFolder('specific-place')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()