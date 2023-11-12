extends Node

@export var inventory: InventoryResource
@export var market: MarketResource
@export var sell_interval_in_seconds: float
@export var max_amount_per_sell: int
@export var sell_item_slots: Array[String] = []

var progress: float = 0

func _process(delta) -> void:
	progress += delta
	if progress >= sell_interval_in_seconds:
		progress = 0
		sell_items()

func sell_items() -> void:
	for item_name in sell_item_slots:
		if item_name != "":
			sell_item(item_name)
	
func sell_item(item_name: String):
	var item = inventory.get_item(item_name)
	var amount_to_sell = clampi(item.in_stock, 0, max_amount_per_sell)
	inventory.craft("money", {
		item_name: amount_to_sell
	}, floori(item.base_price * amount_to_sell))
