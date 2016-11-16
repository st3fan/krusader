; MicroChess (c) 1976-2002 Peter Jennings, peterj@benlo.com

; this version for the integrated macroassembler, simulator and debugger for
; 650x microprocessor family by Michal Kowalski http://home.pacbell.net/michal_k/

; additions and changes by Lee Davison http://members.lycos.co.uk/leeedavison/
; from suggested ASCII routines in the KIM MicroChess programmers notes

; this version is posted with the permission of Peter Jennings, peterj@benlo.com

; display flash during compute move replaced by '?' PROMPT flash
; piece display changed to display piece at 'to' square after each move

; Simulator I/O base addresse is $F000
; Simulator window size is 64 columns x 20 rows

;
; Additional code by Lee Davidson, Darryl Richter and Ken Wessen
; Source formatted for KRUSADER - the Replica 1 Assembler

;  Start a new game by running from location $1000
;  Resume a game by running from location $1009

APPLE1 = 0

; Constants

BS	= $08		; backspace
SP	= $20		; space
CR	= $0D		; carriage return
LF	= $0A		; line feed
ESC	= $1B		; escape
INMASK  = $7F

; page zero variables

MNUCNT		= $40
MENUL		= $41
MENUH		= $42
POPENL		= $43
POPENH		= $44

DIS1		= $4B
DIS2		= $4A
DIS3		= $49
BESTP		= DIS1
BESTV		= DIS2
BESTM		= DIS3

PROMPT		= $4C			; PROMPT character, '?' or ' "
REVRSE		= $4D			; which way round is the display board
COMPW		= $4E

BOARD		= $50
BK		= $60
PIECE		= $B0
SQUARE		= $B1
SP2		= $B2
SP1		= $B3
INCHEK		= $B4
STATE		= $B5
MOVEN		= $B6
OMOVE		= $DC
WCAP0		= $DD
COUNT		= $DE
BCAP2		= $DE
WCAP2		= $DF
BCAP1		= $E0
WCAP1		= $E1
BCAP0		= $E2
MOB		= $E3
MAXC		= $E4
CC		= $E5
PCAP		= $E6
BMOB		= $E3
BMAXC		= $E4
XBCC		= $E5 			; was BCC
BMAXP		= $E6
XMAXC		= $E8
WMOB		= $EB
WMAXC		= $EC
WCC		= $ED
WMAXP		= $EE
PMOB		= $EF
PMAXC		= $F0
PCC		= $F1
PCP		= $F2
OLDKY		= $F3
		
		*=$1000			; load into RAM @ $1000 onwards

START	
	JSR	PRNTC		; print copyright
	JSR 	INIT
	JSR 	SETBRD
	LDA 	COMPW
	AND	#$01
	BEQ	.SKIP		; COMPUTER IS PLAYING WHITE
	BNE	DOREV	
.SKIP	LDA	#$CC	
	STA	DIS3		; Display CCC
CHESS
	CLD				; INITIALIZE
	LDX	#$FF			; TWO STACKS
	TXS	
	LDX	#$C8
	STX	SP2

;	ROUTINES TO LIGHT LED
;	DISPLAY AqND GET KEY
;	FROM KEYBOARD

OUT	JSR	DRWBRD		; draw board
	LDA	#'?'			; PROMPT character
	STA	PROMPT			; save it
GETKEY	JSR	UPDDSP		; update PROMPT & display
	JSR	GETCH			; get key press

	CMP	#'C'			; is it 'C"
	BNE	NOSET			; branch if not

	JSR 	SETBRD			; else set up board
	BNE	CLDSP			; always branches

NOSET	CMP	#'E'			; [E]
	BNE	NOREV			; REVRSE

DOREV	JSR	REV			

	LDA	REVRSE			; get REVRSEd flag
	EOR	#$01			; toggle REVRSE bit
	STA	REVRSE			; save flag

	LDA	#$EE			; IS
	BNE	CLDSP

NOREV	CMP	#'D'			; [D]
	BNE	NODISP			; REDRAW BOARD

	JMP	CHESS

NODISP	CMP	#'P'			; [P]
	BNE	NOGO			; PLAY CHESS

	JSR	CRLF
	JSR	GO
CLDSP	STA	DIS1			; DISPLAY
	;LDA	#$00
	STA	DIS2			; ACROSS
	STA	DIS3			; DISPLAY
	;BEQ	CHESS
	BNE	CHESS

NOGO	CMP	#$0D			; [Enter]
	BNE	NOMV			; MOVE MAN

	LDA 	DIS3
	JSR 	PRTAKE
	JSR	MOVE			; AS ENTERED
;	JSR	DISP2			; piece into display
	JSR	DISP3			; piece into display
	JMP	CHESS			; main loop

NOMV	CMP	#'Q'			; [Q] ***Added to allow game exit***
	BEQ	DONE			; quit the game, exit back to system.

	JMP	INPUT			; process move
DONE	JMP	$FF1F			; *** MUST set this to YOUR OS starting address

SETBRD	LDX	#$1F			; 32 pieces to do
WHSET	LDA	SETW,X			; FROM
	STA	BOARD,X			; SETW
	DEX	
	BPL	WHSET

	LDA	#$00			; no REVRSE
	STA	REVRSE			; set it

	LDX	#$1B			; *ADDED
	STX	OMOVE			; INITS TO $FF
	LDA	#$CC			; Display CCC
	RTS
	
NUMOPN = $0A
OPENSZ = $1C
 
OPENGS
FDW 	.byte $99
	.byte $22
	.byte $06
	.byte $45
	.byte $32
	.byte $0C
	.byte $72
	.byte $14
 	.byte $01
	.byte $63
	.byte $63
	.byte $05
	.byte $64
	.byte $43
	.byte $0F
	.byte $63
 	.byte $41
	.byte $05
	.byte $52
	.byte $25
	.byte $07
	.byte $44
	.byte $34
	.byte $0E
 	.byte $53
	.byte $33
	.byte $0F
	.byte $CC
FDB	.byte $99
	.byte $22
	.byte $07
	.byte $55
 	.byte $32
	.byte $0D
	.byte $45
	.byte $06
	.byte $00
	.byte $63
	.byte $14
	.byte $01
 	.byte $14
	.byte $13
	.byte $06
	.byte $34
	.byte $14
	.byte $04
	.byte $36
	.byte $25
 	.byte $06
	.byte $52
	.byte $33
	.byte $0E
	.byte $43
	.byte $24
	.byte $0F
	.byte $44
GPW	.byte $99
	.byte $25
	.byte $0B
	.byte $25
	.byte $01
	.byte $00
	.byte $33
	.byte $25
 	.byte $07
	.byte $36
	.byte $34
	.byte $0D
	.byte $34
	.byte $34
	.byte $0E
	.byte $52
 	.byte $25
	.byte $0D
	.byte $45
	.byte $35
	.byte $04
	.byte $55
	.byte $22
	.byte $06
 	.byte $43
	.byte $33
	.byte $0F
	.byte $CC
GPB	.byte $99
	.byte $52
	.byte $04
	.byte $52
 	.byte $52
	.byte $06
	.byte $75
	.byte $44
	.byte $06
	.byte $52
	.byte $41
	.byte $04
 	.byte $43
	.byte $43
	.byte $0F
	.byte $43
	.byte $25
	.byte $06
	.byte $52
	.byte $32
 	.byte $04
	.byte $42
	.byte $22
	.byte $07
	.byte $55
	.byte $34
	.byte $0F
	.byte $44
RLW	.byte $99
	.byte $25
	.byte $07
	.byte $66
	.byte $43
	.byte $0E
	.byte $55
	.byte $55
 	.byte $04
	.byte $54
	.byte $13
	.byte $01
	.byte $63
	.byte $34
	.byte $0E
	.byte $33
 	.byte $01
	.byte $00
	.byte $52
	.byte $46
	.byte $04
	.byte $55
	.byte $22
	.byte $06
 	.byte $43
	.byte $33
	.byte $0F
	.byte $CC
RLB	.byte $99
	.byte $06
	.byte $00
	.byte $52
 	.byte $11
	.byte $06
	.byte $34
	.byte $22
	.byte $0B
	.byte $22
	.byte $23
	.byte $06
 	.byte $64
	.byte $14
	.byte $04
	.byte $43
	.byte $44
	.byte $06
	.byte $75
	.byte $25
 	.byte $06
	.byte $31
	.byte $22
	.byte $07
	.byte $55
	.byte $34
	.byte $0F
	.byte $44
QIW	.byte $99
	.byte $25
	.byte $01
	.byte $25
	.byte $15
	.byte $01
	.byte $33
	.byte $25
 	.byte $07
	.byte $72
	.byte $01
	.byte $00
	.byte $63
	.byte $11
	.byte $04
	.byte $66
 	.byte $21
	.byte $0A
	.byte $56
	.byte $22
	.byte $06
	.byte $53
	.byte $35
	.byte $0D
 	.byte $52
	.byte $34
	.byte $0E
	.byte $CC
QIB	.byte $99
	.byte $35
	.byte $0C
	.byte $52
 	.byte $52
	.byte $06
	.byte $62
	.byte $44
	.byte $06
	.byte $52
	.byte $06
	.byte $00
 	.byte $75
	.byte $14
	.byte $04
	.byte $66
	.byte $11
	.byte $05
	.byte $56
	.byte $21
 	.byte $0B
	.byte $55
	.byte $24
	.byte $0F
	.byte $42
	.byte $25
	.byte $06
	.byte $43
FKW	.byte $99
	.byte $03
	.byte $02
	.byte $63
	.byte $25
	.byte $0B
	.byte $25
	.byte $41
 	.byte $05
	.byte $54
	.byte $24
	.byte $0E
	.byte $72
	.byte $01
	.byte $00
	.byte $36
 	.byte $46
	.byte $04
	.byte $52
	.byte $25
	.byte $07
	.byte $55
	.byte $22
	.byte $06
 	.byte $43
	.byte $33
	.byte $0F
	.byte $CC
FKB	.byte $99
	.byte $03
	.byte $07
	.byte $74
 	.byte $14
	.byte $01
	.byte $52
	.byte $52
	.byte $04
	.byte $36
	.byte $23
	.byte $0E
 	.byte $53
	.byte $06
	.byte $00
	.byte $75
	.byte $41
	.byte $04
	.byte $31
	.byte $25
 	.byte $06
	.byte $52
	.byte $22
	.byte $07
	.byte $55
	.byte $34
	.byte $0F
	.byte $44

;	THE ROUTINE JANUS DIRECTS THE
;	ANALYSIS BY DETERMINING WHAT
;	SHOULD OCCUR AFTER EACH MOVE
;	GENERATED BY GNM

JANUS
	LDX	STATE
	BMI	NOCNT

;	THIS ROUTINE COUNTS OCCURRENCES
;	IT DEPENDS UPON STATE TO INDEX
;	THE CORRECT COUNTERS

COUNTS	LDA	PIECE
	BEQ	OVER			; IF STATE=8
	CPX 	#$08			; DO NOT COUNT
	BNE	OVER			; BLK MAX CAP
	CMP	BMAXP			; MOVES FOR
	BEQ	XRT			; WHITE

OVER	INC	MOB,X			; MOBILITY
	CMP 	#$01			;	+ QUEEN
	BNE	NOQ			; FOR TWO
	INC	MOB,X

NOQ	BVC	NOCAP
	LDY	#$0F			; CALCULATE
	LDA	SQUARE			; POINTS
ELOOP	CMP	BK,Y			; CAPTURED
	BEQ	FOUN			; BY THIS
	DEY				; MOVE
	BPL	ELOOP
FOUN	LDA	POINTS,Y
	CMP	MAXC,X
	BCC	LESS			; SAVE IF
	STY	PCAP,X			; BEST THIS
	STA	MAXC,X			; STATE

LESS	CLC
	PHP				; ADD TO
	ADC	CC,X			; CAPTURE
	STA	CC,X			; COUNTS
	PLP

NOCAP	CPX	#$04
	BEQ	ON4
	BMI	TREE			; (=00 ONLY)
XRT	RTS

;	GENERATE FURTHER MOVES FOR COUNT
;	AND ANALYSIS

ON4	LDA	XMAXC			; SAVE ACTUAL
	STA	WCAP0			; CAPTURE
	LDA	#$00			; STATE=0
	STA	STATE
	JSR	MOVE			; GENERATE
	JSR	REV			; IMMEDIATE
	JSR	GNMZ			; REPLY MOVES
	JSR	REV

	LDA	#$08			; STATE=8
	STA	STATE			; GENERATE
	JSR	GNM			; CONTINUATION
	JSR	UMOVE			; MOVES

	JMP	STRAT			; FINAL EVALUATION
NOCNT
	CPX	#$F9
	BNE	TREE

;	DETERMINE IF THE KING CAN BE
;	TAKEN, USED BY CHKCHK

	LDA	BK			; IS KING
	CMP	SQUARE			; IN CHECK?
	BNE	RETJ			; SET INCHEK=0
	LDA	#$00			; IF IT IS
	STA	INCHEK
RETJ	RTS

;	IF A PIECE HAS BEEN CAPTURED BY
;	A TRIAL MOVE, GENERATE REPLIES &
;	EVALUATE THE EXCHANGE GAIN/LOSS

TREE
	BVC	RETJ			; NO CAP
	LDY	#$07			; (PIECES)
	LDA	SQUARE
LOOPX	CMP	BK,Y
	BEQ	FOUNX
	DEY	
	BEQ	RETJ			; (KING)
	BPL	LOOPX			; SAVE
FOUNX	LDA	POINTS,Y		; BEST CAP
	CMP	BCAP0,X			; AT THIS
	BCC	NOMAX			; LEVEL
	STA	BCAP0,X
NOMAX	DEC	STATE
	LDA	#$FB			; IF STATE=FB
	CMP	STATE			; TIME TO TURN
	BEQ	UPTREE			; AROUND
	JSR	GENRM			; GENERATE FURTHER
UPTREE	INC	STATE			; CAPTURES
	RTS

;	THE PLAYER'S MOVE IS INPUT

INPUT
	SEC				; set for subtract
	SBC	#'0'			; convert.ascii # to binary

	CMP	#$08			; NOT A LEGAL
	BCS	ERROR			; SQUARE #

	JSR	DISMV
	JSR	DISP2			; put piece into display
ERROR	JMP	GETKEY			; go update move display and wait for next key
;	JMP	CHESS

DISP3
	LDA	DIS3			; get position
	.byte	$2C			; make next LDA into BIT xxxx
DISP2	LDA	DIS2			; get position
	LDX	#$1F
SEARCH	CMP	BOARD,X			; compare with this piece's position
;	LDA	BOARD,X
;	CMP	DIS2
	BEQ	HERE			; DISPLAY
	DEX				; PIECE AT
	BPL	SEARCH			; FROM
	LDX	#$BB			; blank square if no matching piece
HERE	STX	DIS1			; SQUARE
	STX	PIECE
	RTS

;	GENERATE ALL MOVES FOR ONE
;	SIDE, CALL JANUS AFTER EACH
;	ONE FOR NEXT STE?

GNMZ
	LDX	#$10			; CLEAR
GNMX	LDA	#$00			; COUNTERS
CLEAR	STA	COUNT,X
	DEX
	BPL	CLEAR

GNM	LDA	#$10			; SET UP
	STA	PIECE			; PIECE
NEWP	DEC	PIECE			; NEW PIECE
	BPL	NEX			; ALL DONE?
	RTS				; #NAME?

NEX	JSR	RESET			; READY
	LDY	PIECE			; GET PIECE
	LDX	#$08
	STX	MOVEN			; COMMON START
	CPY	#$08			; WHAT IS IT?
	BPL	PAWN			; PAWN
	CPY	#$06
	BPL	KNIGHT			; KNIGHT
	CPY	#$04
	BPL	BISHOP			; BISHOP
	CPY	#$01
	BEQ	QUEEN			; QUEEN
	BPL	ROOK			; ROOK

KING	JSR	SNGMV			; MUST BE KING!
	BNE	KING			; MOVES
	BEQ	NEWP			; 8 TO 1
QUEEN	JSR	LINE
	BNE	QUEEN			; MOVES
	BEQ	NEWP			; 8 TO 1

ROOK	LDX	#$04
	STX	MOVEN			; MOVES
AGNR	JSR	LINE			; 4 TO 1
	BNE	AGNR
	BEQ	NEWP

BISHOP	JSR	LINE
	LDA	MOVEN			; MOVES
	CMP	#$04			; 8 TO 5
	BNE	BISHOP
	BEQ	NEWP

KNIGHT	LDX	#$10
	STX	MOVEN			; MOVES
AGNN	JSR	SNGMV			; 16 TO 9
	LDA	MOVEN
	CMP	#$08
	BNE	AGNN
	BEQ	NEWP

PAWN	LDX	#$06
	STX	MOVEN
P1	JSR	CMOVE			; RIGHT CAP?
	BVC	P2
	BMI	P2
	JSR	JANUS			; YES
P2	JSR	RESET
	DEC	MOVEN			; LEFT CAP?
	LDA	MOVEN
	CMP	#$05
	BEQ	P1
P3	JSR	CMOVE			; AHEAD
	BVS	NEWP			; ILLGAL
	BMI	NEWP
	JSR	JANUS
	LDA	SQUARE			; GETS TO
	AND	#$F0			; 3RD RANK?
	CMP	#$20
	BEQ	P3			; DO DOUBLE
	JMP	NEWP

;	CALCULATE SINGLE STEP MOVES
;	FOR K,N

SNGMV
	JSR	CMOVE			; CALC MOVE
	BMI	ILL1			; -IF LEGAL
	JSR	JANUS			; -EVALUATE
ILL1	JSR	RESET
	DEC	MOVEN
	RTS

;	CALCULATE ALL MOVES DOWN A
;	STRAIGHT LINE FOR Q,B,R

LINE
	JSR	CMOVE			; CALC MOVE
	BCC	OVL			; NO CHK
	BVC	LINE			; NOCAP
OVL	BMI	ILL			; RETURN
	PHP
	JSR	JANUS			; EVALUATE POSN
	PLP
	BVC	LINE			; NOT A CAP
ILL	JSR	RESET			; LINE STOPPED
	DEC	MOVEN			; NEXT DIR
	RTS

;	EXCHANGE SIDES FOR REPLY
;	ANALYSIS

REV
	LDX	#$0F
ETC	SEC
	LDY	BK,X			; SUBTRACT
	LDA 	#$77			; POSITION
	SBC	BOARD,X			; FROM 77
	STA	BK,X
	STY	BOARD,X			; AND
	SEC
	LDA	#$77			; EXCHANGE
	SBC 	BOARD,X			; PIECES
	STA	BOARD,X
	DEX
	BPL	ETC
	RTS

;	CMOVE CALCULATES THE TO SQUARE
;	USING SQUARE AND THE MOVE
;	TABLE	FLAGS SET AS FOLLOWS:
;	N#NAME?	MOVE
;	V#NAME?	(LEGAL UNLESS IN CR)
;	C#NAME?	BECAUSE OF CHECK
;	[MY &THANKS TO JIM BUTTERFIELD
;	WHO WROTE THIS MORE EFFICIENT
;	VERSION OF CMOVE)

CMOVE
	LDA	SQUARE			; GET SQUARE
	LDX	MOVEN			; MOVE POINTER
	CLC
	ADC	MOVEX,X			; MOVE LIST
	STA	SQUARE			; NEW POS'N
	AND	#$88
	BNE	ILLGAL			; OFF BOARD
	LDA	SQUARE

	LDX	#$20
LOOP	DEX				; IS TO
	BMI	NO			; SQUARE
	CMP	BOARD,X			; OCCUPIED?
	BNE	LOOP

	CPX	#$10			; BY SELF?
	BMI	ILLGAL

	LDA	#$7F			; MUST BE CAP!
	ADC	#$01			; SET V FLAG
	BVS	SPX 			; (JMP)

NO	CLV				; NO CAPTURE

SPX	LDA	STATE			; SHOULD WE
	BMI	RETL			; DO THE
	CMP	#$08 			; CHECK CHECK?
	BPL	RETL

;	CHKCHK REVRSES SIDES
;	AND LOOKS FOR A KING
;	CAPTURE TO INDICATE
;	ILLGAL MOVE BECAUSE OF
;	CHECK	SINCE THIS IS
;	TIME CONSUMING, IT IS NOT
;	ALWAYS DONE	

CHKCHK	PHA				; STATE	#392
	PHP
	LDA	#$F9
	STA	STATE			; GENERATE
	STA	INCHEK			; ALL REPLY
	JSR	MOVE			; MOVES TO
	JSR	REV			; SEE IF KING
	JSR	GNM			; IS IN
	JSR	RUM			; CHECK
	PLP
	PLA
	STA	STATE
	LDA	INCHEK
	BMI	RETL			; NO - SAFE
	SEC				; YES - IN CHK
	LDA	#$FF
	RTS

RETL	CLC				; LEGAL
	LDA	#$00			; RETURN
	RTS

ILLGAL	LDA	#$FF
	CLC				; ILLGAL
	CLV				; RETURN
	RTS

;	REPLACE PIECE ON CORRECT SQUARE

RESET
	LDX	PIECE			; GET LOGAT
	LDA	BOARD,X			; FOR PIECE
	STA	SQUARE			; FROM BOARD
	RTS

GENRM
	JSR	MOVE			; MAKE MOVE
GENR2	JSR	REV			; REVRSE BOARD
	JSR	GNM			; GENERATE MOVES
RUM	JSR	REV			; REVRSE BACK

;	ROUTINE TO UNMAKE A MOVE MADE BY
;	MOVE

UMOVE	TSX				; UNMAKE MOVE
	STX	SP1
	LDX	SP2			; EXCHANGE
	TXS				; STACKS
	PLA				; MOVEN
	STA	MOVEN
	PLA				; CAPTURED
	STA	PIECE			; PIECE
	TAX
	PLA				; FROM SQUARE
	STA	BOARD,X
	PLA				; PIECE
	TAX
	PLA				; TO SOUARE
	STA	SQUARE
	STA	BOARD,X
	JMP	STRV

;	THIS ROUTINE MOVES PIECE
;	TO SQUARE, PARAMETERS
;	ARE SAVED IN A STACK TO UNMAKE
;	THE MOVE LATER

MOVE
	TSX	
	STX	SP1			; SWITCH
	LDX	SP2			; STACKS
	TXS	
	LDA	SQUARE
	PHA				; TO SQUARE
	TAY	
	LDX	#$1F
CHECK	CMP	BOARD,X			; CHECK FOR
	BEQ	TAKE			; CAPTURE
	DEX	
	BPL	CHECK
TAKE	LDA	#$CC
	STA	BOARD,X
	TXA				; CAPTURED
	PHA				; PIECE
	LDX	PIECE
	LDA	BOARD,X
	STY	BOARD,X			; FROM
	PHA				; SQUARE
	TXA
	PHA				; PIECE
	LDA	MOVEN
	PHA				; MOVEN
STRV	TSX
	STX	SP2			; SWITCH
	LDX	SP1			; STACKS
	TXS				; BACK
	RTS

;	CONTINUATION OF SUB STRAT
;	-CHECKS FOR CHECK OR CHECKMATE
;	AND ASSIGNS VALUE TO MOVE

CKMATE
	LDY	BMAXC			; CAN BLK CAP
	CPX	POINTS			; MY KING?
	BNE	NOCHEK
	LDA	#$00			; GULP!
	BEQ	RETV			; DUMB MOVE!

NOCHEK	LDX	BMOB			; IS BLACK
	BNE	RETV			; UNABLE TO
	LDX	WMAXP			; MOVE AND
	BNE	RETV			; KING IN CH?
	LDA	#$FF			; YES! MATE

RETV	LDX	#$04			; RESTORE
	STX	STATE			; STATE=4

;	THE VALUE OF THE MOVE (IN ACCU)
;	IS COMPARED TO THE BEST MOVE AND
;	REPLACES IT IF IT IS BETTER

PUSH	CMP	BESTV			; IS THIS BEST
	BCC	RETP			; MOVE SO FAR?
	BEQ	RETP
	STA	BESTV			; YES!
	LDA	PIECE			; SAVE IT
	STA	BESTP
	LDA	SQUARE
	STA	BESTM			; FLASH DISPLAY
RETP	LDA	PROMPT			; get PROMPT character
	EOR	#$1F			; toggle between [OUTSP] and '?"
	STA	PROMPT			; save it back			
	;JMP	UPDDSP		; update PROMPT & display	
	JMP	DSPDOT			; update PROMPT & display

;	MAIN PROGRAM TO PLAY CHESS
;	PLAY FROM OPENING OR THINK

; ARE WE STILL INSIDE A CANNED OPENING?
OPENOK	
	LDY	OMOVE
	LDA	DIS3			; -YES WAS
	CMP	(POPENL),Y		; OPPONENT'S
.NO	RTS

; MOVE DIDNT MATCH EXPECTED MOVE FOR OPENING
; SO TEST AGAINST ALL OUR KNOWN OPENINGS
CHKOPN
	LDY 	#NUMOPN			; 10 OPENINGS TO CHECK
.LOOP	DEY
	TYA
	PHA				; CRAPPY CODE...
	JSR 	SETOPN
	JSR 	OPENOK
	BEQ 	GO			; TRY AGAIN WITH MATCHING OPENING
	PLA
	TAY
	DEY		
	BNE 	.LOOP
	BEQ 	END			; CHECKED ALL

GO
	LDY	OMOVE			; OPENING?
	BMI	NOOPEN			; -NO	*ADD CHANGE FROM BPL
	JSR	OPENOK
	BNE	CHKOPN			; MOVE OK?
	DEY
	LDA	(POPENL),Y		; GET NEXT
	STA	DIS1			; CANNED
	DEY				; OPENING MOVE
	LDA	(POPENL),Y
	STA	DIS3			; DISPLAY IT
	DEY
	STY	OMOVE			; MOVE IT
	BNE	MV2			; (JMP)

END	LDA	#$FF			; *ADD - STOP CANNED MOVES
	STA	OMOVE			; FLAG OPENING
NOOPEN	LDX	#$0C			; FINISHED
	STX	STATE			; STATE=C
	STX	BESTV			; CLEAR BESTV
	LDX	#$14			; GENERATE P
	JSR	GNMX			; MOVES

	LDX	#$04			; STATE=4
	STX	STATE			; GENERATE AND
	JSR	GNMZ			; TEST AVAILABLE
;
;	MOVES

	LDX	BESTV			; GET BEST MOVE
	CPX	#$0F			; IF NONE
	BCC	MATE			; OH OH!

MV2	LDX	BESTP			; MOVE
	LDA	BOARD,X			; THE
	STA	BESTV			; BEST
	STX	PIECE			; MOVE
	LDA	BESTM
	STA	SQUARE			; AND DISPLAY
	JSR	PRTAKE			; PRINT MESSAGE IF CAPTURE
	JSR	MOVE			; IT

	JSR	DISP3			; piece into display

	JMP	CHESS

MATE	LDA	#$FF			; RESIGN
	RTS				; OR STALEMATE

;	SUBROUTINE TO ENTER THE
;	PLAYER'S MOVE

DISMV
	LDX	#$04			; ROTATE
DROL	ASL	DIS3			; KEY
	ROL	DIS2			; INTO
	DEX				; DISPLAY
	BNE	DROL			;

	ORA	DIS3
	STA	DIS3
	STA	SQUARE
	RTS

;	THE FOLLOWING SUBROUTINE ASSIGNS
;	A VALUE TO THE MOVE UNDER
;	CONSIDERATION AND RETURNS IT IN
;	THE ACCUMULATOR


STRAT
	CLC
	LDA	#$80
	ADC	WMOB			; PARAMETERS
	ADC	WMAXC			; WITH WHEIGHT
	ADC	WCC			; OF O25
	ADC	WCAP1
	ADC	WCAP2
	SEC
	SBC	PMAXC
	SBC	PCC
	SBC	BCAP0
	SBC	BCAP1
	SBC	BCAP2
	SBC	PMOB
	SBC	BMOB
	BCS	POS			; UNDERFLOW
	LDA	#$00			; PREVENTION
POS	LSR
	CLC				; **************
	ADC	#$40
	ADC	WMAXC			; PARAMETERS
	ADC	WCC			; WITH WEIGHT
	SEC				; OF 05
	SBC	BMAXC
	LSR				; **************
	CLC
	ADC	#$90
	ADC	WCAP0			; PARAMETERS
	ADC	WCAP0			; WITH WEIGHT
	ADC	WCAP0			; OF 10
	ADC	WCAP0
	ADC	WCAP1
	SEC				; [UNDER OR OVER-
	SBC	BMAXC			; FLOW MAY OCCUR
	SBC	BMAXC			; FROM THIS
	SBC	XBCC			; SECTION]
	SBC	XBCC
	SBC	BCAP1
	LDX	SQUARE			; ***************
	CPX	#$33
	BEQ	POSN			; POSITION
	CPX	#$34			; BONUS FOR
	BEQ	POSN			; MOVE TO
	CPX	#$22			; CENTRE
	BEQ	POSN			; OR
	CPX	#$25			; OUT OF
	BEQ	POSN			; BACK RANK
	LDX	PIECE
	BEQ	NOPOSN
	LDY	BOARD,X
	CPY	#$10
	BPL	NOPOSN
POSN	CLC
	ADC	#$02
NOPOSN	JMP	CKMATE			; CONTINUE

; most new code from here on

; update move display, do PROMPT, piece, 'FROM' and 'TO' squares

UPDDSP
	JSR 	CRLF
	LDA	PROMPT			; PROMPT
	JSR	OUTCH		;.byte out to display
	JSR	OUTSP			; [OUTSP] out to display

	JSR	DSPPCE		; display piece (from.byte in DIS1)

	JSR	OUTSP			; [OUTSP] out to display
	LDA	DIS2			; 2nd display.byte
	JSR	PSQR			; Print square
	JSR	OUTSP			; [OUTSP] out to display
	LDA	DIS3			; 3rd display.byte
	JMP	PSQR			; Print square

; draw board on an.ascii character display
; the display in the simulator has cursor
; positioning. Other displays may use escape
; codes to the same ends.

DSPDOT
	LDA #'.'
	JMP OUTCH

DRWBRD
	JSR 	CRLF
	JSR	PCOLNM			; print column labels
	JSR	HLINE			; print horizontal line
	LDY	#$00			; init board location
PNVRT	JSR	PROWNM			; print row number
PVRT	LDA	#'!'			; print vertical edge
	JSR	OUTCH		;.byte out to display

	LDX	#$1F			; for each piece
	TYA				; copy square #
PPCE	CMP	BOARD,X			; this piece in this square?
	BEQ	PCEOUT		; if so print the piece's color and type

	DEX				; else try next piece
	BPL	PPCE			; if not done then loop

	TYA				; copy square #
	ASL				; shift column LSB into Cb
	ASL				;
	ASL				;
	ASL				;
	TYA				; copy square # again
	ADC	#$00			; add column LSB
	LSR				; result into carry	
	LDA	#SP			; assume white square
	BCC	ISWHTE 		; branch if white

	LDA	#'#'			; else make square black
ISWHTE	JSR	OUTCH		;.byte out to display
	JSR	OUTCH		;.byte out to display
PNXTC	INY				; next column
	TYA				; get square #
	AND	#$08			; have we completed the row?
	BEQ	PVRT			; if not go do next column

	LDA	#'!'			; yes, put the right edge on
	JSR	OUTCH		;.byte out to display
	JSR	PROWNM			; print row number
	JSR	CRLF			; print CRLF
	JSR	HLINE			; print horizontal line
	TYA				; copy square #
	CLC				; clear for add
	ADC	#$08			; increment to beginning of next row
	BMI	PCOLNM			; done so go finish board

	TAY				; else copy new square #
	BPL	PNVRT		; go do next row

; output piece's color & type

PCEOUT	LDA	#'W'			; assume white
	CPX	#$10			; compare with breakpoint (result in Cb)
	BIT	REVRSE			; test REVRSE.byte
	BEQ	NOFLIP			; branch if not REVRSE

					; else toggle Cb state
	ROL				; Cb into D0		
	EOR	#$01			; toggle bit
	ROR				; D0 into Cb
NOFLIP	BCC	NOTBLK		; branch if white

	LDA	#'B'			; else make black
NOTBLK	JSR	OUTCH		;.byte out to display
	TXA				; copy piece
	AND	#$0F			; mask black/white
	TAX				; back to index
	LDA	PPIECE,x		; get current piece 2nd.byte
	JSR	OUTCH		;.byte out to display
	BNE	PNXTC		; branch always

; print '  ', line of -'s then [CR]
HLINE
	JSR OUTSP
	JSR OUTSP
	TXA  		; PRINT '+--+--...--+<CRLF>"
	PHA
	LDX #$8
.LOOP	LDA #'+'
	JSR OUTCH 	
	LDA #'-'
	JSR OUTCH
	JSR OUTCH
	DEX
	BNE .LOOP
	LDA #'+'
	JSR OUTCH
	PLA
	TAX
	JSR CRLF
	RTS

; print the column labels

PCOLNM
	JSR	OUTSP			; [OUTSP] out to display
	JSR	OUTCH		;.byte out to display (2nd [OUTSP])
	LDX	#$00			; clear index
PNXTCN	JSR	OUTSP			; [OUTSP] out to display
	TXA				; get column number
	JSR	HEXOUT			; A out as hex
	INX				; next column
	CPX	#$08			; is it done?
	BNE	PNXTCN		; loop if not

	JMP	CRLF			; else do newline and return

; print (c) message

PRNTC
	LDX	#$00			; initial 0
PRNTCL	LDA	C,X			; get.byte
	BMI	PRNTCE		; exit if $FF [EOT]
	JSR	OUTCH		;.byte out to display
	INX				; increment index
	BNE	PRNTCL		; loop
PRNTCE	RTS	

PROWNM
	TYA				; copy row number
PSQR	AND 	#$77			; mask unused bits
	JMP 	HEXOUT
	
PRTAKE
	;STX $11
	LDX #$1F			; loop all pieces each piece
.LOOP	CMP BOARD,X			; this piece in this square?
	BEQ .YES			; if so print the piece's color and type
	DEX				; else try next piece
	BPL .LOOP			; if not done then loop
	RTS
.YES	PHA	
	LDA DIS1
	PHA
	TXA
	STA DIS1
	JSR CRLF
	LDX #$9C;#PCAPT-PNAME		; set pointer
	JSR DISSTR			; go print it
	JSR OUTSP
	JSR DSPPCE
	PLA
	STA DIS1
	PLA
	;LDX $11
	RTS

; display piece byte in DIS1 as ascii string

DSPPCE
	LDA	DIS1			; get piece for this move
	BMI	DSPSPC		; branch if not piece

	AND	#$0F			; don't care black or white
	ASL				; *2
	ASL				; *4
	ASL				; *8
	TAX				; copy index
DISSTR	LDY	#$08			; character count
.LOOP	LDA	PNAME,X		; get.byte
	JSR	OUTCH		; out to display
	INX				; increment index
	DEY				; decrement count
	BNE	.LOOP			; loop if not done

	RTS

; set X for 'special' $CC, $EE and $FF piece codes, else set null

DSPSPC
	CMP	#$CC			; compare with reset
	BNE	NOTRST		; branch if not reset

	LDX	#$80;PRES-PNAME		; set pointer
	BNE	DISSTR		; go print it

NOTRST	CMP	#$EE			; compare with exchange
	BNE	NOTEX			; branch if not exchange

	LDX	#$88;PEXG-PNAME		; set pointer
	BNE	DISSTR		; go print it
				; else null
NOTEX	CMP	#$FF			; compare with check mate
	BNE	NOTCHK			; branch if not check mate

	LDX	#$90;PCKM-PNAME		; set pointer
	BNE	DISSTR		; go print it

					; else null
NOTCHK	LDX	#$94;PNUL-PNAME		; set pointer
	BNE	DISSTR		; go print it

; start up menus
; Menu data

SPDMNU	.ascii "SELECT"
	.byte $20
	.ascii "LEVEL:"
	.byte $00
	.byte $00
	.ascii "0)"
	.byte $20
	.ascii "SUPER"
	.ascii "BLITZ"
	.byte $00
	.ascii "1)"
	.byte $20
	.ascii "BLITZ"
	.byte $00
	.ascii "2)"
	.byte $20
	.ascii "NORMAL"
	.byte $00
	.byte $FF
	
OPNMNU	.byte $00
	.ascii "SELECT"
	.byte $20
	.ascii "OPENING:"
	.byte $20
	.ascii "COMP"
	.byte $20
	.ascii "PLAYS"
	.byte $00
	.byte $00
	.ascii "FRENCH"
	.byte $20
	.ascii "DEFENCE:"
	.byte $20
	.ascii "0)"
	.byte $20
	.ascii "W"
	.byte $20
	.ascii "1)"
	.byte $20
	.ascii "B"
	.byte $00
	.ascii "GIUOCO"
	.byte $20
	.ascii "PIANO:"
	.byte $20
	.byte $20
	.byte $20
	.ascii "2)"
	.byte $20
	.ascii "W"
	.byte $20
	.ascii "3)"
	.byte $20
	.ascii "B"
	.byte $00
	.ascii "RUY"
	.byte $20
	.ascii "LOPEZ:"
	.byte $20
	.byte $20
	.byte $20
	.byte $20
	.byte $20
	.byte $20
	.ascii "4)"
	.byte $20
	.ascii "W"
	.byte $20
	.ascii "5)"
	.byte $20
	.ascii "B"
	.byte $00
	.ascii "QUEEN"
	.byte $27
	.ascii "S"
	.byte $20
	.ascii "INDIAN:"
	.byte $20
	.ascii "6)"
	.byte $20
	.ascii "W"
	.byte $20
	.ascii "7)"
	.byte $20
	.ascii "B"
	.byte $00
	.ascii "FOUR"
	.byte $20
	.ascii "KNIGHTS:"
	.byte $20
	.byte $20
	.byte $20
	.ascii "8)"
	.byte $20
	.ascii "W"
	.byte $20
	.ascii "9)"
	.byte $20
	.ascii "B"
	.byte $00
	.byte $FF

INIT	LDA #<SPDMNU
	STA MENUL
	LDA #>SPDMNU
	STA MENUH
	
	JSR SHOW	; show the menu
	JSR GETCH	; get the input
	JSR OUTCH
	
	SEC
	SBC #'0'	; subtract.ascii "1' to get offfset
	TAX
	BNE .1
	STX SPX+5	; store 0
	DEX
	STX NOMAX+3	; store FF 
	BNE .OPEN	; always branches
	
.1	DEX
	BNE .2
	STX SPX+5	; store 0
	LDX #$FB
	STX NOMAX+3	; store FF 
	BNE .OPEN	; always branches
	
.2	DEX
	BNE INIT	; invalid entry
	LDX #$8
	STX SPX+5	; store 0
	LDX #$FB
	STX NOMAX+3	; store FF 
	
.OPEN	LDA #<OPNMNU
	STA MENUL
	LDA #>OPNMNU
	STA MENUH

	JSR SHOW	; show the menu
	JSR GETCH	; get the input
	JSR OUTCH
	
	SEC
	SBC #'0'	; subtract.ascii "1' to get offfset
	CMP MNUCNT	; Are we in range?
	BCS .OPEN	; Too large
	
SETOPN	STA COMPW 
	TAX	
	INX
	LDA #>OPENGS
	STA POPENH
	LDA #<OPENGS
	
.LOOP	DEX
	BEQ .RET
	CLC
	ADC #OPENSZ
	BCC .LOOP
	INC POPENH
	BNE .LOOP	; always branches
.RET	STA POPENL
	RTS
	
SHOW	JSR CRLF
	LDY #$FF	; data
.NEXT	INY
	LDA (MENUL),Y
	BNE .NOTEOL
	JSR CRLF
	JMP .NEXT
.NOTEOL	CMP #$FF
	BEQ .DONE
	JSR OUTCH
	JMP .NEXT
.DONE	STY MNUCNT
	RTS		
	

; text descriptions for the S in DIS1

PNAME .ascii "KING"
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 
 .ascii "QUEEN"
 .byte SP
 .byte SP
 .byte SP
 
 .ascii "K"
 .byte SP
 .ascii "ROOK"
 .byte SP
 .byte SP
 
 .ascii "Q"
 .byte SP
 .ascii "ROOK"
 .byte SP
 .byte SP
 
 .ascii "K"
 .byte SP
 .ascii "BISHOP"
 
 .ascii "Q"
 .byte SP
 .ascii "BISHOP"
 
 .ascii "K"
 .byte SP
 .ascii "KNIGHT"
 
 .ascii "Q"
 .byte SP
 .ascii "KNIGHT"
 
 .ascii "K"
 .byte SP
 .ascii "R"
 .byte SP
 .ascii "PAWN"
 
 .ascii "Q"
 .byte SP
 .ascii "R"
 .byte SP
 .ascii "PAWN"
 
 .ascii "K"
 .byte SP
 .ascii "N"
 .byte SP
 .ascii "PAWN"
 
 .ascii "Q"
 .byte SP
 .ascii "N"
 .byte SP
 .ascii "PAWN"
 
 .ascii "K"
 .byte SP
 .ascii "B"
 .byte SP
 .ascii "PAWN"
 
 .ascii "Q"
 .byte SP
 .ascii "B"
 .byte SP
 .ascii "PAWN"
 
 .ascii "Q"
 .byte SP
 .ascii "PAWN"
 .byte SP
 .byte SP
 
 .ascii "K"
 .byte SP
 .ascii "PAWN"
 .byte SP
 .byte SP
 
PRES  .ascii "RESET"
 .byte SP
 .byte SP
 .byte SP
 
PEXG .ascii "EXCHANGE"

PCKM .ascii "MATE"

PNUL .byte SP
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 
PCAPT .ascii "CAPTURES"

; copyright banner


; copyright banner

C
	.if APPLE1
 .byte CR
 .ascii "+----------"
 .ascii "----------+"
 .byte  CR
 .byte $00
 .ascii "!"
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .ascii "MICRO"
 .ascii "CHESS"
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .byte SP
 .ascii "!"
 .byte  CR
 .byte $00
 .ascii "!"
 .byte SP
 .ascii "(c)"
 .byte SP
 .ascii "PETER"
 .byte SP
 .ascii "JENNINGS"
 .byte SP
 .ascii "!"
 .byte  CR
 .byte $00
 .ascii "!"
 .byte SP
 .byte SP
 .ascii "PETERJ@"
 .ascii "BENLO.COM"
 .byte SP
 .byte SP
 .ascii "!"
 .byte  CR
 .byte $00
 .ascii "+----------"
 .ascii "----------+"
 .byte  CR
 .byte $FF
	.else
	.byte	" +--------------------+",CR,LF,$00
	.byte	"!     MicroChess     !",CR,LF,$00
	.byte	"! (c) Peter Jennings !",CR,LF,$00
	.byte	"!  peterj@benlo.com  !",CR,LF,$00
	.byte	"+--------------------+",CR,LF,$FF
	.endif

; piece character table

PPIECE .ascii "KQRRBBNN"
 .ascii "PPPPPPPP"

; initial positions

SETW .byte $03
 .byte $04
 .byte $00
 .byte $07
 .byte $02
 .byte $05
 .byte $01
 .byte $06
 .byte $10
 .byte $17
 .byte $11
 .byte $16
 .byte $12
 .byte $15
 .byte $14
 .byte $13
 .byte $73
 .byte $74
 .byte $70
 .byte $77
 .byte $72
 .byte $75
 .byte $71
 .byte $76
 .byte $60
 .byte $67
 .byte $61
 .byte $66
 .byte $62
 .byte $65
 .byte $64
 .byte $63

MOVEX .byte $00
 .byte $F0
 .byte $FF
 .byte $01
 .byte $10
 .byte $11
 .byte $0F
 .byte $EF
 .byte $F1
 .byte $DF
 .byte $E1
 .byte $EE
 .byte $F2
 .byte $12
 .byte $0E
 .byte $1F
 .byte $21

POINTS .byte $0B
 .byte $0A
 .byte $06
 .byte $06
 .byte $04
 .byte $04
 .byte $04
 .byte $04
 .byte $02
 .byte $02
 .byte $02
 .byte $02
 .byte $02
 .byte $02
 .byte $02
 .byte $02


OUTSP	
	LDA #SP
	JMP OUTCH
	
CRLF			; Go to a new line.
	LDA #CR		; "CR"
	.if APPLE1
	JMP OUTCH
	.else
	JSR OUTCH
	LDA #LF		; "LF" - is this needed for the Apple 1?
	JMP OUTCH
	.endif

GETCH   		; Get a character from the keyboard.
	LDA KBDRDY
	.if APPLE1
	BPL GETCH
	LDA KBD
	AND #INMASK
	.else
	BEQ GETCH
	.endif
	RTS	
	
	.if APPLE1
; Apple 1 I/O values
OUTCH	=$FFEF		; Apple 1 Echo
PRHEX	=$FFE5		; Apple 1 Echo
HEXOUT	=$FFDC		; Apple 1 Print Hex Byte Routine
KBD     =$D010		; Apple 1 Keyboard character read.
KBDRDY  =$D011		; Apple 1 Keyboard data waiting when negative.
	.else
IOMEM	=$E000
PUTCH	=IOMEM+1
KBD	=IOMEM+4
KBDRDY  =IOMEM+4
	.ORG $FFDC
HEXOUT	PHA 		; Print 1 hex byte. 
	LSR
	LSR 
	LSR
	LSR 
	JSR PRHEX
	PLA 
PRHEX	AND #$0F	; Print 1 hex digit
	ORA #$30
	CMP #$3A
	BCC OUTCH
	ADC #$06
OUTCH	STA PUTCH
	RTS  
	.endif