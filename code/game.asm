TITLE ASM1 (EXE)
;-------------------------------------------------------------------------------------------
STACKSEG SEGMENT PARA 'Stack'
  DW 32 DUP ('E')
STACKSEG ENDS
;-------------------------------------------------------------------------------------------
DATASEG SEGMENT PARA 'Data'
  MESSAGE DB ?
  MENUFILE      DB 'menu.txt', 00H
  HOWFILE       DB 'how.txt', 00H
  EXITFILE      DB 'exit.txt', 00H
  LOADING       DB 'loading.txt', 00H
  DONE_LOADING  DB 'doneload.txt', 00H

  NEW_INPUT     DB ?
  FLAG          DW 01H,'$'

  STAT          DB 1

  FILEHANDLE    DW ?

  RECORD_STR    DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_LOAD    DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_M    DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_H    DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_E    DB 7500 DUP('$')  ;length = original length of record + 1 (for $)


  ERROR1_STR    DB 'Error in opening file.$'
  ERROR2_STR    DB 'Error reading from file.$'
  ERROR3_STR    DB 'No record read from file.$'
  TEMP    DB    ?
  LOAD_STR  DB    'L O A D I N G$'

DATASEG ENDS
;-------------------------------------------------------------------------------------------
CODESEG SEGMENT PARA 'Code'
  ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG

START:

MAIN PROC FAR

  MOV AX, DATASEG
  MOV DS, AX
  MOV ES, AX


  ;SETUP
  MOV   BH, 07H           
  MOV   CX, 0000H         ;from top, leftmost
  MOV   DX, 184FH         ;to bottom, rightmost
  CALL  _CLEAR_SCREEN     ;clear screen

  CALL _FILE_READ         ;setup loading screen
  MOV FLAG, 01H
  CALL LOADING_PAGE       ;loading page
  MOV FLAG, 02H
  CALL _FILE_READ         ;done loading

  LOOP_FOR_ENTER:

    CALL _GET_KEY
    CMP NEW_INPUT, 13 ;FIX THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS ENTER
    JE MENU_START
    CMP NEW_INPUT, 48H
    JE MENU_START
    JMP LOOP_FOR_ENTER

MENU_START:

  MOV   BH, 07H           
  MOV   CX, 0000H         ;from top, leftmost
  MOV   DX, 184FH         ;to bottom, rightmost
  CALL  _CLEAR_SCREEN     ;clear screen

  MOV FLAG, 03H
  CALL _FILE_READ
  MOV NEW_INPUT, 04BH
  CALL _NAVIGATION

EXIT_:
  MOV   AH, 4CH         ;force exit
  INT   21H

MAIN ENDP

;-------------------------------------------------------------------------------------------

_NAVIGATION PROC NEAR

LOOP_NAVIGATE:

  CALL _GET_KEY
  CMP NEW_INPUT, 00H
  JE LOOP_NAVIGATE
  CMP NEW_INPUT, 4BH
  JE MOVELEFT
  CMP NEW_INPUT, 4DH
  JE MOVERIGHT
  CMP NEW_INPUT, 48H
  JE GOODBYE

  MOV NEW_INPUT, 00H
  JMP LOOP_NAVIGATE
  MOV NEW_INPUT, 00H

MOVELEFT:
  CMP STAT, 1
  JE LOOP_NAVIGATE
  JNE SUB_STAT

MOVERIGHT:
  CMP STAT, 3
  JE LOOP_NAVIGATE
  JB ADD_STAT

ADD_STAT:
  CMP STAT, 1
  JE TWO
  JNE THREE

GOODBYE:
  JMP BYEEE

TWO:
  MOV STAT, 2
  JMP EVALUATE

THREE:
  MOV STAT, 3
  JMP EVALUATE

SUB_STAT:
  CMP STAT, 3
  JE SUBTWO
  JNE SUBONE

SUBTWO:
  MOV STAT, 2
  JMP EVALUATE

SUBONE:
  MOV STAT, 1
  JMP EVALUATE

EVALUATE:
  CMP STAT, 1
  JE MENU_
  CMP STAT, 2
  JE HOW_
  CMP STAT, 3
  JE EXIT_2
  JMP LOOP_NAVIGATE

MENU_:
  MOV FLAG, 03H
  JMP READ

HOW_:
  MOV FLAG, 04H
  JMP READ

EXIT_2:
  MOV FLAG, 05H
  JMP READ

READ:
  CALL _FILE_READ
  JMP LOOP_NAVIGATE

BYEEE:

_NAVIGATION ENDP

;-------------------------------------------------------------------------------------------

_CLEAR_SCREEN PROC  NEAR
  MOV   AX, 0600H
  INT   10H
  RET
_CLEAR_SCREEN ENDP

;-------------------------------------------------------------------------------------------

_SET_CURSOR PROC  NEAR
      MOV   AH, 02H
      MOV   BH, 00
      INT   10H
      RET
_SET_CURSOR ENDP

;-------------------------------------------------------------------------------------------

OUTPUT_EXT PROC NEAR

PRINT:
  MOV   DX, [SI]
  CMP   DL, 226
  JE    SPEC 
  CMP   DL, 194
  JE    THIS_HERE
  JNE   CONT

SPEC:
  
  INC   SI
  MOV   DX, [SI]
  CMP   DL, 96H
  JE    SPECIAL
  INC   SI
  MOV   DX, [SI]
  CMP   DL, 94H
  JE    UP_LEFT
  CMP   DL, 97H
  JE    UP_RIGHT
  CMP   DL, 91H
  JE    STRA_VERT
  CMP   DL, 9DH
  JE    LOW_LEFT
  CMP   DL, 9AH
  JE    LOW_RIGHT
  CMP   DL, 90H
  JE    STRA_HORI
  CMP   DL, 166
  JE    TOP_DOWN
  CMP   DL, 169
  JE    BOTTOM_UP
  JNE   CONT

CONT:
  CMP   DL, 24H
  JE    RETURN_LOAD
  MOV   AH, 02H
  INT   21H
  INC   SI
  JMP   PRINT
THIS_HERE:
  MOV   DL, 175
  JMP   CONT
TOP_DOWN:
  MOV   DL, 203
  JMP   CONT
BOTTOM_UP:
  MOV   DL, 202
  JMP   CONT
UP_LEFT:
  MOV   DL, 201
  JMP   CONT
UP_RIGHT:
  MOV   DL, 187
  JMP   CONT
STRA_VERT:
  MOV   DL, 186
  JMP   CONT
LOW_RIGHT:
  MOV   DL, 200
  JMP   CONT
LOW_LEFT:
  MOV   DL, 188
  JMP   CONT
STRA_HORI:
  MOV   DL, 205
  JMP   CONT
STRIKE:
  MOV   DL, 176
  JMP   CONT
BLACK:
  MOV   DL, 219
  JMP   CONT
BLACK_STRIKE:
  MOV   DL, 178
  JMP   CONT
CURSOR_POINT:
  MOV   DL, 16
  JMP   CONT

SPECIAL:
  INC   SI 
  MOV   DX, [SI]
  CMP   DL, 91H
  JE    STRIKE
  CMP   DL, 88H
  JE    BLACK
  CMP   DL, 93H
  JE    BLACK_STRIKE
  CMP   DL, 186
  JE    CURSOR_POINT
  JNE   CONT
RETURN_LOAD:
  RET
OUTPUT_EXT ENDP

;-------------------------------------------------------------------------------------------

LOADING_PAGE PROC NEAR

;clear screen
      CALL  _CLEAR_SCREEN

      ;set cursor
      MOV   DL, 22H
      MOV   DH, 11
      CALL  _SET_CURSOR

      ;display loading
      MOV   AH, 09H
      LEA   DX, LOAD_STR
      INT   21H

      MOV   TEMP, 06 ;changed ;left

  __ITERATE:
      ;set cursor
      MOV   DL, TEMP
      MOV   DH, 15 ;changed ; y axis
      CALL  _SET_CURSOR

      ;display char from register
      MOV   AL, 0DBH
      MOV   AH, 02H
      MOV   DL, AL
      INT   21H

      CALL  _DELAY

      INC   TEMP
      CMP   TEMP, 4AH ;changed ; right
      JE    DONE_LOAD

      JMP   __ITERATE

DONE_LOAD:

LOADING_PAGE ENDP


;-------------------------------------------------------------------------------------------

_GET_KEY  PROC  NEAR
      MOV   AH, 01H   ;check for input
      INT   16H

      JZ    __LEAVETHIS

      MOV   AH, 00H   ;get input  MOV AH, 10H; INT 16H
      INT   16H

      MOV   NEW_INPUT, AH

  __LEAVETHIS:
      RET
_GET_KEY  ENDP

;-------------------------------------------------------------------------------------------

_FILE_READ PROC NEAR

  MOV AH, 3DH
  MOV AL, 00  

  CMP FLAG, 01H
  JE DISPLAY_LOADING

  CMP FLAG, 02H
  JE DISPLAY_DONELOADING

  CMP FLAG, 03H
  JE DISPLAY_MENU

  CMP FLAG, 04H
  JE DISPLAY_HOW

  CMP FLAG, 05H
  JE DISPLAY_EXIT

DISPLAY_LOADING:
  LEA DX, LOADING
  JMP CONTINUE_AF

DISPLAY_DONELOADING:
  LEA DX, DONE_LOADING
  JMP CONTINUE_AF

DISPLAY_MENU:
  LEA DX, MENUFILE
  JMP CONTINUE_AF

DISPLAY_HOW:
  LEA DX, HOWFILE
  JMP CONTINUE_AF

DISPLAY_EXIT:
  LEA DX, EXITFILE
  JMP CONTINUE_AF

CONTINUE_AF:
  INT 21H
  MOV FILEHANDLE, AX

  MOV AH, 3FH           
  MOV BX, FILEHANDLE   
  MOV CX, 7500          
  
  CMP FLAG, 01H
  JE RECORD_THISSTR

  CMP FLAG, 02H
  JE RECORD_DONELOAD

  CMP FLAG, 03H
  JE RECORD_MENU

  CMP FLAG, 04H
  JE RECORD_HOW

  CMP FLAG, 05H
  JE RECORD_EXIT
  
RECORD_THISSTR:

  LEA DX, RECORD_STR    
  INT 21H
  LEA SI, RECORD_STR

  JMP DONE_RECORD

RECORD_DONELOAD:

  LEA DX, RECORD_LOAD    
  INT 21H
  LEA SI, RECORD_LOAD

  JMP DONE_RECORD

RECORD_MENU:

  LEA DX, RECORD_M    
  INT 21H
  LEA SI, RECORD_M

  JMP DONE_RECORD

RECORD_HOW:

  LEA DX, RECORD_H    
  INT 21H
  LEA SI, RECORD_H

  JMP DONE_RECORD

RECORD_EXIT:

  LEA DX, RECORD_M    
  INT 21H
  LEA SI, RECORD_M

  JMP DONE_RECORD

DONE_RECORD:
  CALL OUTPUT_EXT
  MOV AH, 3EH           
  MOV BX, FILEHANDLE    
  INT 21H

  JMP EXIT

EXIT:
_FILE_READ ENDP

;-------------------------------------------------------------------------------------------

_DELAY PROC NEAR
      mov bp, 2 ;lower value faster
      mov si, 2 ;lower value faster
    delay2:
      dec bp
      nop
      jnz delay2
      dec si
      cmp si,0
      jnz delay2
      RET
_DELAY ENDP
;-------------------------------------------------------------------------------------------
_TERMINATE PROC NEAR
      ;set cursor
      MOV   DL, 22H
      MOV   DH, 11
      CALL  _SET_CURSOR

      ;set cursor
      MOV   DL, 00
      MOV   DH, 13
      CALL  _SET_CURSOR

      MOV   AX, 4C00H
      INT   21H
_TERMINATE ENDP
;-------------------------------------------------------------------------------------------

CODESEG ENDS
END START