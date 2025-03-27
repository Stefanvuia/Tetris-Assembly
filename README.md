🧱 Tetris in MIPS Assembly
CSC258H1F Winter 2024 — Final Project
Authors: Stefan Vuia (1009041920), Mikhail Skazhenyuk (1009376337)

📜 Project Overview
This project is an implementation of the classic game Tetris, written entirely in MIPS Assembly for the bitmap display and keyboard I/O provided by the CSC258 course simulator.

We developed a functioning Tetris game engine including rendering, movement, rotation, collision detection, line clearing, and a Tetris theme melody.

🖥️ Display Configuration
Display Width: 512 pixels

Display Height: 512 pixels

Pixel Unit Size: 16×16

Display Memory Base Address: 0x10008000 ($gp)

Keyboard Input Address: 0xFFFF0000

🎮 Features
Tetromino Types: T, O, I, S, Z, L, J

Rotations: Each tetromino rotates with logic specific to its shape

Collision Detection: For downward, leftward, and rightward movement

Line Clearing: Full lines are removed and higher blocks shift down

Pause Functionality: Press P to pause, press again to resume

Game Over Detection: When new pieces can’t spawn, the game ends

Tetris Theme Music: Plays alongside gameplay via system call 31

🎮 Controls
Key	Action
A	Move Left
D	Move Right
S	Move Down
W	Rotate Piece
P	Pause / Unpause
Q	Quit Game
R	Restart (after game over)
🧠 Implementation Highlights
Modular Macros: Drawing, rotation, movement, collision detection, and rendering are abstracted into macros.

Memory Stack Use: Tetromino positions are stored on the stack to enable transformation and manipulation.

Color Management: colour_array stores tetromino colors; background, border, and inactive grid are rendered with grayscale.

Random Piece Generation: Uses syscall 42 with an upper bound of 7 to spawn one of the 7 tetromino shapes.

Music System: Sound plays based on a pre-defined array of notes (Tetris_theme) with pauses in between.

📁 Files
tetris.asm: Complete implementation of Tetris in MIPS Assembly (provided above)

README.md: This file

✅ Requirements
Run using the MIPS simulator provided in CSC258 (Mars or QtSpim with bitmap & keyboard memory-mapped I/O extensions)

Ensure display and keyboard are connected to the correct base addresses

🚀 How to Run
Open the file in MARS or QtSpim with bitmap display and keyboard support

Load and assemble the code

Run the program

Control the tetrominoes using the keyboard as described above

📌 Notes
Ensure you don't move a tetromino into invalid positions; collisions are handled but misaligned logic may cause visual glitches.

Game resets automatically after each loss if R is pressed.

All stack offsets and data structures are manually managed — use caution when extending functionality.

📚 Acknowledgements
Thanks to Professor [Your Instructor's Name] and the CSC258 team for support and resources.

Let me know if you'd like it in .md file format or if you want to add screenshots, a GIF, or extra explanations of specific macros.
