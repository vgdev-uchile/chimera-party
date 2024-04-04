class_name Statics
extends Node

enum Inputs {
	LEFT  = 1 << 0,
	RIGHT = 1 << 1,
	UP    = 1 << 2,
	DOWN  = 1 << 3,
	A     = 1 << 4,
	B     = 1 << 5,
}

static func pick_by_weight(weights: Array[float]) -> int:
	var weights_acc := []
	weights_acc.resize(weights.size())
	var weights_sum := 0.0
	for i in weights_acc.size():
		weights_sum += weights[i]
		weights_acc[i] = weights_sum
	var weight_threshold := randf_range(0.0, weights_acc.back())
	return weights_acc.bsearch(weight_threshold)
