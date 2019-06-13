# hw2_main1.asm
# This file is NOT part of your homework 2 submission.
# Any changes to this file WILL NOT BE GRADED.
#
# We encourage you to modify this file  and/or make your own mains to test different inputs

#.include "hw3_examples_2.asm"
.include "hw3_examples.asm"
#.include "hw2_grading.asm"

# Constants
.data
newline:  .asciiz "\n"
comma:    .asciiz ", "
testchar: .byte '9'
success: .asciiz "Success: "
bytes: .asciiz "Bytes: "
packetNumber_1: .asciiz "packet number "
packetNumber_2: .asciiz " has invalid checksum"
leftPar: .asciiz "("
rightPar: .asciiz ")"
bunny: .asciiz "Bunny"
funny: .asciiz "Funny"
sun: .asciiz "SuN"
mon: .asciiz "Mon"
cat: .asciiz "Cat"
toad: .asciiz "Toad"
numbers: .asciiz "1234567890"
one: .asciiz "1"
blank: .asciiz ""

ivysaur: .asciiz "Ivysaur"

msg: .asciiz "a\nbb\nccc\ndddd\neeeee\nffffff\n"
msg2: .asciiz "hi\n\nhowareyou?\n"
msg3: .asciiz "helloworld"

alphabet: .asciiz "aaaabcdde"

FBunny: .asciiz "Funny Bunny"

.text
.globl _start


####################################################################
# This is the "main" of your program; Everything starts here.
####################################################################

_start:

	
	##################
	# replace1st
	##################
#	la $a0, FBunny
#	li $a1, 'F'
#	li $a2,	'B'
#	jal replace1st

	# print return value
#	move $a0, $v0
#	li $v0, 1
#	syscall
#	li $v0, 4
#	la $a0, newline
#	syscall

#	la $a0, msg
#	li $a1, 26
#	la $a2, abcArray
#	jal processDatagram

	# print return value
#	move $a0, $v0
#	li $v0, 1
#	syscall
#	li $v0, 4
#	la $a0, newline
#	syscall
	
	
	########################
	# printUnorderedDatagram
	########################
#	la $a0, queen_holes
#	li $a1, 4
#	la $a2, msg_buffer
#	la $a3, str_array
#	addi $sp, $sp, -4
#	li $s0, 80
#	sw $s0, 0($sp)
#	jal printUnorderedDatagram
	
#	lw $s0, 0($sp)
#	addi $sp, $sp, 4
	
#	move $a0, $v0
#	li $v0, 1
#	syscall
#	li $v0, 4
#	la $a0, newline
#	syscall
	
	
	la $a0, numbers
	la $a1, one
	li $a2, 10
	li $a3, 1
	jal editDistance
	
	move $a0, $v0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	


###################################################################
# End of MAIN program
####################################################################
# Exit the program
	li $v0, 10
	syscall


#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw3.asm"
