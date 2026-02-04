extends Node

enum State {
	FIELD,
	MENU,
	BATTLE,
	EVENT
}

var state: State = State.FIELD
