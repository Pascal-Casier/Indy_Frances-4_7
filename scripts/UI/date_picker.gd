extends Control

var current_date = Time.get_date_dict_from_system()
var selected_date = {}
var months = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]

@onready var year_spinbox = $VBoxContainer/HBoxContainer/YearSpinBox
@onready var month_option = $VBoxContainer/HBoxContainer/MonthOptionButton
@onready var day_option = $VBoxContainer/HBoxContainer/DayOptionButton
@onready var selected_date_label = $VBoxContainer/SelectedDateLabel

func _ready():
	setup_year_spinbox()
	setup_month_option()
	setup_day_option()
	update_selected_date()

func setup_year_spinbox():
	year_spinbox.min_value = 1900
	year_spinbox.max_value = 2100
	year_spinbox.value = current_date.year
	year_spinbox.value_changed.connect(_on_year_changed)

func setup_month_option():
	for i in range(12):
		month_option.add_item(months[i], i + 1)
	month_option.select(current_date.month - 1)
	month_option.item_selected.connect(_on_month_changed)

func setup_day_option():
	update_days_in_month()
	day_option.select(current_date.day - 1)
	day_option.item_selected.connect(_on_day_changed)

func update_days_in_month():
	var year = year_spinbox.value
	var month = month_option.get_selected_id()
	var days_in_month = get_days_in_month(year, month)
	
	day_option.clear()
	for i in range(1, days_in_month + 1):
		day_option.add_item(str(i), i)

func get_days_in_month(year: int, month: int) -> int:
	var days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and is_leap_year(year):
		return 29
	return days_per_month[month - 1]

func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

func _on_year_changed(_value):
	update_days_in_month()
	update_selected_date()

func _on_month_changed(_index):
	update_days_in_month()
	update_selected_date()

func _on_day_changed(_index):
	update_selected_date()

func update_selected_date():
	selected_date = {
		"year": year_spinbox.value,
		"month": month_option.get_selected_id(),
		"day": day_option.get_selected_id()
	}
	selected_date_label.text = "Date sélectionnée : %02d-%02d-%04d" % [selected_date.day, selected_date.month, selected_date.year]

func get_selected_date():
	return selected_date
