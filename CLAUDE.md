# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains **macro.cnc**, a professional CNC macro file for Sorotec CNC machines with Eding CNC 5.3 control system. The macro provides comprehensive functionality for tool measurement, zero-point setting, probing operations, and automated workflows.

**Target Machine:** Sorotec Aluline AL1110 with 2kW spindle (24,000 RPM)
**Control System:** Eding CNC 5.3
**Language:** German (comments, dialogs, messages)

## Architecture

### Core Structure

The macro is organized into distinct sections:

1. **Header & Documentation** (Lines 1-210)
   - Unit declaration (`;@unit mm` - MUST be on line 1)
   - Version history
   - Variable documentation
   - Initialization routine

2. **User Subroutines** (Lines 211-2100+)
   - `user_1` through `user_12`: Main user-facing functions
   - Each subroutine is self-contained with full documentation
   - Follows naming convention: `SUB user_N` / `ENDSUB`

3. **Internal Subroutines** (Lines 2100+)
   - `change_tool`: Tool change automation
   - `home_*`: Homing routines
   - `check_sensor_connected`: Safety checks
   - `xhc_*`: Handwheel pendant integration

### Variable System

Eding CNC uses a numbered variable system:

- **#3500-#3510**: System flags (init status, tool measured, etc.)
- **#4400-#4699**: Configuration parameters (sensor types, positions, speeds)
- **#1000-#1199**: Measurement storage
- **#2000-#2199**: Calculation temporary storage
- **#5000+**: Eding CNC system variables (read-only or special purpose)

**Critical variables:**
- `#4546`: 3D probe ball radius (ESSENTIAL for accuracy)
- `#4400`: Tool length sensor type (0=NC, 1=NO)
- `#4544`: 3D probe sensor type (0=NC, 1=NO)

## Eding CNC 5.3 Syntax Rules

### CRITICAL SYNTAX REQUIREMENTS

1. **Unit Declaration**
   - MUST be first line: `;@unit mm` or `;@unit in`
   - Without this: G1290 "Macro does not specify unit" error

2. **Feed Rate Syntax**
   - Feed rate MUST be directly on movement command: `G38.2 X10 F[#4548]`
   - NEVER use isolated F commands: `F[#4549]` alone will cause G1516 error
   - G0 (rapid) commands must NOT have F parameter

3. **Boolean Expressions**
   - AND/OR operators must be INSIDE outer brackets
   - CORRECT: `IF [[#var1 == 1] AND [#var2 == 2]] THEN`
   - WRONG: `IF [#var1 == 1] AND [#var2 == 2] THEN`
   - Range validation: Use OR, not AND
     - CORRECT: `IF [[#var < 0] OR [#var > 1]] THEN` (invalid if outside 0-1)
     - WRONG: `IF [[#var != 0] AND [#var != 1]] THEN` (logically impossible)

4. **Control Structure Balance**
   - Every `IF` needs `ENDIF`
   - Every `SUB` needs `ENDSUB`
   - Every `WHILE` needs `ENDWHILE`

5. **Comments**
   - Semicolon for line comments: `; This is a comment`
   - Cannot use block comments like `/* */`

### Common Error Codes

- **G1290**: Missing unit declaration (`;@unit mm`)
- **G1516**: Incorrect feed rate (isolated F command or missing feed rate)
- **G1171**: Boolean expression syntax error (bracket mismatch)

## Development Guidelines

### Making Changes

1. **Always read the file first** before editing
   - The file is 2500+ lines, use offset/limit parameters

2. **Preserve German language**
   - All comments, messages, and dialogs are in German
   - Variable names use German abbreviations
   - Keep this convention for consistency

3. **Test syntax mentally**
   - Eding CNC has strict syntax requirements
   - Count brackets in boolean expressions
   - Verify feed rates are on movement commands
   - Check IF/ENDIF balance

4. **Update version history**
   - When making significant changes, bump version (currently V3.3)
   - Add entry to VERSIONSHISTORIE section
   - Update version in header comment

5. **Variable usage**
   - Check documentation before using new variables
   - Ranges #1200-#1299 and #2200-#2299 are available
   - System variables #5000+ are managed by Eding CNC

### User Subroutines Overview

| Function | Purpose | Key Features |
|----------|---------|--------------|
| user_1 | Tool length measurement | Safety checks, positive length validation |
| user_2 | Z zero point setting | Uses probe height compensation |
| user_3 | Spindle warm-up | Multi-stage RPM ramp |
| user_4 | Tool change | Calls change_tool internal routine |
| user_5 | Single edge probing | X+/X-/Y+/Y- with ball radius compensation |
| user_6 | Corner probing | 2 edges + rotation calculation |
| user_7 | Hole center probing | 4-point measurement |
| user_8 | Boss/cylinder probing | External 4-point measurement |
| user_9 | Tool breakage detection | Compares current vs. stored length |
| user_10 | Rectangle measurement | 4 edges + dimensional accuracy check |
| user_11 | Workpiece thickness | Top + bottom surface measurement |
| user_12 | Coordinate system manager | G54-G59 storage and activation |

### Probing Operations

All probing functions use:
- **G38.2**: Probe toward with stop on contact
- **Two-stage approach**: Fast search + slow measurement
- **Ball radius compensation**: Automatically applied (#4546)
- **Safety checks**: Sensor state validation before movement

### Configuration System

The `config` subroutine (user_0 or called via `gosub config` in MDI):
- Initializes all parameters on first run (#3500 flag)
- Sets default values if variables are zero
- Uses multiple dialog pages (DlgMsg) for user input
- ONLY callable from MDI mode (not from programs)

## Git Workflow

### Commit Messages

Follow this format:
```
Update to VX.X: Brief title

BUGFIXES:
- List specific bugs fixed

CHANGES/ENHANCEMENTS:
- List functional changes

DOCUMENTATION:
- List doc updates
```

### Important Notes

- Always commit with both macro.cnc AND updated README.md if user-facing changes
- Update version number in macro header when releasing
- Create CHANGELOG_VX.X.md for major versions (3.2, 3.3, etc.)

## Testing Approach

Since this is CNC machine control code:

1. **Syntax validation**: Check against Eding CNC 5.3 rules
2. **Logic validation**: Trace through code paths mentally
3. **Safety validation**: Ensure all sensor checks are present
4. **Variable validation**: Verify variable ranges and initialization

**DO NOT** suggest running the macro without:
- Proper machine setup
- Sensor calibration
- Safety checks
- User understanding of the operations

## Special Considerations

### 3D Probe Ball Radius (#4546)

This is THE most critical parameter. Affects all probing operations:
- user_5, user_6, user_7, user_8, user_10, user_11
- Must be measured accurately (e.g., 1.5mm for 3mm ball)
- Compensation is automatic but only correct if #4546 is right

### Sensor Types

Two sensor types are used:
- **Tool length sensor**: Fixed position (X=#4507, Y=#4508, Z=#4509)
- **3D probe/Z-probe**: Mobile, attached to spindle as tool #98 or #99

Each has a type parameter (0=NC opener, 1=NO closer).

### Coordinate Systems

- Eding CNC supports G54-G59 (6 work coordinate systems)
- Stored in #5221-#5276 (10 variables per system: 6 axes + unused)
- user_12 provides friendly interface to these

## Common Tasks

### Fix Syntax Error

1. Identify error line from Eding CNC error message
2. Read that section of macro.cnc with offset/limit
3. Check against syntax rules above
4. Fix and test logic
5. Commit with clear description

### Add New User Function

1. Choose next available user_N number
2. Add SUB/ENDSUB block after existing functions
3. Follow documentation template (see existing functions)
4. Assign variables from available ranges
5. Update README.md with new function description
6. Update version history

### Modify Existing Function

1. Read entire function first (typically 50-200 lines)
2. Understand variable usage within function
3. Make minimal changes to preserve tested logic
4. Update function header documentation if behavior changes
5. Test mentally for edge cases

## Resources

- **Eding CNC Documentation**: https://www.eding.de (official docs for G-code syntax)
- **Sorotec Forum**: https://forum.sorotec.de (community support)
- **README.md**: Full user documentation for all functions
- **Macro header comments**: Lines 1-210 contain complete variable documentation

## Anti-Patterns (DO NOT DO)

❌ Don't use isolated F commands: `F[#4549]`
❌ Don't use AND for range validation: `IF [[#var != 0] AND [#var != 1]]`
❌ Don't add feed rates to G0: `G0 X10 F100`
❌ Don't forget unit declaration on line 1
❌ Don't use English in comments/messages (keep German)
❌ Don't modify system variables #5000+ (read-only)
❌ Don't skip sensor safety checks
❌ Don't create functions without full documentation

## Version History Quick Reference

- **V3.3** (current): Fixed G1516 feedrate errors, removed Z-probing from user_5
- **V3.2**: Fixed G1516 by initializing #4548/#4549, added Z-probing to user_5
- **V3.1**: Added user_10, user_11, user_12 (advanced measurement functions)
- **V3.0**: Major refactor with improved safety and documentation
- **V2.x**: Original Sorotec-based macro

When in doubt, consult the macro's own documentation (lines 1-210) - it's comprehensive and accurate.
