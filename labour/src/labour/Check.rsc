module labour::Check

import labour::AST;
import labour::Parser;
import labour::CST2AST;

import IO;
import List;
import Set;
import Prelude;
import String;


/*
 * Implement a well-formedness checker for the LaBouR language. For this you must use the AST.
 * - Hint: Map regular CST arguments (e.g., *, +, ?) to lists
 * - Hint: Map lexical nodes to Rascal primitive types (bool, int, str)
 * - Hint: Use switch to do case distinction with concrete patterns
 */

/*
 * Define a function per each verification defined in the PDF (Section 2.2.)
 * Some examples are provided below.
 */

bool checkBoulderWallConfiguration(BoulderingWallAST wall){
  bool numberOfHolds = checkNumberOfHolds(wall);

  bool startingLabelLimit = checkStartingHoldsTotalLimit(wall);
  bool unique_end_hold = checkUniqueEndHold(wall);

  return (numberOfHolds && startingLabelLimit && unique_end_hold);
}


// Check that there are at least two holds in the wall
bool checkNumberOfHolds(BoulderingWallAST wall) {
  num_holds = 0;
  visit(wall) {
        // Count number of holds
        case hold(_, _): num_holds = num_holds + 1;
    };
  // Return true if there are at least 2 holds in the wall.
  return (num_holds >= 2);
}

// This function will insure that there is only one hold assign to end hold
// This function will ensure that there is only one hold assigned as end_hold
bool checkUniqueEndHold(BoulderingWallAST wall){
  int endHoldCount = 0;
  visit(wall) {
    case hold(_, list[PropsAST] props): {
      for (prop <- props) {
        switch(prop){
          case end_hold(): endHoldCount = endHoldCount + 1;
        }
      }
    }
  }
  return endHoldCount == 1;
}


// Every wall must have at least one volume and one route
bool checkOneVolumeOneRoute(BoulderingWallAST wall){
  int num_volume = 0;
  int num_route = 0;
  visit(wall) {
    case circle(_): num_volume += 1;
    case rectangle(_): num_volume += 1;
    case polygon(_): num_volume += 1;
    case route(_, _) : num_route = num_route + 1;
  }
  return num_volume >= 1 && num_route >= 1;
}

// Every route must have two or more holds
bool checkHoldsRoute(BoulderingWallAST wall){
  int num_holds = 0;
  visit(wall) {
    case hold(_, _): num_holds += 1;
  }
  return num_holds >= 2;
}

// Every route must have between zero and two hand start holds
bool checkHandStartHoldsRoute(BoulderingWallAST wall){
  int num_hand_starts = 0;
  visit(wall) {
    case hold(_, list[PropsAST] props):
      for (prop <- props) {
        // Match only start_hold with value 1 or 2
        switch (prop) {
          case start_hold(1): num_hand_starts += 1;
          case start_hold(2): num_hand_starts += 1;
        }
      }
  }
  return num_hand_starts >= 0 && num_hand_starts <= 2;
}

// Every route must have a grade, a grid_base_point, and an identifier.
bool checkGradeGridIdentifier(BoulderingWallAST wall) {
  bool hasGrade = false;
  bool hasGridBase = false;
  visit(wall) {
    case route(_, list[RoutePropsAST] props): {
      for (prop <- props) {
        switch (prop) {
          case grade(_): hasGrade = true;
          case grid_base_point(_, _): hasGridBase = true;
        }
      }
    }
  }
  return hasGrade && hasGridBase;
}

// The grid_base_point must have an x and a y component
bool checkXYComponent(BoulderingWallAST wall) {
  x_flag = false;
  y_flag = false;
  visit(wall) {
    case route(_, list[RoutePropsAST] props): {
      for (prop <- props) {
        switch (prop) {
          case grid_base_point(CoordinateAST xComp, CoordinateAST yComp): {
            switch (xComp) {
              case x(_): x_flag = true;
            }
            switch (yComp) {
              case y(_): y_flag = true;
            }
          }
        }
      }
    }
  }
  return x_flag && y_flag;
}

// Every route has at most one hold indicated as end_hold
bool checkEndHoldsRoute(BoulderingWallAST wall){
  int num_end_holds = 0;
  visit(wall) {
    case hold(_, list[PropsAST] props):
      for (prop <- props) {
        switch (prop) {
          case end_hold(): num_end_holds += 1;
        }
      }
  }
  return num_end_holds <= 1;
}
// Hold IDs are always defined with four digits, for example, ”0025“. The wall and route IDs can take any alphanumeric character
bool checkIDs(BoulderingWallAST wall){
  // Checked by syntax regex
  return true;
}
// The holds in a bouldering route must all have the same colour, but some holds may be
// multi-coloured (think of a plexiglas hold with some coloured pieces visible inside), in which
// case one of these colours has to match the route’s colour. The order of the colours in a
// multi-coloured hold does not matter
bool checkSameColour(BoulderingWallAST wall) {
  visit(wall) {
    case route(_, list[RoutePropsAST] routeProps): {
      list[str] holdIds = [];
      str routeColour = "";

      // Extract hold IDs from the route
      for (prop <- routeProps) {
        switch (prop) {
          case holds(list[str] ids): holdIds = ids;
        }
      }

      // Get the first hold's colour (for routeColour)
      for (id <- holdIds) {
        visit(wall) {
          case hold(str hid, list[PropsAST] props): {
            if (hid == id && routeColour == "") {
              for (p <- props) {
                switch (p) {
                  case colours(list[str] cs):
                    if (!isEmpty(cs)) {
                      routeColour = cs[0]; // take first colour
                      break;
                    }
                }
              }
            }
          }
        }
        if (routeColour != "") break;
      }

      // Check all holds match routeColour
      for (id <- holdIds) {
        bool hasMatchingColour = false;

        visit(wall) {
          case hold(str hid, list[PropsAST] props): {
            if (hid == id) {
              for (p <- props) {
                switch (p) {
                  case colours(list[str] cs):
                    if (routeColour in cs) {
                      hasMatchingColour = true;
                    }
                }
              }
            }
          }
        }
        if (!hasMatchingColour) {
          return false;
        }
      }
    }
  }

  return true;
}

// Every hold must have a position (defined by x and y), a shape, and colour. The rotation property is optional.
bool checkCompleteHold(BoulderingWallAST wall) {
  bool allComplete = true;

  visit(wall) {
    case hold(_, list[PropsAST] props): {
      bool pos_flag = false;
      bool x_flag = false;
      bool y_flag = false;
      bool shape_flag = false;
      bool colour_flag = false;

      for (prop <- props) {
        switch (prop) {
          case pos(CoordinateAST xCoord, CoordinateAST yCoord): {
            pos_flag = true;
            switch (xCoord) {
              case x(_): x_flag = true;
            }
            switch (yCoord) {
              case y(_): y_flag = true;
            }
          }
          case shape(_): shape_flag = true;
          case colours(_): colour_flag = true;
        }
      }
      if (!(pos_flag && x_flag && y_flag && shape_flag && colour_flag)) {
        allComplete = false;
      }
    }
  }
  return allComplete;
}

// If a hold has a rotation, its value must be between 0 and 359
bool checkRotation(BoulderingWallAST wall) {
  bool all_valid = true;
  visit(wall) {
    case hold(_, list[PropsAST] props): {
      for (prop <- props) {
        switch (prop) {
          case rotation(int rot): {
            if (rot < 0 || rot > 359) {
              all_valid = false;
            }
          }
        }
      }
    }
  }
  return all_valid;
}

// The colour values used must be valid. For now, we assume valid colours to be white,
// yellow, green, blue, red, purple, pink, black, and orange
bool checkCorrectColours(BoulderingWallAST wall) {
  // Checked by syntax
  return true;
}

// There are only three types of volumes: circle, rectangle, and polygon
bool checkCorrectVolume(BoulderingWallAST wall) {
  // Checked by syntax
  return true;
}

// A circular volume must have a radius, a depth and a position
bool checkCorrectCircle(BoulderingWallAST wall) {
  bool all_valid = true;

  visit(wall) {
    case circle(list[PropsAST] props): {
      bool radius_flag = false;
      bool depth_flag = false;
      bool pos_flag = false;
      bool x_flag = false;
      bool y_flag = false;

      for (prop <- props) {
        switch (prop) {
          case radius(_): radius_flag = true;
          case depth(_): depth_flag = true;
          case pos(CoordinateAST xCoord, CoordinateAST yCoord): {
            pos_flag = true;
            switch (xCoord) {
              case x(_): x_flag = true;
            }
            switch (yCoord) {
              case y(_): y_flag = true;
            }
          }
        }
      }
      if (!(radius_flag && depth_flag && pos_flag && x_flag && y_flag)) {
        all_valid = false;
      }
    }
  }
  return all_valid;
}

// A rectangular volume must have a depth, a position, a width and a height
bool checkCorrectCircle(BoulderingWallAST wall) {
  bool all_valid = true;

  visit(wall) {
    case rectangle(list[PropsAST] props): {
      bool depth_flag = false;
      bool width_flag = false;
      bool height_flag = false;
      bool pos_flag = false;
      bool x_flag = false;
      bool y_flag = false;

      for (prop <- props) {
        switch (prop) {
          case depth(_): depth_flag = true;
          case width(_): width_flag = true;
          case height(_): height_flag = true;
          case pos(CoordinateAST xCoord, CoordinateAST yCoord): {
            pos_flag = true;
            switch (xCoord) {
              case x(_): x_flag = true;
            }
            switch (yCoord) {
              case y(_): y_flag = true;
            }
          }
        }
      }
      if (!(depth_flag && width_flag && height_flag && pos_flag && x_flag && y_flag)) {
        all_valid = false;
      }
    }
  }
  return all_valid;
}

// A polygonal volume must have an array of at least one face that defines the sides of the
// volume. Each face must be composed of three points
bool checkCorrectPolygon(BoulderingWallAST wall){
  bool all_valid = true;

  visit(wall) {
    case polygon(list[PropsAST] props): {
      bool hasFaces = false;

      for (prop <- props) {
        switch (prop) {
          case faces(list[FaceAST] fs): {
            if (size(fs) >= 1) {
              hasFaces = true;

              for (face(list[VertexAST] vertices, _ ) <- fs) {
                if (size(vertices) != 3) {
                  all_valid = false;
                }
              }

            } else {
              all_valid = false;
            }
          }
        }
      }
      if (!hasFaces) {
        all_valid = false;
      }
    }
  }
  return all_valid;
}
