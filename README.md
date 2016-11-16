# Ken's Rather Useless Symbolic Assembly Development Environment for the Replica 1
_(c) 2009 Ken Wessen_

> Taken from http://school.anhb.uwa.edu.au/personalpages/kwessen/apple1/Krusader.htm Unclear what the exact license is.

KRUSADER is a program written to allow assembly language development on the Replica 1 -- an Apple 1 clone designed by Vince Briel, and described in the book Apple 1 Replica Creation: Back to the Garage by Tom Owad.

KRUSADER includes a simple shell and editor, a single-pass symbolic assembler, a disassembler, and an interactive debugger, and fits in just under 4K (so it is small enough to fit in the 8K of Replica 1 ROM along with the monitor and Apple BASIC). Although designed for the Replica 1/Apple 1, there is very little system dependent code, and since full source code is provided, KRUSADER can easily be adapted to any other 6502 based system. However, its limitations may mean it is not an appropriate tool in many cases (for example, it has no concept of a file-system and so would not be particularly suitable for use on an Apple II).

KRUSADER can assemble for either the 6502 or the 65C02, and handles a fairly standard and expressive syntax for its assembly source code. For users who are unfamiliar with the 6502 instruction set, I recommend this introduction by Andrew John Jacobs. On a Replica 1, KRUSADER can assemble over 200 lines of code per second, and given its 32K or RAM, the defaults provide space for up to 20K of tokenised source code, 8K of generated code, and up to 256 global symbols.




