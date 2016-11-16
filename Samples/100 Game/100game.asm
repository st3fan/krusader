ECHO   .=  $FFEF
PRHEX  .=  $FFE5
OUTHEX .=  $FFDC
KBD    .=  $D010
KBDRDY .=  $D011

FAIL   .=  $FF
CR     .=  $0D
SP     .=  $20
ESC    .=  $1B

IOBUF  .=  $00
SCRTCH .=  $02
MSGL   .=  $03
MSGH   .=  $04
SUM    .=  $05
TARGET .=  $06
TURN   .=  $07

MAIN   .M  
       SED 
       JSR INIT
       JMP PLAY

ERROR  .S  'INVALID'
       .B  $0
YOU    .S  'YOU'
       .B  $0
WIN    .S  'WIN!'
       .B  $0
LOSE   .S  'LOSE!'
       .B  $0
CMPPLY .S  'I'
       .B  SP
       .S  'PLAY'
       .B  SP
       .B  $0
SUMLN  .S  'SUM'
       .B  SP
       .S  'IS'
       .B  SP
       .B  $0
       
PLAY  .M
       INC TURN
       JSR PRSUM
       LDA SUM
       JSR PRVAL
       LDA TURN
       ROR 
       BCC .PLYR
       JSR MYNUM
       BNE .CONT
.PLYR  JSR YRNUM
.CONT  CLC 
       ADC SUM
       BCS .ENDED
       STA SUM
       BNE PLAY
.ENDED PHA 
       PHA 
       JSR CRLF
       JSR PRSUM
       LDA #$1
       JSR PRHEX
       PLA 
       JSR OUTHEX
       JSR CRLF
       JSR CRLF
       JSR YOUORI
       JSR OUTSP
       PLA 
       BEQ .WIN
       LDA #<LOSE
       STA MSGL
       LDA #>LOSE
       STA MSGH
       SEC 
       BCS .SHOW
.WIN   LDA #<WIN
       STA MSGL
       LDA #>WIN
       STA MSGH
.SHOW  JSR SHWMSG
       JSR CRLF
       JSR CRLF
       JMP MAIN
       
GETCH  .M    
       LDA KBDRDY
       BPL GETCH
       LDA KBD
       AND #$7F
       RTS 

PROMPT .M   
       LDA #'-'
       JSR ECHO
OUTSP    
       LDA #SP
       JMP ECHO

CRLF   .M  
       LDA #CR
       JMP ECHO

PRVAL  .M
       CMP #$10
       BCC .NOTEN
       JSR OUTHEX
       BNE .SKIP
.NOTEN JSR PRHEX
.SKIP  JMP CRLF

SHWMSG .M
       LDY #$0
.PRINT LDA (MSGL),Y
       BEQ .DONE
       JSR ECHO
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

BYT2HX .M
       LDA IOBUF,X
       JSR ASC2HX
       CMP #FAIL
       BEQ .ERR
       PHA 
       INX 
       LDA IOBUF,X
       JSR ASC2HX
       CMP #FAIL
       BNE .CONT
       PLA 
       RTS 
.CONT  STA SCRTCH
       PLA 
       ASL 
       ASL 
       ASL 
       ASL 
       ADC SCRTCH
       RTS 
.ERR   LDA #FAIL
       RTS 

INIT   .M 
       LDA #$0
       STA TURN
       DEC TURN
       STA SUM
       STA TARGET
       INC TARGET
       RTS 

MYPLAY .M  
       LDA #<CMPPLY
       STA MSGL
       LDA #>CMPPLY
       STA MSGH
       JSR SHWMSG
       RTS 

MYNUM  .M  
       LDA SUM
       CMP TARGET
       BEQ .BAD
       BMI .GOOD
       LDA #$11
       CLC 
       ADC TARGET
       STA TARGET
       JMP MYNUM
.BAD   LDA SUM
       ADC TARGET
       AND #$0F
       BNE .SHOW
       LDA #$05
       BNE .SHOW
.GOOD  LDA TARGET
       SEC 
       SBC SUM
.SHOW  PHA 
       PHA 
       JSR MYPLAY
       PLA 
       JSR PRVAL
       PLA 
       RTS 

YRNUM  .M  
       JSR PROMPT
       LDX #$0
       STX IOBUF
       STX IOBUF+1
.ONECH JSR GETCH
       CMP #ESC
       BEQ .QUIT
       CMP #CR
       BEQ .DONE
       CMP #'0'
       BMI .ONECH
       CMP #'9'+1
       BPL .ONECH
       STA IOBUF,X
       JSR ECHO
       INX 
       CPX #$2
       BNE .ONECH
.DONE  JSR CRLF
       LDX #$0
       JSR BYT2HX
       BEQ .ERR
       CMP #FAIL
       BEQ .ERR
       CMP #$11
       BCS .ERR
       RTS 
.ERR   LDA #<ERROR
       STA MSGL
       LDA #>ERROR
       STA MSGH
       JSR SHWMSG
       JSR CRLF
       JMP YRNUM
.QUIT  PLA
       PLA
       RTS

PRSUM  .M  
       LDA #<SUMLN
       STA MSGL
       LDA #>SUMLN
       STA MSGH
       JMP SHWMSG

YOUORI .M  
       LDA TURN
       ROR 
       BCC .YOU
       LDA #'I'
       JMP ECHO
.YOU   LDA #<YOU
       STA MSGL
       LDA #>YOU
       STA MSGH
       JSR SHWMSG
       RTS 