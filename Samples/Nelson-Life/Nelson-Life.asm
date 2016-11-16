; JOHN CONWAY'S GAME OF LIFE
; CODE BY LARRY NELSON
; KRUSADER PORT BY KEN WESSEN

; NOTE BOARD MEMORY AT $2400+
; CLASHES WITH KRUSADER DEFAULT
; PROGRAM STORAGE LOCATION
; ZERO PAGE USAGE MOVED TO $Dn

ECHO    .= $FFEF
SP      .= $A0
CR      .= $8D

LIFE    .M
        LDX #$00        ENTRY POINT
        LDA #SP         PUT SPACES ON MAP
.CLEAR  STA $2400,X     BY STORING
        STA $2500,X     ON EACH PAGE
        STA $2600,X     OF THE FOUR
        STA $2700,X     PAGES USED
        INX             DONE YET?
        BNE .CLEAR      LOOP BACK

.MESS   LDA MESGE,X     GET THE OPENING MESSAGE
        JSR ECHO        AND PRINT IT ALL
        INX             UNTIL DONE
        CPX #$38       
        BNE .MESS       

.NAME   JSR INPUT       INPUT USER’S NAME
        CMP #CR         JUST TO RANDOMIZE
        BNE .NAME       THE RANDOM SEED
        JSR RANDOM      GET RANDOM NUMBER FOR START
        AND #$3F        RESULT IS 0 TO $3F
        ADC #$20        NOW RESULT IS $20 TO $5F
        STA $D9         NUMBER OF STARS TO START
        LDY #$00        ZERO THE INDIRECT POINTER

.RAND   JSR RANDOM      NOW WE WILL PLACE
        AND #$03        STARS ON MAP RANDOMLY
        CLC             FIRST CHOOSE A LOCATION
        ADC #$24        FROM PAGE
        STA $D1         $2400 TO PAGE
        LDA $DA         $27FF
        STA $D0         AND STORE IT AT $D0,$D1
        LDA #'*'        GET A 'STAR'
        STA ($D0),Y     PUT IT ON THE MAP
        DEC $D9         ARE WE DONE?
        BNE .RAND       NO, LOOP BACK.

PROUT   .M
        LDA #$24        PRINT BORDER ON SCREEN
        STA $D9         BY STORING START
        LDA #$40        LOCATION OF MAP
        STA $D8         AND
        LDX #$27        NUMBER OF ONE LINE
        LDA #'-'        OF 'DASHES'

.LOOP3  STA $27D8,X     PUT 'DASHES' AT BOTTOM
        STA $2440,X     AND TOP OF MAP
        DEX             UNTIL WE’VE DONE 40D
        BPL .LOOP3      LOOPS

.PRSCR  LDA ($D8),Y     NOW PRINT THE MAP
        JSR ECHO        TO THE SCREEN
        INC $D8         INCREMENT THE POINTERS
        BNE .PRSCR      NOT A NEW PAGE
        INC $D9         NEW PAGE
        LDA $D9         TEST IF DONE
        CMP #$28        BY COMPARING
        BNE .PRSCR      AND LOOPING

PAUSE   JSR INPUT       PAUSE AFTER PRINTING
        LDY #$00        AND START OVER

DUPL    .M     
        JSR STBRD       BY ZEROING POINTERS
.DUP2   LDA ($D0),Y     THEN MAKING A
        STA ($D2),Y     DUPLICATE OF THE MAP.
        INC $D0         IN ANOTHER MEMORY
        INC $D2         LOCATION
        BNE .DUP2       INCREMENT THE PAGES
        INC $D1         FROM AND TO
        INC $D3         
        LDA $D1         TEST FOR DONE
        CMP #$28       
        BNE .DUP2       AND LOOP IF NOT
        JSR ZEROS       FILL MAP WITH ZEROS

.LOOP1  LDY #$00        AND INDIRECT POINTER
        LDA ($D2),Y     IS THIS LOCATION
        CMP #'*'        A 'STAR'?
        BNE .INCR       NO THEN NEXT LOCATION
        LDY #$27        MUST BE A STAR
        JSR SETMAP      ADD ONE TO EACH NEIGHBOR
        LDY #$01        ALL EIGHT LOCATIONS
        JSR INCMAP     

.INCR   INC $D0         TRY NEXT LOCATION
        INC $D2         BOTH MAPS
        BNE .LOOP1      NEW PAGE?
        INC $D1         
        INC $D3         
        LDA $D1         TEST FOR DONE
        CMP #$28       
        BNE .LOOP1      AND LOOP IF NOT
        CLC             NOW TO ADD THE TOP

XFR     LDX #$27        AND BOTTOM LINES
.XFR1   LDA $27D8,X     TO MAKE THE MAP
        ADC $2468,X     A SPHERE
        STA $2468,X     BY TTESTING FOR NEIGHBORS
        LDA $2440,X     AT THE OTHER EDGE
        ADC $27B0,X     AND ADDING THEM TO
        STA $27B0,X     THE RESULTS STORED.
        DEX             ONLY HAVE TO DO
        BPL .XFR1       THIS 40 TIMES
        JSR STBRD       THEN APPLY

.MAKE   LDY #$00        CONWAYS RULES
        LDA ($D0),Y     FOR LIFE
        CMP #$02        OR DEATH OF THE
        BNE .NOT2       STARS
        LDA ($D2),Y     ONLY SITES WITH
        BNE .FOUND      THE RIGHT NUMBER

.NOT2   CMP #$03        OF NEIGHBORS WILL
        BNE .NOT3       LIVE OR BIRTH
        LDA #'*'        3 GIVES BIRTH
        BNE .FOUND      JUMP OVER

.NOT3   LDA #SP         SPACE IS DEATH

.FOUND  STA ($D0),Y     STORE SYMBOL
        INC $D0         AND GO TO NEXT
        INC $D2         SPACE
        BNE .MAKE       
        INC $D1         
        INC $D3         
        LDA $D3         
        CMP #$2C       
        BNE .MAKE       UNTIL
        JMP PROUT       DONE

STBRD   .M
        LDA #$24        SET UP POINTERS
        STA $D1         BY STORING
        LDA #$28        VALUES
        STA $D3         AT
        LDA #$40        FO,D1
        STA $D0         AND D2,D3
        STA $D2
        RTS

INPUT   .M
        INC $DA         ADD ONE TO LOW BYTE
        BNE .NEXT       IF ZERO,
        INC $DB         ADD 1 TO HIGH BYTE
       
.NEXT   LDA $D011       IS KEYBOARD ACTIVE?
        BPL INPUT       TIME TO INCREMENT RANDOM
        LDA $D010       ELSE GET THE KEY PRESS
        JSR ECHO        AND PRINT TO SCREEN
        RTS             THEN REURN

SETMAP  .M
        JSR INCMAP      THE NEIGHBORS OF A STAR
        INY             ARE +/-27,28,29
        CPY #$2A        AND +/-1
        BNE SETMAP      LOOP UNTIL
        RTS             DONE

INCMAP  .M
        CLC             Y HAS 1,27,28 OR 29
        LDA ($D0),Y     SO WE CAN
        ADC #$01        ADD 1 TO THE POSITIVE
        STA ($D0),Y     NEIGHBOR
        STY $D9         AND SAVE Y
        SEC             SO WE CAN
        LDA $D0         GET THE NEGATIVE
        SBC $D9         NEIGHBOR
        STA $D6         ADDRESS
        LDA $D1         LOW AND HIGH
        SBC #$00        AND STORE
        STA $D7         THE NEW ADDRESS
        LDY #$00        NOW SET POINTER
        LDA ($D6),Y     LOAD NEIGHBOR
        CLC             GET READY TO ADD
        ADC #$01        ONE TO NEIGHBOR
        STA ($D6),Y     AND SAVE RESULT
        LDY $D9         RESTORE Y
        RTS             RETURN

RANDOM  .M
        LDA $DB         RANDOM NUMBER GENERATOR
        STA $D6         SAVE HI BYTE TO TEMP
        LDA $DA         GET LO BYTE
        ASL             SHIFT LEFT
        ROL $D6         ROL INTO TEMP
        ASL             DO IT AGAIN
        ROL $D6         NOW 4 TIMES ORIGINAL
        CLC             CLEAR CARRY FLAG
        ADC $DA         ADD LO TO RESULT
        PHA             SAVE ACCUMULATOR ON STACK
        LDA $D6         GET TEMP
        ADC $DB         ADD HI BYTE
        STA $DB         SAVE
        PLA             RESTORE ACCUMULATOR
        ADC $11         ADD 17D
        STA $DA         STORE IT FOR SEED
        LDA $DB         GET HI BYTE
        ADC $36         ADD 54D – TOTAL =13841
        STA $DB         SAVE FOR SEED
        RTS             RETURN W/HI BYTE IN ACCUM.

ZEROS   .M
        JSR STBRD       SET UP POINTERS
        LDA #$00        CLEAR MAP
        TAY             ZERO Y
.ZERO   STA ($D0),Y     WORK THROUGH
        INC $D0         ALL MEMORY LOCATIONS
        BNE .ZERO       IN ALL FOUR PAGES
        INC $D1         
        LDX $D1         
        CPX #$28        UNTIL DONE
        BNE .ZERO       
        JSR STBRD       SET UP POINTERS AGAIN
        RTS     

MESGE   .B  CR
        .B  CR
        .S  'CONWAY'    OPENING MESSAGE
        .B  $A7
        .S  'S'
        .B  SP
        .S  'GAME'
        .B  SP
        .S  'OF'
        .B  SP
        .S  'LIFE'
        .B  CR
        .S  'PLEASE'
        .B  SP
        .S  'TYPE'
        .B  SP
        .S  'YOUR'
        .B  SP
        .S  'FULL'
        .B  SP
        .S  'NAME.'
        .B  CR
        .B  CR