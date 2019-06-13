##############################################################
# name: Mei Qi Deanna Liu
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################
replace1st:
	#a0 is String
	#a1 is toReplace
	#a2 is replaceWith
	move $t2, $a0 			# copy $a0 (the word) into $t2 
	blt $a1, 0x00, error 		# checks for Error
	bgt $a1, 0x7F, error		# checks for Error
	blt $a2, 0x00, error		# checks for Error
	bgt $a2, 0x7F, error		# checks for Error
	j innerStr 			# if no error start the replace loop - "innerStr"
error:
	li $v0, -1 			# return -1
	jr $ra				# end
innerStr:
	lbu $t3, 0($t2) 		# load the letter into $t3
	beqz $t3, printZero		# if the letter is /0 then print a 0
	beq $t3, $a1, replace		# if the letter = toReplace then perform the replace
	addi $t2, $t2, 1		# increment to the next letter
	j innerStr
replace:
	sb $a2, 0($t2)			# storing the replaceWith into where the String is pointing at the moment	
	addi $t2, $t2, 1		# increment the memory address by 1
	move $v0, $t2			# returning the modified String
	jr $ra				# end
printZero:
	li $v0, 0			# return 0
	jr $ra				# end

################################### 1B #######################################
printStringArray:
 	blt $a3, 1, printError 		# Length is less than 1
   	bltz $a1, printError 		# startIndex is less than 0
   	bge $a1, $a3, printError 	# startIndex is greater than or equal length
   	bltz $a2, printError 		# endIndex is less than 0
   	bge $a2, $a3, printError 	# endIndex is greater than or equal length
   	blt $a2, $a1, printError 	# endIndex is less than startIndex
   	
   	move $t0, $a0			# move sArray to $t0
   	move $t1, $a1 			# move startIndex into $t1
   	li $t2, 0			# counter for how many is printed out

   	startLoop:
   		bge $t1, $a2, endLoop 	# if endIndex = startIndex as it's counting then it's at the end, need to END
   		sll $t3, $t1, 2		
   		add $t4, $t0, $t3	# increment the array to next word
   		lw $t5, 0($t4)		# load the word to print
   		move $a0, $t5		
   		li $v0, 4		# prints the word
   		syscall
   		la $a0, newLine		
   		syscall			# prints a new line
   		syscall			# prints a new line
   		addi $t1, $t1, 1	# increment startIndex 
   		addi $t2, $t2, 1	# increment counter
   		j startLoop		# go throught the loop again
   	
   	endLoop:
   		move $v0, $t2 		# return the counter
   		jr $ra			# end
   	printError:
   		li $v0, -1		# return -1
   		jr $ra			# end
    	
########################## 1C #####################################################
verifyIPv4Checksum:
	move $t0, $a0 			# move $a0 [Valid Header] into $t0
	lbu $t1, 3($t0) 		# whole byte is [Version || HeaderLength]
	sll $t1, $t1, 28		# get the HeaderLength
	srl $t1, $t1, 28		# $t1 is the HeaderLength 
#HW3 CHECK HEADERLENGTH VALUE [5, 15]
	blt $t1, 5, endVerifyCheckSum
	bgt $t1, 15, endVerifyCheckSum
	j afterHeaderValid
		endVerifyCheckSum:
			li $v1, -1
			jr $ra
afterHeaderValid:
	li $t2, 2		
	mult $t1, $t2
	mflo $t3 			# HeaderLength * 2
	li $t5, 0 			# sum Of Everything
	li $t4, 0 			# pointer 
looploop:
	lhu $t7, ($t0)		
	beq $t4, $t3, endlooploop
	add $t5, $t5, $t7 		# adding to sum of everything
	addi $t4, $t4, 1
	addi $t0, $t0, 2
	j looploop
endlooploop:
	li $t6, 65536
	bge $t5, $t6, endAround 	# if the sum of everything is greater than 65536 then do the end around carry
	move $v0, $t5			# return the sum of everything
	jr $ra				# end
endAround:
	srl $t3, $t5, 16 		# Remove the last 4 bits
	sll $t6, $t5, 16 		
	srl $t6, $t6, 16		
	add $t6, $t3, $t6		
	xori $t6, $t6, 0xffff 		# flip all the bits
	move $v0, $t6			# return $t6
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################
extractData:
	#a0 = parray
	#a1 = n
	#a2 = msg
	addi $sp, $sp, -36
	sw $s7, 32($sp)
	sw $s6, 28($sp)
	sw $s5, 24($sp)
	sw $s4, 20($sp)
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
	move $a3, $a2
	move $s0, $a0 
	# s0 = parray
	# get payload first
	li $t8, 20 
	li $s2, 0 			# sum of bytes
	li $s3, 0 			# parray pointer
	extractPayload:
	beq $s3, $a1, endFill		# compare length and parraypointer
	lhu $s4, 0($s0) 		# total length is in s4
		addi $s5, $s4, -20 
		add $s2, $s2, $s5
	lbu $s1, 3($s0) 		# Version || HeaderLength
	sll $s1, $s1, 28
	srl $s1, $s1, 28
	sub $s6, $s4, $s1 		# s6 = payload
		move $a0, $s0
		move $s7 ,$s0
		jal verifyIPv4Checksum
			addi $s3, $s3, 1 
			addi $s0, $s0, 60
			bnez $v0, errorFill
		j extractPayload
		
	endFill:	
		move $v1, $s2
		addi $s7, $s7, 20
		li $s3, 0
		beqz $v0, fillbytes
	
	nextPacket:
		addi $s7, $s7, 20
		li $t8, 20 
		addi $s3, $s3, 1
		beq $s3, $a1, endfill2
		j fillbytes
	errorFill:
		addi $s3, $s3, -1
		li $v0, -1
		move $v1, $s3
		j endfill2
	endfill2:
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36
    		jr $ra

	fillbytes:
		lbu $t3, 0($s7)
		sb $t3, 0($a3)
		addi $s7, $s7, 1
		beq $t8, 60, nextPacket
		addi $t8, $t8, 1
		addi $a3, $a3, 1
		j fillbytes

    #################################### 2E ##############################
processDatagram:  
	#Define your code here
  	#a0 is msg
    	#a1 is M
    	#a2 is sarray
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s1, 4($sp)
	sw $s7, 8($sp)
	
	move $t5, $a0 					# $t5 is a copy of the msg
	move $t7, $a1 					# $t7 is a copy of M
	move $t6, $a2 					# $t6 is a copy of sArray
	
	li $s1, 0					# $s1 is the byte changed every time replace1st happens
					
	li $a1, '\n'
	li $a2, '\0'
	ble $t7, 0, errorload
	li $t4, 0  					# $t4 is the byte counter
	li $t2, 0  
	li $t8, 0					# $t8 is the count # changed
	li $s7, 0					# $s7 is the end address
	add $s7, $t7, $t5 				# $s7 = M + StartingAddress
	replaceLoop:
		jal replace1st				# call replace1st
		beq $v0, 0, store0AtEnd			# if replace1st doesn't replace anything, then store a \0 at the end
		sub $s1, $v0, $a0 			# getting the byte change
		add $t4, $t4, $s1			# increment the byte counter
		addi $t4, $t4, 1
		sw $a0, 0($t6)				# store the address into sArray
		add $a0, $a0, $s1			# increment address by the bytes changed
		addi $t6, $t6, 4			# increment sArray to next byte
		addi $t8, $t8, 1			# increment how many changed
		bge $t4, $t7, endReplace		# if the byte is still less than M then keep going
		j replaceLoop
	store0AtEnd:
		sw $a0, 0($t6)				# store address into sArray
		move $a0, $s7				# go to the end of the words
		sb $a2, 0($a0)				# store a \0 at the end
		addi $t8, $t8, 1			# adding 1 to numbers changed because the end got changed too
	endReplace:					# done replacing all the \n to \0
		move $v0, $t8				# returning how many \0 got put into the msg
		j exitProcessDatagram			# exit
	errorload:
		li $v0, -1				# error return -1
	exitProcessDatagram:
		lw $ra, 0($sp)				# register conventions
		lw $s1, 4($sp)
		lw $s7, 8($sp)
		addi $sp, $sp, 12
		jr $ra					# end
##############################
# PART 3 FUNCTIONS
##############################
printDatagram:
       	addi $sp, $sp, -16
	sw $s3, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $ra, 0($sp)
	
	move $s3, $a0 					# $s3 is parray
	move $s7, $a1
	move $s2, $a2 					# $s2 is msg_buffer
	move $s5, $a3 

    blez $a1, errorInData
    jal extractData
	beq $v0, -1, errorInData
    startProcess:
   	 move $a0, $a2
   	 move $a1, $v1 					# v1 is M
   	 move $a2, $a3
    jal processDatagram
    move $s1, $v0 					# $s1 = result in processDatagram
    move $v0, $s1
    beq $v0, -1, errorInData
    startPrint:
	move $a0, $a3
	li $a1, 0
	move $a2, $v0
	addi $a2, $a2, -1
	move $a3, $v0
   	jal printStringArray
   	li $v0, 0
   	j ending
errorInData: 
	li $v0, -1
ending:
    	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
    jr $ra

######################################## HOMEWORK#3 ######################################
extractUnorderedData:
# $a0 = pArray - array of packets
# $a1 = n - number of packets in pArray
# $a2 = msg 
# $a3 = packetentrysize - number of bytes for each pArray[i]
	## RETURNS (0, M+1) - SUCCESS
	## RETURNS (-1, k) - FAILURE
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	#RETURN (-1, -1) IF
	blt $a1, 1, neg1Final 
		j parrayValidity
	neg1Final:
		li $v0, -1
		li $v1, -1
		j endUnorderedPackets
#check validity of parray
parrayValidity:
	li $s0, 0 						# $s0 is the packetCounter
	move $s1, $a0 						# $s1 is the array of packets 
	li $s7, 0						# $s7 holds M
	beq $a1, 1, fragmentedPacket
	bgt $a1, 1, goThroughPacketForVerification
	
	fragmentedPacket:					# Check if packet is not fragmented
		lhu $s2, 4($s1)					# $s2 = FLAGS || FRAGMENTOFFSET
		srl $s3, $s2, 13 				# $s3 = FLAGS
		sll $s4, $s2, 19
		srl $s4, $s4, 19				# $s4 = FRAGMENTOFFSET					
		beq $s3, 2, goThroughPacketForVerification	# Flags equal 010
		beq $s2, 0, goThroughPacketForVerification	# Flags equal 000 with a Fragment Offset of 0
	
	goThroughPacketForVerification:
		bge $s0, $a1, afterChecksumVerification		# if $s0 is >= number of packets, done looping
		lhu $s5, 0($a0)					# $s5 = Total Length of the current Packet
		jal verifyIPv4Checksum				# else: call verifyIPv4Checksum
		bnez $v0, checkSumFailure			# if packet fails the verifyIPv4Checksum then FAILURE
		bgt $s5, $a3, checkSumFailure			# if Total Length for a packet > packetentrysize then FAILURE
		addi $s0, $s0, 1				# increment packetCounter
		add $s1, $s1, $a3				# increment pArray by packetEntrySize to get to next Packet
		j goThroughPacketForVerification		
		
	checkSumSuccess:
		li $v0, 0
		j afterChecksumVerification

	checkSumFailure:
		li $v0, -1 
		move $v1, $s0
		j endUnorderedPackets
		
	afterChecksumVerification:
		li $s0, 0					# reset packetCounter to 0
		move $s1, $a0					# reset packet to the beginning
		move $t7, $a0					# $t7 also holds the parray
		li $t5, 0 					# $t5 is the beginningPacketCounter
		li $t6, 0					# $t6 is the lastFragmentPacketCounter
		storePayload:
			bge $s0, $a1, endVerification
			li $s6, 0 				# $s6 is the msg index
			move $t4, $a2				# $t4 is the msg
			lhu $s2, 4($s1)				# $s2 = FLAGS || FRAGMENTOFFSET
			srl $s3, $s2, 13 			# $s3 = FLAGS
			sll $s4, $s2, 19
			srl $s4, $s4, 19			# $s4 = FRAGMENTOFFSET
			lhu $t0, 0($s1) 			# $t0 = Total Length
			lbu $t1, 3($s1) 			# $t1 = Version || Header Length
			sll $t1, $t1, 28			
			srl $t1, $t1, 28			# $t1 = Header Length
			li $t3, 4
			mult $t1, $t3
			mflo $t3				# $t3 = Header * 4
			sub $t2, $t0, $t3			# $t2 = payload size
#			add $s7, $s7, $t2			# M 
			
			beq $a1, 1, checkError
		checkFlags:
			beq $s3, 4, flagIs4			# check if flag is 100
			beq $s3, 0, flagIs0			# check if flag is 000
			beq $s3, 2, flagIs2			# check if flag is 010
	checkError:
		beq $s3, 4, neg1Final				# if Flags equal 100 = error
		bnez $s2, neg1Final				# if Flags || OFFSET != 0 that is an Error
		j checkFlags
	flagIs4:
		beqz $s4, fragmentIs0				# check if fragment is 0
		j fragmentIntermediate				# if fragment is not 0 then it's an intermediate packet 
	flagIs0:
		beqz $s4, fragmentIs0				# check if fragment is 0
		j fragmentIntermediateIncrement			# if fragment is not 0 then it's an intermediate packet
	flagIs2:
	#	sb $t2, 0($t4)					# store payload into msg[0]
		li $t9, 0					# $t9 = payload pointer
		add $t7, $t7, $t3				# increment the packet by header length
		fillBytesAtFlag2:	
			beq $t9, $t2, doneFillingBytesAtFlag2	# if payload pointer is equal to payload length then it's done
			lbu $t8, 0($t7)				# load each letter into $t8
			sb $t8, ($t4)				# store each letter into msg
			addi $t7, $t7, 1			# increment the packet byte
			addi $t9, $t9, 1			# increment payload pointer
			addi $t4, $t4, 1			# increment msg pointer
			j fillBytesAtFlag2				
		doneFillingBytesAtFlag2:
			j neg1Final				# return (-1, -1) 
	incrementM:
		add $s7, $s7, $t2
		j fragIs0and4
	fragmentIs0:
			beqz $s3, incrementM
		fragIs0and4:
			li $t9, 0				# $t9 = payload pointer
			add $t7, $t7, $t3			# increment the packet by header length 
		fillBytesAt0:	
			bge $t9, $t2, doneFillingBytesAt0	# if payload pointer is equal to payload length then it's done
			lbu $t8, 0($t7)				# load each letter into $t8
			sb $t8, ($t4)				# store each letter into msg
			addi $t7, $t7, 1			# increment the packet byte
			addi $t9, $t9, 1			# increment payload pointer
			addi $t4, $t4, 1			# increment msg pointer
			j fillBytesAt0				
		doneFillingBytesAt0:
			addi $s0, $s0, 1			# increment packetCounter
			move $t7, $s1				# reset $t1 to the beginning of the packet
			add $s1, $s1, $a3			# increment pArray by packetEntrySize to get to next Packet
			add $t7, $t7, $a3			# increment pArray [t1] by packetEntrySize to get to next Packet
			addi $t5, $t5, 1			# increment how many beginning packets there are
			j storePayload						
	fragmentIntermediate:
		add $t4, $t4, $s4				# msg[fragment Offset]
		j placeAtFragOff
	fragmentIntermediateIncrement: 				# this is the last fragmentpacket
		add $t4, $t4, $s4				# msg[fragment Offset]
		j placeAtFragOffIncrement
	placeAtFragOff:
		li $t9, 0					# $t9 = payload pointer
		add $t7, $t7, $t3				# increment the packet by header length
		fillBytes:
			beq $t9, $t2, doneFillingBytes		# if payload pointer is equal to payload length then it's done
			lbu $t8, 0($t7)				# load each letter into $t8
			sb $t8, ($t4)				# store each letter into msg
			addi $t7, $t7, 1			# increment the packet byte
			addi $t9, $t9, 1			# increment payload pointer
			addi $t4, $t4, 1			# increment msg pointer
			j fillBytes
	doneFillingBytes:
		addi $s0, $s0, 1				# increment packetCounter
		move $t7, $s1					# reset $t1 to the beginning of the packet
		add $s1, $s1, $a3				# increment pArray by packetEntrySize to get to next Packet
		add $t7, $t7, $a3				# increment pArray [t1] by packetEntrySize to get to next Packet
		j storePayload
	placeAtFragOffIncrement:
		li $t9, 0					# $t9 = payload pointer
		add $t7, $t7, $t3				# increment the packet by header length
		payloadFillBytes:
			beq $t9, $t2, doneFillingBytesInc	# if payload pointer is equal to payload length then it's done
			lbu $t8, 0($t7)				# load each letter into $t8
			sb $t8, ($t4)				# store each letter into msg
			addi $t7, $t7, 1			# increment the packet byte
			addi $t9, $t9, 1			# increment payload pointer
			addi $t4, $t4, 1			# increment msg pointer
			j payloadFillBytes
	doneFillingBytesInc:
		move $s7, $t4
		sub $s7, $s7, $a2
		addi $s0, $s0, 1				# increment packetCounter
		move $t7, $s1					# reset $t1 to the beginning of the packet
		add $s1, $s1, $a3				# increment pArray by packetEntrySize to get to next Packet
		add $t7, $t7, $a3				# increment pArray [t1] by packetEntrySize to get to next Packet
		addi $t6, $t6, 1				# increment how many last packets there are
		j storePayload
	
endVerification:
	move $v1, $s7
	bne $a1, 1, checkBeginningFinal
	j endUnorderedPackets
	
checkBeginningFinal:
	bne $t5, 1, neg1Final
	bne $t6, 1, neg1Final
	
endUnorderedPackets:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	jr $ra

printUnorderedDatagram:
	# $a0 = parray
	# $a1 = n - Amount of Packets
	# $a2 = msg 
	# $a3 = sarray
	# $s0 = packet Entry Size - length of each packet
	
	lw $s0, 0($sp)						# get $s0 off the stack
	move $s1, $s0						# $s1 = packet entry size
	addi $sp, $sp, 4					# increment the stack to original position
		
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	move $s0, $a0 						# $s0 = parray
	move $s2, $a1						# $s2 = n - Amount of packets in parray
	move $s3, $a2						# $s3 = msg
	move $s4, $a3						# $s4 = sarray
	
	blez $a1, errorFormed					# check that n >= 0
	move $a3, $s1						# pass in packet entry size as the 4th argument
	jal extractUnorderedData				# call extractUnorderedData
	beq $v0, -1, errorFormed				# extractUnorderedData should return 0 to be valid, else ERROR
	
	move $a0, $s3						# argument1 for processDatagram is msg
	move $a1, $v1						# argument2 for processDatagram is M
	move $a2, $s4						# argument3 for processDatagram is sarray
	jal processDatagram					# call processDatagram
	beq $v0, -1, errorFormed				# check that result of process datagram is not -1
	
	move $a0, $s4						# argument1 for printStringArray is sarray 
	li $a1, 0						# argument2 for printStringArray is 0 [startIndex]
	move $a2, $v0						# argument3 for printStringArray is processDatagram result [numbers changed]
#	addi $a2, $a2, -1
	move $a3, $v0						
	addi $a3, $a3, 1					# argument4 for printStringArray is processDatagram result + 1 since the length is +1 of biggest index
	jal printStringArray					# call printStringArray
	
	li $v0, 0						# successfully printed, return 0
	j endPrintUnorderedData					# end function
	
	errorFormed:
		li $v0, -1					# error, return -1
endPrintUnorderedData:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	jr $ra							# end
	
editDistance:
 	# $a0 is str1
	# $a1 is str2
	# $a2 is length of str1
	# $a3 is length of str2
	
	addi $sp, $sp, -20
	
	move $t0, $a0						# $t0 is copy of original str1

	addi $t4, $a2, -1				# compute m - 1
	addi $t5, $a3, -1				# compute n - 1
	
	sw $t4, 0($sp)					# store m - 1
	sw $t5, 4($sp)					# store n - 1
	sw $a2, 8($sp)					# store m
	sw $a3, 12($sp)					# store n
	sw $ra, 16($sp)
	
# ERROR CASE
	bltz $a2, errorInDistance				# if m < 0, error
	bltz $a3, errorInDistance				# if n < 0, error
	j print							# no error, start printing
	
	errorInDistance:
		li $v0, -1
		jr $ra
	
	print:
		#Prints in format of (m,n)
		la $a0, m
		li $v0, 4
		syscall
		move $a0, $a2
		li $v0, 1
		syscall
		la $a0, n
		li $v0, 4
		syscall
		move $a0, $a3
		li $v0, 1
		syscall
		la $a0, newLine
		li $v0, 4
		syscall
	
	baseCase:	
		move $a0, $t0 				# reset $a0 to the original passed in argument
		beqz $a2, returnN			# if m = 0 return n
		beqz $a3, returnM			# if n = 0 return m
		j checkLastCharacter		
		
	returnN:
		move $v0, $a3	
		j exitEditDistance
	returnM:
		move $v0, $a2
		j exitEditDistance
	
	checkLastCharacter:
		#The last character is the starting address + the length - 1
		add $t8, $a0, $a2				# $t8 = starting address + m
		addi $t8, $t8, -1				# $t8 = starting address + m - 1
		lbu $t7, 0($t8)					# $t7 holds the last character of str1
	
		add $t9, $a1, $a3
		addi $t9, $t9, -1
		lbu $t6, 0($t9)					# $t6 holds the last character of str2
		
		bne $t6, $t7, threeOperations

		#move $a0, $t0
		#move $a1, $t1
		move $a2, $t4
		move $a3, $t5
		jal editDistance
		j exitEditDistance
		
	threeOperations:
		insert:	
		#	move $a0, $t0
		#	move $a1, $t1
		#	move $a2, $t2
			move $a3, $t5
			#addi $a3, $a3, -1
			jal editDistance
			lw $t4, 0($sp)
			lw $t5, 4($sp)
			lw $a2, 8($sp)
			lw $a3, 12($sp)
			
			move $t1, $v0			# $t1 is what insert returns

		remove:
		#	move $a0, $t0
		#	move $a1, $t1
			move $a2, $t4
			#addi $a2, $a2, -1
		#	move $a3, $t3
			jal editDistance
			lw $t4, 0($sp)
			lw $t5, 4($sp)
			lw $a2, 8($sp)
			lw $a3, 12($sp)
			move $t2, $v0			# $t2 is what remove returns 

		replaceED:
			#move $t2, $s0
			#move $t3, $s1
		#	move $a0, $t0
		#	move $a1, $t1
			move $a2, $t4
			#addi $a2, $a2, -1
			move $a3, $t5
			#addi $a3, $a3, -1
			jal editDistance
		
			lw $t4, 0($sp)
			lw $t5, 4($sp)
			lw $a2, 8($sp)
			lw $a3, 12($sp)
			
			move $t3, $v0			# $t3 is what replaceED returns
		#	j exitEditDistance
	getMin:
		ble $t2, $t3, minIsRemoveSoFar		# compare $t2 and $t3
		ble $t3, $t1, minIsInsertSoFar		# compare $t3 and $t1
	minIsReplace:
		addi $t3, $t3, 1
		move $v0, $t3
		j exitEditDistance
	minIsRemoveSoFar:
		ble $t2, $t1, minIsRemove
		j minIsInsertSoFar
	minIsRemove:
		addi $t2, $t2, 1
		move $v0, $t2
		j exitEditDistance
	minIsInsertSoFar:
		ble $t3, $t2, minIsReplace
		j minIsRemove
	minIsInsert:
		addi $t1, $t1, 1
		move $v0, $t1
	exitEditDistance:
		lw $ra, 16($sp)
		addi $sp, $sp, 20
		jr $ra					#end
#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

#place all data declarations here

newLine:  .asciiz "\n"
m: .asciiz "m:"
n: .asciiz ",n:"