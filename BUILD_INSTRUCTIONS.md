# Build Script for Civilian Interaction Addon

## Using Arma 3 Tools
1. Open Arma 3 Tools
2. Use "Addon Builder" tool
3. Select source folder: `addons/ci_interaction`
4. Output to your mod's `addons` folder
5. Build the PBO

## Using PBO Manager or mikero's tools
```batch
# Using makepbo (if you have mikero's tools)
makepbo -P -A addons\ci_interaction

# The resulting ci_interaction.pbo should be placed in your mod's addons folder
```

## Manual Installation
1. Copy the entire `addons/ci_interaction` folder to your Arma 3 mod directory
2. Use any PBO creation tool to build `ci_interaction.pbo`
3. Place the PBO in your mod's `addons` folder

## Testing
1. Load the mod in Arma 3
2. Place civilian units in the editor
3. Test interactions and verify debug output
4. Check that map markers appear for detected threats
