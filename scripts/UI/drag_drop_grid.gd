class_name DragDropGrid extends GridContainer

signal dragged(from : Vector2i, to : Vector2i)

var _cells := []

func _ready() -> void:
	for x in columns:
		_cells.append([])
	var row: int = 0
	var column : int = 0
	for cell in get_children():
		_cells[column].append(cell)
		cell.grid_position = Vector2i(column, row)
		cell.dragged.connect(dragged.emit)
	
		column += 1
		if column >= columns:
			column = 0
			row +=1
