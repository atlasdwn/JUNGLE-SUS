extends Control

# ATENÇÃO: Ajuste este caminho para apontar para o VBoxContainer dentro da sua cena de Quest
@onready var quest_list: VBoxContainer = $MarginContainer/QuestList

func _ready() -> void:
	# Sempre que o Autoload avisar que uma quest mudou, a interface se redesenha
	QuestManager.quests_updated.connect(update_quest_log)
	
	# Desenha a lista pela primeira vez quando o jogo abre
	update_quest_log()

func update_quest_log() -> void:
	# Limpa os painéis antigos da tela
	for child in quest_list.get_children():
		child.queue_free()
		
	# Cria o novo visual para cada missão ativa
	for quest in QuestManager.active_quests:
		# 1. Cria o Fundo (PanelContainer)
		var panel = PanelContainer.new()
		
		# 2. Cria um organizador vertical para ficar dentro do painel
		var vbox = VBoxContainer.new()
		panel.add_child(vbox)
		
		# 3. Cria o Título (Label)
		var title_label = Label.new()
		title_label.text = "- " + quest.title + ":"
		title_label.add_theme_font_size_override("font_size", 26)
		# Opcional: Aqui você pode colocar uma fonte em negrito ou mudar a cor depois
		vbox.add_child(title_label)
		
		# 4. Cria a Descrição (RichTextLabel)
		var desc_label = RichTextLabel.new()
		desc_label.text = quest.description
		desc_label.fit_content = true # Essencial: faz o RichTextLabel esticar para baixo até caber todo o texto
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_font_size_override("normal_font_size", 26)
		
		# 5. Cria o recuo/espaçamento na esquerda (exatamente como no seu desenho)
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20) # Empurra o texto 20 pixels para a direita
		margin.add_child(desc_label)
		
		vbox.add_child(margin)
		
		# 6. Finalmente, adiciona esse "cartão" completo na lista da sua interface!
		quest_list.add_child(panel)
