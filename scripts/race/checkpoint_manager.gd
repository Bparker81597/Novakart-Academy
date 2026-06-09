class_name CheckpointManager
extends Node

var next_checkpoint: int = 0

func reach_checkpoint(checkpoint_index: int, checkpoint_count: int) -> bool:
	if checkpoint_index != next_checkpoint:
		return false
	next_checkpoint = (next_checkpoint + 1) % checkpoint_count
	return next_checkpoint == 0
