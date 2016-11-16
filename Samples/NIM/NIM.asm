OUTCH  .=  $FFEF
PRHEX  .=  $FFE5
OUTHEX .=  $FFDC
KBD    .=  $D010
KBDRDY .=  $D011

FAIL   .=  $FF
CR     .=  $0D
LF     .=  $0A
SP     .=  $20
ESC    .=  $1B

SCRTCH .=  $10
MSGL   .=  $11
MSGH   .=  $12
TURN   .=  $13
N      .=  $14
VALS   .=  $15

MAIN   .M  
       JSR INIT
       JMP PLAY

INV    .S  'INVALID'
       .B  $0
YOU    .S  'YOU'
       .B  $0
WIN    .S  'WIN!'
       .B  $0
CMPPLY .S  'I'
       .B  SP
TAKE   .S  'TAKE'
       .B  $0
FROM   .S  'FROM'
       .B  SP
HEAP   .S  'HEAP'
       .B  $0
HEAPS  .S  'S'
       .B  SP
       .S  'ARE'
       .B  $0
       
PLAY   .M
       INC TURN
       JSR PRHEAP
       LDA TURN
       ROR 
       BCC .PLYR
       JSR MYGO
       SEC 
       BCS .CONT
.PLYR  JSR YRGO
.CONT  JSR CRLF
       LDX N
.CHECK LDA VALS-1,X
       BNE PLAY
       DEX 
       BNE .CHECK
       JSR PRHEAP
       JSR CRLF
       JSR YOUORI
       JSR OUTSP
.WIN   LDA #<WIN
       STA MSGL
       LDA #>WIN
       STA MSGH
       JSR SHWMSG
       JSR CRLF
       JSR CRLF
       JSR GETCH
       JMP MAIN

GETCH  .M  
       LDA KBDRDY
       BPL GETCH
       LDA KBD
       AND #$7F
       CMP #ESC
       BNE .OUT
       PLA
       PLA
       PLA
       PLA
       PLA
       PLA
       RTS 
.OUT   JMP OUTCH

PROMPT .M  
       LDA #'?'
       JSR OUTCH
OUTSP  .M  
       LDA #SP
       JMP OUTCH

CRLF   .M  
       LDA #CR
       JMP OUTCH

SHWMSG .M  
       LDY #$0
.PRINT LDA (MSGL),Y
       BEQ .DONE
       JSR OUTCH
       INY 
       BNE .PRINT
.DONE  RTS 

ASC2HX .M  
       EOR #$30
       CMP #$0A
       BCC .VALID
       ADC #$88
       CMP #$FA
       BCC .ERR
       AND #$0F
.VALID RTS 
.ERR   LDA #FAIL
       RTS 

ERROR  .M  
       JSR CRLF
       LDA #<INV
       STA MSGL
       LDA #>INV
       STA MSGH
       JSR SHWMSG
       JMP CRLF
SHWHP  .M  
       LDA #<HEAP
       STA MSGL
       LDA #>HEAP
       STA MSGH
       JMP SHWMSG

GETNMM .M  
       JSR SHWMSG
GETNM  JSR PROMPT
       JSR GETCH
       JMP ASC2HX

INIT   .M  
       LDA #$0
       STA TURN
       DEC TURN

.RPT   JSR CRLF
       JSR SHWHP
       LDA #'S'
       JSR OUTCH
       JSR GETNM
       TAX 
       BEQ .ERR
       CMP #FAIL
       BEQ .ERR
       STX N
.RPT1  LDY #'1'
       LDX #$0
.NEXT  JSR CRLF
       TYA 
       JSR OUTCH
       JSR GETNM
       CMP #$0
       BEQ .ERR1
       CMP #FAIL
       BEQ .ERR1
       STA VALS,X
       INY 
       INX 
       CPX N
       BNE .NEXT
       JSR CRLF
       RTS 
.ERR   JSR ERROR
       JMP .RPT
.ERR1  JSR ERROR
       JMP .RPT1

CALCGO .M  

       LDX N
       LDA #$0
.NEXT  EOR VALS-1,X
       DEX 
       BNE .NEXT
       STA SCRTCH
       CMP #$0
       BEQ .BAD
       LDX N
.NEXT2 LDA SCRTCH
       EOR VALS-1,X
       CMP VALS-1,X
       BMI .GOOD
       DEX 
       BNE .NEXT2
.GOOD  STA SCRTCH
       LDA VALS-1,X
       SEC 
       SBC SCRTCH
       RTS 
.BAD   LDX N
.NEXT3 LDA VALS,X
       BNE .OK
       DEX 
       BNE .NEXT3
.OK    LDA #$1
       RTS 

MYGO   .M  
       LDA #<CMPPLY
       STA MSGL
       LDA #>CMPPLY
       STA MSGH
       JSR SHWMSG
       JSR OUTSP
       JSR CALCGO
       STA SCRTCH
       JSR PRHEX
       JSR OUTSP
       LDA #<FROM
       STA MSGL
       LDA #>FROM
       STA MSGH
       JSR SHWMSG
       JSR OUTSP
       TXA 
       JSR PRHEX
       DEX 
UPDTHP .M  
       LDA VALS,X
       SEC 
       SBC SCRTCH
       STA VALS,X
       JSR CRLF
       RTS 

YRGO   .M  
       JSR SHWHP
       JSR GETNM
       TAX 
       BEQ .ERR
       CPX #FAIL
       BEQ .ERR
       CPX N
       BEQ .OK
       BCS .ERR
.OK    DEX 
       JSR CRLF
       LDA #<TAKE
       STA MSGL
       LDA #>TAKE
       STA MSGH
       JSR GETNMM
       CMP #$0
       BEQ .ERR
       CMP #FAIL
       BEQ .ERR
       CMP VALS,X
       BEQ .UPD
       BCS .ERR
.UPD   STA SCRTCH
       JMP UPDTHP
.ERR   JSR ERROR
       JMP YRGO

PRHEAP .M  
       JSR SHWHP
       LDA #<HEAPS
       STA MSGL
       LDA #>HEAPS
       STA MSGH
       JSR SHWMSG
       LDX #$0
.NEXT  JSR OUTSP
       LDA VALS,X
       JSR PRHEX
       INX 
       CPX N
       BMI .NEXT
       JSR CRLF
       RTS 

YOUORI .M  
       LDA TURN
       ROR 
       BCC .YOU
       LDA #'I'
       JMP OUTCH
.YOU   LDA #<YOU
       STA MSGL
       LDA #>YOU
       STA MSGH
.SHOW  JSR SHWMSG
       RTS 