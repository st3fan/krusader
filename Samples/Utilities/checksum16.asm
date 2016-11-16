PRBYTE .=  $FFDC

CRCLO  .=  $10
CRCHI  .=  $11
STARTL .=  $12
STARTH .=  $13
ENDL   .=  $14
ENDH   .=  $15

START  .=  $F000
ENDP1  .=  $FEFF

MAIN   .M
       LDA #<START
       STA STARTL
       LDA #>START
       STA STARTH
       LDA #<ENDP1
       STA ENDL
       LDA #>ENDP1
       STA ENDH
       LDA #$FF
       STA CRCLO
       STA CRCHI
.LOOP  LDY #$0
       LDA (STARTL),Y
       SEC
       BCS CRC16
;       JSR CRC16
CONT   INC STARTL
       BNE .SKIP2
       INC STARTH
.SKIP2 LDA STARTH
       CMP ENDH
       BNE .LOOP
       LDA STARTL
       CMP ENDL
       BNE .LOOP
       LDA CRCHI
       JSR PRBYTE
       LDA CRCLO
       JSR PRBYTE
       RTS
       
CRC16  .M
      EOR CRCHI
      STA CRCHI
      LSR
      LSR
      LSR
      LSR
      TAX
      ASL
      EOR CRCLO
      STA CRCLO
      TXA
      EOR CRCHI
      STA CRCHI
      ASL
      ASL
      ASL
      TAX
      ASL
      ASL
      EOR CRCHI
      TAY
      TXA
      ROL
      EOR CRCLO
      STA CRCHI
      STY CRCLO
      SEC
      BCS CONT
;      RTS