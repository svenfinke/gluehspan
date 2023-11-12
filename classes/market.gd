extends Resource
class_name MarketResource

@export var market_prices: Dictionary = {}
@export var default_price: float = 1

func get_price(item: String) -> float:
	return market_prices[item] if market_prices.has(item) else default_price
