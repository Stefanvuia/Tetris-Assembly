################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Stefan Vuia 1009041920
# Student 2: Mikhail Skazhenyuk 1009376337
######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
white:
    .word 0xFFFFFF
colour_array: .word 0xDD0AB2, 0xFFFF00, 0xADD8E6, 0x00FF00, 0xFF0000, 0xFF8000, 0xFF11AA
darkgrey:
    .word 0x202020
black:
    .word 0x000000
Tetris_theme:
    .word 64, 0, 59, 60, 62, 0, 60, 59, 57, 0, 57, 60, 64, 0, 62, 60, 59, 0, 59, 60, 62, 0, 64, 0, 60, 0, 57, 0, 57, 0, 0, 0,
    0, 62, 62, 65, 69, 0, 67, 65, 64, 0, 0, 60, 64, 0, 62, 60, 59, 0, 59, 60, 62, 0, 64, 0, 60, 0, 57, 0, 57, 0, 0, 0, 0, -1

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main
.macro background
    addi $t0, $sp, -4096 #allocate space on the stack for the bitmap
    lw $t1, ADDR_DSPL  #Base address for display memory
    addi $t1, $t1, 264 #shift pointer of display
    addi $t0, $t0, 264 #shift pointer of game
    li $t3, 0 #counter 1
    li $t7, 21 #condition 1
    lw $t9, white #border colour
    lw $t4, darkgrey #next colour
    lw $t5, black #other colour
    
    loop1:
    beq $t3, $t7, EXIT1
    sw $t9, 0($t1) # colour border
    sw $t9, 0($t0) # colour border in stack
    addi $t1, $t1, 4 # move pointers
    addi $t0, $t0, 4
    li $t2, 0 #counter 2
    li $t8, 10 #condition 2
    
    loop2: # draw the game arena row
    beq $t2, $t8, EXIT2
    sw $t4, 0($t1) #colour sqaure
    sw $t4, 0($t0)
    move $t6, $t4 #swap next colour and other colour
    move $t4, $t5 
    move $t5, $t6
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    j loop2
    EXIT2:
    
    sw $t9, 0($t1)
    sw $t9, 0($t0) 
    move $t6, $t4 #swap next colour and other colour
    move $t4, $t5 
    move $t5, $t6
    addi $t1, $t1, 84
    addi $t0, $t0 84
    addi $t3, $t3, 1
    j loop1
    EXIT1:
      
    li $t2, 0
    li $t8, 12
    loop3: # draw the last row
    beq $t2, $t8, EXIT3
    sw $t9, 0($t1) #colour sqaure
    sw $t9, 0($t0)
    move $t6, $t4 #swap next colour and other colour
    move $t4, $t5 
    move $t5, $t6
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    j loop3
    EXIT3:
.end_macro

.macro reset_piece
    addi $t0, $sp, -4160
    addi $t1, $t0, 64
    
    loop:
    beq $t0, $t1, end
    sw $zero, 0($t0)
    addi $t0, $t0, 4
    j loop
    
    end:
.end_macro

.macro redraw_board
    li $t0, 0
    li $t1, 1024
    lw $t2, ADDR_DSPL
    addi $t3, $sp, -4096 
    loop:
    beq $t0, $t1, end
    lw $t4, 0($t3)
    sw $t4, 0($t2)
      
    addi $t2, $t2, 4
    addi $t3, $t3, 4
    addi $t0, $t0, 1
    j loop
    
    end:
.end_macro

.macro save_board
    li $t0, 0
    li $t1, 1024
    lw $t2, ADDR_DSPL
    addi $t3, $sp, -4096 
    loop:
    beq $t0, $t1, end
    lw $t4, 0($t2)
    sw $t4, 0($t3)
      
    addi $t2, $t2, 4
    addi $t3, $t3, 4
    addi $t0, $t0, 1
    j loop
    
    end:
.end_macro

.macro draw_tetromino
    li $t0, 0
    beq, $t0, $s7, c0
    addi, $t0, $t0, 1
    beq, $t0, $s7, c1
    addi, $t0, $t0, 1
    beq, $t0, $s7, c2
    addi, $t0, $t0, 1
    beq, $t0, $s7, c3
    addi, $t0, $t0, 1
    beq, $t0, $s7, c4
    addi, $t0, $t0, 1
    beq, $t0, $s7, c5
    addi, $t0, $t0, 1
    beq, $t0, $s7, c6

    c0:
    draw_tetromino_t
    j end
    c1:
    draw_tetromino_o
    j end
    c2:
    draw_tetromino_I
    j end
    c3:
    draw_tetromino_s
    j end
    c4:
    draw_tetromino_z
    j end
    c5:
    draw_tetromino_L
    j end
    c6:
    draw_tetromino_j
    
    end:
.end_macro

.macro draw_tetromino_t #draws the tetromino and sets its location in the stack
    lw $t1, ADDR_DSPL # Base address for display memory
    addi $sp, $sp, -4140
    addi $t1, $t1, 412 # center point
    
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    addi $t1, $t1, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -12
    addi $t1, $t1, -124
    sw $t1, 0($sp)
    addi $sp, $sp, 20
    addi $t1, $t1, 132
    sw $t1, 0($sp)
    
    addi $sp, $sp, 4136
    
    draw
.end_macro

.macro draw_tetromino_o
    lw $t1, ADDR_DSPL # Base address for display memory
    
    addi $t1, $t1, 412 # center point
    addi $sp, $sp, -4140 #center point in tetromino
    
    sw $t1, 0($sp)
    addi $t1, $t1, 4
    sw $t1, 4($sp)
    addi $t1, $t1, -128
    sw $t1, -12($sp)
    addi $t1, $t1, -4
    sw $t1, -16($sp)    
    
    addi $sp, $sp, 4140
    draw
.end_macro

.macro draw_tetromino_I

    lw $t1, ADDR_DSPL # Base address for display memory
    
    addi $t1, $t1, 284 # center point
    
    sw $t1, -4124($sp)
    addi $t1, $t1, 128
    sw $t1, -4108($sp)
    addi $t1, $t1, -256
    sw $t1, -4140($sp)
    addi $t1, $t1, -128
    sw $t1, -4156($sp)    
    
    draw
.end_macro

.macro draw_tetromino_s
    lw $t1, ADDR_DSPL # Base address for display memory
    
    addi $t1, $t1, 412 # center point
    
    sw $t1, -4140($sp)
    addi $t1, $t1, -4
    sw $t1, -4144($sp)
    addi $t1, $t1, -124
    sw $t1, -4156($sp)
    addi $t1, $t1, 4
    sw $t1, -4152($sp)    
    
    draw
.end_macro

.macro draw_tetromino_z
    lw $t1, ADDR_DSPL # Base address for display memory
    
    addi $t1, $t1, 412 # center point
    
    sw $t1, -4140($sp)
    addi $t1, $t1, 4
    sw $t1, -4136($sp)
    addi $t1, $t1, -132
    sw $t1, -4156($sp)
    addi $t1, $t1, -4
    sw $t1, -4160($sp)    
    
    draw
.end_macro

.macro draw_tetromino_L
    lw $t1, ADDR_DSPL # Base address for display memory
    
    addi $t1, $t1, 412 # center point
    
    sw $t1, -4124($sp)
    addi $t1, $t1, 4
    sw $t1, -4120($sp)
    addi $t1, $t1, -132
    sw $t1, -4140($sp)
    addi $t1, $t1, -128
    sw $t1, -4156($sp)    
    
    draw
.end_macro

.macro draw_tetromino_j
    lw $t1, ADDR_DSPL # Base address for display memory
    
    addi $t1, $t1, 412 # center point
    
    sw $t1, -4124($sp)
    addi $t1, $t1, 4
    sw $t1, -4120($sp)
    addi $t1, $t1, -128
    sw $t1, -4136($sp)
    addi $t1, $t1, -128
    sw $t1, -4152($sp)    
    
    draw
.end_macro

.macro draw
    sll $t4, $s7, 2
    la $t5, colour_array
    add $t5, $t5, $t4
    lw $t2, 0($t5)
    
    addi $t0, $sp, -4160 # tetromino
    addi $t1, $sp, -4096 # grid starts
    f1: # foor loop
    beq $t0, $t1, e1 
    lw $t3, 0($t0) #address in bitmap
    if: 
    beq $t3, $zero, end
    sw $t2, 0($t3)
    end:
    addi $t0, $t0, 4
    j f1
    e1:
    
.end_macro

.macro rotate_tetromino
    li $t0, 0
    beq, $t0, $s7, c0
    addi, $t0, $t0, 1
    beq, $t0, $s7, end
    addi, $t0, $t0, 1
    beq, $t0, $s7, c2
    addi, $t0, $t0, 1
    beq, $t0, $s7, c3
    addi, $t0, $t0, 1
    beq, $t0, $s7, c4
    addi, $t0, $t0, 1
    beq, $t0, $s7, c5
    addi, $t0, $t0, 1
    beq, $t0, $s7, c6

    c0:
    rotate_t
    j end
    c2:
    rotate_I
    j end
    c3:
    rotate_s
    j end
    c4:
    rotate_z
    j end
    c5:
    rotate_L
    j end
    c6:
    rotate_j
    end:
.end_macro

.macro rotate_t
    lw $t6, darkgrey
    addi $t0, $sp, -4160 # tetromino

    lw $t1, 4($t0)
    lw $t2, 24($t0)
    lw $t3, 36($t0)
    lw $t4, 16($t0)
    
    if:
    beq $t1, $zero, continue1
    beq $t2, $zero, continue2
    beq $t3, $zero, continue3
    beq $t4, $zero, continue4
    
    continue1:
    addi $t5, $t4, -124
    jal check
    sw $t5, 4($t0)
    sw $zero, 24($t0)
    j end
    
    continue2:
    addi $t5, $t1, 132
    jal check
    sw $t5, 24($t0)
    sw $zero, 36($t0)
    j end
    
    continue3:
    addi $t5, $t2, 124
    lw $t7, 0($t5)
    jal check  
    sw $t5, 36($t0)
    sw $zero, 16($t0)
    j end
    
    continue4:
    addi $t5, $t3, -132 
    jal check
    sw $t5, 16($t0)
    sw $zero, 4($t0)
    j end
    
    check:
    lw $t7, 0($t5)
    bne $t7, $zero, g
    jr $ra
    g:
    bne $t7, $t6, end
    jr $ra
    
    end:
.end_macro

.macro rotate_I
    lw $t6, darkgrey
    addi $t0, $sp, -4160 # tetromino
    lw $t1, 4($t0)
    lw $t2, 32($t0)
    lw $t3, 36($t0) #middle
    
    if:
    beq $t1, $zero, continue1
    beq $t2, $zero, continue2
    
    continue1:
    addi $t5, $t3, -256
    jal check
    addi $t5, $t3, -128
    jal check
    addi $t5, $t3, 128
    jal check
    sw $t5, 52($t0)
    addi $t5, $t3, -128
    sw $t5, 20($t0)
    addi $t5, $t3, -256
    sw $t5, 4($t0)
    
    sw $zero, 32($t0)
    sw $zero, 40($t0)
    sw $zero, 44($t0)
    j end
    
    continue2:
    addi $t5, $t3, 4
    jal check
    addi $t5, $t3, 8
    jal check
    addi $t5, $t3, -4
    jal check
    sw $t5, 32($t0)
    addi $t5, $t3, 4
    sw $t5, 40($t0)
    addi $t5, $t3, 8
    sw $t5, 44($t0)
    
    sw $zero, 4($t0)
    sw $zero, 20($t0)
    sw $zero, 52($t0)
    j end
    
    check:
    lw $t7, 0($t5)
    bne $t7, $zero, g
    jr $ra
    g:
    bne $t7, $t6, end
    jr $ra
    
    end:
.end_macro

.macro rotate_z
lw $t6, darkgrey
    addi $t0, $sp, -4160 # tetromino
    lw $t1, 0($t0)
    lw $t2, 16($t0)
    lw $t3, 20($t0) #middle
    
    if:
    beq $t1, $zero, continue1
    beq $t2, $zero, continue2
    
    continue1:
    addi $t5, $t3, -132
    jal check
    addi $t5, $t3, 4
    jal check
    sw $t5, 24($t0)
    addi $t5, $t3, -132
    sw $t5, 0($t0)
       
    sw $zero, 32($t0)
    sw $zero, 16($t0)
    j end
    
    continue2:
    addi $t5, $t3, -4
    jal check
    addi $t5, $t3, 124
    jal check
    sw $t5, 32($t0)
    addi $t5, $t3, -4
    sw $t5, 16($t0)
    
    sw $zero, 0($t0)
    sw $zero, 24($t0)
    j end
    
    check:
    lw $t7, 0($t5)
    bne $t7, $zero, g
    jr $ra
    g:
    bne $t7, $t6, end
    jr $ra
    
    end:
.end_macro

.macro rotate_s
    lw $t6, darkgrey
    addi $t0, $sp, -4160 # tetromino
    lw $t1, 0($t0)
    lw $t2, 4($t0)
    lw $t3, 20($t0) #middle
    
    if:
    beq $t1, $zero, continue1
    beq $t2, $zero, continue2
    
    continue1:
    addi $t5, $t3, -132
    jal check
    addi $t5, $t3, 128
    jal check
    sw $t5, 36($t0)
    addi $t5, $t3, -132
    sw $t5, 0($t0)
       
    sw $zero, 4($t0)
    sw $zero, 8($t0)
    j end
    
    continue2:
    addi $t5, $t3, -128
    jal check
    addi $t5, $t3, -124
    jal check
    sw $t5, 8($t0)
    addi $t5, $t3, -128
    sw $t5, 4($t0)
    
    sw $zero, 0($t0)
    sw $zero, 36($t0)
    j end
    
    check:
    lw $t7, 0($t5)
    bne $t7, $zero, g
    jr $ra
    g:
    bne $t7, $t6, end
    jr $ra
    
    end:
.end_macro

.macro rotate_L
    lw $t6, darkgrey
    addi $t0, $sp, -4160 # tetromino

    lw $t1, 24($t0)
    lw $t2, 20($t0)
    lw $t3, 36($t0)
    lw $t4, 40($t0)
    
    if:
    beq $t1, $zero, continue1
    beq $t2, $zero, continue2
    beq $t3, $zero, continue3
    beq $t4, $zero, continue4
    
    continue1:
    addi $t5, $t4, -128
    jal check
    addi $t5, $t3, -4
    jal check
    sw $t5, 32($t0)
    addi $t5, $t4, -128
    sw $t5, 24($t0)
    
    sw $zero, 20($t0)
    sw $zero, 4($t0)
    j end
    
    continue2:
    addi $t5, $t1, -4
    jal check
    addi $t5, $t1, 256
    jal check
    sw $t5, 56($t0)
    addi $t5, $t1, -4
    sw $t5, 20($t0)
    
    sw $zero, 36($t0)
    sw $zero, 32($t0)
    j end
    
    continue3:
    addi $t5, $t4, -4
    jal check
    addi $t5, $t1, 4
    jal check
    sw $t5, 28($t0)
    addi $t5, $t4, -4
    sw $t5, 36($t0)
    
    sw $zero, 56($t0)
    sw $zero, 40($t0)
    j end
    
    continue4:
    addi $t5, $t3, 4
    jal check
    addi $t5, $t2, -128
    jal check
    sw $t5, 4($t0)
    addi $t5, $t3, 4
    sw $t5, 40($t0)
    
    sw $zero, 24($t0)
    sw $zero, 28($t0)
    j end
    
    check:
    lw $t7, 0($t5)
    bne $t7, $zero, g
    jr $ra
    g:
    bne $t7, $t6, end
    jr $ra
    
    end:
.end_macro

.macro rotate_j
    lw $t6, darkgrey
    addi $t0, $sp, -4160 # tetromino

    lw $t1, 20($t0)
    lw $t2, 24($t0)
    lw $t3, 40($t0)
    lw $t4, 36($t0)
    
    if:
    beq $t1, $zero, continue1
    beq $t2, $zero, continue2
    beq $t3, $zero, continue3
    beq $t4, $zero, continue4
    
    continue1:
    addi $t5, $t4, -128
    jal check
    addi $t5, $t3, 4
    jal check
    sw $t5, 44($t0)
    addi $t5, $t4, -128
    sw $t5, 20($t0)
    
    sw $zero, 8($t0)
    sw $zero, 24($t0)
    j end
    
    continue2:
    addi $t5, $t1, 4
    jal check
    addi $t5, $t1, 256
    jal check
    sw $t5, 52($t0)
    addi $t5, $t1, 4
    sw $t5, 24($t0)
    
    sw $zero, 40($t0)
    sw $zero, 44($t0)
    j end
    
    continue3:
    addi $t5, $t4, 4
    jal check
    addi $t5, $t1, -4
    jal check
    sw $t5, 16($t0)
    addi $t5, $t4, 4
    sw $t5, 40($t0)
    
    sw $zero, 36($t0)
    sw $zero, 52($t0)
    j end
    
    continue4:
    addi $t5, $t3, -4
    jal check
    addi $t5, $t2, -128
    jal check
    sw $t5, 8($t0)
    addi $t5, $t3, -4
    sw $t5, 36($t0)
    
    sw $zero, 16($t0)
    sw $zero, 20($t0)
    j end
    
    check:
    lw $t7, 0($t5)
    bne $t7, $zero, g
    jr $ra
    g:
    bne $t7, $t6, end
    jr $ra
    
    end:
.end_macro

.macro move_left
    check_collision_left
    li $t0, 1
    bne $v0, $t0, e1

    addi $t0, $sp, -4160 # tetromino
    addi $t1, $sp, -4096 # grid starts
    f1: # foor loop
    beq $t0, $t1, e1 
    lw $t3, 0($t0) #address in bitmap
    if: 
    beq $t3, $zero, end
    addi $t3, $t3, -4
    sw $t3, 0($t0)
    end:
    addi $t0, $t0, 4
    j f1
    e1:	
.end_macro

.macro move_right
    check_collision_right
    li $t0, 1
    bne $v0, $t0, e1
    
    addi $t0, $sp, -4160 # tetromino
    addi $t1, $sp, -4096 # grid starts
    f1: # foor loop
    beq $t0, $t1, e1 
    lw $t3, 0($t0) #address in bitmap
    if: 
    beq $t3, $zero, end
    addi $t3, $t3, 4
    sw $t3, 0($t0)
    end:
    addi $t0, $t0, 4
    j f1
    e1:	
.end_macro

.macro move_down
    check_collision_down
    li $t0, 1
    bne $v0, $t0, e1
    
    addi $t0, $sp, -4160 # tetromino
    addi $t1, $sp, -4096 # grid starts
    f1: # foor loop
    beq $t0, $t1, e1 
    lw $t3, 0($t0) #address in bitmap
    if: 
    beq $t3, $zero, end
    addi $t3, $t3, 128
    sw $t3, 0($t0)
    end:
    addi $t0, $t0, 4
    j f1
    e1:	
.end_macro

.macro check_collision_down
    addi $t0, $sp, -4100 # tetromino counter
    addi $t7, $sp, -4100 # coloumn counter
    addi $t1, $t0, -16 # tetromino end
    li $v0, 1 #return true
    lw $t9, black
    lw $t8, darkgrey
    
    f1: # foor loop 1
    beq $t0, $t1, endf1
    li $t2, 0
    li $t3, 4
    
    f2: #for loop 2
    beq $t2, $t3, endifgreyorblack
    lw $t4, 0($t0) #address in bitmap
    
    ifzero: #if address is zero 
    beq $t4, $zero, endifzero
    lw $t5, 128($t4) #pixel below
    
    ifnotblack: #pixel is a border or block
    bne $t5, $t9, ifnotgrey
    j endifgreyorblack
    
    ifnotgrey:
    bne $t5, $t8, cantmovedown
    j endifgreyorblack
    
    endifzero:
    addi $t2, $t2, 1
    addi $t0, $t0, -16
    j f2
    
    endifgreyorblack:
    addi $t7, $t7, -4
    move $t0, $t7 
    j f1
    
    cantmovedown:
    li $v0, 0
    
    endf1: 	
.end_macro
.macro check_collision_left
    addi $t0, $sp, -4160 # tetromino counter
    addi $t7, $sp, -4160 # row counter
    addi $t1, $t0, 64 # tetromino end
    li $v0, 1 #return true
    lw $t9, black
    lw $t8, darkgrey
    
    f1: # foor loop 1
    beq $t0, $t1, endf1
    li $t2, 0
    li $t3, 4
    
    f2: #for loop 2
    beq $t2, $t3, endifgreyorblack
    lw $t4, 0($t0) #address in bitmap
    
    ifzero: #if address is zero 
    beq $t4, $zero, endifzero
    lw $t5, -4($t4) #pixel to the left
    
    ifnotblack: #pixel is a border or block
    bne $t5, $t9, ifnotgrey
    j endifgreyorblack
    
    ifnotgrey:
    bne $t5, $t8, cantmoveleft
    j endifgreyorblack
    
    endifzero:
    addi $t2, $t2, 1
    addi $t0, $t0, 4
    j f2
    
    endifgreyorblack:
    addi $t7, $t7, 16
    move $t0, $t7 
    j f1
    
    
    cantmoveleft:
    li $v0, 0
    
    endf1: 	
.end_macro

.macro check_collision_right
    addi $t0, $sp, -4100 # tetromino counter
    addi $t7, $sp, -4100 # row counter
    addi $t1, $t0, -64 # tetromino end
    li $v0, 1 #return true
    lw $t9, black
    lw $t8, darkgrey
    
    f1: # foor loop 1
    beq $t0, $t1, endf1
    li $t2, 0
    li $t3, 4
    
    f2: #for loop 2
    beq $t2, $t3, endifgreyorblack
    lw $t4, 0($t0) #address in bitmap
    
    ifzero: #if address is zero 
    beq $t4, $zero, endifzero
    lw $t5, 4($t4) #pixel to the right
    
    ifnotblack: #pixel is a border or block
    bne $t5, $t9, ifnotgrey
    j endifgreyorblack
    
    ifnotgrey:
    bne $t5, $t8, cantmoveright
    j endifgreyorblack
    
    endifzero:
    addi $t2, $t2, 1
    addi $t0, $t0, -4
    j f2
    
    endifgreyorblack:
    addi $t7, $t7, -16
    move $t0, $t7 
    j f1
    
    
    cantmoveright:
    li $v0, 0
    
    endf1: 	
.end_macro

.macro check_lines_full
    lw $s0, ADDR_DSPL
    addi $s0, $s0, 2828 #pixel
    move $s6, $s0 #row
    li $s1, 0 #counters
    li $s2, 20
    lw $t9, black #colours
    lw $t8, darkgrey
    
    loop1: #loop over rows
    beq $s1, $s2, end1
    li $t3, 0
    li $t4, 10
    
    loop2: #loop over pixels
    beq $t3, $t4, remove_row
    lw $t5, 0($s0)
    
    checkifnotblack:
    bne $t5, $t9, checkifnotgrey
    addi $s1, $s1, 1
    addi $s6, $s6, -128
    move $s0, $s6
    j loop1
    
    checkifnotgrey:
    bne $t5, $t8, move_next_pixel
    addi $s1, $s1, 1
    addi $s6, $s6, -128
    move $s0, $s6
    j loop1
    
    move_next_pixel:
    addi $t3, $t3, 1
    addi $s0, $s0, 4
    j loop2
    
    remove_row:
    move $a0, $s6
    remove_row_
    addi $s1, $s1, 1
    move $s0, $s6
    j loop1
    
    end1:
    
.end_macro

.macro remove_row_ #a0 = coloumn, t9 = black, t8 = grey
    move $t2, $a0 #coloumn
    li $t3, 0
    li $t4, 10
 
    loop1:
    beq $t3, $t4, end1
    move $t1, $s1 #rows to shift
      
    loop2:
    beq $t1, $s2, end2
    lw $t6, -128($t2)
    beq $t6, $t9, changegrey
    beq $t6, $t8, changeblack
    j continue
    changeblack:
    lw $t6, black
    j continue
    changegrey:
    lw $t6, darkgrey
    continue:
    sw $t6, 0($t2)
    addi $t2, $t2, -128
    addi $t1, $t1, 1
    j loop2
    
    end2:
    addi $t3, $t3, 1
    addi $a0, $a0, 4
    move $t2, $a0
    j loop1
    
    end1:
.end_macro

.macro random_int
    li $v0, 42  # 42 is system call code to generate random int
    li $a1, 7 # $a1 is where you set the upper bound
    syscall     # your generated number will be at $a0

    move $s7, $a0
.end_macro
	
.macro pause_screen
    lw $t0, white
    lw $t1, ADDR_DSPL
    
    
    addi $t1, $t1, 188
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1) 
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    
    addi $t1, $t1, 128
    addi $t1, $t1, 128
    
    sw $t0, 0($t1)
    addi $t1, $t1, 4                
    sw $t0, 0($t1)                  
    addi $t1, $t1, 4                
    sw $t0, 0($t1) 
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    
    addi $t1, $t1, 128
    addi $t1, $t1, 120
    
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    
    addi $t1, $t1, 128
    
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    
    addi $t1, $t1, 120
    addi $t1, $t1, 128
    
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
.end_macro

.macro clear_pause_screen
    lw $t0, black
    lw $t1, ADDR_DSPL
    
    
    addi $t1, $t1, 188
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1) 
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    
    addi $t1, $t1, 128
    addi $t1, $t1, 128
    
    sw $t0, 0($t1)
    addi $t1, $t1, 4                
    sw $t0, 0($t1)                  
    addi $t1, $t1, 4                
    sw $t0, 0($t1) 
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    
    addi $t1, $t1, 128
    addi $t1, $t1, 120
    
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 8
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    
    addi $t1, $t1, 128
    
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    
    addi $t1, $t1, 120
    addi $t1, $t1, 128
    
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 120
    sw $t0, 0($t1)
    addi $t1, $t1, 128
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    sw $t0, 0($t1)
.end_macro

.macro clear_screen
    lw $t1, ADDR_DSPL
    addi $t1, $t1, 4
    li $t2, 0
    li $t3, 1024
    
    loop:
    beq $t2, $t3, end
    sw $zero, 0($t1)
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    j loop
    end:
.end_macro

.macro print_game_over
    lw $t1, ADDR_DSPL
    addi $t1, $t1, 4
    lw $t2, white
    
    sw $t2, 1412($t1)
    sw $t2, 1416($t1)
    sw $t2, 1420($t1)
    sw $t2, 1540($t1)
    sw $t2, 1668($t1)
    sw $t2, 1672($t1)
    sw $t2, 1676($t1)
    sw $t2, 1548($t1)
    sw $t2, 1804($t1)
    sw $t2, 1932($t1)
    sw $t2, 1928($t1) #g
    
    sw $t2, 1428($t1)
    sw $t2, 1432($t1)
    sw $t2, 1436($t1)
    sw $t2, 1564($t1)
    sw $t2, 1692($t1)
    sw $t2, 1820($t1)
    sw $t2, 1948($t1)
    sw $t2, 1556($t1)
    sw $t2, 1684($t1)
    sw $t2, 1688($t1)
    sw $t2, 1812($t1)
    sw $t2, 1940($t1) #a
    
    sw $t2, 1444($t1)
    sw $t2, 1572($t1)
    sw $t2, 1700($t1)
    sw $t2, 1828($t1)
    sw $t2, 1956($t1)
    sw $t2, 1576($t1)
    sw $t2, 1708($t1)
    sw $t2, 1584($t1)
    sw $t2, 1460($t1)
    sw $t2, 1588($t1)
    sw $t2, 1716($t1)
    sw $t2, 1844($t1)
    sw $t2, 1972($t1) #m
    
    sw $t2, 1468($t1)
    sw $t2, 1472($t1)
    sw $t2, 1476($t1)
    sw $t2, 1596($t1)
    sw $t2, 1724($t1)
    sw $t2, 1728($t1)
    sw $t2, 1852($t1)
    sw $t2, 1980($t1)
    sw $t2, 1984($t1)
    sw $t2, 1988($t1)#E
    
    addi $t1, $t1, 4
    
    sw $t2, 2228($t1)
    sw $t2, 2356($t1)
    sw $t2, 2484($t1)
    sw $t2, 2612($t1)
    sw $t2, 2740($t1)
    sw $t2, 2232($t1)
    sw $t2, 2236($t1)
    sw $t2, 2364($t1)
    sw $t2, 2492($t1)
    sw $t2, 2620($t1)
    sw $t2, 2748($t1)
    sw $t2, 2744($t1)#O
    
    sw $t2, 2244($t1)
    sw $t2, 2372($t1)
    sw $t2, 2500($t1)
    sw $t2, 2628($t1)
    sw $t2, 2760($t1)
    sw $t2, 2636($t1)
    sw $t2, 2508($t1)
    sw $t2, 2380($t1)
    sw $t2, 2252($t1)#V
    
    sw $t2, 2260($t1)
    sw $t2, 2264($t1)
    sw $t2, 2268($t1)
    sw $t2, 2388($t1)
    sw $t2, 2516($t1)
    sw $t2, 2520($t1)
    sw $t2, 2644($t1)
    sw $t2, 2772($t1)
    sw $t2, 2776($t1)
    sw $t2, 2780($t1)#E
    
    sw $t2, 2276($t1)
    sw $t2, 2280($t1)
    sw $t2, 2284($t1)
    sw $t2, 2404($t1)
    sw $t2, 2412($t1)
    sw $t2, 2532($t1)
    sw $t2, 2536($t1)
    sw $t2, 2540($t1)
    sw $t2, 2660($t1)
    sw $t2, 2664($t1)
    sw $t2, 2788($t1)
    sw $t2, 2796($t1)#R
.end_macro
    # Run Tetris
main:
#reset the sound card
    li $a0, 0
    li $a1, 1250
	li $a2, 7
	li $a3, 0

	li $v0, 31
	
	syscall
	
    li $v0, 32
    	li $a0, 1000
    	syscall
    	
# Initialize the game
background
li $t0, 1
sw $t0, -4164($sp)#counter for gravity
la $s3, Tetris_theme
game_start: 
save_board
reset_piece
random_int
draw_tetromino
check_collision_down
li $t0, 0
beq $v0, $t0, game_over

game_loop:
	# 1a. Check if key has been pressed
    lw $t7, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t7)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed

    j collisions


    # 1b. Check which key has been pressed
    keyboard_input:                   # A key is pressed
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x70, respond_to_P    # Check if the key p was pressed
    beq $a0, 0x77, respond_to_W    # Check if the key w was pressed
    beq $a0, 0x61, respond_to_A   # Check if the key a was pressed
    beq $a0, 0x73, respond_to_S    # Check if the key s was pressed
    beq $a0, 0x64, respond_to_D    # Check if the key d was pressed

    b game_loop
    
    respond_to_Q:
        clear_screen
	li $v0, 10                      # Quit gracefully
	syscall
	
    respond_to_P:
    	pause_screen
    	lw $t7, ADDR_KBRD
    	lw $t8, 0($t7)
    	beq $t8, 0, respond_to_P      # If first word 1, key is pressed
    	lw $a0, 4($t7)                  # Load second word from keyboard
    	beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    	bne $a0, 0x70, respond_to_P    # Check if the key p was pressed
    	beq $a0, 0x70, unpause    # Check if the key p was pressed
    
    unpause:
    	clear_pause_screen
    	j collisions
	
respond_to_W:
    rotate_tetromino
    redraw_board
    draw
    j collisions
    
respond_to_A:
    move_left
    redraw_board
    draw
    j collisions

respond_to_S:
    move_down
    redraw_board
    draw
    j collisions
        
respond_to_D:
    move_right
    redraw_board
    draw
    j collisions

    # 2a. Check for collisions
    	collisions: 	
    	check_collision_down
        li $t0, 1
        bne $v0, $t0, remove_lines
        
        lw $s0, -4164($sp)
        addi $s0, $s0, 1
        sw $s0, -4164($sp)
	
	li $v0, 32
    	li $a0, 1
    	syscall
	
	li $t1, 100
	div $s0, $t1        # Divide $t0 by $t1
        mfhi $t2 
        beq $t2, 0, playnote  
	continue_after_note:
	
	li $t1, 500
	div $s0, $t1        # Divide $t0 by $t1
        mfhi $t2 
	beq $t2, 0, gravity  
        j game_loop
        
        
        gravity:
        move_down
    	redraw_board
    	draw
        j collisions
        
	# 3 Update lines
	remove_lines:
	check_lines_full       
    	j game_start
	
	playnote:
	lw, $a0, 0($s3)
	li $t0, -1
	beq $a0, $t0, reset_notes
	addi $s3, $s3, 4
	li $a1, 1250
	li $a2, 7
	li $a3, 90

	li $v0, 31
	
	syscall
	j continue_after_note
	
	reset_notes:
	la $s3, Tetris_theme
	j playnote
	
    #5. Go back to 1
    
game_over:
clear_screen
print_game_over
loop_game_over:
    lw $t7, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t7)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input_2      # If first word 1, key is pressed

    j loop_game_over


    # 1b. Check which key has been pressed
    keyboard_input_2:                   # A key is pressed
    lw $a0, 4($t7)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    bne $a0, 0x72, loop_game_over
    clear_screen
    j main
