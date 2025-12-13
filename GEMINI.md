# GEMINI.md

## Directory Overview

This directory contains resources for working with a SOROTEC CNC machine running on EDING CNC 5.3. It includes the main macro file (`macro.cnc`), a syntax summary, and the official user manual. The primary goal is the development, maintenance, and continuous improvement of the `macro.cnc` file.

## Key Files

*   **`macro.cnc`**: The central macro file containing various subroutines for automated CNC tasks like tool measurement, probing, and tool changes. It is written in the EDING CNC G-code dialect.
*   **`Eding_Syntax_Zusammenfassung.md`**: A detailed markdown document summarizing the key syntax, commands, variables, and best practices for the EDING CNC language. This is the primary reference for development.
*   **`Eding_Handbuch.pdf`**: The official and comprehensive user manual for the EDING CNC software. It serves as the ultimate source of truth for all functionalities.

## Recent Changes and Improvements

*   **Simulation Safety Checks**: Implemented critical safety checks for `G38.2` probing commands across multiple subroutines (`user_5` through `user_11`). These checks now ensure that probing operations are only executed when the CNC machine is not in simulation (`#5380 == 0`) or render mode (`#5397 == 0`), preventing unexpected behavior and potential errors during G-code simulation.
*   **Dialog Message String Length Fixes**: Addressed "Unnamed string too long" errors by shortening the message strings in `DlgMsg` commands (specifically in `user_5`). This ensures compatibility with the CNC controller's string length limitations for dialog messages.

## Usage

*   To understand the functionality, start by reading `Eding_Syntax_Zusammenfassung.md` for a quick overview, then `macro.cnc` to see the implementation.
*   For in-depth questions or details on specific G/M-codes, refer to the `Eding_Handbuch.pdf`.
*   When modifying `macro.cnc`, adhere to the existing coding style, variable naming, and commenting conventions. Always consult the syntax summary to avoid common errors, and ensure that any new probing logic includes the necessary simulation safety checks.