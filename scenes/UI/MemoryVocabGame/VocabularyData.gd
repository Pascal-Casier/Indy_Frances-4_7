# ==============================================================================
# Fichier: VocabularyData.gd
# Ce script définit un type de ressource personnalisé pour notre vocabulaire.
# ==============================================================================
extends Resource
class_name VocabularyData

@export var pairs: Dictionary[String, String] = {}
