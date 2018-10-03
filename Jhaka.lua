Jhaka = CreateFrame( "Frame", "JhakaLua", UIParent, "ActionButtonTemplate" );
JhakaVersion = 0.1;

--[[----------------------------------------------------------------------------
    Global Variables
------------------------------------------------------------------------------]]
Jhaka_Settings = {
    MinimapPos = 45;
}

Jhaka_LevelTimes = {
    [1] = { ["current"] = "8:34", ["goal"] = "5:00", ["split"] = "+3:34" },
    [2] = { ["current"] = "", ["goal"] = "", ["split"] = "" },
};

JhakaIsOpen = false;
JhakaCurrentPage = 1;
JhakaCurrentLevel = 1;
JhakaSessionStart = 0;
JhakaSessionTotal = 0;
JhakaLevelStart = 0;
JhakaLevelTotal = 0;
JhakaMessageColor = { ["r"] = 0, ["g"] = 0, ["b"] = 0 };

--[[----------------------------------------------------------------------------
    Function:   Jhaka:SetupDefaults()
    Brief:      ...
------------------------------------------------------------------------------]]
function Jhaka:SetupDefaults()
    if not Jhaka_LevelTimes then
        Jhaka_LevelTimes = {}
    end

    if not Jhaka_Settings then
        Jhaka_Settings = {}
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:OnLoad()
    this:RegisterEvent( "ADDON_LOADED" );
    this:RegisterEvent( "VARIABLES_LOADED")
    this:RegisterEvent( "PLAYER_LOGIN" );
    this:RegisterEvent( "PLAYER_LOGOUT" );
    this:RegisterEvent( "PLAYER_LEVEL_UP" );

    SlashCmdList[ "JHAKA" ] = Jhaka_SlashCmdList;
    SLASH_JHAKA1 = "/jhaka";
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:OnEvent()
    if event == "VARIABLES_LOADED" then
        Jhaka_MinimapButton_Reposition();
        Jhaka:SetupDefaults();
    elseif event == "PLAYER_LOGIN" then
        Jhaka:PlayerLogin();
    elseif event == "PLAYER_LOGOUT" then
        Jhaka:PlayerLogout();
    elseif event == "PLAYER_LEVEL_UP" then
        Jhaka:PlayerLevelUp();
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka_MinimapButton_Reposition()
    Jhaka_MinimapButton:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        52 - ( 80 * cos( Jhaka_Settings.MinimapPos )),
        ( 80 * sin( Jhaka_Settings.MinimapPos )) - 52 );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka_MinimapButton_DraggingFrame_OnUpdate()
    local xpos, ypos = GetCursorPosition();
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();

    xpos = xmin - xpos / UIParent:GetScale() + 70;
    ypos = ypos / UIParent:GetScale() - ymin - 70;

    Jhaka_Settings.MinimapPos = math.deg( math.atan2( ypos, xpos ));
    Jhaka_MinimapButton_Reposition();
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka_MinimapButton_OnClick()
    if arg1 == "LeftButton" then
        Jhaka:ToggleFrame();
    elseif arg1 == "RightButton" then
        ReloadUI();
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:ToggleFrame()
    if JhakaIsOpen then
        Jhaka:CloseFrame();
    else
        Jhaka:OpenFrame();
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:OpenFrame()
    PlaySound( "igSpellBookOpen" );
    JhakaFrame:Show();
    JhakaIsOpen = true;
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:CloseFrame()
    PlaySound( "igSpellBookClose" );
    JhakaFrame:Hide();
    JhakaIsOpen = false;
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:PlayerLogin()
    JhakaSessionStart = GetTime();
    JhakaLevelStart = GetTime();
    JhakaCurrentLevel = UnitLevel( "player" );

    Jhaka:SetMessageColour();
    Jhaka:Message( "Session Started" );
    JhakaFrame_UpdatePage();
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:PlayerLogout()
    JhakaSessionTotal = JhakaSessionTotal + ( GetTime() - JhakaSessionStart );
    JhakaLevelTotal = JhakaLevelTotal + ( GetTime() - JhakaLevelStart );

    Jhaka:SetMessageColour();
    Jhaka:Message(
        "Session Stopped. Total time was "
        .. Jhaka_FormatTime( JhakaSessionTotal ));
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:PlayerLevelUp()
    JhakaLevelTotal = JhakaLevelTotal + ( GetTime() - JhakaLevelStart );

    Jhaka:Message(
        "Levelled up! Total time was "
        .. Jhaka_FormatTime( JhakaLevelTotal ));

    JhakaLevelStart = GetTime();
    JhakaLevelTotal = 0;
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:SetMessageColour()
    local class = UnitClass( "player" );

    if class == "Druid" then
        JhakaMessageColor = {
            ["r"] = 0.00,
            ["g"] = 0.49,
            ["b"] = 0.04,
            ["rgb"] = "00ff7d0a"
        };
    elseif class == "Hunter" then
        JhakaMessageColor = {
            ["r"] = 0.67,
            ["g"] = 0.83,
            ["b"] = 0.45,
            ["rgb"] = "00abd473"
        };
    elseif class == "Mage" then
        JhakaMessageColor = {
            ["r"] = 0.41,
            ["g"] = 0.80,
            ["b"] = 0.94,
            ["rgb"] = "0069ccf0"
        };
    elseif class == "Paladin" then
        JhakaMessageColor = {
            ["r"] = 0.96,
            ["g"] = 0.55,
            ["b"] = 0.73,
            ["rgb"] = "00f58cba"
        };
    elseif class == "Priest" then
        JhakaMessageColor = {
            ["r"] = 1.00,
            ["g"] = 1.00,
            ["b"] = 1.00,
            ["rgb"] = "00ffffff"
        };
    elseif class == "Rogue" then
        JhakaMessageColor = {
            ["r"] = 1.00,
            ["g"] = 0.96,
            ["b"] = 0.41,
            ["rgb"] = "00fff569"
        };
    elseif class == "Shaman" then
        JhakaMessageColor = {
            ["r"] = 0.00,
            ["g"] = 0.44,
            ["b"] = 0.87,
            ["rgb"] = "000070de"
        };
    elseif class == "Warlock" then
        JhakaMessageColor = {
            ["r"] = 0.58,
            ["g"] = 0.51,
            ["b"] = 0.79,
            ["rgb"] = "009482c9"
        };
    elseif class == "Warrior" then
        JhakaMessageColor = {
            ["r"] = 0.78,
            ["g"] = 0.61,
            ["b"] = 0.43,
            ["rgb"] = "00c79c6e"
        };
    else
        JhakaMessageColor = {
            ["r"] = 1.00,
            ["g"] = 1.00,
            ["b"] = 1.00,
            ["rgb"] = "00ffffff"
        };
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
JhakaSlashCmd = {
    [ "help" ] = function()
        DEFAULT_CHAT_FRAME:AddMessage( "Jhaka SlashCommand Help Menu:", 1, 0.75, 0 );
        Jhaka:PrintHelp( "option1", "Does something to the first option" );
        Jhaka:PrintHelp( "option2", "Does something to the second option" );
        Jhaka:PrintHelp( "option3", "Does something to the third option" );
    end
};

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:Message( message )
    DEFAULT_CHAT_FRAME:AddMessage(
        "[Jhaka] " .. message,
        JhakaMessageColor.r,
        JhakaMessageColor.g,
        JhakaMessageColor.b
    );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka:PrintHelp( arg, message )
    DEFAULT_CHAT_FRAME:AddMessage( "|c0000c0ff  /jhaka " .. arg .. "|r " .. message, 1, 1, 1 );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka_FormatTime( time )
    minutes = time / 60;
    seconds = math.mod( time, 60 );
    hours = minutes / 60;
    minutes = math.mod( minutes, 60 );
    days = time / ( 24 * 60 );

    return
    math.floor( days ) .. " days, " ..
        math.floor( hours ) .. " hours, " ..
        math.floor( minutes ) .. " minutes, " ..
        math.floor( seconds ) .. " seconds";
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka_SlashCmdList( message )
    local space = findFirstIndexOf( message, " " );
    local msg, args;

    if not space or space == 1 then
        msg = message;
    else
        msg = string.sub( message, 1, space );
        args = string.sub( message, space + 2 );
    end

    if JhakaSlashCmd[ msg ] ~= nil then
        JhakaSlashCmd[ msg ]( args );
    else
        if not msg or msg == "" then
            JhakaSlashCmd[ "help" ]();
        else
            DEFAULT_CHAT_FRAME:AddMessage( "Unknown operation: |c00ffff00\"" .. msg .. "\"|r try /jhaka help" );
        end
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function Jhaka_HelpMenu( slashcommand, effect, istoggle, variable )
    local toggle, value;

    if istoggle then
        toggle = "|c0000ffc0 (toggle)|r ";
    else
        toggle = "";
    end

    DEFAULT_CHAT_FRAME:AddMessage( "|c0000c0ff  /jhaka " .. slashcommand .. "|r" .. toggle .. effect .. " " .. Jhaka_Toggle( variable ), 1, 1, 1 );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function findFirstIndexOf( message, value )
    local index = string.find( message, value );

    if index == nil then
        return nil;
    else
        return index - 1;
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_ChangePage( offset )
    JhakaCurrentPage = JhakaCurrentPage + offset;

    if JhakaCurrentPage < 1 then
        JhakaCurrentPage = 1;
    elseif JhakaCurrentPage > 4 then
        JhakaCurrentPage = 4;
    end

    JhakaFrame_UpdatePage();
    PlaySound( "igSpellBokPageTurn" );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_UpdatePage()
    JhakaFrame_UpdateLevel();
    JhakaFrame_UpdateCurrent();
    JhakaFrame_UpdateGoal();
    JhakaFrame_UpdateSplit();
    JhakaFrame_UpdateBest();

    Jhaka_PageText:SetText( "Page " .. JhakaCurrentPage );

    Jhaka_PrevPage:Enable();
    Jhaka_NextPage:Enable();

    if JhakaCurrentPage == 1 then
        Jhaka_PrevPage:Disable();
    elseif JhakaCurrentPage == 4 then
        Jhaka_NextPage:Disable();
    end
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_UpdateLevel()
    level = {
        (( JhakaCurrentPage - 1 ) * 15 ) + 1,
        (( JhakaCurrentPage - 1 ) * 15 ) + 2,
        (( JhakaCurrentPage - 1 ) * 15 ) + 3,
        (( JhakaCurrentPage - 1 ) * 15 ) + 4,
        (( JhakaCurrentPage - 1 ) * 15 ) + 5,
        (( JhakaCurrentPage - 1 ) * 15 ) + 6,
        (( JhakaCurrentPage - 1 ) * 15 ) + 7,
        (( JhakaCurrentPage - 1 ) * 15 ) + 8,
        (( JhakaCurrentPage - 1 ) * 15 ) + 9,
        (( JhakaCurrentPage - 1 ) * 15 ) + 10,
        (( JhakaCurrentPage - 1 ) * 15 ) + 11,
        (( JhakaCurrentPage - 1 ) * 15 ) + 12,
        (( JhakaCurrentPage - 1 ) * 15 ) + 13,
        (( JhakaCurrentPage - 1 ) * 15 ) + 14,
        (( JhakaCurrentPage - 1 ) * 15 ) + 15
    };

    levelstring = {};

    for i = 1, 15 do
        local coloropen = "";
        local colorclose = "";

        if level[i] == JhakaCurrentLevel then
            coloropen = "|c" .. JhakaMessageColor.rgb;
            colorclose = "|r";
        end

        if level[i] < 10 then
            levelstring[i] = coloropen .. " " .. level[i] .. "." .. colorclose;
        else
            levelstring[i] = coloropen .. level[i] .. "." .. colorclose;
        end
    end

    Jhaka_Level1:SetText( levelstring[1] );
    Jhaka_Level2:SetText( levelstring[2] );
    Jhaka_Level3:SetText( levelstring[3] );
    Jhaka_Level4:SetText( levelstring[4] );
    Jhaka_Level5:SetText( levelstring[5] );
    Jhaka_Level6:SetText( levelstring[6] );
    Jhaka_Level7:SetText( levelstring[7] );
    Jhaka_Level8:SetText( levelstring[8] );
    Jhaka_Level9:SetText( levelstring[9] );
    Jhaka_Level10:SetText( levelstring[10] );
    Jhaka_Level11:SetText( levelstring[11] );
    Jhaka_Level12:SetText( levelstring[12] );
    Jhaka_Level13:SetText( levelstring[13] );
    Jhaka_Level14:SetText( levelstring[14] );
    Jhaka_Level15:SetText( levelstring[15] );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_UpdateCurrent()
    Jhaka_CurrentLevel1:SetText( Jhaka_LevelTimes[1]["current"] );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_UpdateGoal()
    Jhaka_GoalLevel1:SetText( Jhaka_LevelTimes[1]["goal"] );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_UpdateSplit()
    local coloropen = "";
    local colorclose = "";

    time = Jhaka_LevelTimes[1][ "split" ];

    if string.find( time, "+" ) then
        coloropen = "|c00ff6060";
        colorclose = "|r";
    elseif string.find( time, "-" ) then
        coloropen = "|c0060ff60";
        colorclose = "|r";
    end

    Jhaka_SplitLevel1:SetText( coloropen .. Jhaka_LevelTimes[1]["split"] .. colorclose );
end

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]
function JhakaFrame_UpdateBest()
    --
end