/*
    Civilian Interaction Dialog (Addon) - Self-contained version
*/

// Base control classes embedded directly
#define ST_LEFT 0x00
#define ST_CENTER 0x02

class RscText
{
    access = 0; type = 0; idc = -1; style = ST_LEFT; lineSpacing = 1;
    colorBackground[] = {0,0,0,0}; colorText[] = {1,1,1,1}; text = ""; fixedWidth = 0; shadow = 1;
    font = "RobotoCondensed"; sizeEx = 0.04;
};

class RscButton
{
    access = 0; type = 1; idc = -1; style = ST_CENTER; text = "";
    colorText[] = {1,1,1,1}; colorDisabled[] = {1,1,1,0.25}; colorBackground[] = {0.2,0.4,0.6,1};
    colorBackgroundActive[] = {0.3,0.5,0.7,1}; colorBackgroundDisabled[] = {0.2,0.2,0.2,0.5};
    colorFocused[] = {0.3,0.5,0.7,1}; colorShadow[] = {0,0,0,0.3}; colorBorder[] = {0,0,0,1};
    soundEnter[] = {"",0,1}; soundPush[] = {"",0,1}; soundClick[] = {"",0,1}; soundEscape[] = {"",0,1};
    font = "RobotoCondensed"; sizeEx = 0.035; offsetX = 0; offsetY = 0; offsetPressedX = 0.002; offsetPressedY = 0.002; borderSize = 0;
};

class CivilianInteractionDialog
{
    idd = 2400;
    movingEnable = 0;
    enableSimulation = 1;

    class ControlsBackground
    {
        class Background: RscText
        {
            idc = -1;
            x = 0.3; y = 0.25; w = 0.4; h = 0.5;
            colorBackground[] = {0,0,0,0.8};
        };
        class Title: RscText
        {
            idc = -1;
            text = "Civilian Interaction";
            x = 0.3; y = 0.25; w = 0.4; h = 0.05;
            colorBackground[] = {0.2,0.4,0.6,1};
            colorText[] = {1,1,1,1};
            sizeEx = 0.04;
            style = ST_CENTER;
        };
    };

    class Controls
    {
        class QuestionText: RscText
        {
            idc = -1;
            text = "What would you like to ask?";
            x = 0.32; y = 0.32; w = 0.36; h = 0.04;
            colorText[] = {1,1,1,1};
            sizeEx = 0.035;
        };
        class AskAboutEnemies: RscButton
        {
            idc = -1;
            text = "Have you seen any enemy troops?";
            x = 0.32; y = 0.38; w = 0.36; h = 0.05;
            action = "['enemies'] call CI_fnc_processInteractionResponse;";
        };
        class AskAboutMines: RscButton
        {
            idc = -1;
            text = "Do you know of any mines or explosives?";
            x = 0.32; y = 0.45; w = 0.36; h = 0.05;
            action = "['mines'] call CI_fnc_processInteractionResponse;";
        };
        class GeneralTalk: RscButton
        {
            idc = -1;
            text = "How are things around here?";
            x = 0.32; y = 0.52; w = 0.36; h = 0.05;
            action = "['general'] call CI_fnc_processInteractionResponse;";
        };
        class CloseButton: RscButton
        {
            idc = -1;
            text = "Leave";
            x = 0.32; y = 0.59; w = 0.36; h = 0.04;
            action = "
                if (!isNil 'CI_CurrentCivilian') then {
                    private _civilian = CI_CurrentCivilian;
                    if (!isNull _civilian && {_civilian getVariable ['CI_WasMovingDisabled', false]}) then {
                        _civilian enableAI 'MOVE';
                        _civilian setVariable ['CI_WasMovingDisabled', false];
                    };
                };
                closeDialog 0;
            ";
        };
			};

    onUnload = "
        if (!isNil 'CI_CurrentCivilian') then {
            private _civilian = CI_CurrentCivilian;
            if (!isNull _civilian && {_civilian getVariable ['CI_WasMovingDisabled', false]}) then {
                _civilian enableAI 'MOVE';
                _civilian setVariable ['CI_WasMovingDisabled', false];
            };
        };
    ";
};