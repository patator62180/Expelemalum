Inpired from official godot gdscript_styleguide:

01. @tool
02. class_name
03. extends
04. # docstring

05. signals
06. enums
07. constants
08. exported variables
09. public variables
10. private _variables
11. onready variables


12. public methods
13. optional built-in virtual _init method
14. optional built-in virtual _enter_tree() method
15. built-in virtual _ready method
16. remaining built-in virtual methods
17. private _methods
18. subclasses


Various rules:

-in func declaration, put an "_" before unused parameter to avoid warning

-past tense for signal name (ex: door_opened)

-signal callback prefixed with "_on_emitername_signal_name"  (ex: _on_myNode_door_opened)

-no signal binding in editor, only by code

-@export var is uppercase if it's only modified in editor (if possible)

-Node Names in editor in CamelCase

