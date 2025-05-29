# Incorrect Examples

For the incorrect examples, we decided to check for every property that is syntactically valid but semantically incorrect. The examples below follow the files: 1 pertains to file `example1.labour`, and so on.

## 1. Every Route Must Have At Least Two Holds

**Description:**  
Each bouldering route must reference at least two distinct holds from the volumes on the wall. This ensures a meaningful climbing path.

**Violation Example:**  
A route listing only one hold in its `holds` array will parse correctly but is semantically invalid because the route cannot form a climb with a single hold.

---

## 2. A Route Can Have At Most Two Start Holds

**Description:**  
No more than two holds on a route should be marked as start holds (`start_hold` property). This restricts the starting complexity and follows typical climbing route conventions.

**Violation Example:**  
If more than two holds are marked as `start_hold` within the route’s volume holds, the program is incorrect.

---

## 3. Each Route Must Include Grade, Grid Base Point, and an ID

**Description:**  
Every route must specify:
- A `grade` (difficulty rating)
- A `grid_base_point` (origin point for hold grid referencing)
- A unique identifier (name)

**Violation Detail:**
While the syntax allows some of these to be omitted individually, semantic validation requires all three to be present for a well-defined route. We chose to leave out the grade in this case.

---

## 4. Each Route Can Have At Most One End Hold

**Description:**  
Only one hold per route should be marked as the `end_hold`, defining the finish of the climb.

**Violation Example:**  
Multiple holds marked as `end_hold` in the volumes referenced by a single route are syntactically allowed but semantically invalid.

---

## 5. Holds Referenced by a Route Must Share At Least One Colour

**Description:**  
All holds listed in a route’s `holds` array must have at least one colour in common. This maintains visual consistency and climbing logic.

**Violation Example:**  
Holds of completely different colours referenced by the same route parse correctly but violate this semantic rule.

---

## 6. Holds Must Contain Position, Shape, and Colour Properties

**Description:**  
Every hold must have:
- A `pos` (position with x and y coordinates)
- A `shape` (numeric identifier as a string)
- A `colours` list (containing valid colours)

**Violation Example:**
Missing any of these properties will not break parsing but results in invalid hold definitions. We decided to leave shape out of one of the holds' definition.

## 7. Rotation must be between 0 and 359

**Description:**  
Rotation parameter of a hold must be between 0 and 359.

**Violation Example:**
We decided to try with 400 to verify the property is checked.

## 8. Three Vertices Violation

**Description:**  
Each face of a polygon must have exactly three vertices.

**Violation Example:**
The face of the polygon has 2.

## 9. Also Three Vertices Violation

**Description:**  
Each face of a polygon must have exactly three vertices.

**Violation Example:**
The face of the polygon has 4.


