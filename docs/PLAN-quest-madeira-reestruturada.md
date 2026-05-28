# PLANO: Reestruturação da Quest da Madeira + Novos Diálogos

## Escopo

Reestruturar o fluxo de quest da madeira para integrar com o Madeireiro e atualizar todos os diálogos do Barqueiro para o novo roteiro. NÃO toca no código/cenas do Madeireiro (trabalho do colega).

---

## Novo Fluxo de Quest

1. Carina coleta suprimentos normalmente
2. Carina finaliza a quest do Madeireiro (colega seta `quest_madeireiro_concluida = true`)
3. Carlos avisa automaticamente: "Karina, volte aqui!"
4. Carina vai falar com Carlos → Diálogo pedindo_ajuda (Carlos pede madeira, menciona o Madeireiro)
5. Madeiras aparecem no mapa (área do Madeireiro)
6. Carina coleta as madeiras
7. Carina volta para Carlos → Diálogo concluido (entrega e conversa sobre a Iara)
8. Carlos libera Carina para coletar os suprimentos restantes
9. Boto cor-de-rosa entrega o último remédio (futuro)
10. Diálogo final com Iara + Carlos
11. Jogo encerra

---

## Tarefas

### TAREFA 1 — global_player_manager.gd
Adicionar: `var quest_madeireiro_concluida: bool = false`

### TAREFA 2 — mundo.gd
- Remover o trigger de "5 suprimentos"
- Adicionar `_disparar_pedido_madeira()` chamado quando `quest_madeireiro_concluida` virar true
- Monitorar via `_process()`:
  ```gdscript
  var _esperando_madeireiro := true
  func _process(_delta):
      if _esperando_madeireiro and PlayerManager.quest_madeireiro_concluida:
          _esperando_madeireiro = false
          _disparar_pedido_madeira()
  ```
- Ajustar slices de `inicio.tres` para slice(0,12), slice(12,18), slice(18)

### TAREFA 3 — inicio.tres (33 linhas)
Parte 1 [0-11]: Conversa Carlos/Karina antes da Iara aparecer
Parte 2 [12-17]: Carlos "!!", Karina "!", Iara fala 3 linhas
Parte 3 [18-32]: Pós-Iara, Karina decide ir buscar suprimentos

### TAREFA 4 — pedindo_ajuda.tres (26 linhas)
Diálogo completo Carlos pedindo madeira + Karina mencionando o madeireiro

### TAREFA 5 — concluido.tres (17 linhas)
Diálogo da entrega da madeira + conversa sobre a Iara (humor)

### TAREFA 6 — chamada.tres (47 linhas)
Diálogo final completo: Carlos preso pela Iara, Karina negocia, Iara entrega medicamento

### TAREFA 7 — consertando.tres
"Ainda preciso da madeira. Vai lá no madeireiro!"

---

## Conexão com Colega
O colega deve setar: `PlayerManager.quest_madeireiro_concluida = true`
ao finalizar a quest do Madeireiro.

---

## Arquivos Afetados
- autoloads/global_player_manager.gd
- cenas/mundo/scripts/mundo.gd
- recursos/dialogs/barqueiro/inicio.tres
- recursos/dialogs/barqueiro/pedindo_ajuda.tres
- recursos/dialogs/barqueiro/concluido.tres
- recursos/dialogs/barqueiro/chamada.tres
- recursos/dialogs/barqueiro/consertando.tres

NÃO TOCAR: cenas/cenamadeireiro/, recursos/dialogs/madeireiro/
