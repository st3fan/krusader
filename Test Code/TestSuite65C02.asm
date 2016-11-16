BS	.=  $08		; backspace
SP	.=  $20		; space
CR	.=  $0D		; carriage return
LF	.=  $0A		; line feed
ESC	.=  $1B		; escape
INMASK  .=  $7F

OUTCH	.=  $FFEF	; Apple 1 Echo
PRHEX	.=  $FFE5	; Apple 1 Echo
OUTHEX	.=  $FFDC	; Apple 1 Print Hex Byte Routine
KBD     .=  $D010	; Apple 1 Keyboard character read.
KBDRDY  .=  $D011	; Apple 1 Keyboard data waiting when negative.

B1      .=  $5
B2      .=  $E5
W1      .=  $123
W2      .=  $CDCB

ALTEND  .= $1F

SRCL    .=  $10
SRCH    .=  $11

MAIN
	JSR TSTINZ
	JSR TSTSTZ
	JSR TSTBIT
	JSR TSTJMP
	JSR TSTSNG
	JSR TSTEXP
	RTS
	
ERROR
	LDX #$00
.LOOP	LDA .MSG,X
	BEQ .DONE
	JSR OUTCH
	INX
	BNE .LOOP
.DONE	LDA SRCH
	JSR OUTHEX
	LDA SRCL
	JSR OUTHEX
	JSR CRLF
	RTS

.MSG	.S 'ERROR'
	.B SP
	.S 'IN'
	.B SP
	.S 'ROUTINE'
	.B SP
	.S 'AT'
	.B SP
	.S 'ADDRESS'
	.B SP
	.B $00

TSTINZ	.M

ORAINZ .= $12
ANDINZ .= $32
EORINZ .= $52
ADCINZ .= $72
STAINZ .= $92
LDAINZ .= $B2
CMPINZ .= $D2
SBCINZ .= $F2

.TEST	LDA #<.TEST	; SAVE ADDRESS OF THIS ROUTINE
	STA SRCL
	LDA #>.TEST
	STA SRCH
	LDX #$FF
.LOOP	INX
	LDA .SRC,X
	BEQ .DONE
	CMP .DATA,X
	BEQ .LOOP
	JSR ERROR
.DONE	RTS

.SRC	ORA ($5)	; INDEXED ZERO PAGE
	ORA ($E5)
	ORA (B1)
	ORA (B2)
	
	AND ($5)	
	AND ($E5)
	AND (B1)
	AND (B2)
	
	EOR ($5)	
	EOR ($E5)
	EOR (B1)
	EOR (B2)
	
	ADC ($5)	
	ADC ($E5)
	ADC (B1)
	ADC (B2)
	
	STA ($5)	
	STA ($E5)
	STA (B1)
	STA (B2)
	
	LDA ($5)	
	LDA ($E5)
	LDA (B1)
	LDA (B2)
	
	CMP ($5)	
	CMP ($E5)
	CMP (B1)
	CMP (B2)
	
	SBC ($5)	
	SBC ($E5)
	SBC (B1)
	SBC (B2)
	
	.B $00	; indicates end of source
	
.DATA	.B ORAINZ
	.B $5
	.B ORAINZ
	.B $E5
	.B ORAINZ
	.B B1
	.B ORAINZ
	.B B2	
	
	.B ANDINZ
	.B $5
	.B ANDINZ
	.B $E5
	.B ANDINZ
	.B B1
	.B ANDINZ
	.B B2
	
	.B EORINZ
	.B $5
	.B EORINZ
	.B $E5
	.B EORINZ
	.B B1
	.B EORINZ
	.B B2	
	
	.B ADCINZ
	.B $5
	.B ADCINZ
	.B $E5
	.B ADCINZ
	.B B1
	.B ADCINZ
	.B B2
	
	.B STAINZ
	.B $5
	.B STAINZ
	.B $E5
	.B STAINZ
	.B B1
	.B STAINZ
	.B B2
	
	.B LDAINZ
	.B $5
	.B LDAINZ
	.B $E5
	.B LDAINZ
	.B B1
	.B LDAINZ
	.B B2
	
	.B CMPINZ
	.B $5
	.B CMPINZ
	.B $E5
	.B CMPINZ
	.B B1
	.B CMPINZ
	.B B2
	
	.B SBCINZ
	.B $5
	.B SBCINZ
	.B $E5
	.B SBCINZ
	.B B1
	.B SBCINZ
	.B B2

; STZ

TSTSTZ

STZZPG .= $64
STZZPX .= $74
STZABS .= $9C
STZABX .= $9E

.TEST	LDA #<.TEST	; SAVE ADDRESS OF THIS ROUTINE
	STA SRCL
	LDA #>.TEST
	STA SRCH
	LDX #$FF
.LOOP	INX
	LDA .SRC,X
	BEQ .DONE
	CMP .DATA,X
	BEQ .LOOP
	JSR ERROR
.DONE	RTS

.SRC	STZ $5		; ZERO PAGE LOCATIONS
	STZ $E5
	STZ B1
	STZ B2

	STZ $5,X	; ZERO PAGE INDEXED,X
	STZ $E5,X
	STZ B1,X
	STZ B2,X
	
	STZ $123	; ABSOLUTE LOCATIONS
	STZ $CDCB
	STZ W1
	STZ W2
	
	STZ $123,X	; ABSOLUTE INDEXED,X
	STZ $CDCB,X
	STZ W1,X
	STZ W2,X
	
	.B $00	; indicates end of source
	
.DATA	.B STZZPG
	.B $5
	.B STZZPG
	.B $E5
	.B STZZPG
	.B B1
	.B STZZPG
	.B B2
	
	.B STZZPX
	.B $5 
	.B STZZPX
	.B $E5
	.B STZZPX
	.B B1
	.B STZZPX
	.B B2	
	
	.B STZABS
	.W $123
	.B STZABS
	.W $CDCB
	.B STZABS
	.W W1
	.B STZABS
	.W W2
	
	.B STZABX
	.W $123
	.B STZABX
	.W $CDCB
	.B STZABX
	.W W1
	.B STZABX
	.W W2

; BIT

TSTBIT

BITIMM .= $89
BITZPX .= $34
BITABX .= $3C
TSBZPG .= $04
TSBABS .= $0C
TRBZPG .= $14
TRBABS .= $1C

.TEST	LDA #<.TEST	; SAVE ADDRESS OF THIS ROUTINE
	STA SRCL
	LDA #>.TEST
	STA SRCH
	LDX #$FF
.LOOP	INX
	LDA .SRC,X
	BEQ .DONE
	CMP .DATA,X
	BEQ .LOOP
	JSR ERROR
.DONE	RTS

.SRC	BIT #$5		; CONSTANTS
	BIT #$E5	
	BIT #B1
	BIT #B2

	BIT $5,X	; ZERO PAGE INDEXED,X
	BIT $E5,X
	BIT B1,X
	BIT B2,X
	
	BIT $123,X	; ABSOLUTE INDEXED,X
	BIT $CDCB,X
	BIT W1,X
	BIT W2,X
	
	TSB $5		; ZERO PAGE LOCATIONS
	TSB $E5
	TSB B1
	TSB B2
	
	TSB $123	; ABSOLUTE LOCATIONS
	TSB $CDCB
	TSB W1
	TSB W2
	
	TRB $5		; ZERO PAGE LOCATIONS
	TRB $E5
	TRB B1
	TRB B2
	
	TRB $123	; ABSOLUTE LOCATIONS
	TRB $CDCB
	TRB W1
	TRB W2
	
	.B $00	; indicates end of source
	
.DATA	.B BITIMM
	.B $5
	.B BITIMM
	.B $E5
	.B BITIMM
	.B B1
	.B BITIMM
	.B B2	
	
	.B BITZPX
	.B $5
	.B BITZPX
	.B $E5
	.B BITZPX
	.B B1
	.B BITZPX
	.B B2	
	
	.B BITABX
	.W $123
	.B BITABX
	.W $CDCB
	.B BITABX
	.W W1
	.B BITABX
	.W W2
	
	.B TSBZPG
	.B $5
	.B TSBZPG
	.B $E5
	.B TSBZPG
	.B B1
	.B TSBZPG
	.B B2
	
	.B TSBABS
	.W $123
	.B TSBABS
	.W $CDCB
	.B TSBABS
	.W W1
	.B TSBABS
	.W W2
	
	.B TRBZPG
	.B $5
	.B TRBZPG
	.B $E5
	.B TRBZPG
	.B B1
	.B TRBZPG
	.B B2
	
	.B TRBABS
	.W $123
	.B TRBABS
	.W $CDCB
	.B TRBABS
	.W W1
	.B TRBABS
	.W W2

; JMP AND BRA

TSTJMP

JMPIAX .= $7C
BRAREL .= $80

.TEST	LDA #<.TEST	; SAVE ADDRESS OF THIS ROUTINE
	STA SRCL
	LDA #>.TEST
	STA SRCH
	LDX #$FF
.LOOP	INX
	LDA .SRC,X
	CMP #ALTEND
	BEQ .DONE
	CMP .DATA,X
	BEQ .LOOP
	JSR ERROR
.DONE	RTS

.SRC	JMP ($1,X)	; ABSOLUTE INDIRECT INDEXED
	JMP ($CD,X)
	JMP ($123,X)
	JMP ($CDCB,X)
	JMP (B1,X)
	JMP (B2,X)
	JMP (W1,X)
	JMP (W2,X)
	
.BRA	BRA .BRA
	BRA .BRA+80
	BRA .BRA+2
	BRA .BRA-5
	BRA *
	BRA *+17
	BRA *-75
	
	.B ALTEND	; indicates end of source
	
.DATA	.B JMPIAX
	.W $1
	.B JMPIAX
	.W $CD
	.B JMPIAX
	.W $123
	.B JMPIAX
	.W $CDCB
	.B JMPIAX
	.W B1
	.B JMPIAX
	.W B2
	.B JMPIAX
	.W W1
	.B JMPIAX
	.W W2

	.B BRAREL
	.B $FE
	.B BRAREL
	.B $7C
	.B BRAREL
	.B $FC
	.B BRAREL
	.B $F3
	.B BRAREL
	.B $FE
	.B BRAREL
	.B $15
	.B BRAREL
	.B $89	
	
; SINGLE BYTE INSTRUCTIONS

TSTSNG

.TEST	LDA #<.TEST	; SAVE ADDRESS OF THIS ROUTINE
	STA SRCL
	LDA #>.TEST
	STA SRCH
	LDX #$FF
.LOOP	INX
	LDA .SRC,X
	BEQ .DONE
	CMP .DATA,X
	BEQ .LOOP
	JSR ERROR
.DONE	RTS

.SRC	INA 
	DEA
	PHY
	PLY
	PHX
	PLX
	
	.B $00	; indicates end of source
	
.DATA	.B $1A
	.B $3A
	.B $5A
	.B $7A
	.B $DA
	.B $FA

; VARIOUS EXPRESSIONS

TSTEXP

.TEST	LDA #<.TEST	; SAVE ADDRESS OF THIS ROUTINE
	STA SRCL
	LDA #>.TEST
	STA SRCH
	LDX #$FF
.LOOP	INX
	LDA .SRC,X
	CMP #ALTEND
	BEQ .DONE
	CMP .DATA,X
	BEQ .LOOP
	JSR ERROR
.DONE	RTS

.SRC	CMP ($5+25)	; INDEXED ZERO PAGE
	CMP ($E5-5)
	CMP (<B1-25)
	CMP (B2+5)
	CMP (<$123+5)	
	CMP (<$CDCB-25)
	CMP (<W1-25)
	CMP (<W2+5)
	CMP (>$123-5)	
	CMP (>$CDCB+25)
	CMP (>W1+25)
	CMP (>W2-5)
	
	JMP ($5+25,X)	; ABSOLUTE INDEXED INDIRECT,X
	JMP ($E5-5,X)
	JMP (B1+5,X)
	JMP (B2-25,X)
	JMP (>$123-5,X)	
	JMP (>$CDCB+25,X)
	JMP (>W1-25,X)
	JMP (>W2+5,X)
	JMP (<$123+5,X)	
	JMP (<$CDCB-25,X)
	JMP (<W1+25,X)
	JMP (<W2-5,X)
	JMP ($123-5,X)	
	JMP ($CDCB+25,X)
	JMP (W1-25,X)
	JMP (W2+5,X)
	
	.B ALTEND	; indicates end of source
	
.DATA	.B CMPINZ
	.B $2A
	.B CMPINZ
	.B $E0
	.B CMPINZ
	.B $E0
	.B CMPINZ
	.B $EA
	.B CMPINZ
	.B $28
	.B CMPINZ
	.B $A6
	.B CMPINZ
	.B $FE
	.B CMPINZ
	.B $D0
	.B CMPINZ
	.B $01
	.B CMPINZ
	.B $CD
	.B CMPINZ
	.B $01
	.B CMPINZ
	.B $CD
	
	.B JMPIAX
	.W $2A
	.B JMPIAX
	.W $E0
	.B JMPIAX
	.W $0A
	.B JMPIAX
	.W $C0
	.B JMPIAX
	.W $01
	.B JMPIAX
	.W $CD
	.B JMPIAX
	.W $00
	.B JMPIAX
	.W $CD
	.B JMPIAX
	.W $28
	.B JMPIAX
	.W $A6
	.B JMPIAX
	.W $48
	.B JMPIAX
	.W $C6
	.B JMPIAX
	.W $011E
	.B JMPIAX
	.W $CDF0
	.B JMPIAX
	.W $FE
	.B JMPIAX
	.W $CDD0
	
; ****************************************
; I/O routines
; ****************************************

OUTSP	
	LDA #SP
	JMP OUTCH
	
CRLF			; Go to a new line.
	LDA #CR		; 'CR'
	JMP OUTCH

GETCH   		; Get a character from the keyboard.
	LDA KBDRDY
	BPL GETCH
	LDA KBD
	AND #INMASK
	RTS	
