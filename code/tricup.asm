TITLE ASM1 (EXE)
;-------------------------------------------------------------------------------------------
STACKSEG SEGMENT PARA 'Stack'
  DW 32 DUP ('E')
STACKSEG ENDS
;-------------------------------------------------------------------------------------------
DATASEG SEGMENT PARA 'Data'
  MESSAGE DB ?
  MENUFILE      DB 'menu.txt', 00H
  LOADING       DB 'loading.txt', 00H
  DONE_LOADING  DB 'doneload.txt', 00H
  HOW_TO        DB 'hs.txt', 00H
  MAZE_1        DB 'maze1.txt', 00H
  WIN           DB 'win.txt', 00H

  NEW_INPUT     DB ? 
  FLAG          DW 01H,'$'

  STAT          DB 1

  FILEHANDLE    DW ?

  RECORD_STR    DB 7500 DUP('$')  
  RECORD_LOAD   DB 7500 DUP('$')  
  RECORD_M      DB 7500 DUP('$') 
  RECORD_H      DB 7500 DUP('$')  
  RECORD_E      DB 7500 DUP('$')  
  RECORD_MAZE1  DB 7500 DUP('$')
  RECORD_WIN    DB 7500 DUP('$')

  ERROR1_STR    DB 'Error in opening file.$'
  ERROR2_STR    DB 'Error reading from file.$'
  ERROR3_STR    DB 'No record read from file.$'
  TEMP          DB  ?
  LOAD_STR      DB  'L O A D I N G$'

  MOV_X         DB 03H
  MOV_Y         DB 46H
  NEW_ACTION    DB ?, '$'

  TEMP_X        DB ?, '$'
  TEMP_Y        DB ?, '$'

  MOV_X2        DB 13H
  MOV_Y2        DB 42H

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

  TSY           DB ?
  TSX           DB ?
  
  PLAYER_POST1  DB 03H
  PLAYER_POST2  DB 03H
  
  HIT_FLAG1     DB 00H
  HIT_FLAG2     DB 00H
  
  COUNT1        DB 10
  COUNT2        DB 10
  
  COL_CHECK     DB ?
  
  IS_COLLISION  DB 00H
  INPUT         DB ?

  CALLER_FLAG   DB ?

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
  MOV   CX, 0000H         
  MOV   DX, 184FH         
  CALL  _CLEAR_SCREEN

  MOV FLAG, 05H
  CALL _FILE_READ         
  
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

  MOV NEW_ACTION, 00H
  CALL _GET_KEY

  CMP NEW_ACTION, 0067H
    JE CHECK_STATUS
    JNE CHECK_ATTACK

  CHECK_STATUS:
    CMP SPELL_STATUS1, 00H
    JE CALL_SPELL_P1
    JNE CHECK_ATTACK
    
  CHECK_ATTACK:
    CMP NEW_ACTION, 006DH
    JE CHECK_STATUS1
    JNE UPDATE

  CHECK_STATUS1:
    CMP SPELL_STATUS2, 00H
    JE CALL_SPELL_P2
    JNE UPDATE  

    CALL_SPELL_P1:
      CALL CAST_SPELL_P1
      JMP __ITERATE

    CALL_SPELL_P2:
      CALL CAST_SPELL_P2
      JMP __ITERATE

    UPDATE:
      CALL UPDATE_PLAYER
      CALL UPDATE_SPELL_P1
      CALL UPDATE_SPELL_P2
      ;CALL UPDATE_HIT
      ;MOV HIT_FLAG1, AL
      ;MOV HIT_FLAG2, AH

JMP __ITERATE
MAIN ENDP
;-------------------------------------------------------------------------------------------
UPDATE_HIT PROC NEAR
  MOV AL, COUNT1
  MOV AH, COUNT2
  MOV AL, HIT_FLAG1
  MOV AH, HIT_FLAG2
  CMP HIT_FLAG1, 01H
  JE SUB_COUNT
  JNE CHECK_HIT2

  CHECK_HIT2:
    CMP HIT_FLAG2, 01H
    JE SUB_COUNTT
    JNE SUPER

  SUB_COUNT:  
    DEC CL
    MOV COUNT1, CL
    CMP COUNT1, 00
    JE SET_FLAG1
    JNE SUPER
    SET_FLAG1:
      MOV AL, 00H
      MOV CL, 10
      MOV COUNT1, CL
      JMP SUPER

  SUB_COUNTT:  
    DEC CH
    MOV COUNT2, CH
    CMP COUNT2, 00
    JE SET_FLAG2
    JNE SUPER
    SET_FLAG2:
      MOV AH, 00H
      MOV CH, 10
      MOV COUNT2, CH
      JMP SUPER
SUPER:      
RET    
UPDATE_HIT ENDP
;-------------------------------------------------------------------------------------------
CAST_SPELL_P1 PROC NEAR
CMP HIT_FLAG1, 01H
JE _OUT
  MOV SPELL_STATUS1, 01H
  MOV DH, MOV_X
  MOV DL, MOV_Y
  MOV ONE_X1, DH
  MOV ONE_Y1, DL
  MOV DH, ONE_X1
  MOV DL, ONE_Y1
_OUT:  
RET
CAST_SPELL_P1 ENDP
;-------------------------------------------------------------------------------------------
CAST_SPELL_P2 PROC NEAR
CMP HIT_FLAG2, 01H
JE __OUT
  MOV SPELL_STATUS2, 01H
  MOV DH, MOV_X2
  MOV DL, MOV_Y2
  
  MOV TWO_X1, DH
  MOV TWO_Y1, DL
  MOV DH, TWO_X1
  MOV DL, TWO_Y1
__OUT:  
RET
CAST_SPELL_P2 ENDP
;-------------------------------------------------------------------------------------------
COLLISION_UP PROC NEAR
  MOV SY, DL
  MOV SX, DH
  MOV DL, SY
  MOV DH, SX
  MOV DH, TSX
  MOV DL, TSY

    DEC TSX
    MOV DH, TSX
    CALL _SET_CURSOR
    CALL _GET_CHAR_AT_CURSOR
    MOV INPUT, AL
    MOV DH, SY
    MOV DL, SX

    CMP INPUT, 32
    JE UPPING
    JNE CMP_PLAY2

    CMP_PLAY2:
      CMP INPUT, 02H
      JE HIT_ENEMY
      JNE HIT_OBJECT

    UPPING:
      CALL _SET_CURSOR
      CALL _ERASE
      ;DEC ONE_X1
      MOV AH, 01H
      RET

    HIT_ENEMY:
      CALL _SET_CURSOR
      CALL _ERASE
      MOV IS_COLLISION, 01H
      MOV HIT_FLAG2, 01H
      MOV SPELL_STATUS1, 00H
      MOV AH, 00H
      RET

    HIT_OBJECT:
      CALL _SET_CURSOR
      CALL _ERASE
      MOV SPELL_STATUS1, 00H
      MOV AH, 00H
      RET     

RET
COLLISION_UP ENDP
;-------------------------------------------------------------------------------------------
UPDATE_SPELL_P1 PROC NEAR
  
  CMP SPELL_STATUS1, 01H
  JE CHEK_COLLISION 
  JNE HELPER_LEAVE

CHEK_COLLISION:
  MOV DH, ONE_X1
  MOV DL, ONE_Y1
  MOV SY, DL
  MOV SX, DH

  UP_CHECK:
    CALL COLLISION_UP
    MOV COL_CHECK, AH
    CMP COL_CHECK, 00H
     JE CONTINUE
     JNE HELPER_LEAVE

CONTINUE:
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
    JE HELPER_SET_RIGHT
    JNE CHECK_LEFT

  CHECK_LEFT:
    CMP PLAYER_POST1, 03H
    JE HELPER_SET_LEFT
    JMP SET_POST1
;-------------------------------------------
HELPER_LEAVE:
    JMP LEAVING
HELPER_SET_RIGHT:
    JMP SET_RIGHT
HELPER_SET_LEFT:
    JMP SET_LEFT
;-------------------------------------------      
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
UPDATE_SPELL_P1 ENDP
;-------------------------------------------------------------------------------------------
UPDATE_SPELL_P2 PROC NEAR
  CMP SPELL_STATUS2, 01H
  JE CPP
  RET

  CPP:
  ;MOV TWO_X1, DH
  ;MOV TWO_Y1, DL
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
UPDATE_SPELL_P2 ENDP
;-------------------------------------------------------------------------------------------
UPDATE_PLAYER PROC NEAR
  ;MOV NEW_ACTION, 00H
  ;CALL _GET_KEY

  CALL _DELAY

PLAYER1:
  CMP HIT_FLAG1, 01H
  JE PLAY2
  JNE PLAY1

PLAY1:
  CMP_DOWN:
    CMP NEW_ACTION, 0073H
    JE HELPER_DOWN  
    JNE CMP_UP

  CMP_UP:
    CMP NEW_ACTION, 0077H
    JE HELPER_UP
    JNE CMP_LEFT

  CMP_LEFT:
    CMP NEW_ACTION, 0061H
    JE HELPER_LEFT
    JNE CMP_RIGHT

  CMP_RIGHT:
    CMP NEW_ACTION, 0064H
    JE HELPER_RIGHT
    JNE CMP_DOWN2

PLAYER2:
  CMP HIT_FLAG2, 01H
  JE OUTA
  JNE PLAY2    

PLAY2:
  CMP_DOWN2:
    CMP NEW_ACTION, 50H
    JE HELPER_DOWN2
    JNE CMP_UP2

  CMP_UP2:
    CMP NEW_ACTION, 48H
    JE HELPER_UP2
    JNE CMP_LEFT2

  CMP_LEFT2:
    CMP NEW_ACTION, 4BH
    JE HELPER_LEFT2
    JNE CMP_RIGHT2

  CMP_RIGHT2:
    CMP NEW_ACTION, 4DH
    JE HELPER_RIGHT2
    RET
OUTA:
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
      MOV FLAG, 06H
      CALL _FILE_READ
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
      MOV FLAG, 06H
      CALL _FILE_READ
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
      MOV FLAG, 06H
      CALL _FILE_READ
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
      MOV FLAG, 06H
      CALL _FILE_READ
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
_ERASE PROC NEAR
  MOV DL, 32
  MOV AH, 02H
  INT 21H
RET
_ERASE ENDP
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
_GET_CHAR_AT_CURSOR PROC  NEAR  
      MOV   AH, 08H
      MOV   BH, 00
      INT   10H
      RET
_GET_CHAR_AT_CURSOR ENDP
;-------------------------------------------------------------------------------------------
_FILE_READ PROC NEAR

;This reads the different stages in our game: the loading state, done loading state, menu state, 
;the mazes which are the game states, the highest score state,
;list of scores state and game over state.

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
  JE DISPLAY_WIN

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

DISPLAY_WIN:
  LEA DX, WIN
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
  JE RECORD_WINNER

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

RECORD_WINNER:
  LEA DX, RECORD_WIN
  INT 21H
  LEA SI, RECORD_WIN

  JMP DONE_RECORD  

DONE_RECORD:
  CALL OUTPUT_EXT
  MOV AH, 3EH           
  MOV BX, FILEHANDLE    
  INT 21H
RET
_FILE_READ ENDP
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
_GET_KEY  PROC  NEAR
      MOV   AH, 01H   ;check for input
      INT   16H

      JZ    __LEAVETHIS

      MOV   AH, 00H   ;get input  MOV AH, 10H; INT 16H
      INT   16H

      MOV   NEW_ACTION, AH

      CMP AL, 27
      JE  EXIT

      CMP NEW_ACTION, 50H
      JE __LEAVETHIS

      CMP NEW_ACTION, 48H
      JE __LEAVETHIS

      CMP NEW_ACTION, 4BH
      JE __LEAVETHIS

      CMP NEW_ACTION, 4DH
      JE __LEAVETHIS

      CMP AL, 64H
      JE NEXT1
      NEXT1:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS
      JNE CONT1  

      CONT1:
      CMP AL, 61H
      JE NEXT2
      NEXT2:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS
      JNE CONT2  

      CONT2:
      CMP AL, 74H
      JE NEXT3
      NEXT3:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS
      JNE CONT3  

      CONT3:
      CMP AL, 77H
      JE NEXT4
      NEXT4:
        MOV NEW_ACTION, AL
        JMP __LEAVETHIS 
      JNE CONT4

      CONT4:
        CMP AL, 67H
        JE NEXT5
        NEXT5:
          MOV NEW_ACTION, AL
          JMP __LEAVETHIS

      CONT5:
        CMP AL, 6DH
        JE NEXT6
        NEXT6:
          MOV NEW_ACTION, AL
          JMP __LEAVETHIS
 
  __LEAVETHIS:
      RET
_GET_KEY  ENDP
;-------------------------------------------------------------------------------------------
_DELAY PROC NEAR
      MOV   BP, 2     ;lower value faster
      MOV   SI, 02H   ;lower value faster
    delay2:
      DEC   BP
      NOP
      JNZ   delay2
      DEC   SI
      CMP   SI, 0
      JNZ   delay2
      RET
_DELAY ENDP
;-------------------------------------------------------------------------------------------
_TERMINATE PROC NEAR
      MOV   AX, 4C00H
      INT   21H
_TERMINATE ENDP
;-------------------------------------------------------------------------------------------
EXIT:
  MOV   AH, 4CH         
  INT   21H
CODESEG ENDS
END START