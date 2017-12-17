TITLE CAPSTONE (EXE)
;-------------------------------------------------------------------------------------------
STACKSEG SEGMENT PARA 'Stack'
STACKSEG ENDS
;-------------------------------------------------------------------------------------------
DATASEG SEGMENT PARA 'Data'

  MESSAGE DB ?
  MENUFILE      DB 'menu.txt', 00H
  LOADING       DB 'loading.txt', 00H
  DONE_LOADING  DB 'doneload.txt', 00H
  HOW_TO        DB 'how.txt', 00H
  MAZE_1        DB 'maze1.txt', 00H
  MAZE_2        DB 'maze4.txt', 00H
  GAME_OVER     DB 'gameover.txt',00H
  MAZE_3        DB 'maze3.txt',00H
  WINNER        DB 1
  PLAYER_ONEW   DB "PLAYER 1 WINS!!!",'$'
  PLAYER_TWOW   DB "PLAYER 2 WINS!!!",'$'
  LEVEL_FLAG    DB 1
  CONTINUE_MES  DB "Press Up Button to continue...", '$'
  PLAYER1_TRACK DB "Player 1: ",'$'
  PLAYER2_TRACK DB "Player 2: ",'$'
  PLAYER1_OVERALL DB "TRIWIZARD CHAMPION IS PLAYER 1!!!",'$'
  PLAYER2_OVERALL DB "TRIWIZARD CHAMPION IS PLAYER 2!!!",'$'


  NEW_INPUT     DB ?
  FLAG          DW 01H,'$'

  PLAYER1_SCORE DB 48, '$'
  PLAYER2_SCORE DB 48, '$'

  STAT          DB 1

  FILEHANDLE    DW ?
  HERE          DB ">>$"
  BLANK         DB "  $"

  RECORD_STR        DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_LOAD       DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_M          DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_H          DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_MAZE1      DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_MAZE2      DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_GAMEOVER   DB 7500 DUP('$')  ;length = original length of record + 1 (for $)
  RECORD_MAZE_3     DB 7500 DUP('$')  ;length = original length of record + 1 (for $)

  TEMP    DB    ?
  LOAD_STR  DB    'L O A D I N G$'


  MOV_X         DB 23 ;x coordinate of player1
  MOV_Y         DB 75 ;y coordinate of player2
  NEW_ACTION    DB ?, '$'

  TEMP_X        DB ?, '$' ;temporary x
  TEMP_Y        DB ?, '$' ;temporary y

  MOV_X2        DB 23 ;x coordinate of player1
  MOV_Y2        DB 74 ;y coordinate of player2

  MOV_STATUS    DB ?, '$'
  X             DB ?, '$'
  Y             DB ?, '$'
  ONE_X1        DB ?
  ONE_Y1        DB ?
  TWO_X1        DB ?
  TWO_Y1        DB ?
  SPELL_STATUS1 DB 00H
  SPELL_STATUS2 DB 00H
  SY            DB ?
  SX            DB ?
  PLAYER_POST1  DB 03H ;to know the current position player 1 (left, right, up, down)
  PLAYER_POST2  DB 03H ;to know the current position player 2 (left, right, up, down)

DATASEG ENDS
;-------------------------------------------------------------------------------------------
CODESEG SEGMENT PARA 'Code'
  ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG

START:

MAIN PROC FAR ;This is where the flow of the game lies from START to EXIT.

  MOV AX, DATASEG
  MOV DS, AX
  MOV ES, AX


  ;SETUP
  ;MOV   BH, 07H           
  ;MOV   CX, 0000H         ;from top, leftmost
  ;MOV   DX, 184FH         ;to bottom, rightmost
  ;CALL  _CLEAR_SCREEN     ;clear screen

  CALL _FILE_READ         ;setup loading screen
  MOV FLAG, 01H
  CALL LOADING_PAGE       ;loading page
  MOV FLAG, 02H
  CALL _FILE_READ         ;done loading

  LOOP_FOR_ENTER: ; ;wait for up to go next

    CALL _GET_KEY
    CMP NEW_INPUT, 13 ;
    JE MENU_START
    CMP NEW_INPUT, 48H
    JE MENU_START
    JMP LOOP_FOR_ENTER

MENU_START:
  MOV STAT, 1H

  MOV   BH, 175           
  MOV   CX, 0000H         ; from top, leftmost
  MOV   DX, 184FH         ; to bottom, rightmost
  CALL  _CLEAR_SCREEN      ; clear screen
  MOV FLAG, 03H
  CALL _FILE_READ          ; call file read to show menu
  MOV NEW_INPUT, 04BH      ; get whether the player clicked up
  CALL _NAVIGATION         ; navigate through menu
  CALL _DETERMINE_MENU     ; when up is clicked, menu will go to the navigation page

  CMP STAT, 1
  JE START_GAME
  CMP STAT, 3
  JE EXIT_
  JMP EXIT_

  START_GAME:
    CALL _PLAY_NOW

EXIT_:
  MOV   AH, 4CH         ;force exit
  INT   21H

MAIN ENDP
;-------------------------------------------------------------------------------------------
_PLAY_NOW PROC NEAR ;this starts the game

__ITERATE:
  CALL _CLEAR_SCREEN

  MOV DL, MOV_Y
  MOV DH, MOV_X
  CALL _SET_CURSOR

  MOV   AL, 0001H
  MOV   AH, 02H
  MOV   DL, AL
  INT   21H

  MOV DL, MOV_Y2
  MOV DH, MOV_X2
  CALL _SET_CURSOR

  MOV   AL, 0002H
  MOV   AH, 02H
  MOV   DL, AL
  INT   21H

  MOV DL, ONE_Y1
  MOV DH, ONE_X1
  CALL _SET_CURSOR

  MOV NEW_ACTION, 00H
  CALL _GET_KEY_

  CMP NEW_ACTION, 0067H
    JE CHECK_STATUS
    JNE CHECK_ATTACK

  CHECK_STATUS:
    CMP SPELL_STATUS1, 03H
    JL CALL_SPELL_P1
    JGE CHECK_ATTACK
    
  CHECK_ATTACK:
    CMP NEW_ACTION, 006DH
    JE CHECK_STATUS1
    JNE UPDATE

  CHECK_STATUS1:
    CMP SPELL_STATUS2, 03H
    JL CALL_SPELL_P2
    JGE UPDATE  

    CALL_SPELL_P1:
      CALL CAST_SPELL_P1
      JMP __ITERATE

    CALL_SPELL_P2:
      CALL CAST_SPELL_P2
      JMP __ITERATE

    UPDATE:
      CALL UPDATE_PLAYER
      ;CALL UPDATE_SPELL_P1
      ;CALL UPDATE_SPELL_P2

JMP __ITERATE
_PLAY_NOW ENDP
;-------------------------------------------------------------------------------------------
CAST_SPELL_P1 PROC NEAR
  INC SPELL_STATUS1
  MOV DH, MOV_X
  MOV DL, MOV_Y
  MOV ONE_X1, DH
  MOV ONE_Y1, DL
  MOV DH, ONE_X1
  MOV DL, ONE_Y1

  CHEK_UP:
    CMP PLAYER_POST1, 00H
    JE SET_UP
    JNE CHECK_DOWN

  CHECK_DOWN:
    CMP PLAYER_POST1, 01H
    JE SET_DOWN
    JNE CHECK_RIGHT
  
  CHECK_RIGHT:
    CMP PLAYER_POST1, 02H
    JE SET_RIGHT
    JNE CHECK_LEFT

  CHECK_LEFT:
    CMP PLAYER_POST1, 03H
    JE SET_LEFT
    JMP SET_POST1

  SET_UP:  
    CALL UP_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_SU
    JNE SEE_STATUS_SU

    SEE_STATUS_SU:
      CMP MOV_STATUS, 02H
      JE DEC_SU
      JNE LEAVE_SU
    DEC_SU:
      DEC ONE_X1
      JMP SET_POST1
    LEAVE_SU:
      JMP LEAVING

  SET_DOWN:
    CALL DOWN_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_SD
    JNE SEE_STATUS_SD

    SEE_STATUS_SD:
      CMP MOV_STATUS, 02H
      JE DEC_SD
      JNE LEAVE_SD
    DEC_SD:
      INC ONE_X1
      JMP SET_POST1
    LEAVE_SD:
      JMP LEAVING

  SET_RIGHT:
    CALL RIGHT_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_SR
    JNE SEE_STATUS_SR

    SEE_STATUS_SR:
      CMP MOV_STATUS, 02H
      JE DEC_SR
      JNE LEAVE_SR
    DEC_SR:
      INC ONE_Y1
      JMP SET_POST1
    LEAVE_SR:
      JMP LEAVING

  SET_LEFT:
    CALL LEFT_MOVE
    MOV MOV_STATUS, AH
    
    CMP MOV_STATUS, 01H
    JE LEAVE_SL
    JNE SEE_STATUS_SL

    SEE_STATUS_SL:
      CMP MOV_STATUS, 02H
      JE DEC_SL
      JNE LEAVE_SL
    DEC_SL:
      DEC ONE_Y1
      JMP SET_POST1
    LEAVE_SL:
      JMP LEAVING    

SET_POST1:
  MOV DH, ONE_X1
  MOV DL, ONE_Y1
  CALL _SET_CURSOR
  MOV   AL, 002AH
  MOV   AH, 02H
  MOV   DL, AL
  INT   21H

LEAVING:
  RET
CAST_SPELL_P1 ENDP
;-------------------------------------------------------------------------------------------
CAST_SPELL_P2 PROC NEAR
  INC SPELL_STATUS2
  MOV DH, MOV_X2
  MOV DL, MOV_Y2
  
  MOV TWO_X1, DH
  MOV TWO_Y1, DL
  MOV DH, TWO_X1
  MOV DL, TWO_Y1

CONTINUING:
  CHEK_UP2:
    CMP PLAYER_POST2, 00H
    JE SET_UP2
    JNE CHECK_DOWN2

  CHECK_DOWN2:
    CMP PLAYER_POST2, 01H
    JE SET_DOWN2
    JNE CHECK_RIGHT2
  
  CHECK_RIGHT2:
    CMP PLAYER_POST2, 02H
    JE SET_RIGHT2
    JNE CHECK_LEFT2

  CHECK_LEFT2:
    CMP PLAYER_POST2, 03H
    JE SET_LEFT2
    JMP SET_POST

  SET_UP2:  
    CALL UP_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_SU2
    JNE SEE_STATUS_SU2

    SEE_STATUS_SU2:
      CMP MOV_STATUS, 02H
      JE DEC_SU2
      JNE LEAVE_SU2
    DEC_SU2:
      DEC TWO_X1
      JMP SET_POST
    LEAVE_SU2:
      JMP LEAVES

  SET_DOWN2:
    CALL DOWN_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_SD2
    JNE SEE_STATUS_SD2

    SEE_STATUS_SD2:
      CMP MOV_STATUS, 02H
      JE DEC_SD2
      JNE LEAVE_SD2
    DEC_SD2:
      INC TWO_X1
      JMP SET_POST
    LEAVE_SD2:
      RET

  SET_RIGHT2:
    CALL RIGHT_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_SR2
    JNE SEE_STATUS_SR2

    SEE_STATUS_SR2:
      CMP MOV_STATUS, 02H
      JE DEC_SR2
      JNE LEAVE_SR2
    DEC_SR2:
      INC TWO_Y1
      JMP SET_POST
    LEAVE_SR2:
      JMP LEAVES

  SET_LEFT2:
    CALL LEFT_MOVE
    MOV MOV_STATUS, AH
    
    CMP MOV_STATUS, 01H
    JE LEAVE_SL2
    JNE SEE_STATUS_SL2

    SEE_STATUS_SL2:
      CMP MOV_STATUS, 02H
      JE DEC_SL2
      JNE LEAVE_SL2
    DEC_SL2:
      DEC TWO_Y1
      JMP SET_POST
    LEAVE_SL2:
      RET    

  SET_POST:
    MOV DH, TWO_X1
    MOV DL, TWO_Y1
    CALL _SET_CURSOR
    MOV   AL, 002AH
    MOV   AH, 02H
    MOV   DL, AL
    INT   21H

 LEAVES:   
  RET
CAST_SPELL_P2 ENDP
;-------------------------------------------------------------------------------------------
;This procedure analysis the given key input and moves the player accordingly
UPDATE_PLAYER PROC NEAR
  ;MOV NEW_ACTION, 00H
  ;CALL _GET_KEY

  CALL _DELAY
;moving conditions for player1
  CMP_DOWN: ;PLAYER 1
    CMP NEW_ACTION, 0073H
    JE HELPER_DOWN  
    JNE CMP_UP

  CMP_UP: ;PLAYER 1
    CMP NEW_ACTION, 0077H
    JE HELPER_UP
    JNE CMP_LEFT

  CMP_LEFT: ;PLAYER 1
    CMP NEW_ACTION, 0061H
    JE HELPER_LEFT
    JNE CMP_RIGHT

  CMP_RIGHT: ;PLAYER 1
    CMP NEW_ACTION, 0064H
    JE HELPER_RIGHT
    JNE CMP_DOWN2
;moving conditions for player2
  CMP_DOWN2: ;PLAYER 2
    CMP NEW_ACTION, 50H
    JE HELPER_DOWN2
    JNE CMP_UP2

  CMP_UP2: ;PLAYER 2
    CMP NEW_ACTION, 48H
    JE HELPER_UP2
    JNE CMP_LEFT2

  CMP_LEFT2: ;PLAYER 2
    CMP NEW_ACTION, 4BH
    JE HELPER_LEFT2
    JNE CMP_RIGHT2

  CMP_RIGHT2: ;PLAYER 2
    CMP NEW_ACTION, 4DH
    JE HELPER_RIGHT2
    RET
;-------------------------------------------
HELPER_DOWN:
    JMP DOWN
HELPER_UP:
    JMP UP
HELPER_LEFT:
    JMP LEFT
HELPER_RIGHT:
    JMP RIGHT
;-------------------------------------------        
HELPER_DOWN2:
    JMP DOWN2
HELPER_UP2:
    JMP UP2
HELPER_LEFT2:
    JMP LEFT2
HELPER_RIGHT2:
    JMP RIGHT2         
;-------------------------------------------
UP:
    MOV WINNER, 1
    MOV PLAYER_POST1, 00H
    MOV DL, MOV_Y
    MOV DH, MOV_X
    CALL UP_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_U2
    JNE SEE_STATUS_U2

    SEE_STATUS_U2:
      CMP MOV_STATUS, 02H
      JE DEC_U2
      JNE LEAVE_U2
    DEC_U2:
      DEC MOV_X
    LEAVE_U2:
      RET
;-------------------------------------------
DOWN:
    MOV WINNER, 1
    MOV PLAYER_POST1, 01H
    MOV DL, MOV_Y
    MOV DH, MOV_X
    CALL DOWN_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_D2
    JNE SEE_STATUS_D2

    SEE_STATUS_D2:
      CMP MOV_STATUS, 02H
      JE DEC_D2
      JNE LEAVE_D2
    DEC_D2:
      INC MOV_X
    LEAVE_D2:
      RET
;-------------------------------------------
RIGHT:
    MOV WINNER, 1
    MOV PLAYER_POST1, 02H
    MOV DL, MOV_Y
    MOV DH, MOV_X
    CALL RIGHT_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_R2
    JNE SEE_STATUS_R2

    SEE_STATUS_R2:
      CMP MOV_STATUS, 02H
      JE DEC_R2
      JNE LEAVE_R2
    DEC_R2:
      INC MOV_Y
    LEAVE_R2:
      RET
;-------------------------------------------
LEFT:
    MOV WINNER, 1
    MOV PLAYER_POST1, 03H
    MOV DL, MOV_Y
    MOV DH, MOV_X
    CALL LEFT_MOVE
    MOV MOV_STATUS, AH
    
    CMP MOV_STATUS, 01H
    JE LEAVE_L2
    JNE SEE_STATUS_L2

    SEE_STATUS_L2:
      CMP MOV_STATUS, 02H
      JE DEC_L2
      JNE LEAVE_L2
    DEC_L2:
      DEC MOV_Y
    LEAVE_L2:
      RET
;-------------------------------------------
UP2:
    MOV WINNER, 2
    MOV PLAYER_POST2, 00H
    MOV DL, MOV_Y2
    MOV DH, MOV_X2
    CALL UP_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_U
    JNE SEE_STATUS_U

    SEE_STATUS_U:
      CMP MOV_STATUS, 02H
      JE DEC_U
      JNE LEAVE_U
    DEC_U:
      DEC MOV_X2
    LEAVE_U:
      RET
;-------------------------------------------
DOWN2:
    MOV WINNER, 2
    MOV PLAYER_POST2, 01H
    MOV DL, MOV_Y2
    MOV DH, MOV_X2
    CALL DOWN_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_D
    JNE SEE_STATUS_D

    SEE_STATUS_D:
      CMP MOV_STATUS, 02H
      JE DEC_D
      JNE LEAVE_D
    DEC_D:
      INC MOV_X2
    LEAVE_D:
      RET
;-------------------------------------------
RIGHT2:
    MOV WINNER, 2
    MOV PLAYER_POST2, 02H
    MOV DL, MOV_Y2
    MOV DH, MOV_X2
    CALL RIGHT_MOVE
    MOV MOV_STATUS, AH

    CMP MOV_STATUS, 01H
    JE LEAVE_R
    JNE SEE_STATUS_R

    SEE_STATUS_R:
      CMP MOV_STATUS, 02H
      JE DEC_R
      JNE LEAVE_R
    DEC_R:
      INC MOV_Y2
    LEAVE_R:
      RET
;-------------------------------------------
LEFT2:
    MOV WINNER, 2 
    MOV PLAYER_POST2, 03H
    MOV DL, MOV_Y2
    MOV DH, MOV_X2
    CALL LEFT_MOVE
    MOV MOV_STATUS, AH
    
    CMP MOV_STATUS, 01H
    JE LEAVE_L
    JNE SEE_STATUS_L

    SEE_STATUS_L:
      CMP MOV_STATUS, 02H
      JE DEC_L
      JNE LEAVE_L
    DEC_L:
      DEC MOV_Y2
    LEAVE_L:
      RET
UPDATE_PLAYER ENDP
;-------------------------------------------------------------------------------------------
;This procedure allows the left movement of the players
LEFT_MOVE PROC NEAR
    MOV Y, DL
    MOV X, DH
    MOV DL, Y
    MOV DH, X
    MOV TEMP_Y, DL
    DEC TEMP_Y
    MOV DL, TEMP_Y
    CALL _SET_CURSOR

    CALL _GET_CHAR_AT_CURSOR
    MOV NEW_INPUT, AL
    MOV DL, Y

    CMP NEW_INPUT, 32
    JE INC_LEFT
    JNE CHECK_PLAY1_LEFT

    CHECK_PLAY1_LEFT:
      CMP NEW_INPUT, 01H
      JE INC_LEFT
      JNE CHECK_PLAY2_LEFT

    CHECK_PLAY2_LEFT:
      CMP NEW_INPUT, 02H
      JE INC_LEFT
      JNE CHECK_CUP_LEFT

    CHECK_CUP_LEFT:
      CMP NEW_INPUT, 89
      JE WIN_LEFT
      JNE DEC_LEFT

    WIN_LEFT:
      MOV SPELL_STATUS1, 00H
      MOV SPELL_STATUS2, 00H
      CALL _PLAYER_WIN
      CALL _TERMINATE

    DEC_LEFT:
      MOV AH, 01H
      RET

    INC_LEFT:  
      CALL _SET_CURSOR
      CALL _ERASE
      MOV AH, 02H
  RET
LEFT_MOVE ENDP
;-------------------------------------------------------------------------------------------
;This procedure allows the right movement of the players
RIGHT_MOVE PROC NEAR
    MOV Y, DL
    MOV X, DH
    MOV DL, Y
    MOV DH, X
    MOV TEMP_Y, DL
    INC TEMP_Y
    MOV DL, TEMP_Y
    CALL _SET_CURSOR

    CALL _GET_CHAR_AT_CURSOR
    MOV NEW_INPUT, AL
    MOV DL, Y

    CMP NEW_INPUT, 32
    JE INC_RIGHT
    JNE CHECK_PLAY1_RIGHT

    CHECK_PLAY1_RIGHT:
      CMP NEW_INPUT, 01H
      JE INC_RIGHT
      JNE CHECK_PLAY2_RIGHT

    CHECK_PLAY2_RIGHT:
      CMP NEW_INPUT, 02H
      JE INC_RIGHT
      JNE CHECK_CUP_RIGHT

    CHECK_CUP_RIGHT:
      CMP NEW_INPUT, 89
      JE WIN_RIGHT
      JNE DEC_RIGHT

    WIN_RIGHT:
      MOV SPELL_STATUS1, 00H
      MOV SPELL_STATUS2, 00H
      CALL _PLAYER_WIN
      CALL _TERMINATE
    DEC_RIGHT:
      MOV AH, 01H
      RET
    INC_RIGHT:  
      CALL _SET_CURSOR
      CALL _ERASE
      MOV AH, 02H
RET
RIGHT_MOVE ENDP
;-------------------------------------------------------------------------------------------
;This procedure allows the down movement of the players
DOWN_MOVE PROC NEAR
    MOV Y, DL
    MOV X, DH
    MOV DL, Y
    MOV DH, X
    MOV TEMP_X, DH
    INC TEMP_X
    MOV DH, TEMP_X
    CALL _SET_CURSOR
    CALL _GET_CHAR_AT_CURSOR
    MOV NEW_INPUT, AL
    MOV DH, X
    
    CMP NEW_INPUT, 32
    JE INC_DOWN
    JNE CHECK_PLAY1_DOWN

    CHECK_PLAY1_DOWN:
      CMP NEW_INPUT, 01H
      JE INC_DOWN
      JNE CHECK_PLAY2_DOWN

    CHECK_PLAY2_DOWN:
      CMP NEW_INPUT, 02H
      JE INC_DOWN
      JNE CHECK_CUP_DOWN

    CHECK_CUP_DOWN:
      CMP NEW_INPUT, 89
      JE WIN_DOWN
      JNE DEC_DOWN

    WIN_DOWN:
      MOV SPELL_STATUS1, 00H
      MOV SPELL_STATUS2, 00H
      CALL _PLAYER_WIN
      CALL _TERMINATE

    DEC_DOWN:
      MOV MOV_STATUS, 01H
      RET
    INC_DOWN:  
      CALL _SET_CURSOR
      CALL _ERASE
      MOV MOV_STATUS, 02H
RET
DOWN_MOVE ENDP
;-------------------------------------------------------------------------------------------
;This procedure allows the up movement of the players
UP_MOVE PROC NEAR
    MOV Y, DL
    MOV X, DH
    MOV DL, Y
    MOV DH, X
    MOV TEMP_X, DH
    DEC TEMP_X
    MOV DH, TEMP_X
    CALL _SET_CURSOR
    CALL _GET_CHAR_AT_CURSOR
    MOV NEW_INPUT, AL
    MOV DH, X
    
    CMP NEW_INPUT, 32
    JE INC_UP
    JNE CHECK_PLAY1_UP

    CHECK_PLAY1_UP:
      CMP NEW_INPUT, 01H
      JE INC_UP
      JNE CHECK_PLAY2_UP

    CHECK_PLAY2_UP:
      CMP NEW_INPUT, 02H
      JE INC_UP
      JNE CHECK_CUP_UP

    CHECK_CUP_UP:
      CMP NEW_INPUT, 89
      JE WIN_UP
      JNE DEC_UP

    WIN_UP:
      MOV SPELL_STATUS1, 00H
      MOV SPELL_STATUS2, 00H
      CALL _PLAYER_WIN
      CALL _TERMINATE

    DEC_UP:
      MOV MOV_STATUS, 01H
      RET
    INC_UP:  
      CALL _SET_CURSOR
      CALL _ERASE
      MOV MOV_STATUS, 02H
RET
UP_MOVE ENDP
;-------------------------------------------------------------------------------------------
;this erase the char on the poition of the previous move
_ERASE PROC NEAR
  MOV DL, 32
  MOV AH, 02H
  INT 21H
RET
_ERASE ENDP

;-------------------------------------------------------------------------------------------
;this set the next postion of the players after the first level, 
;this also notify which player win the first level
  _PLAYER_WIN PROC NEAR
  MOV MOV_X, 16
  MOV MOV_Y, 78
  MOV MOV_X2, 4
  MOV MOV_Y2, 10

  MOV FLAG, 06H
  ;MOV BH, 07H           ; light gray on black
  CALL _CLEAR_SCREEN

  CALL _FILE_READ

  CMP WINNER, 1
  JE PRINT_PLAYER1
  JNE PRINT_PLAYER2

  PRINT_PLAYER1:
  INC PLAYER1_SCORE
  MOV DH, 19 ;y
  MOV DL, 33 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER_ONEW
  MOV AH, 9
  INT 21H
  CMP LEVEL_FLAG, 1
  JE SECOND_LEVEL
  CMP LEVEL_FLAG, 3
  JE DONTPRINT
  JNE THIRD_LEVEL

  PRINT_PLAYER2:
  INC PLAYER2_SCORE
  MOV DH, 19 ;y
  MOV DL, 33 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER_TWOW
  MOV AH, 9
  INT 21H
  CMP LEVEL_FLAG, 1
  JE SECOND_LEVEL
  CMP LEVEL_FLAG, 3
  JE DONTPRINT
  JNE THIRD_LEVEL

SECOND_LEVEL:
  MOV LEVEL_FLAG, 2
  CALL SECOND_LEVEL1

THIRD_LEVEL:
  MOV LEVEL_FLAG, 3
  CALL THIRD_LEVEL1

  dontprint:

  MOV DH, 15 ;y
  MOV DL, 8 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_TRACK
  MOV AH, 9
  INT 21H

  MOV DH, 16 ;y
  MOV DL, 12 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_SCORE
  MOV AH, 9
  INT 21H

  MOV DH, 15 ;y
  MOV DL, 60 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_TRACK
  MOV AH, 9
  INT 21H

  MOV DH, 16 ;y
  MOV DL, 65 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_SCORE
  MOV AH, 9
  INT 21H

  MOV AL, PLAYER1_SCORE
  CMP PLAYER2_SCORE, AL
  JA TWOWINS
  JMP ONEWINS

  ONEWINS:
  MOV DH, 10 ;y
  MOV DL, 22 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_OVERALL
  MOV AH, 9
  INT 21H

  CALL _TERMINATE
  TWOWINS:

  MOV DH, 10 ;y
  MOV DL, 22 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_OVERALL
  MOV AH, 9
  INT 21H
  CALL _TERMINATE
_PLAYER_WIN ENDP

;-------------------------------------------------------------------------------------------
;sets the position of the player in the next level, notify the winner and call the next maze
THIRD_LEVEL1 PROC NEAR
  MOV MOV_X, 14
  MOV MOV_Y, 60
  MOV MOV_X2, 14
  MOV MOV_Y2, 60

  MOV DH, 20 ;y
  MOV DL, 25 ;x
  CALL _SET_CURSOR
  LEA DX, CONTINUE_MES
  MOV AH, 9
  INT 21H
  MOV DH, 15 ;y
  MOV DL, 8 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_TRACK
  MOV AH, 9
  INT 21H

  MOV DH, 16 ;y
  MOV DL, 12 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_SCORE
  MOV AH, 9
  INT 21H

  MOV DH, 15 ;y
  MOV DL, 60 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_TRACK
  MOV AH, 9
  INT 21H

  MOV DH, 16 ;y
  MOV DL, 65 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_SCORE
  MOV AH, 9
  INT 21H

  MOV NEW_INPUT, 00H
  LOOP_HERE_3: 
  MOV DX, 0000H
  CALL _SET_CURSOR
  CALL _GET_KEY
  CMP NEW_INPUT, 48H
  JE CONTINUE_THIRD_LEVEL

  JMP LOOP_HERE_3

CONTINUE_THIRD_LEVEL:
  MOV FLAG, 07H
  MOV DX, 0000H
  CALL _SET_CURSOR
  CALL _CLEAR_SCREEN
  CALL _FILE_READ
  CALL _PLAY_NOW


THIRD_LEVEL1 ENDP
;-------------------------------------------------------------------------------------------
;sets the position of the player in the next level, notify the winner and call the next maze
SECOND_LEVEL1 PROC NEAR
  MOV DH, 20 ;y
  MOV DL, 25 ;x
  CALL _SET_CURSOR
  LEA DX, CONTINUE_MES
  MOV AH, 9
  INT 21H
  MOV DH, 15 ;y
  MOV DL, 8 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_TRACK
  MOV AH, 9
  INT 21H

  MOV DH, 16 ;y
  MOV DL, 12 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER1_SCORE
  MOV AH, 9
  INT 21H

  MOV DH, 15 ;y
  MOV DL, 60 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_TRACK
  MOV AH, 9
  INT 21H

  MOV DH, 16 ;y
  MOV DL, 65 ;x
  CALL _SET_CURSOR
  LEA DX, PLAYER2_SCORE
  MOV AH, 9
  INT 21H

  MOV NEW_INPUT, 00H
  LOOP_HERE_2: 
  MOV DX, 0000H
  CALL _SET_CURSOR
  CALL _GET_KEY
  CMP NEW_INPUT, 48H
  JE CONTINUE_SECOND_LEVEL

  JMP LOOP_HERE_2

CONTINUE_SECOND_LEVEL:
  MOV FLAG, 08H
  MOV DX, 0000H
  CALL _SET_CURSOR
  CALL _CLEAR_SCREEN
  CALL _FILE_READ
  CALL _PLAY_NOW

SECOND_LEVEL1 ENDP
;-------------------------------------------------------------------------------------------

_DETERMINE_MENU PROC NEAR ;This procedure determines whether the state should be a game state, how to play state, or terminate.

DETERMINE_THIS:

  CMP STAT, 1
  JE PLAY_PLAY

  CMP STAT, 2
  JE PLAY_HOW

  CMP STAT, 3
  JE BYE2

PLAY_HOW: 

  MOV FLAG, 04H
  JMP CHANGE_STATE

PLAY_PLAY:
  MOV FLAG, 05H
  JMP CHANGE_STATE

CHANGE_STATE:
  ;MOV BH, 27H
  ;MOV   CX, 0000H         ;from top, leftmost
  ;MOV   DX, 184FH         ;to bottom, rightmost
  CALL _CLEAR_SCREEN
  CALL _FILE_READ
  MOV NEW_INPUT, 00H

  CMP STAT, 2
  JE WHAT_NEXT
  JMP BYE3

WHAT_NEXT:
  CALL _GET_KEY
  CMP NEW_INPUT, 4BH
  JE CHANGESTAT
  CMP NEW_INPUT, 4DH
  JE BYE2
  JMP WHAT_NEXT

CHANGESTAT:
  MOV FLAG, 03H
  CALL _CLEAR_SCREEN
  CALL _FILE_READ
  MOV FLAG, 00H
  CALL _NAVIGATION         ; navigate through menu
  JMP DETERMINE_THIS

  JMP BYE3
BYE2:
  CALL _TERMINATE
BYE3:
_DETERMINE_MENU ENDP

;-------------------------------------------------------------------------------------------

_NAVIGATION PROC NEAR ;This procedure figures out where in the menu is the user navigating to.

MOV STAT, 00H
MOV STAT, 1

LOOP_NAVIGATE:
  
  CALL _GET_KEY
  CMP NEW_INPUT, 50H
  JE LOOP_NAVIGATE
  CMP NEW_INPUT, 4BH
  JE MOVELEFT
  CMP NEW_INPUT, 4DH
  JE MOVERIGHT
  CMP NEW_INPUT, 48H
  JE GOODBYE

  MOV NEW_INPUT, 50H
  JMP LOOP_NAVIGATE
  MOV NEW_INPUT, 50H

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

  MOV DH, 22 ;y
  MOV DL, 30 ;x
  CALL _SET_CURSOR
  LEA DX, BLANK
  MOV AH, 9
  INT 21H

  MOV DH, 22 ;y
  MOV DL, 56 ;x
  CALL _SET_CURSOR
  LEA DX, BLANK
  MOV AH, 9
  INT 21H

  MOV DH, 22 ;y
  MOV DL, 10 ;x
  CALL _SET_CURSOR
  LEA DX, BLANK
  MOV AH, 9
  INT 21H

  CMP STAT, 1
  JE MENU_
  CMP STAT, 2
  JE HOW_
  CMP STAT, 3
  JE EXIT_2
  JMP LOOP_NAVIGATE

MENU_:

  MOV DH, 22 ;y
  MOV DL, 10 ;x
  CALL _SET_CURSOR
  LEA DX, HERE
  MOV AH, 9
  INT 21H

  JMP READ

HOW_:
  MOV DH, 22 ;y
  MOV DL, 30 ;x
  CALL _SET_CURSOR
  LEA DX, HERE
  MOV AH, 9
  INT 21H

  JMP READ

EXIT_2:
  MOV DH, 22 ;y
  MOV DL, 56 ;x
  CALL _SET_CURSOR
  LEA DX, HERE
  MOV AH, 9
  INT 21H
  JMP READ

 READ: 
  MOV NEW_INPUT, 00H
  JMP LOOP_NAVIGATE

BYEEE:
;goodbye

_NAVIGATION ENDP

;-------------------------------------------------------------------------------------------

_CLEAR_SCREEN PROC  NEAR ;This clears the screen to view a state.
  MOV   AX, 0600H
  INT   10H
  RET
_CLEAR_SCREEN ENDP

;-------------------------------------------------------------------------------------------

_SET_CURSOR PROC  NEAR ;This sets the cursor at the end of the screen or wherever it should be placed.
      MOV   AH, 02H
      MOV   BH, 00
      INT   10H
      RET
_SET_CURSOR ENDP

;-------------------------------------------------------------------------------------------
;this procedure allows the printing of the ascii characters that are out of scope in 8086
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

LOADING_PAGE PROC NEAR ;This calls the state where it loads the game.

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

  ___ITERATE:
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

      JMP   ___ITERATE

DONE_LOAD:

LOADING_PAGE ENDP


;-------------------------------------------------------------------------------------------

_GET_KEY  PROC  NEAR ;This procedure helps get the inputs from both players. There are if-else statements within the code regarding the different inputs.
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

;This reads the different stages in our game: the loading state, done loading state, menu state, the mazes which are the game states, the highest score state,
;list of scores state and game over state.
  MOV   BH, 2FH          
  MOV   CX, 0000H         ;from top, leftmost
  MOV   DX, 184FH         ;to bottom, rightmost
  CALL  _CLEAR_SCREEN     ;clear screen

  MOV   DX, 0000
  CALL  _SET_CURSOR

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
  JE DISPLAY_MAZE

  CMP FLAG, 06H
  JE DISPLAY_GAMEOVER

  CMP FLAG, 07H
  JE DISPLAY_MAZE_3

  CMP FLAG, 08H
  JE DISPLAY_MAZESECOND

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
  LEA DX, HOW_TO
  JMP CONTINUE_AF

DISPLAY_MAZE:
  LEA DX, MAZE_1
  JMP CONTINUE_AF

DISPLAY_GAMEOVER:
  LEA DX, GAME_OVER
  JMP CONTINUE_AF

DISPLAY_MAZE_3:
  LEA DX, MAZE_3
  JMP CONTINUE_AF

DISPLAY_MAZESECOND:
  LEA DX, MAZE_2
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
  JE RECORD_MAZEONE

  CMP FLAG, 06H
  JE RECORD_GAMEOVER1
  
  CMP FLAG, 07H
  JE RECORD_HS

  CMP FLAG, 08H
  JE RECORD_MMAZE2

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

RECORD_MAZEONE:
  LEA DX, RECORD_MAZE1    
  INT 21H
  LEA SI, RECORD_MAZE1
  JMP DONE_RECORD

RECORD_GAMEOVER1:
  LEA DX, RECORD_GAMEOVER    
  INT 21H
  LEA SI, RECORD_GAMEOVER
  JMP DONE_RECORD
RECORD_HS:
  LEA DX, RECORD_MAZE_3    
  INT 21H
  LEA SI, RECORD_MAZE_3
  JMP DONE_RECORD
RECORD_MMAZE2:
  LEA DX, RECORD_MAZE2
  INT 21H
  LEA SI, RECORD_MAZE2
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
;ends the program
_TERMINATE PROC NEAR
      ;set cursor
      MOV   DL, 00H
      MOV   DH, 00
      CALL  _SET_CURSOR

      ;set cursor
      MOV   DL, 00
      MOV   DH, 00
      CALL  _SET_CURSOR

      MOV   AX, 4C00H
      INT   21H
_TERMINATE ENDP
;-------------------------------------------------------------------------------------------
;get the character at the cursor location
_GET_CHAR_AT_CURSOR PROC  NEAR  
      MOV   AH, 08H
      MOV   BH, 00
      INT   10H
      RET
_GET_CHAR_AT_CURSOR ENDP
;-------------------------------------------------------------------------------------------
;this get the user input
_GET_KEY_  PROC  NEAR
      MOV   AH, 01H   ;check for input
      INT   16H

      JZ    __LEAVETHIS_

      MOV   AH, 00H   ;get input  MOV AH, 10H; INT 16H
      INT   16H

      MOV   NEW_ACTION, AH

      CMP AL, 27
      JE  EXIT

      CMP NEW_ACTION, 50H
      JE __LEAVETHIS_

      CMP NEW_ACTION, 48H
      JE __LEAVETHIS_

      CMP NEW_ACTION, 4BH
      JE __LEAVETHIS_

      CMP NEW_ACTION, 4DH
      JE __LEAVETHIS_

      CMP AL, 64H
      JE NEXT1
      NEXT1:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS_
      JNE CONT1  

      CONT1:
      CMP AL, 61H
      JE NEXT2
      NEXT2:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS_
      JNE CONT2  

      CONT2:
      CMP AL, 74H
      JE NEXT3
      NEXT3:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS_
      JNE CONT3  

      CONT3:
      CMP AL, 77H
      JE NEXT4
      NEXT4:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS_ 
      JNE CONT4

      CONT4:
        CMP AL, 67H
        JE NEXT5
        NEXT5:
          MOV NEW_ACTION, AL
          JMP __LEAVETHIS_

      CONT5:
        CMP AL, 6DH
        JE NEXT6
        NEXT6:
          MOV NEW_ACTION, AL
          JMP __LEAVETHIS_
 
  __LEAVETHIS_:
      RET
_GET_KEY_  ENDP

;-------------------------------------------------------------------------------------------

CODESEG ENDS
END START
