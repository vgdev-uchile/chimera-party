extends Node2D

signal fired


func fire() -> void:
	fired.emit()
	
