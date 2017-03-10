######################################################################
# 			     Circle 	                             #
######################################################################
#           						             #
######################################################################
#	This program requires the Keyboard and Display MMIO          #
#       and the Bitmap Display to be connected to MIPS.              #
#								     #
#       Bitmap Display Settings:                                     #
#	Unit Width: 1						     #
#	Unit Height: 1						     #
#	Display Width: 512					     #
#	Display Height: 512					     #
#	Base Address for Display: 0x10010000(static data)	     #
######################################################################
.eqv KEY_CODE 0xFFFF0004  # ASCII code to show, 1 byte 
#.eqv KEY_READY 0xFFFF0000        # =1 if has a new keycode ?                                  
				# Auto clear after lw 
#.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte 
#.eqv DISPLAY_READY 0xFFFF0008  # =1 if the display has already to do                                  
				# Auto clear after sw 

.data
L :	.asciiz "a"
R : 	.asciiz "d"
U: 	.asciiz "w"
D: 	.asciiz "s"
C :     .asciiz "b"

.text	
	li $k0, KEY_CODE 	# chua ký tu nhap vao     
	#li $k1, KEY_READY	# kiem tra da nhap phim nao chua  
	#li $s2, DISPLAY_CODE	# hien thi ky tu  
	#li $s1, DISPLAY_READY	# kiem tra xem man hinh da san sang hien thi chua
	
	addi	$s7, $0, 512			#store the width in s7
	addi 	$s0, $0, 0x00FF0000		#pass the colour through to s0 - for every param the colour is s0, a0-3 are the xy + size params
	#circle:
	addi	$a0, $0, 256		#x = 256
	addi	$a1, $0, 256		#y = 256	
	addi	$a2, $0, 20		#r = 20
	addi 	$s0, $0, 0x00FFFF66
	jal 	DrawCircle	
	nop
moving:
	
	beq $t0,97,left     			#so sanh t0 kiem tra phim nhap vao(A)
	beq $t0,100,right			#so sanh t0 kiem tra phim nhap vao(D)
	beq $t0,115,down			#so sanh t0 kiem tra phim nhap vao(S)
	beq $t0,119,up				#so sanh t0 kiem tra phim nhap vao(W)
	j Input
	
	left: 					#di chuyen hinh sang trai
		addi $s0,$0,0x00000000		# dat mau hinh tron thanh mau den
		jal DrawCircle		 	#xoa hinh o vi tri cu(ve hinh cu trung vs mau nen)
		addi $a0,$a0,-1			# giam x di 1
		add $a1,$a1, $0			#giu nguyen y
		addi $s0,$0,0x00FFFF66		#dat mau hinh tron thanh mau vang
		jal DrawCircle			# ve hinh o vi tri moi
		jal Pause			#Thoi gian cho truoc khi thuc hien lenh tiep theo
		bltu $a0,20,reboundRight  	#So sanh toa do x voi 20 neu nho hon 20 thi nay lai
		j Input
	right: 					#di chuyen hinh sang phai
		addi $s0,$0,0x00000000		# dat mau hinh tron thanh mau den
		jal DrawCircle			#xoa hinh o vi tri cu(ve hinh cu trung vs mau nen)
		addi $a0,$a0,1			#tang x len 1
		add $a1,$a1, $0			#giu nguyen y
		addi $s0,$0,0x00FFFF66		#dat mau hinh tron thanh mau vang
		jal DrawCircle			# ve hinh o vi tri moi
		jal Pause			#Thoi gian cho truoc khi thuc hien lenh tiep theo
		bgtu $a0,492,reboundLeft	#So sanh toa do x voi 492 neu lon hon 492 thi nay lai
		j Input
	up: 					#di chuyen hinh len tren
		addi $s0,$0,0x00000000		# dat mau hinh tron thanh mau den
		jal DrawCircle			#xoa hinh o vi tri cu(ve hinh cu trung vs mau nen)
		addi $a1,$a1,-1			#giam y di 1
		add $a0,$a0,$0			#giu nguyen x
		addi $s0,$0,0x00FFFF66		#dat mau hinh tron thanh mau vang
		jal DrawCircle			# ve hinh o vi tri moi
		jal Pause			#Thoi gian cho truoc khi thuc hien lenh tiep theo
		bltu $a1,20,reboundDown		#So sanh toa do y voi 20 neu nho hon 20 thi nay lai
		j Input
	down: 					#di chuyen hinh xuong duoi
		addi $s0,$0,0x00000000		# dat mau hinh tron thanh mau den
		jal DrawCircle			#xoa hinh o vi tri cu(ve hinh cu trung vs mau nen)
		addi $a1,$a1,1			#tang y len 1
		add $a0,$a0,$0			#giu nguyen x
		addi $s0,$0,0x00FFFF66		#dat mau hinh tron thanh mau vang
		jal DrawCircle			# ve hinh o vi tri moi
		jal Pause			#Thoi gian cho truoc khi thuc hien lenh tiep theo
		bgtu $a1,492,reboundUp		#So sanh toa do y voi 20 neu nho hon 20 thi nay lai
		j Input
	reboundLeft:				#Nay lai khi dap vao canh phai
		li $t3 97			
		sw $t3,0($k0)			#Gan keycode= A
		j Input
	reboundRight:				#Nay lai khi dap vao canh trai
		li $t3 100
		sw $t3,0($k0)			#Gan keycode= D
		j Input
	reboundDown:				#Nay lai khi dap vao canh tren
		li $t3 115
		sw $t3,0($k0)			#Gan keycode= S
		j Input
	reboundUp:				#Nay lai khi dap vao canh duoi
		li $t3 119
		sw $t3,0($k0)			#Gan keycode= W
		j Input
endMoving:...
Input:						#Kiem tra dau vao
	#WaitForKey: 
	#lw   $t1, 0($k1)            # $t1 = [$k1] = KEY_READY              
	#beq  $t1, $zero, WaitForKey # if $t1 == 0 then Polling   
	ReadKey: lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
	j moving
	
	
Pause:						#Delay
	addiu $sp,$sp,-4			#adjust stack for 1 item
	sw $a0, ($sp)				# luu lai $a0
	la $a0,5				# speed =20ms
	li $v0, 32			 	#syscall value for sleep
	syscall
	lw $a0,($sp)				#Lay lai $a0 da luu
	addiu $sp,$sp,4				#pop 1 item from stack
	jr $ra
######################################################################################
# Cach ve hinh tron: Ve 1/8 hinh tron va doi cho toa do x,y so voi tam duong tron    #
#voi nhau de duoc 1 hinh tron hoan thien					     #		
######################################################################################
DrawCircle:					#ve hinh tron voi dau vao:
	#a0 = cx
	#a1 = cy
	#a2 = radius
	#s0 = colour
	
	addiu	$sp, $sp, -32			#Luu tru cac thanh ghi vao stack
	sw 	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s2, 4($sp)
	sw	$s0, ($sp)
	
	#code goes here
	sub	$s2, $0, $a2			#error =  -radius
	add	$s3, $0, $a2			#x = radius
	add	$s4, $0, $0			#y = 0 (s4)
	
	DrawCircleLoop:				#Vong lap ve tung diem cua hinh tron
	bgt 	$s4, $s3, exitDrawCircle	#if y is greater than x, break the loop (while loop x >= y)
	nop
	
	#plots 4 points along the right of the circle, then swaps the x and y and plots the opposite 4 points
	jal	plot8points
	nop
	
	add	$s2, $s2, $s4			#error += y
	addi	$s4, $s4, 1			#++y
	add	$s2, $s2, $s4			#error += y
	
	blt	$s2, 0, DrawCircleLoop		#if error <= 0, start loop again
	nop
	
	sub	$s3, $s3, 1			#--x
	sub	$s2, $s2, $s3			#error -= x
	sub	$s2, $s2, $s3			#error -= x
	
	j	DrawCircleLoop
	nop	
	
	exitDrawCircle:
	
	lw	$s0, ($sp)			#khoi phuc cac thanh ghi da luu
	lw	$s2, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$a2, 16($sp)
	lw	$a1, 20($sp)
	lw	$a0, 24($sp)
	lw	$ra, 28($sp)
	
	addiu	$sp, $sp, 32			#lay cac gia tri tu stack
	
	jr 	$ra
	nop
	
plot8points:
	addiu	$sp, $sp -4
	sw	$ra, ($sp)
	
	jal	plot4points
	nop
	
	beq 	$s4, $s3, skipSecondplot
	nop
	
	#swap y and x, and do it again
	add	$t2, $0, $s4			#puts y into t2
	add	$s4, $0, $s3			#puts x in to y
	add	$s3, $0, $t2			#puts y in to x
	
	jal	plot4points
	nop
	
	#swap them back
	add	$t2, $0, $s4			#puts y into t2
	add	$s4, $0, $s3			#puts x in to y
	add	$s3, $0, $t2			#puts y in to x
		
	skipSecondplot:
		
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4
	
	jr	$ra
	nop
	
plot4points:
	#plots 4 points along the right side of the circle, then swaps the cd and cy values to do the opposite side
	#if statements are for optimisation, they work if the branches are removed
	addiu	$sp, $sp -4
	sw	$ra, ($sp)
	
	#$a0 = a0 + s3, $a2 = a1 + s4
	add	$t0, $0, $a0			#store a0 (cx in t0)
	add	$t1, $0, $a1			#store a2 (cy in t1)
	
	add	$a0, $t0, $s3			#set a0 (x for the setpixel, to cx + x)
	add	$a2, $t1, $s4			#set a2 (y for setPixel to cy + y)
	
	jal	SetPixel			#draw the first pixel
	nop
	
	sub	$a0, $t0, $s3			#cx - x
	#add	$a2, $t1, $s4			#cy + y
	
	beq	$s3, $0, skipXnotequal0 	#if s3 (x) equals 0, skip
	nop
	
	jal 	SetPixel			#if x!=0 (cx - x, cy + y)
	nop	

	skipXnotequal0:	
	sub	$a2, $t1, $s4			#cy - y (a0 already equals cx - x
	jal 	SetPixel			#no if	 (cx - x, cy - y)
	nop
	
	add	$a0, $t0, $s3
	
	beq	$s4, $0, skipYnotequal0 	#if s4 (y) equals 0, skip
	nop
	
	jal	SetPixel			#if y!=0 (cx + x, cy - y)
	nop
	
	skipYnotequal0:
	
	add	$a0, $0, $t0			
	add	$a2, $0, $t1			
	
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4
	
	jr	$ra
	nop
SetPixel:
	#a0 x
	#a1 y
	#s0 colour
	addiu	$sp, $sp, -20			# Save return address on stack
	sw	$ra, 16($sp)
	sw	$s1, 12($sp)
	sw	$s0, 8($sp)			# Save original values of a0, s0, a2
	sw	$a0, 4($sp)
	sw	$a2, ($sp)

	lui	$s1, 0x1001			#starting address of the screen	
	sll	$a0, $a0, 2 			#multiply 4
	add	$s1, $s1, $a0			#x co-ord addded to pixel position
	mul  	$a2, $a2, $s7			#multiply by width (s7 declared at top of program, never saved and loaded and it should never be changed)
	mul	$a2, $a2, 4			#myltiply by the size of the pixels (4)
	add	$s1, $s1, $a2			#add y co-ord to pixel position

	sw	$s0, ($s1)			#stores the value of colour into the pixels memory address
	
	lw	$a2, ($sp)			#retrieve original values and return address
	lw	$a0, 4($sp)
	lw	$s0, 8($sp)
	lw	$s1, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20	
	
	jr	$ra
	nop
	
