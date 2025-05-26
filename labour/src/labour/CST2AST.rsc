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
 * Implementation of a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 * We also try to handle a few errors to help the programmer.
 */

BoulderingWallAST cst2ast(start[BoulderingWall] b){
    return load(b.top);
}

BoulderingWallAST load((BoulderingWall) `bouldering_wall <Label label> { volumes [ <{Volume ","}+ vols> ], routes [ <{Route ","}+ routes> ] }`)
	= boulderingWall(unquoteString("<label>"), [loadVolume(v) | v <- vols],  [loadRoute(r) | r <- routes]);

BoulderingWallAST load(BoulderingWall b){
	println("<b>");
	throw "Unknown bouldering_wall definition";
}
 
VolumeAST loadVolume(Volume v) {
	switch (v) {
		case (Volume) `circle { <{Props ","}+ props> }`:{
			return circle([loadProp(p) | p <- props]);
    	}	

		case (Volume) `rectangle { <{Props ","}+ props> }`:{
			return rectangle([loadProp(p) | p <- props]);
		}

		case (Volume) `polygon { <{Props ","}+ props> }`:{
			return polygon([loadProp(p) | p <- props]);
    	}	

		default: throw "Unknown volume type";
	}
}

PropsAST loadProp(Props p){
	switch (p) {
		case (Props) `height: <Int h1>` : {
			return height(toInt("<h1>"));
		}
		case (Props) `depth: <Int d1>` : {
			return depth(toInt("<d1>"));
		}
		case (Props) `width: <Int w1>` : {
			return width(toInt("<w1>"));
		}
		case (Props) `radius: <Int r1>` : {
			return radius(toInt("<r1>"));
		}
		case (Props) `rotation: <Int r2>` : {
			return rotation(toInt("<r2>"));
		}
		case (Props) `pos { <Coord c1>, <Coord c2> }` : {
			return pos(loadCoordinate(c1), loadCoordinate(c2));
		}
		case (Props) `holds [ <{Hold ","}+ hs> ]` : {
			return holds([loadHold(h) | h <- hs]);
		}
		case (Props) `start_hold: <StartHoldValue s>` : {
			return start_hold(toInt("<s>"));
		}
		case (Props) `shape: <ShapeProp sp>` : {
			return shape(unquoteString("<sp>"));
		} 
		case (Props) `colours [ <{Colour ","}+ cs> ]` : {
			return colours(["<c>" | c <- cs]);
		}
		case (Props) `faces [ <{Face ","}+ fs> ]` : {
			return faces([loadFace(f) | f <- fs]);
		}
		case (Props) `end_hold` : {
			return end_hold();
		}
		default : throw "Unknown prop type";
	}
}

FaceAST loadFace(Face f) {
	switch (f) {
		case (Face) `face { <{FaceProps ","}+ fps> }` : {
			return face([loadFaceProps(fp) | fp <- fps]);
		}
		default : throw "Incorrect face definition";
	}
}

FacePropsAST loadFaceProps(FaceProps fp){
	switch (fp) {
		case (FaceProps) `vertices [ <{Vertices ","}+ vs> ]` : {
			return vertices([loadVertices(v) | v <- vs]);
		}
		case (FaceProps) `holds [ <{Hold ","}+ hs> ]` : {
			return face_holds([loadHold(h) | h <- hs]);
		}
		default : throw "Unknown face props";
	}
}

VertexAST loadVertices((Vertices) `{ <Coord c1> , <Coord c2> , <Coord c3> }`)
	= vertex(loadCoordinate(c1), loadCoordinate(c2), loadCoordinate(c3));

VertexAST loadVertices(Vertices vs){
	println("<vs>");
	throw "Unknown vertices definition";
}

HoldAST loadHold((Hold) `hold <HoldID id> { <{Props ","}+ ps> }`)
	= hold(unquoteString("<id>"), [loadProp(p) | p <- ps]);

HoldAST loadHold(Hold h){
	println("<h>");
	throw "Unknown hold definition";
}

CoordinateAST loadCoordinate(Coord c) {
	switch (c) {
		case (Coord) `x: <Int i>` : {
			return x(toInt("<i>"));
		}
		case (Coord) `y: <Int i>` : {
			return y(toInt("<i>"));
		}
		case (Coord) `z: <Int i>` : {
			return z(toInt("<i>"));
		}
		default: throw "Unknown coordinate type";
	}
}

RouteAST loadRoute((Route) `bouldering_route <String s> { <{RouteProps ","}+ rps> }`) {
	return route(unquoteString("<s>"), [loadRouteProp(rp) | rp <- rps]);
}

RouteAST loadRoute(Route r) {
	println(r[0]);
	throw "Unknown route definition";
}

RoutePropsAST loadRouteProp(RouteProps rp) {
	switch (rp) {
		case (RouteProps) `grade: <String g>` : {
			return grade(unquoteString("<g>"));
		}
		case (RouteProps) `grid_base_point { <Coord c1> , <Coord c2> }` : {
			return grid_base_point(loadCoordinate(c1), loadCoordinate(c2));
		}
		case (RouteProps) `holds [ <{HoldID ","}+ hs> ]` : {
			return holds([unquoteString("<h>") | h <- hs]);
		}
		default : throw "Unknown route prop";
	}
}

str unquoteString(str s) {
    if (size(s) >= 2 && s[0] == "\"" && s[size(s) - 1] == "\"") {
        return substring(s, 1, size(s) - 1);
    }
    return s;
}
