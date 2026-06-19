extends Area3D

class_name Interactable

# Emitted when an Interactor starts looking at me.
@warning_ignore("unused_signal")
signal focused(interactor: Interactor)
# Emitted when an Interactor stops looking at me.
@warning_ignore("unused_signal")
signal unfocused(interactor: Interactor)
# Emitted when an Interactor interacts with me.
@warning_ignore("unused_signal")
signal interacted(interactor: Interactor)
