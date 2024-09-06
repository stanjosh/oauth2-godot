extends Node
class_name HTML

var page : PackedByteArray
var file : FileAccess

func _init(path: String):
	file = FileAccess.open(path, FileAccess.READ)

func ascii() -> PackedByteArray:
	if file != null:
		page = ("HTTP/1.1 %d\r\n" % 200).to_ascii_buffer()
		page += file.get_as_text().replace("    ", "\t").insert(0, "\n").to_ascii_buffer()
		file.close()
	return page
