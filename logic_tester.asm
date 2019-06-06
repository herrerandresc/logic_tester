;Autores: Andrés Herrera, Francisco Barrera

;LCD CON PIC 18F4550
    LIST P=18F4550;DECLARAMOS EL PIC CON EL QUE TRABAJAREMOS
    #INCLUDE <P18F4550.INC>;INCLUIMOS LA LIBRERIA DEL PIC CON EL QUE TRABAJAREMOS
    CBLOCK;ABRIMOS EL AREA DE VARIABLES ...
    T1;LO UTILIZAREMOS PARA REALIZAR UN RETARDO
    ENDC

    CONFIG FOSC = XT_XT ; RELOJ 4 MHz
    CONFIG WDT = OFF ;DESHABILITAMOS EL PERO GUARDIAN WATCH DOG TIMER
    CONFIG MCLRE = ON ; HABILITAMOS EL MASTER CLEAR (RESET)
    CONFIG LVP = OFF

    menu_all EQU 0x003
    compuertas_pastilla EQU 0x004
    contador EQU 0x005
    timer_comodin EQU 0x006
    timer_comodin_dos EQU 0x007

    ORG 0X0000;INICIAMOS EN LA POSICION 0 DEL PIC

    goto MAIN

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIONES INICIALES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONFIGURACIONES INICIALES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MAIN

    MOVLW B'00000000';DECLARAMOS COMO SALIDA AL PUERTO DE PARA EL BUS DE DATOS BIDIRECCIONAL DEL LCD
    MOVWF TRISD
    ;RW LO COLOCAMOS A 0 VA HACIA TIERRA 
    BCF TRISC,0;RS
    BCF TRISC,1;ENABLE
    
    ;INICIALIZAMOS EL LCD
    INICIALCD:
    BCF PORTC,0
    BCF PORTC,1
    CALL TLCD;LLAMAMOS AL RETARDO
    
    MOVLW B'00111000' ;function set
    MOVWF PORTD
    CALL ENABLE
    
    MOVLW B'00001100' ;display ON/OFF control (cursor y blink)
    MOVWF PORTD
    CALL ENABLE
    
    MOVLW B'00000011' ;return home
    MOVWF PORTD
    CALL ENABLE

    MOVLW 0X01 ; B'00000001' ;clear display
    MOVWF PORTD
    CALL ENABLE

    ;MOVLW b'00001001'
    ;MOVWF compuertas_pastilla

    MOVLW b'00000001'
    MOVWF menu_all  ;carga menu_1 en la inicialización


    ;setear puertos como digitales
    MOVLW 0Fh
    MOVWF ADCON1

    ;apaga comparadores para poder usar los puertos digitales
    MOVLW 07h
    MOVWF CMCON


    ;setear puertos de botones

    CLRF PORTB  ; Initialize PORTB by
                ; clearing output
                ; data latches
    CLRF LATB    ; Alternate method
                 ; to clear output
                 ; data latches

    MOVLW 00Fh  ; Value used to
                ; initialize data
                ; direction
    MOVWF TRISB  ; Set RB<3:0> as inputs
                 ; RB<7:5>, RB3 as outputs


    ;setear puertos de pastillas

    CLRF PORTA  ; Initialize PORTA by
                ; clearing output
                ; data latches
    CLRF LATA    ; Alternate method
                 ; to clear output
                 ; data latches

    MOVLW b'00100100'   ; Value used to
                        ; initialize data
                        ; direction
    MOVWF TRISA     ; Set A2,A5 as inputs
                    ; A0,A1,A3,A4 as outputs



    CLRF PORTE  ; Initialize PORTE by
                ; clearing output
                ; data latches
    CLRF LATE    ; Alternate method
                 ; to clear output
                 ; data latches
    MOVLW b'100'    ; Value used to
                    ; initialize data
                    ; direction

    MOVWF TRISE ; Set E2 as inputs
                ; E0,E1 as outputs


    CLRF PORTC  ; Initialize PORTC by
                ; clearing output
                ; data latches
    CLRF LATC       ; Alternate method
                    ; to clear output
                    ; data latches

    MOVLW b'00000100'
    MOVWF TRISC ;C0 E, C1 RS (no se modifican)
                ;C2 input
                ;C6,C7 outputs




    ;;;;;;;;;;;;;;;;;;;;;;;;;COMIENZA DISPLAY MENSAJE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;COMIENZA DISPLAY MENSAJE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    BCF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW 0x80
    MOVWF PORTD ;pone el cursor en la primera dirección del display
    CALL ENABLE

    BSF PORTC,0
    BCF PORTC,1
    CALL TLCD


    loop_menu

    BTFSC menu_all, 0
    call menu_1

    BTFSC menu_all, 1
    call menu_2

    BTFSC menu_all, 2
    call test_muestra_AND

    BTFSC menu_all, 3
    call test_muestra_OR

    BTFSC menu_all, 4
    call test_muestra_NOT

    BTFSC menu_all, 5
    call test_muestra_NAND

    BTFSC menu_all, 6
    call test_muestra_NOR

    BTFSC menu_all, 7
    call test_muestra_XOR

    BTFSC PORTB, 0
    call boton_1

    BTFSC PORTB, 1
    call boton_2

    BTFSC PORTB, 2
    call boton_3

    BTFSC PORTB, 3
    call volver

    goto loop_menu

    boton_1
    call probar_AND_NAND
    RETURN

    boton_2
    call probar_OR_NOR
    RETURN

    boton_3
    call probar_NOT_XOR
    RETURN

    
    probar_AND_NAND
    BTFSC menu_all, 0
    goto probar_AND
    goto probar_NAND

    probar_AND
    MOVLW b'00000100'
    MOVWF menu_all
    call llamada_comodin
    RETURN
    
    probar_NAND
    MOVLW b'00100000'
    MOVWF menu_all
    call llamada_comodin
    RETURN

    test_muestra_AND
    call testeo_AND
    call muestra_4_compuertas
    RETURN

    test_muestra_NAND
    call testeo_NAND
    call muestra_4_compuertas
    RETURN


    probar_OR_NOR
    BTFSC menu_all, 0
    goto probar_OR
    goto probar_NOR
    
    probar_OR
    MOVLW b'00001000'
    MOVWF menu_all
    call llamada_comodin
    RETURN
    
    probar_NOR
    MOVLW b'01000000'
    MOVWF menu_all
    call llamada_comodin
    RETURN
    
    test_muestra_OR
        call testeo_OR
        call muestra_4_compuertas
    RETURN

    test_muestra_NOR
        call testeo_NOR
        call muestra_4_compuertas
    RETURN

    
    probar_NOT_XOR
    BTFSC menu_all, 0
    goto probar_NOT
    goto probar_XOR

    probar_NOT
    MOVLW b'00010000'
    MOVWF menu_all
    call llamada_comodin
    RETURN
    
    probar_XOR
    MOVLW b'10000000'
    MOVWF menu_all
    call llamada_comodin
    RETURN

    test_muestra_NOT
        call testeo_NOT
        call muestra_NOT
    RETURN

    test_muestra_XOR
        call testeo_XOR
        call muestra_4_compuertas
    RETURN



    volver
    BTFSS menu_all, 0
    goto volver_1
    goto volver_2

    volver_1
    MOVLW b'00000001'
    MOVWF menu_all
    call llamada_comodin
    RETURN

    volver_2
    MOVLW b'00000010'
    MOVWF menu_all
    call llamada_comodin
    RETURN


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU_1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU_1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    menu_1

    BCF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW 0x80
    MOVWF PORTD ;pone el cursor en la primera dirección del display
    CALL ENABLE

    BSF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW'E'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'l'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'i'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'j'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'a'
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW'P'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'a'
    MOVWF PORTD
    CALL ENABLE
    MOVLW's'
    MOVWF PORTD
    CALL ENABLE
    MOVLW't'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'i'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'l'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'l'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'a'
    MOVWF PORTD
    CALL ENABLE
    ;MOVLW' '
    ;MOVWF PORTD
    ;CALL ENABLE

    BCF PORTC,0 ;RS
    CALL TLCD
    MOVLW 0xC0
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    CALL TLCD

    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW'A'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'N'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'D'
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW'O'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'R'
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW'N'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'O'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'T'
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW b'01111110'
    MOVWF PORTD
    CALL ENABLE

    RETURN



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU_2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU_2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    menu_2

    BCF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW 0x80
    MOVWF PORTD ;pone el cursor en la primera dirección del display
    CALL ENABLE


    BSF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    MOVLW'E'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'l'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'i'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'j'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'a'
    MOVWF PORTD
    CALL ENABLE

    MOVLW' '
    MOVWF PORTD
    CALL ENABLE
    
    MOVLW'P'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'a'
    MOVWF PORTD
    CALL ENABLE
    MOVLW's'
    MOVWF PORTD
    CALL ENABLE
    MOVLW't'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'i'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'l'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'l'
    MOVWF PORTD
    CALL ENABLE
    MOVLW'a'
    MOVWF PORTD
    CALL ENABLE
    MOVLW' '
    MOVWF PORTD
    CALL ENABLE

    BCF PORTC,0 ;RS
    CALL TLCD
    MOVLW 0xC0
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    CALL TLCD

    movlw 'N'
    movwf PORTD
    call ENABLE
    movlw 'A'
    movwf PORTD
    call ENABLE
    movlw 'N'
    movwf PORTD
    call ENABLE
    movlw 'D'
    movwf PORTD
    call ENABLE
    movlw ' '
    movwf PORTD
    call ENABLE
    movlw 'N'
    movwf PORTD
    call ENABLE
    movlw 'O'
    movwf PORTD
    call ENABLE
    movlw 'R'
    movwf PORTD
    call ENABLE
    movlw ' '
    movwf PORTD
    call ENABLE
    movlw ' '
    movwf PORTD
    call ENABLE
    movlw 'X'
    movwf PORTD
    call ENABLE
    movlw 'O'
    movwf PORTD
    call ENABLE
    movlw 'R'
    movwf PORTD
    call ENABLE
    movlw ' '
    movwf PORTD
    call ENABLE
    movlw ' '
    movwf PORTD
    call ENABLE
    movlw b'01111111' ;flecha hacia la izquierda que "pasa" al menu_1
    movwf PORTD
    call ENABLE

    RETURN



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU COMPUERTAS GENERAL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU COMPUERTAS GENERAL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    muestra_4_compuertas
    BCF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW 0x80
    MOVWF PORTD ;pone el cursor en la primera dirección del display
    CALL ENABLE


    BSF PORTC,0
    BCF PORTC,1
    CALL TLCD

    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 0
    movlw'O'
    movwf PORTD
    call ENABLE
    
    movlw'X'
    btfsc compuertas_pastilla, 0
    movlw'K'
    movwf PORTD
    call ENABLE
    
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 1
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 1
    movlw'K'
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    
    BCF PORTC,0
    CALL TLCD
    MOVLW 0xC0
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    CALL TLCD
    
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 3
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 3
    movlw'K'
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 2
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 2
    movlw'K'
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw'M'
    movwf PORTD
    call ENABLE
    movlw'E'
    movwf PORTD
    call ENABLE
    movlw'N'
    movwf PORTD
    call ENABLE
    movlw'U'
    movwf PORTD
    call ENABLE

    RETURN

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU COMPUERTAS NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO MENU COMPUERTAS NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    muestra_NOT
    BCF PORTC,0
    BCF PORTC,1
    CALL TLCD

    MOVLW 0x80
    MOVWF PORTD ;pone el cursor en la primera dirección del display
    CALL ENABLE


    BSF PORTC,0
    BCF PORTC,1
    CALL TLCD

    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 0
    movlw'O'
    movwf PORTD
    call ENABLE
    
    movlw'X'
    btfsc compuertas_pastilla, 0
    movlw'K'
    movwf PORTD
    call ENABLE
    
    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 1
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 1
    movlw'K'
    movwf PORTD
    call ENABLE

    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 2
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 2
    movlw'K'
    movwf PORTD
    call ENABLE

    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    
    BCF PORTC,0
    CALL TLCD
    MOVLW 0xC0
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    CALL TLCD
    
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE
    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 5
    movlw'O'
    movwf PORTD
    call ENABLE
    
    movlw'X'
    btfsc compuertas_pastilla, 5
    movlw'K'
    movwf PORTD
    call ENABLE
    
    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 4
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 4
    movlw'K'
    movwf PORTD
    call ENABLE

    movlw' '
    movwf PORTD
    call ENABLE

    movlw'X'
    btfsc compuertas_pastilla, 3
    movlw'O'
    movwf PORTD
    call ENABLE
    movlw'X'
    btfsc compuertas_pastilla, 3
    movlw'K'
    movwf PORTD
    call ENABLE

    movlw' '
    movwf PORTD
    call ENABLE
    
    movlw'M'
    movwf PORTD
    call ENABLE
    movlw'E'
    movwf PORTD
    call ENABLE
    movlw'N'
    movwf PORTD
    call ENABLE
    movlw'U'
    movwf PORTD
    call ENABLE

    RETURN


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO SUBRUTINAS GENERALES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO SUBRUTINAS GENERALES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ENABLE:
    CALL TLCD
    BSF PORTC,1
    CALL TLCD
    BCF PORTC,1
    CALL TLCD
    RETURN

    TLCD:
    T1MSEG: MOVLW .249
    MOVWF T1
    LAZO1:NOP
    DECFSZ T1,F
    GOTO LAZO1
    RETURN
    
    llamada_comodin
    MOVLW 0xFF
    MOVWF timer_comodin
    loop_1
        MOVWF timer_comodin_dos
        loop_2
            DECFSZ timer_comodin_dos
        goto loop_2            
        DECFSZ timer_comodin
    goto loop_1    
    RETURN


    contar
        incf contador   ;incrementa en 1 el valor guardado en la dirección contador
    RETURN





    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO AND;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO AND;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    testeo_AND  

    CLRF compuertas_pastilla

    CLRF contador       ;primera compuerta
    BCF PORTB,6     ;setea RA0 en 0
    BCF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BCF PORTB,6     ;setea RA0 en 0
    BSF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BCF PORTB,7     ;setea RA1 en 0
    BTFSS PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BSF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2 ;si el tercer bit equivale a 1, setear el primer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,0




    CLRF contador       ;segunda compuerta
    BCF PORTA,3     ;setea RA3 en 0
    BCF PORTA,4     ;setea RA4 en 0
    BTFSS PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BCF PORTA,3     ;setea RA3 en 0
    BSF PORTA,4     ;setea RA4 en 1
    BTFSS PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BCF PORTA,4     ;setea RA4 en 0
    BTFSS PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BSF PORTA,4     ;setea RA4 en 1
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el segundo bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,1



    CLRF contador       ;tercera compuerta
    BCF PORTE,0     ;setea RE0 en 0
    BCF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BCF PORTE,0     ;setea RE0 en 0
    BSF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BCF PORTE,1     ;setea RE1 en 0
    BTFSS PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BSF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el tercer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,2

    CLRF contador       ;cuarta compuerta
    BCF PORTB,4     ;setea RC5 en 0
    BCF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BCF PORTB,4     ;setea RC5 en 0
    BSF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BCF PORTB,5     ;setea RC7 en 0
    BTFSS PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BSF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el cuarto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,3

    RETURN



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO OR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO OR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    testeo_OR

    CLRF compuertas_pastilla

    CLRF contador       ;primera compuerta
    BCF PORTB,6     ;setea RA0 en 0
    BCF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BCF PORTB,6     ;setea RA0 en 0
    BSF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BCF PORTB,7     ;setea RA1 en 0
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BSF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2 ;si el tercer bit equivale a 1, setear el primer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,0




    CLRF contador       ;segunda compuerta
    BCF PORTA,3     ;setea RA3 en 0
    BCF PORTA,4     ;setea RA4 en 0
    BTFSS PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BCF PORTA,3     ;setea RA3 en 0
    BSF PORTA,4     ;setea RA4 en 1
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BCF PORTA,4     ;setea RA4 en 0
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BSF PORTA,4     ;setea RA4 en 1
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el segundo bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,1



    CLRF contador       ;tercera compuerta
    BCF PORTE,0     ;setea RE0 en 0
    BCF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BCF PORTE,0     ;setea RE0 en 0
    BSF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BCF PORTE,1     ;setea RE1 en 0
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BSF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el tercer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,2

    CLRF contador       ;cuarta compuerta
    BCF PORTB,4     ;setea RC5 en 0
    BCF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BCF PORTB,4     ;setea RC5 en 0
    BSF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BCF PORTB,5     ;setea RC7 en 0
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BSF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el cuarto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,3

    RETURN



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    testeo_NOT

    ;realizar configuraciones de los puertos

    MOVLW b'00101010'
    MOVWF TRISA

    BCF TRISB,4
    BSF TRISB,5
    BSF TRISB,7
    BCF TRISC,2

    MOVLW b'101'
    MOVWF TRISE


    
    CLRF compuertas_pastilla

    CLRF contador       ;primera compuerta
    BCF PORTA,0     ;setea RA0 en 0
    BTFSC PORTA,1       ;si RA1 equivale a 1, ir a contar
    call contar

    BSF PORTA,0     ;setea RA0 en 1
    BTFSS PORTA,1       ;si RA1 equivale a 0, ir a contar
    call contar
                    
    BTFSC contador,1    ;si el segundo bit equivale a 1, setear el primer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,0



    CLRF contador       ;segunda compuerta
    BCF PORTA,2     ;setea RA2 en 0
    BTFSC PORTA,3       ;si RA3 equivale a 1, ir a contar
    call contar

    BSF PORTA,2     ;setea RA2 en 1
    BTFSS PORTA,3       ;si RA3 equivale a 0, ir a contar
    call contar
                    
    BTFSC contador,1    ;si el segundo bit equivale a 1, setear el segundo bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,1



    CLRF contador       ;tercera compuerta
    BCF PORTA,4     ;setea RA4 en 0
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,4     ;setea RA4 en 1
    BTFSS PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BTFSC contador,1    ;si el segundo bit equivale a 1, setear el tercer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,2



    CLRF contador       ;cuarta compuerta
    BCF PORTE,1     ;setea RE1 en 0
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BTFSC contador,1    ;si el segundo bit equivale a 1, setear el cuarto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,3

        

    CLRF contador       ;quinta compuerta
    BCF PORTC,2     ;setea RC2 en 0
    BTFSC PORTE,0       ;si RE0 equivale a 1, ir a contar
    call contar

    BSF PORTC,2     ;setea RC2 en 1
    BTFSS PORTE,0       ;si RE0 equivale a 0, ir a contar
    call contar

    BTFSC contador,1    ;si el segundo bit equivale a 1, setear el quinto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,4



    CLRF contador       ;sexta compuerta
    BCF PORTB,4     ;setea RC5 en 0
    BTFSC PORTB,5       ;si RC7 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RE1 en 1
    BTFSS PORTB,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BTFSC contador,1    ;si el segundo bit equivale a 1, setear el sexto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,5

    
    ;restablecer configuraciones de los puertos

    MOVLW b'00100100'
    MOVWF TRISA

    BCF TRISB,4
    BCF TRISB,5
    BCF TRISB,7
    BSF TRISC,2

    MOVLW b'100'
    MOVWF TRISE

    RETURN





    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO NAND;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO NAND;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    testeo_NAND

    CLRF compuertas_pastilla

    CLRF contador       ;primera compuerta
    BCF PORTB,6     ;setea RA0 en 0
    BCF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BCF PORTB,6     ;setea RA0 en 0
    BSF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BCF PORTB,7     ;setea RA1 en 0
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BSF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2 ;si el tercer bit equivale a 1, setear el primer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,0




    CLRF contador       ;segunda compuerta
    BCF PORTA,3     ;setea RA3 en 0
    BCF PORTA,4     ;setea RA4 en 0
    BTFSC PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BCF PORTA,3     ;setea RA3 en 0
    BSF PORTA,4     ;setea RA4 en 1
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BCF PORTA,4     ;setea RA4 en 0
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BSF PORTA,4     ;setea RA4 en 1
    BTFSS PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el segundo bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,1



    CLRF contador       ;tercera compuerta
    BCF PORTE,0     ;setea RE0 en 0
    BCF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BCF PORTE,0     ;setea RE0 en 0
    BSF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BCF PORTE,1     ;setea RE1 en 0
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BSF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el tercer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,2

    CLRF contador       ;cuarta compuerta
    BCF PORTB,4     ;setea RC5 en 0
    BCF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BCF PORTB,4     ;setea RC5 en 0
    BSF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BCF PORTB,5     ;setea RC7 en 0
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BSF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el cuarto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,3

    RETURN






    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO NOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO NOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    testeo_NOR

    CLRF compuertas_pastilla

    CLRF contador       ;primera compuerta
    BCF PORTB,6     ;setea RA0 en 0
    BCF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BCF PORTB,6     ;setea RA0 en 0
    BSF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BCF PORTB,7     ;setea RA1 en 0
    BTFSS PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BSF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2 ;si el tercer bit equivale a 1, setear el primer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,0




    CLRF contador       ;segunda compuerta
    BCF PORTA,3     ;setea RA3 en 0
    BCF PORTA,4     ;setea RA4 en 0
    BTFSC PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BCF PORTA,3     ;setea RA3 en 0
    BSF PORTA,4     ;setea RA4 en 1
    BTFSS PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BCF PORTA,4     ;setea RA4 en 0
    BTFSS PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BSF PORTA,4     ;setea RA4 en 1
    BTFSS PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el segundo bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,1



    CLRF contador       ;tercera compuerta
    BCF PORTE,0     ;setea RE0 en 0
    BCF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BCF PORTE,0     ;setea RE0 en 0
    BSF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BCF PORTE,1     ;setea RE1 en 0
    BTFSS PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BSF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el tercer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,2

    CLRF contador       ;cuarta compuerta
    BCF PORTB,4     ;setea RC5 en 0
    BCF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BCF PORTB,4     ;setea RC5 en 0
    BSF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BCF PORTB,5     ;setea RC7 en 0
    BTFSS PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BSF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el cuarto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,3

    RETURN






    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO XOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INICIO TESTEO XOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    testeo_XOR

    CLRF compuertas_pastilla

    CLRF contador       ;primera compuerta
    BCF PORTB,6     ;setea RA0 en 0
    BCF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 0, ir a contar
    call contar

    BCF PORTB,6     ;setea RA0 en 0
    BSF PORTB,7     ;setea RA1 en 1
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BCF PORTB,7     ;setea RA1 en 0
    BTFSC PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar

    BSF PORTB,6     ;setea RA0 en 1
    BSF PORTB,7     ;setea RA1 en 1
    BTFSS PORTA,2       ;si RA2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2 ;si el tercer bit equivale a 1, setear el primer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,0




    CLRF contador       ;segunda compuerta
    BCF PORTA,3     ;setea RA3 en 0
    BCF PORTA,4     ;setea RA4 en 0
    BTFSS PORTA,5       ;si RA5 equivale a 0, ir a contar
    call contar

    BCF PORTA,3     ;setea RA3 en 0
    BSF PORTA,4     ;setea RA4 en 1
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BCF PORTA,4     ;setea RA4 en 0
    BTFSC PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BSF PORTA,3     ;setea RA3 en 1
    BSF PORTA,4     ;setea RA4 en 1
    BTFSS PORTA,5       ;si RA5 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el segundo bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,1



    CLRF contador       ;tercera compuerta
    BCF PORTE,0     ;setea RE0 en 0
    BCF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 0, ir a contar
    call contar

    BCF PORTE,0     ;setea RE0 en 0
    BSF PORTE,1     ;setea RE1 en 1
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BCF PORTE,1     ;setea RE1 en 0
    BTFSC PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BSF PORTE,0     ;setea RE0 en 1
    BSF PORTE,1     ;setea RE1 en 1
    BTFSS PORTE,2       ;si RE2 equivale a 1, ir a contar
    call contar

    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el tercer bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,2

    CLRF contador       ;cuarta compuerta
    BCF PORTB,4     ;setea RC5 en 0
    BCF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 0, ir a contar
    call contar

    BCF PORTB,4     ;setea RC5 en 0
    BSF PORTB,5     ;setea RC7 en 1
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BCF PORTB,5     ;setea RC7 en 0
    BTFSC PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar

    BSF PORTB,4     ;setea RC5 en 1
    BSF PORTB,5     ;setea RC7 en 1
    BTFSS PORTC,2       ;si RC2 equivale a 1, ir a contar
    call contar
                    
    BTFSC contador,2    ;si el tercer bit equivale a 1, setear el cuarto bit de compuertas_pastilla en 1
    BSF compuertas_pastilla,3

    RETURN




    END