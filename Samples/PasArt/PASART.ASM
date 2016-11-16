; Constants

BS	.= $08		; backspace
SP	.= $20		; space
CR	.= $0D		; carriage return
LF	.= $0A		; line feed
ESC	.= $1B		; escape
INMASK  .= $7F
FAIL	.= $FF
	
; Zero page storage	
ALO	.= $00		; Address of the data array
AHI	.= $01
SIZEX	.= $02		; use a SIZEX rows by SIZEY columns display	
SIZEY	.= $03
STYLE	.= $04		; store 0, 1 or 2 for 1, 2 or 4 triangles
MOD	.= $05
TEMPLO	.= $06		; Address of particular element
TEMPHI	.= $07
CURVAL	.= $08
SAVX	.= $09		; Store X and Y values here
SAVY	.= $0A
TEMPX	.= $0B		; modified sizes stored here when necessary
TEMPY	.= $0C
SCRTCH	.= $0D
INBUF	.= TEMPLO
SYMBLS	.= $10
	
MAIN	.M
	JSR CRLF
	LDA #SP
	STA SYMBLS
	LDA #$0
	STA ALO
	LDA #$10
	STA AHI
	JSR INPUTS
	JSR CALC
	JSR DRAW
	JSR GETCH
	CMP #ESC
	BNE MAIN
	RTS
	
ROWSZ	.= $6
ROWS	.B  SP
	.S '?SWOR'
COLSZ	.= $9
COLS	.B  SP
	.S '?SNMULOC'
SYMSZ	.= $9
SYMS	.B  SP
	.S '?SLOBMYS'
STYLSZ	.= $F
STYLES	.B  SP
	.S '?)3,2,1('
	.B  SP
	.S 'ELYTS'

INPUTS	.M
.ROW	LDX #ROWSZ
.LOOP1	LDA ROWS-1,X
	JSR OUTCH
	DEX
	BNE .LOOP1
	LDA SIZEX
	JSR INPUT
	CMP #$3
	BMI .ROW
	STA SIZEX
	STA TEMPX
.COL	LDX #COLSZ
.LOOP2	LDA COLS-1,X
	JSR OUTCH
	DEX
	BNE .LOOP2
	LDA SIZEY
	JSR INPUT
	CMP #$3
	BMI .COL
	CMP #$28
	BPL .COL
	STA SIZEY
	STA TEMPY
.SYM	LDX #SYMSZ
.LOOP3	LDA SYMS-1,X
	JSR OUTCH
	DEX
	BNE .LOOP3
.SLOOP	JSR GETCH
	CMP #ESC
	BNE .GET
	PLA
	PLA
	RTS
.GET	CMP #CR
	BEQ .MOD
	PHA
	JSR OUTCH
	PLA
	INX
	STA SYMBLS,X
	BNE .SLOOP
.MOD	TXA
	BEQ .KEEP
	INX
	STX MOD
.KEEP	JSR CRLF
.STYL	LDX #STYLSZ
.LOOP4	LDA STYLES-1,X
	JSR OUTCH
	DEX
	BNE .LOOP4
	INC STYLE
	LDA STYLE
	JSR INPUT
	BEQ .STYL
	CMP #$4
	BPL .STYL
	STA STYLE
	DEC STYLE
.DONE	RTS
	
INPUT	.M
	STA SCRTCH		; save default value
	LDX #$0
	STX INBUF
	STX INBUF+1
	STX INBUF+2
.NEXT	JSR GETCH
	CMP #ESC
	BNE .SKIP
	PLA
	PLA
	PLA
	PLA
	RTS
.SKIP	JSR OUTCH
	CMP #CR
	BEQ .CVT
	STA INBUF,X
	INX
	BNE .NEXT
.CVT	TXA
	BEQ .SAME
	JSR BYT2D
	RTS
.SAME	LDA SCRTCH
	RTS
	
CALC	.M		; Loop over all rows and columns to calculate the data array
	LDX #$1
	LDA STYLE
	BEQ .LOOPX
	CMP #$1
	BNE .SKIP
	DEC TEMPX
	BNE .LOOPX
.SKIP	LDA SIZEX	; halve the sizes for this style
	LSR
	ADC #$0
	STA TEMPX
	LDA SIZEY
	LSR
	ADC #$0
	STA TEMPY
.LOOPX	LDY #$1
.LOOPY	LDA #$0
	STX SAVX
	STY SAVY
	DEX
	JSR GETVAL	; get address and value for a(i-1,j)
	STA CURVAL	; store the value
	INX
	DEY
	JSR GETVAL	; get address and value for a(i,j-1)
	INY
	CLC
	ADC CURVAL	; do the sum
	JSR AMODA	; do the modulus
	PHA		; and save the result
	JSR GETADR	; get address for a(i,j)
	PLA		; retrieve the result
	LDX #$0
	STA (TEMPLO,X)	; save to the data array	
	LDX STYLE
	BEQ .0
	DEX
	BEQ .1
	PHA
	LDX SAVX	; 4 triangles .= > 3 copies
	JSR Y2CMY
	JSR GETADR
	PLA
	PHA
	LDX #$0
	STA (TEMPLO,X)
	LDX SAVX
	LDY SAVY
	JSR X2RMX
	JSR GETADR
	PLA
	PHA
	LDX #$0
	STA (TEMPLO,X)
	SEC
	BCS .COPY	
.1	PHA
	LDA SIZEY	; 2 triangles, so copy value and adjust limit
	SEC		; range of Y is from 0 to SIZEY - X
	SBC SAVX
	STA TEMPY
.COPY	LDX SAVX	; restore X
	JSR X2RMX
	JSR Y2CMY
	JSR GETADR
	PLA
	LDX #$0
	STA (TEMPLO,X)	; save to the data array
.0	LDX SAVX	; restore X
	LDY SAVY	; restore Y
	INY
	CPY TEMPY
	BNE .LOOPY
	INX
	CPX TEMPX
	BNE .LOOPX
	RTS

AMODA	.M		; A -> A MOD MOD
	SEC
	SBC MOD
	BEQ .DONE
	BPL AMODA
	CLC
	ADC MOD
.DONE	RTS
	
X2RMX	.M		; input X, return X .=  SIZEX - X - 1
			; preserve A
	PHA
	LDA SIZEX
	SEC
	SBC SAVX
	TAX
	DEX
	PLA
	RTS

Y2CMY	.M		; input Y, return Y .=  SIZEY - Y - 1
			; preserve A
	PHA
	LDA SIZEY
	SEC
	SBC SAVY
	TAY
	DEY
	PLA
	RTS
	
DRAW	.M		; Loop over all rows and columns to draw the array
	LDX #$0
.LOOPX	LDY #$0
	JSR CRLF
.LOOPY	JSR GETVAL	; get value for a(i,j)
	STX SAVX
	TAX
	LDA SYMBLS,X
	LDX SAVX
.PRINT	JSR OUTCH
	INY
	CPY SIZEY
	BNE .LOOPY
	INX
	CPX SIZEX
	BNE .LOOPX
	RTS

GETVAL	.M		; if either index is 0, answer is 1
			; also any edge value for combined triangles is 1
	TXA		; check X for boundary value
	BEQ .BNDRY
	TYA		; check Y for boundary value
	BEQ .BNDRY
	LDA STYLE
	BEQ .SKIP
	TXA
	SEC
	SBC SIZEX
	CMP #$FF
	BEQ .BNDRY	
	TYA
	SEC
	SBC SIZEY
	CMP #$FF
	BEQ .BNDRY
.SKIP	JSR GETADR	; get address for a(i,j)
	STX SCRTCH	; save X
	LDX #$0
	LDA (TEMPLO,X)	; get the value
	LDX SCRTCH	; restore X
	CLC
	BCC .DONE
.BNDRY	LDA #$1		; boundary value
.DONE	RTS
	

GETADR	.M		; Put address of the data entry in TEMPLO,HI
			; Row index is in X, column index is in Y
	TXA
	PHA
	LDA AHI
	STA TEMPHI
	LDA ALO
	STA TEMPLO
	CPX #$0		; First calculate I * SIZE
	BEQ .NEXT
	CLC
.LOOP	ADC SIZEY
	STA TEMPLO
	BCC .SKIP
	INC TEMPHI
.SKIP	DEX
	BNE .LOOP
.NEXT	TYA		; Now add J
	ADC TEMPLO
	STA TEMPLO
	BCC .DONE
	INC TEMPHI
.DONE	PLA
	TAX
	RTS
	
; Utility subroutines

BYT2D	.M		; convert the.S byte (1 or 2 chars) at INBUF to decimal
			; result in A ($FF for fail)
	LDA INBUF
	JSR .A2D	
	CMP #FAIL	; indicates conversion error		
	BEQ .ERR
	PHA
	LDA INBUF+1
	JSR .A2D
	CMP #FAIL
	BNE .CONT
	PLA		; just ignore 2nd character
	RTS
.CONT	STA SCRTCH
	PLA
	STA CURVAL
	ASL		; x 2
	ASL		; x 4
	CLC
	ADC CURVAL	; x 5
	ASL		; x 10
	ADC SCRTCH
	RTS
.A2D 	EOR #$30  	; convert.S code in A to a DEC digit
	CMP #$0A  
	BCC .VALID  
.ERR	LDA #FAIL	; this value can never be from a single digit
.VALID	RTS
		
; I/O subroutines
	
CRLF	.M		; Go to a new line.
	LDA #CR		; "CR"
	JMP OUTCH
	
GETCH   .M		; Get a character from the keyboard.
	LDA KBDRDY
	BPL GETCH
	LDA KBD
	AND #INMASK
	RTS
	
	; Apple 1 I/O values
OUTCH	.= $FFEF		; Apple 1 Echo
PRHEX	.= $FFE5		; Apple 1 Echo
OUTHEX	.= $FFDC		; Apple 1 Print Hex Byte Routine
KBD     .= $D010		; Apple 1 Keyboard character read.
KBDRDY  .= $D011		; Apple 1 Keyboard data waiting when negative.
