-- NewLevelFrame - main.lua
-- Optimized: namespaced, no global print override, classic-safe event handling.

--------------------------------------------------------------------------------
-- Localization strings (defined in localization.lua, loaded before this file)
--------------------------------------------------------------------------------
local REACHED_LEVEL_STR = REACHED_LEVEL_STR or "You've Reached"
local NEW_LEVEL_NUM_STR = NEW_LEVEL_NUM_STR or "Level %d"

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
local TEXTURE_PATH  = "Interface\\AddOns\\NewLevelFrame\\newlevel_frame"
local FRAME_WIDTH,  FRAME_HEIGHT = 400, 200
local FRAME_X,      FRAME_Y      = 0, -128
local HEADER_Y,     FOOTER_Y     = 20, -20
local FADE_IN,      FADE_OUT     = 2, 2
local SHOW_DURATION = 5
local FOOTER_R, FOOTER_G, FOOTER_B, FOOTER_A = 207/255, 191/255, 20/255, 1

--------------------------------------------------------------------------------
-- Frame references (locals, not globals)
--------------------------------------------------------------------------------
local frame, texture, header, footer

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

-- Chat output that does NOT override the global print function.
local function Print(msg)
    if msg and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99NewLevelFrame:|r " .. msg)
    end
end

-- One-time frame setup.
local function SetupFrame()
    if frame then
        return -- already initialized
    end

    frame = CreateFrame("Frame", "NewLevelFrame", UIParent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetWidth(FRAME_WIDTH)
    frame:SetHeight(FRAME_HEIGHT)
    frame:SetPoint("TOP", FRAME_X, FRAME_Y)
    frame:Hide()

    texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(TEXTURE_PATH)
    texture:SetAllPoints(frame)

    header = frame:CreateFontString(nil, "ARTWORK")
    header:SetFont("Fonts\\FRIZQT__.TTF", 18)
    header:SetPoint("CENTER", 0, HEADER_Y)
    header:SetText(REACHED_LEVEL_STR)

    footer = frame:CreateFontString(nil, "ARTWORK")
    footer:SetFont("Fonts\\FRIZQT__.TTF", 30)
    footer:SetPoint("CENTER", 0, FOOTER_Y)
    footer:SetTextColor(FOOTER_R, FOOTER_G, FOOTER_B, FOOTER_A)
end

-- Show the level-up frame for the given level.
local function ShowNewLevelFrame(level)
    if not footer then
        Print("Frame not initialized yet.")
        return
    end

    footer:SetText(string.format(NEW_LEVEL_NUM_STR, level))

    -- Reset state so an interrupted previous fade can't leave partial alpha.
    frame:SetScript("OnUpdate", nil)
    frame:SetAlpha(0)

    if not frame:IsVisible() then
        frame:Show()
    end

    UIFrameFadeIn(frame, FADE_IN, 0, 1)

    local timeShown = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        timeShown = timeShown + (elapsed or 0)
        if timeShown >= SHOW_DURATION then
            UIFrameFadeOut(frame, FADE_OUT, 1, 0)
            frame:SetScript("OnUpdate", nil)
        end
    end)
end

--------------------------------------------------------------------------------
-- Event handler
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

eventFrame:SetScript("OnEvent", function()
    -- Classic 1.12-safe: pull event/args from globals into locals.
    local event, arg1 = event, arg1

    if event == "PLAYER_LOGIN" then
        SetupFrame()
        frame:Hide()
    elseif event == "PLAYER_LEVEL_UP" then
        footer:SetText("")
        ShowNewLevelFrame(arg1)
    end
end)

--------------------------------------------------------------------------------
-- Slash commands: /lvltest [level]  and  /nlf [level]
--------------------------------------------------------------------------------

SLASH_LEVELFRAME1     = "/lvltest"
SLASH_NEWLEVELFRAME1  = "/nlf"

local function TestLevelFrame(msg)
    local level
    if msg and msg ~= "" then
        level = tonumber(msg)
    end
    if not level then
        level = UnitLevel("player")
    end

    if not footer then
        SetupFrame()
    end
    footer:SetText("")
    ShowNewLevelFrame(level)
end

SlashCmdList["LEVELFRAME"]     = TestLevelFrame
SlashCmdList["NEWLEVELFRAME"]  = TestLevelFrame
