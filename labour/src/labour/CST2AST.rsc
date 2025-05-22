module labour::CST2AST

// This provides println which can be handy during debugging.
import IO;

// These provide useful functions such as toInt, keep those in mind.
import Prelude;
import String;

import labour::AST;
import labour::Syntax;
import util::Maybe;


/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 * Hint: Use switch to do case distinction with concrete patterns
 * Map regular CST arguments (e.g., *, +, ?) to lists
 * Map lexical nodes to Rascal primitive types (bool, int, str)
 */

BoulderingWall cst2ast(start[BoulderingWall] b){
    return load(b.top);
}

BoulderingWall load((BoulderingWall)`boulderingWall <Label name> {<{Volume ","}+ vol>} {<{Route ","}+ route>}`) {
	return boulderingWall("<name>", [loadVolume(v) | v <- vol],  [loadRoute(r) | r <- route]);
}

Volume loadVolume(Volume v) {
	switch (v) {
		case (Volume) `circle { <{Props ","}+ props> }`:{
      list[Props] propsList = [p | p <- props];
			return circle(
				extractPos(propsList),
				extractIntProp("depth", propsList),
				extractIntProp("radius", propsList)
			);
    }

		case (Volume) `rectangle { <{Props ","}+ props> }`:{
      list[Props] propsList = [p | p <- props];
			return rectangle(
				extractPos(propsList),
				extractIntProp("depth", propsList),
				extractIntProp("width", propsList),
				extractIntProp("height", propsList),
				extractHoldList(propsList)
			);
    }

		case (Volume) `polygon { <{Props ","}+ props> }`:{
      list[Props] propsList = [p | p <- props];
			return polygon(
				extractPos(propsList),
				extractFaceList(propsList)
			);
    }

		default: throw "Unknown volume type";
	}
}

int extractIntProp(str label, list[Props] props) {
    for (p <- props) {
        switch (p) {
            case (Props) `depth: <Int i>`: 
                if (label == "depth") return toInt("<i>");
            case (Props) `radius: <Int i>`:
                if (label == "radius") return toInt("<i>");
            case (Props) `width: <Int i>`:
                if (label == "width") return toInt("<i>");
            case (Props) `height: <Int i>`:
                if (label == "height") return toInt("<i>");
        }
    }
    throw "Missing property <label>";
}


Pos extractPos(list[Props] props) {
	for (p <- props) {
		switch (p) {
			case (Props) `pos { x: <Int x>, y: <Int y> }`:
				return pos(toInt("<x>"), toInt("<y>"));
		}
	}
	throw "Missing pos";
}

list[Hold] extractHoldList(list[Props] props) {
	for (p <- props) {
		switch (p) {
			case (Props) `holds [ <{Hold ","}+ holds> ]`:
				return [loadHold(h) | h <- holds];
		}
	}
	return []; // optional
}

list[Face] extractFaceList(list[Props] props) {
	for (p <- props) {
		switch (p) {
			case (Props) `faces: [ <{Faces ","}+ faces> ]`:
				return [loadFace(f) | f <- faces];
		}
	}
	return [];
}

Hold loadHold(Hold h) {
	switch (h) {
		case (Hold) `hold <HoldID id> { <{HoldProps ","}+ props> }`:{
      list[HoldProps] propsList = [p | p <- props];
			return hold(
				unquote(id),
				extractHoldPos(propsList),
				extractHoldShape(propsList),
				extractHoldColours(propsList),
        nothing(), // holdtype???
				extractHoldRotation(propsList)
			);
    }
	}
	throw "Invalid hold";
}

Face loadFace(Faces f) {
	switch (f) {
		case (Faces) `face { <Face inner> }`:
			switch (inner) {
				case (Face) `vertices [ <{Vertices ","}+ verts> ]`:
					return face([loadVertex(v) | v <- verts], []);
				case (Face) `holds [ <{Hold ","}+ holds> ]`:
					return face([], [loadHold(h) | h <- holds]);
			}
	}
	throw "Invalid face";
}

Vertex loadVertex(Vertices v) {
	switch (v) {
		case (Vertices) `{ x: <Int x>, y: <Int y>, z: <Int z> }`:
			return vertex(toInt("<x>"), toInt("<y>"), toInt("<z>"));
	}
	throw "Invalid vertex";
}

Pos extractHoldPos(list[HoldProps] props) {
	for (p <- props) {
		switch (p) {
			case (HoldProps) `pos { x: <Int x>, y: <Int y> }`:
				return pos(toInt("<x>"), toInt("<y>"));
		}
	}
	throw "Missing hold position";
}

str extractHoldShape(list[HoldProps] props) {
	for (p <- props) {
		switch (p) {
			case (HoldProps) `shape: "<Int s>"`:
				return "<s>";
		}
	}
	throw "Missing hold shape";
}

list[str] extractHoldColours(list[HoldProps] props) {
	for (p <- props) {
		switch (p) {
			case (HoldProps) `colours: [ <{Colour ","}* colours> ]`:
				return ["<c>" | c <- colours];
		}
	}
	return [];
}


Maybe[int] extractHoldRotation(list[HoldProps] props) {
    for (p <- props) {
        switch (p) {
            case (HoldProps) `rotation: <Int r>`:
                return just(toInt("<r>"));
        }
    }
    return nothing();  
}

str unquote(HoldID s) {
    str stringValue = toString(s); // Convert HoldId to str
    if ((size(stringValue) >= 2) && (stringValue[0] == "\"") && (stringValue[size(stringValue) - 1] == "\"")) {
        return substring(stringValue, 1, size(stringValue) - 1);
    }
    return stringValue;
}

Route loadRoute(Route r) {
    switch (r) {
        case (Route) `bouldering_route <String name> { <{RouteProps ","}+ props> }`: {
            str routeName = unquoteString(toString(name));
            list[RouteProps] propsList = [p | p <- props];

            str grade = extractRouteGrade(propsList);
            Pos gridBase = extractGridBasePoint(propsList);
            list[str] holds = extractRouteHolds(propsList);

            return route(grade, gridBase, routeName, holds);
        }
    }
    throw "Invalid route";
}

str extractRouteGrade(list[RouteProps] props) {
    for (p <- props) {
        switch (p) {
            case (RouteProps) `grade: <String g>`:
                return unquoteString(toString(g));
        }
    }
    throw "Missing route grade";
}

Pos extractGridBasePoint(list[RouteProps] props) {
    for (p <- props) {
        switch (p) {
            case (RouteProps) `grid_base_point { x: <Int x>, y: <Int y> }`:
                return pos(toInt("<x>"), toInt("<y>"));
        }
    }
    throw "Missing grid base point";
}

list[str] extractRouteHolds(list[RouteProps] props) {
    for (p <- props) {
        switch (p) {
            case (RouteProps) `holds [ <{HoldID ","}+ holds> ]`:
                return [unquoteString(toString(h)) | h <- holds];
        }
    }
    return []; 
}

str unquoteString(str s) {
    if (size(s) >= 2 && s[0] == "\"" && s[size(s) - 1] == "\"") {
        return substring(s, 1, size(s) - 1);
    }
    return s;
}
