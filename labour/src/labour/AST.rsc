module labour::AST
import util::Maybe;

/*
 * Definition of the Abstract Syntax for LaBouR
 * 
 * Here we define the Abstract Syntax. We added an AST to the end of the non-terminals in order to differentiate between the CST and the AST.
 * 
 * The terminals have the same name as in the Syntax file.
 */

data BoulderingWallAST
  = boulderingWall(str name, list[VolumeAST] volumes, list[RouteAST] routes);

data VolumeAST
  = circle(list[PropsAST] props)
  | rectangle(list[PropsAST] props)
  | polygon(list[PropsAST] props);

data PropsAST
  = height(int h)
  | depth(int d)
  | radius(int r)
  | width(int w)
  | faces(list[FaceAST] fs)
  | pos(CoordinateAST x, CoordinateAST y)
  | holds(list[HoldAST] hs)
  | start_hold(int number)
  | shape(str s)
  | rotation(int rot)
  | colours(list[str] cs)
  | end_hold();

data CoordinateAST
  = x(int c)
  | y(int c)
  | z(int c);

data FacePropsAST
  = vertices(list[VertexAST] vs)
  | face_holds(list[HoldAST] hs);

data FaceAST
  = face(list[FacePropsAST]);

data VertexAST
  = vertex(CoordinateAST x, CoordinateAST y, CoordinateAST z);

data HoldAST 
  = hold(str holdId, list[PropsAST] props);

data RouteAST 
  = route(str id, list[RoutePropsAST] props);

data RoutePropsAST
  = grade(str g)
  | grid_base_point(CoordinateAST x, CoordinateAST y)
  | holds(list[str] holdIds);
