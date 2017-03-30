//https://github.com/rossengeorgiev/vdf-parser

// a simple parser for Valve's KeyValue format
// https://developer.valvesoftware.com/wiki/KeyValues
//
// author: Rossen Popov, 2014-2016

var fs = require('fs'),
	path = require("path"),
	deepmerge = require('deepmerge');

var TYPE_BLOCK = 0;
function parse(data) {
	// Make sure we have some data to work with
	if(!data) return null;

	var tree = [{}];
	var treeType = [TYPE_BLOCK];
	var keys = [null];

	var i = 0;
	var line = 1;

	while(i < data.length) {
		var chr = data.charAt(i);

		if(chr == ' ' || chr == '\t') {
			// Ignore white space
		} else if(chr == '\n') {
			// We moved onto the next line
			line++;
			if(data.charAt(i+1) == '\r') i++;
		} else if(chr == '\r') {
			// We moved onto the next line
			line++;
			if(data.charAt(i+1) == '\n') i++;
		} else if(chr == '/') {
			if(data.charAt(i+1) == '/') {
				// We found a comment, ignore rest of the line
				while(++i < data.length) {
					chr = data.charAt(i);

					// Check for new line
					if(chr == '\n') {
						if(data.charAt(i+1) == '\r') ++i;
						break;
					}
					if(chr == '\r') {
						if(data.charAt(i+1) == '\n') ++i;
						break;
					}
				}

				// We are on a new line
				line++;
			}
		} else if(chr == '#') {
			if(data.charAt(i+1) == 'b') {
				//#base
				var str = ""
				while(++i < data.length) {
					chr = data.charAt(i);
					str += chr
					// Check for new line
					if(chr == '\n') {
						if(data.charAt(i+1) == '\r') ++i;
						break;
					}
					if(chr == '\r') {
						if(data.charAt(i+1) == '\n') ++i;
						break;
					}
				}
				var path = str.replace("base \"", "").slice(0, -1);
				console.log(path)
				// We are on a new line
				line++;
			}
		} else if(chr == '"') {
			var resultString = '';
			i++;

			while(i < data.length) {
				chr = data.charAt(i);
				if(chr == '"') break;

				if(chr == '\n') {
					// We moved onto the next line
					line++;
					if(data.charAt(i+1) == '\r') i++;
				} else if(chr == '\r') {
					// We moved onto the next line
					line++;
					if(data.charAt(i+1) == '\n') i++;
				} else if(chr == '\\') {
					i++;
					// Gran the mext cjaracter
					chr = data.charAt(i);

					// Check for escaped characters
					switch(chr) {
						case '\\':chr = '\\'; break;
						case '"': chr = '"'; break;
						case '\'': chr = '\''; break;
						case 'n': chr = '\n'; break;
						case 'r': chr = '\r'; break;
						default:
							chr = '\\';
							i--;
						break;
					}
				}

				resultString += chr;
				i++;
			}

			if (i == data.length || chr == '\n' || chr == '\r') throw new Error("Unterminated string at line " + line);

			if(treeType[treeType.length - 1] == TYPE_BLOCK){
				if (keys[keys.length - 1] == null) {
					keys[keys.length - 1] = resultString;
				}else {
					if(tree[tree.length - 1][keys[keys.length - 1]] == null) {
						tree[tree.length - 1][keys[keys.length - 1]] = [];
					}
					tree[tree.length - 1][keys[keys.length - 1]].push(resultString);
					keys[keys.length - 1] = null;
				}
			}

			// Check if we need to reparse the character that ended this string
			if(chr != '"') --i;
		} else if(chr == '{') {
			if(treeType[treeType.length - 1] == TYPE_BLOCK){
				if (keys[keys.length - 1] == null) {
					throw new Error("A block needs a key at line " + line + " (offset " + i + ")");
				}
			}

			tree.push({});
			treeType.push(TYPE_BLOCK);
			keys.push(null);
		} else if (chr == '}') {
			if (tree.length == 1) {
				throw new Error("Mismatching bracket at line " + line + " (offset " + i + ")");
			}
			if (treeType.pop() != TYPE_BLOCK) {
				throw new Error("Mismatching brackets at line " + line + " (offset " + i + ")");
			}
			keys.pop();
			var obj = tree.pop();

			if(treeType[treeType.length - 1] == TYPE_BLOCK){
				tree[tree.length - 1][keys[keys.length - 1]] = obj;
				keys[keys.length - 1] = null;
			}else {
				tree[tree.length - 1].push(obj);
			}
		} else {
			console.log("Unexpected character \"" + chr + "\" at line " + line + " (offset " + i + ")");

			// Skip to next line
			while(++i < data.length) {
				chr = data.charAt(i);

				// Check for new line
				if(chr == '\n') {
					if(data.charAt(i+1) == '\r') ++i;
					break;
				}
				if(chr == '\r') {
					if(data.charAt(i+1) == '\n') ++i;
					break;
				}
			}

			// We are on a new line
			line++;

			// Move onto the next char
			i++;
		}

		i++;
	}

	if (tree.length != 1) {
		throw new Error("Missing brackets");
	}

	return tree[0];
}

function stringify(obj, kvIndentLength, pretty) {
	if (typeof obj != "object") {
		throw new TypeError("VDF.stringify: First input parameter is not an object");
	}

	pretty = (typeof pretty == "boolean" && pretty) ? true : false;

	return _dump(obj, pretty, 0, kvIndentLength);
}

function _dump(obj, pretty, level, kvIndentLength) {
	if (typeof obj != "object") {
		throw new TypeError("VDF.stringify: a key has value of type other than string or object");
	}

	var indent = "    ";//"\t";
	var buf = "";
	var line_indent = "";
	var newline = pretty ? "\n" : ""

	if (pretty) {
		for (var i = 0; i < level; i++) {
			line_indent += indent;
		}
	}

	for (key in obj) {
		if (typeof obj[key] == "object" && !(obj[key] instanceof Array)) {
			buf += [line_indent, '"', key, '"', newline, line_indent, '{', newline, _dump(obj[key], pretty, level + 1, kvIndentLength), line_indent, "}", newline].join('');
		} else {
			var s = line_indent + '"' + key + '"'
			var kvindent = ""
			if (pretty) {
				while (s.length + (line_indent + kvindent).length /** 4*/ < kvIndentLength) {
					kvindent += " " //indent;
				}
			}
			if (obj[key] instanceof Array) {
				buf += [s, kvindent, '"', String(obj[key][0]), '"', newline].join('');
			} else {
				buf += [s, kvindent, '"', String(obj[key]), '"', newline].join('');
			}
		}
	}

	return buf;
}

exports.parse = parse;
exports.stringify = stringify;
exports.dump = stringify;