module labour::AST
import util::Maybe;

/*
 * Define the Abstract Syntax for LaBouR
 * - Hint: make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */

data BoulderingWall
  = boulderingWall(str name, list[Volume] volumes, list[BoulderingRoute] routes);

data Volume 
  = circle(Pos pos, int depth, int radius)
  | rectangle(Pos pos, int depth, int width, int height, list[Hold] holds)
  | polygon(Pos pos, list[Face] faces);

data Pos
  = pos(int x, int y);

data Face
  = face(list[Vertex] vertices, list[Hold] holds);

data Vertex
  = vertex(int x, int y, int z);

data HoldType 
  = startHold(int startNum) 
  | endHold();

data Hold 
  = hold(str id, Pos pos, str shape, list[str] colours, Maybe[HoldType] holdType, Maybe[int] rotation);

data BoulderingRoute 
  = boulderingRoute(str grade, Pos grid_base_point, str id, list[str] holds);
