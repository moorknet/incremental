extends Node2D

const ARENA_SIZE := Vector2(800, 500)
const PLAYER_CORNER := Vector2(400, 250)

@onready var player: Player = $Player
@onready var attack_controller: AttackController = $Player/AttackController
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var enemies_node: Node2D = $Enemies
@onready var projectiles_node: Node2D = $Projectiles
@onready var damage_numbers_node: Node2D = $DamageNumbers
@onready var run_end_screen: Node = $RunEndScreen
@onready var meta_shop: Node = $MetaShop
@onready var pause_menu: Node = $PauseMenu
@onready var hud: Node = $HUD

func _ready() -> void:
	GameManager.damage_numbers_node = damage_numbers_node
	GameManager.enemies_node = enemies_node
	GameManager.projectiles_node = projectiles_node
	run_end_screen.shop_requested.connect(meta_shop.open)
	hud.pause_requested.connect(pause_menu.open)
	player.place_in_corner(PLAYER_CORNER)
	attack_controller.setup(enemies_node, projectiles_node)
	enemy_spawner.setup(PLAYER_CORNER, enemies_node)
	GameManager.start_run()
