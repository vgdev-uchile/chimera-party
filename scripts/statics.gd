class_name Statics
extends Node


static func pick_by_weight(weights: Array[float]) -> int:
	var weights_acc := []
	weights_acc.resize(weights.size())
	var weights_sum := 0.0
	for i in weights_acc.size():
		weights_sum += weights[i]
		weights_acc[i] = weights_sum
	var weight_threshold := randf_range(0.0, weights_acc.back())
	return weights_acc.bsearch(weight_threshold)
