/*
    CI Base Control Classes (Addon copy)
    Minimal self-contained UI base classes for Civilian Interaction dialogs.
*/

#ifndef CI_DIALOG_BASES
#define CI_DIALOG_BASES

// Style constants (subset)
#define ST_LEFT 0x00
#define ST_CENTER 0x02

class RscText
{
    access = 0;
    type = 0;
    idc = -1;
    style = ST_LEFT;
    lineSpacing = 1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    fixedWidth = 0;
    shadow = 1;
    font = "RobotoCondensed";
    sizeEx = 0.04;
};

class RscButton
{
    access = 0;
    type = 1;
    idc = -1;
    style = ST_CENTER;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.25};
    colorBackground[] = {0.2,0.4,0.6,1};
    colorBackgroundActive[] = {0.3,0.5,0.7,1};
    colorBackgroundDisabled[] = {0.2,0.2,0.2,0.5};
    colorFocused[] = {0.3,0.5,0.7,1};
    colorShadow[] = {0,0,0,0.3};
    colorBorder[] = {0,0,0,1};
    soundEnter[] = {"",0,1};
    soundPush[] = {"",0,1};
    soundClick[] = {"",0,1};
    soundEscape[] = {"",0,1};
    font = "RobotoCondensed";
    sizeEx = 0.035;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0.002;
    offsetPressedY = 0.002;
    borderSize = 0;
};

#endif // CI_DIALOG_BASES
