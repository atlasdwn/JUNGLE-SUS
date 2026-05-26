# Draft: Puzzle Ideas for Jungle SUS

## Game Analysis Summary

### Core Mechanics (already implemented)
- **Player**: Carina/Karina - top-down 2D movement (WASD), interaction (E key), inventory (Tab)
- **Inventory**: 15-slot grid, `InventoryData` with `add_item/remove_item/has_item`, `all_collected` signal when `total >= required_items`
- **Items**: `ItemData` (name, description, texture) - Suprimento (medicine supply), Machado (axe)
- **Collectibles**: `Coletavel` (StaticBody2D) - walk near → press E → collect animation → item added to inventory
- **Push Physics**: Carina can push `RigidBody2D` objects (stone puzzle already uses this)
- **Stone Puzzle**: `pedra_puzzle.gd` - push a stone away from its initial position >16px → hidden item reveals
- **NPC System**: `NPCBase` with state machine, `DialogInteraction` (proximity trigger → E to talk), `CharacterResource` (name, portrait)
- **Day/Night Cycle**: `night_cycle.gd` - auto-transition from day to night with configurable duration
- **Torch Light**: `player_torch_light.gd` - flickering PointLight2D follows player, supports obstruction zones
- **Fireflies**: `world_firefly_layer.gd` - atmospheric particle system following camera
- **Cutscene System**: AnimationPlayer-based with camera shake, transitions to game world

### NPCs & Story
- **Barqueiro (Boatman)**: States: AGUARDANDO_SUPRIMENTOS → CHAMANDO → POS_JOGO. Stays at boat, tells Carina to find supplies, calls her back when all collected, then boat departs
- **Madeireiro (Logger)**: States: FIRST_MEET → WAITING_FOR_AXE → COMPLETED. Has dialogue about deforestation ("Tô lucrando, tem diferença?"). Trades suprimento for machado. Dialogue references medicine/dipirona scattered in forest
- **Iara**: States: PRIMEIRO_ENCONTRO → DEFAULT. Mystical figure, says "A floresta está com você, Karina." Knows Carina's name. References drought/dying forest/drying streams
- **Matinta**: States: BEFORE_GIVING → AFTER_GIVING. Gives the machado to Carina after dialogue ("Pega ai")

### Current Quest Flow
1. Cutscene: Boat gets stuck, monkeys steal supplies
2. Barqueiro: "Enquanto eu arrumo o barco, procure os suprimentos."
3. Find supplies scattered in world (push stones, find collectibles)
4. Meet NPCs (Iara, Matinta, Madeireiro)
5. Matinta gives machado → Give machado to Madeireiro → Madeireiro gives suprimento
6. Collect all supplies → `all_collected` signal → Barqueiro calls Carina
7. Return to boat → Board → Departure animation → Level complete

### Game World
- Resolution: 640x360 pixel art
- 5 physics layers: Carina, Mundo, NPCs, Coletáveis, Objetos
- Scenes: mundo.tscn (main world), cena_madeireiro.tscn (logger's area), cutscene_inicio
- Visual effects: Vignette/night, torch light, fireflies, walk dust particles

### Technical Notes
- Godot 4.6, GL Compatibility renderer
- State machine pattern for player (idle/walk/collect/cutscene)
- NPCBase is extensible with states and dialog injection
- Inventory has `required_items` count for completion check
- Collectible system: proximity-based, E to pick up
- RigidBody2D push system already implemented

## Open Questions
- How many total suprimentos need to be collected?
- Is the current world map final or will it expand?
- Are there more NPCs planned?
- What's the target play time?