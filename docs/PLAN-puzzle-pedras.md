# Plan: Puzzle de Empurrar Pedra (Movable Rock)

## Objetivo
Criar uma mecânica onde o jogador empurra uma pedra física (RigidBody2D) de forma livre para revelar um suprimento (coletável) escondido exatamente na sua posição original.

## Requisitos do Usuário
- **Física:** A pedra deve ser movida usando colisão normal (RigidBody2D), sem animações complexas de empurrar. Livre movimento no mundo.
- **Revelação:** O suprimento fica fisicamente debaixo da pedra (invisível e desativado) e torna-se coletável quando a pedra sai de cima.
- **Falha/Reset:** Sem reset. Se o jogador empurrar para a parede, ela fica presa lá (sem mecânica extra).
- **Arte:** Usar `assets/Pixel Crawler - Free Pack/Environment/Props/Static/Rocks.png`.

## Fase 1: Atualização da Cena `pedrasMoveis.tscn`
1. Manter a raiz atual `Node2D` (nome: `PedraMovelPuzzle`).
2. Adicionar os seguintes nós filhos:
   - `RigidBody2D` (nome: `Pedra`)
	 - `Sprite2D` (usando o spritesheet das pedras, com `region_enabled = true` para recortar apenas uma pedra da imagem).
	 - `CollisionShape2D` (tamanho exato da base da pedra).
   - Um nó placeholder para colocar o Suprimento.
3. Configuração do `RigidBody2D`:
   - `gravity_scale` = 0 (por ser jogo top-down).
   - `lock_rotation` = true (para a pedra não girar ao empurrar).
   - `linear_damp` = 15.0 (alta resistência para a pedra não "deslizar no gelo" e parar logo que a Carina parar de empurrar).
   - `mass` = 50.0 (para ter sensação de peso, mas ser empurrável).

## Fase 2: Script da Cena do Puzzle (`pedra_puzzle.gd`)
1. Anexar um novo script à raiz `Node2D`.
2. **Lógica de Ocultação:**
   - No `_ready()`, guardar a `global_position` inicial da `Pedra`.
   - Identificar se há um item escondido configurado via `@export var item_escondido_path: NodePath` (o qual o level designer conectará).
   - Se existir, usar `item.hide()` e `item.process_mode = Node.PROCESS_MODE_DISABLED` para que o player não colete acidentalmente antes de empurrar.
3. **Lógica de Detecção:**
   - No `_physics_process()`, medir a distância entre a `Pedra` atual e a posição inicial.
   - Se `distance > 16.0` (por exemplo), significa que o jogador empurrou.
   - Ativar o item: `item.show()`, `item.process_mode = Node.PROCESS_MODE_INHERIT`.
   - Desativar a verificação: `set_physics_process(false)` para salvar processamento.

## Fase 3: Integração com o Jogador (`Carina`)
No Godot 4, um `CharacterBody2D` como a Carina não empurra um `RigidBody2D` automaticamente só por colidir. 
1. Precisamos verificar o script de movimentação (`carina.gd` ou `state_walk.gd`).
2. Implementar a lógica após `move_and_slide()`:
   ```gdscript
   for i in get_slide_collision_count():
	   var c = get_slide_collision(i)
	   if c.get_collider() is RigidBody2D:
		   c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)
   ```

## Fase 4: Teste e Validação
1. Colocar a cena `pedrasMoveis.tscn` no `mundo.tscn`.
2. Adicionar uma `Maça` (Suprimento) como filho da cena do puzzle e linkar no export.
3. Testar se o empurrão funciona corretamente e o suprimento aparece debaixo.
