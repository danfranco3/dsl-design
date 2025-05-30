module labour::Syntax

/*
 * Define a concrete syntax for LaBouR. The language's specification is available in the PDF (Section 2)
 */

/*
 * Note, the Server expects the language base to be called BoulderingWall.
 * You are free to change this name, but if you do so, make sure to change everywhere else to make sure the
 * plugin works accordingly.
 */


/*
 * Definition of the **concrete syntax** for the LaBouR DSL. It uses *syntax declarations*
 * and *lexical rules* with regular expressions to precisely specify the structure of valid
 * LaBouR programs. The language models bouldering walls, including their volumes, routes,
 * holds, and properties.
 *
 * The syntax includes a variety of shape types, each with configurable properties. It also
 * supports nested constructs for describing complex features like faces, positions, and
 * route specifications.
 *
 * This grammar serves as the foundation for parsing and interpreting LaBouR programs.
 * Multiple example programs are implemented to test and validate this syntax definition.
 */

layout Whitespace = [\t-\n\r\ ]*;     

lexical Comment = ^"#" ![\n]* $;

start syntax BoulderingWall
    = boulder: "bouldering_wall" Label name "{" "volumes" "[" {Volume ","}+ "]" "," "routes" "[" {Route ","}+ "]" "}";

lexical Label
    = "\""[a-zA-Z0-9_]+ "\"";

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


lexical ShapeProp = "\"" Int "\"";

syntax Props
    = prop: "depth:" Int
    | "radius:" Int
    | "width:" Int
    | "height:" Int
    | "faces" "[" {Face ","}+ "]"
    | "pos" "{" Coord "," Coord "}"
    | "holds" "[" {Hold ","}+ "]"
    | "start_hold:" StartHoldValue
    | "shape:" ShapeProp
    | "rotation:" Int
    | "colours" "[" {Colour ","}+ "]"
    | "end_hold";

syntax Face
    = "face" "{" {FaceProps ","}+ "}";

syntax FaceProps
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
 = route: "bouldering_route" String id "{" {RouteProps ","}+ "}";

syntax RouteProps
    = "grade:" String g
    | "grid_base_point" "{" Coord "," Coord "}"
    | "holds" "[" {HoldID ","}+ "]";

lexical Int = [\-]? [0-9]+;
lexical String = "\"" ![\"]+ "\"";