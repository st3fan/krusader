BS      .= $08          BACKSPACE
SP      .= $20          SPACE
CR      .= $0D          CR
ESC     .= $1B          ESC
INMASK  .= $7F

FAIL    .= $FF

SITES   .= $28
BYTES   .= $5

; ZERO PAGE

TEMP    .= $10
CURROW  .= $15
RULE    .= $1A
MASK    .= $1B
CURENV  .= $1C
SEED    .= $1D
R2FLAG	.= $1E
       
OUTCH   .=$FFEF         ECHO
PRHEX   .=$FFE5         HEX DIGIT
HEXOUT  .=$FFDC         HEX BYTE
KBD     .=$D010         READ KBD
KBDRDY  .=$D011         STROBE

MAIN    .M
        JSR INPUT
        JSR CRLF
.ROW    JSR PRROW
        JSR CPYROW
        LDA #$0
        STA CURENV
	LDY #SITES+1	ALL SITES
	LDA R2FLAG	RADIUS 2?
	BEQ .1
	INY
.1	LDA TEMP+4
	LSR
	PHP		CYCLIC BCS
	LSR
	ROL CURENV
	PLP
	ROL CURENV
	LDA TEMP	
	ROL

.SITE   JSR SHIFT       SHIFT ROW
        ROL CURENV      ADJUST ENV
        TXA
        PHA
        TYA
        PHA
        JSR DORUL       APPLY RULE
        PLA
        TAY
        PLA
        TAX
        ROL CURROW+4
        ROL CURROW+3
        ROL CURROW+2
        ROL CURROW+1
        ROL CURROW
        DEY
        BNE .SITE
.2      LDA KBDRDY
        BPL .ROW
        LDA KBD
        AND #INMASK
        JSR GETCH
        CMP #'M'        TO MENU
        BEQ MAIN
        CMP #ESC        QUIT
        BNE .ROW
.RET    RTS
       
PRROW   .M
        JSR CPYROW
        LDY #SITES     
.SITE   JSR SHIFT
        BCS .SKIP
        JSR OUTSP
        BCC .1
.SKIP   LDA #'*'
        JSR OUTCH       
.1      DEY
        BNE .SITE
        RTS     
      
SHIFT	.M
	ROL TEMP+4
	ROL TEMP+3
	ROL TEMP+2
	ROL TEMP+1
	ROL TEMP
	RTS      
      
DORUL   .M     

; ENVIRONMENT BITS ARE IN A
; CREATE BIT MASK
; APPLY MASK TO RULE
; CARRY HOLDS OUTPUT

        LDA CURENV
	LDY R2FLAG
	BEQ .R1

; R = 2 RULE IMPLEMENTATION	

	AND #$1F
	LDX #$0		; X holds the sum
	LDY #$5		; 5 bits to check
.NEXT	LSR
	BCC .1
	INX
.1	DEY	
	BNE .NEXT
.MASK	LDY #$1
	STY MASK
	TXA
	SEC
	BCS .JOIN
	
; R = 1 RULE IMPLEMENTATION

.R1	AND #$07
	LDX #$1
	STX MASK
	TAX
.JOIN	BEQ .DONE
.LOOP   ASL MASK
        DEX
        BNE .LOOP
.DONE   LDA RULE
        AND MASK
        BNE .SKIP
        CLC
        RTS
.SKIP   SEC
        RTS
               
CPYROW  .M
        LDX #BYTES
.COPY   LDA CURROW-1,X
        STA TEMP-1,X
        DEX
        BNE .COPY
        RTS
       
RLSZ    .=  $6
RL      .B  SP
        .S  '?ELUR'
RDSZ	.=  $8
RD	.B  SP
	.S '?SUIDAR'

; MENU DATA

NUM     .=$03           
MNUDAT  .S  'INITIAL'
        .B  SP
        .S  'STATE:'
        .B  $00
        .S  '1.'
        .B  SP
        .S  'DOT'
        .B  $00
        .S  '2.'
        .B  SP
        .S  'RANDOM'
        .B  $00
        .S  '3.'
        .B  SP
        .S  'ENTER'     
        .B  $00
        .S  '>'
        .B  SP
        .B  $FF

INPUT   .M
        JSR SHOW        SHOW MENU
        JSR GETCH       GET CHOICE
        JSR OUTCH
        CMP #ESC
        BEQ STOP
        SEC
        SBC #'0'       
        CMP #NUM+1      CHECK RANGE
        BCS .CONT       TOO LARGE
        TAX             CHOICE IN X
        BEQ .CONT       TOO SMALL
        JSR CRLF
        DEX
        BNE .NODOT
        LDA #$0
        STA CURROW
        STA CURROW+1
        STA CURROW+3
        STA CURROW+4
        LDA #$10
        STA CURROW+2
        BNE INRD
.NODOT  DEX
        BNE .NORND
        LDX #BYTES
.NEXT   JSR RAND
        STA CURROW-1,X
        JSR RAND
        JSR RAND
        DEX
        BNE .NEXT
        BEQ INRD
.NORND  JMP ENTER
.CONT   JMP MAIN        LOOP BACK
STOP    PLA
        PLA
        RTS
       
SHOW    .M
        JSR CRLF
        LDX #$FF       
.NEXT   INX
        LDA MNUDAT,X
        BNE .NOTEL
        JSR CRLF
        JMP .NEXT
.NOTEL  CMP #$FF
        BEQ .DONE
        JSR OUTCH
        JMP .NEXT
.DONE   RTS

ENTER   .M
        LDA #'?'
        JSR OUTCH
        JSR OUTSP
        LDY #$0         GET THE
.LOOP   JSR INBYT       INITIAL ROW
        STA CURROW,Y
        JSR OUTSP
        INY
        CPY #BYTES
        BNE .LOOP
INRDCR	JSR CRLF
INRD	LDX #RDSZ
.L2	LDA RD-1,X
	JSR OUTCH
	DEX
	BNE .L2
	JSR GETCH
	JSR OUTCH
	CMP #ESC
	BEQ STOP
	CMP #'1'
	BEQ .OK
	CMP #'2'
	BNE INRDCR
.OK	SEC
	SBC #'1'
	STA R2FLAG
INRLCR  JSR CRLF
INRULE  LDX #RLSZ
.L3     LDA RL-1,X
        JSR OUTCH
        DEX
        BNE .L3
        JSR INBYT
        STA RULE
        RTS
       
INBYT   .M
        LDX #$0
.IN1    JSR GET1        GET RULE 1
        STA TEMP+1
        JSR ASC2HX
        CMP #FAIL
        BEQ .IN1
        JSR PRHEX
.IN2    JSR GET1        GET RULE 2
        STA TEMP+2
        JSR ASC2HX
        CMP #FAIL
        BEQ .IN2
        JSR PRHEX
        JSR BYT2HX
        RTS
       
GET1    .M
        JSR GETCH
        CMP #ESC
        BNE .SKIP
        PLA
        PLA
        PLA
        PLA
        PLA
        PLA
.SKIP   RTS
       
RAND
        LDA SEED       
        ASL             
        BCC .OK         
        EOR #$CF       
.OK     STA SEED       
        RTS             
       
BYT2HX  .M             

; CONVRT 1 or 2 BYTES TO HEX
; RESULT IN A ($FF FOR FAIL)
       
        JSR AHARGS     
        CMP #FAIL       ERROR
        BEQ ERR
        PHA     
        JSR AHARG1
        DEX
        CMP #FAIL
        BNE .CONT
        PLA             IGNORE
        RTS
.CONT   STA TEMP
        PLA
        ASL             SHIFT
        ASL
        ASL
        ASL
        ADC TEMP
        RTS

AHARG1  INX             
AHARGS  LDA TEMP+1,X
ASC2HX 

; CONVERT CODE IN A TO A HEX DIGIT

        EOR #$30 
        CMP #$0A 
        BCC .VALID 
        ADC #$88        $89 - CLC 
        CMP #$FA 
        BCC ERR 
        AND #$0F   
.VALID  RTS
ERR     LDA #FAIL       
        RTS             
       
OUTSP   .M
        LDA #SP
        JMP OUTCH
       
CRLF    .M             
        LDA #CR         
        JMP OUTCH
       
GETCH   .M             
        INC SEED
        LDA KBDRDY
        BPL GETCH
        LDA KBD
        AND #INMASK
        RTS      
