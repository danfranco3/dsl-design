module labour::Syntax

/*
 * Define a concrete syntax for LaBouR. The language's specification is available in the PDF (Section 2)
 */

/*
 * Note, the Server expects the language base to be called BoulderingWall.
 * You are free to change this name, but if you do so, make sure to change everywhere else to make sure the
 * plugin works accordingly.
 */

start syntax BoulderingWall
    = "bouldering_wall" Label "{" "volumes" "[" {Volume ","}+ "]" "," "routes" "[" {Route ","}+ "]" "}";

lexical Label
    = [a-zA-Z0-9_]+;

syntax Volume
    = "circle" Circle
    | "rectangle" Rectangle
    | "polygon" Polygon ;

syntax Circle 
    = "{" {Props ","}+ "}";

syntax Rectangle
    = "{" {Props ","}+ "}";

syntax Polygon
    = "{" {Props ","}+ "}";

syntax Coord
    = "x:" Int
    | "y:" Int
    | "z:" Int;

syntax Props
    = "depth:" Int
    | "radius:" Int
    | "width:" Int
    | "faces:" "[" {Faces ","}+ "]"
    | "pos" "{" Coord "," Coord "}"
    | "holds" "[" {Hold ","}+ "]";

syntax Faces
    = "face" "{" Face "}";

syntax Face
    = "vertices" "[" {Vertices ","}+ "]"
    | "holds" "[" {Hold ","}+ "]";

syntax Vertices
    = "{" Coord "," Coord "," Coord "}";

lexical StartHoldValue = [1-2];

syntax HoldProps
    = "start_hold:" StartHoldValue
    | "pos" "{" Coord "," Coord "}"
    | "shape:" Int
    | "rotation:" Int
    | "colours" "[" {Colour ","}+ "]"
    | "end_hold";

lexical Colour = "white" | "yellow" | "green" | "blue" | "red" | "purple" | "pink" | "black" | "orange";

lexical HoldID = "\" "[0-9][0-9][0-9][0-9] "\"";

syntax Hold
    = HoldID "{" HoldProps "}";

syntax Route
 = "bouldering_route" String "{" {RouteProps ","}+ "}";

syntax RouteProps
    = "grade:" String
    | "grid_base_point" "{" Coord "," Coord "}"
    | "holds" "[" {HoldID ","}+ "]";

lexical Int = [\-]? [0-9]+;
lexical String = "\"" ![\"]* "\"";