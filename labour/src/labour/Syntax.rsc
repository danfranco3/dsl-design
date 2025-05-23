module labour::Syntax

/*
 * Define a concrete syntax for LaBouR. The language's specification is available in the PDF (Section 2)
 */

/*
 * Note, the Server expects the language base to be called BoulderingWall.
 * You are free to change this name, but if you do so, make sure to change everywhere else to make sure the
 * plugin works accordingly.
 */

layout Whitespace = [\t-\n\r\ ]*;     

start syntax BoulderingWall
    = boulder: "bouldering_wall" Label "{" "volumes" "[" {Volume ","}+ "]" "," "routes" "[" {Route ","}+ "]" "}";

lexical LabelLex
    = "\""[a-zA-Z0-9_]+ "\"";

syntax Label = name: LabelLex;

syntax Volume
    = vol: "circle" Circle
    | "rectangle" Rectangle
    | "polygon" Polygon ;

syntax Circle 
    = circ: "{" {Props ","}+ "}";

syntax Rectangle
    = rect: "{" {Props ","}+ "}";

syntax Polygon
    = pol: "{" {Props ","}+ "}";

syntax Coord
    = coord: "x:" Int
    | "y:" Int
    | "z:" Int;

syntax Props
    = prop: "depth:" Int
    | "radius:" Int
    | "width:" Int
    | "height:" Int
    | "faces:" "[" {Faces ","}+ "]"
    | "pos" "{" Coord "," Coord "}"
    | "holds" "[" {Hold ","}+ "]"
    | "start_hold:" StartHoldValue
    | "shape:" "\"" Int "\""
    | "rotation:" Int
    | "colours" "[" {Colour ","}+ "]"
    | "end_hold";

syntax Faces
    = face: "face" "{" Face "}";

syntax Face
    = "vertices" "[" {Vertices ","}+ "]"
    | "holds" "[" {Hold ","}+ "]";

syntax Vertices
    = vertex: "{" Coord "," Coord "," Coord "}";

lexical StartHoldValue = [1-2];

lexical Colour = "white" | "yellow" | "green" | "blue" | "red" | "purple" | "pink" | "black" | "orange";

lexical HoldID = "\"" [0-9][0-9][0-9][0-9] "\"";

syntax Hold
    = hold: "hold" HoldID "{" {Props ","}+ "}";

syntax Route
 = route: "bouldering_route" String "{" {RouteProps ","}+ "}";

syntax RouteProps
    = routeprop: "grade:" String
    | "grid_base_point" "{" Coord "," Coord "}"
    | "holds" "[" {HoldID ","}+ "]";

lexical Int = [\-]? [0-9]+;
lexical String = "\"" ![\"]* "\"";