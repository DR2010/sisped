/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0130  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Cadastro de Tarifas.                                         |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED                     | Ultima Alteracao                |
  | Analista...: Daniel Machado             | Autor : Daniel Machado          |
  | Programador: Daniel Machado             | Dt/Hr : 13/10/94 - 11:30        |
  | Inicio.....: 21/10/1994                 | Motivo: Inicio.                 |
  |                                         |                                 |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"
#include "sic.ch"
local getlist:={}

private X_CODTAR := space( 3) ,;
        X_VALTAR := 0.00 // N.9.2

setcolor( W_PDCOR )
@ 08,00 clear to 20,79

private W_CAMPOS := { "TARIFA->CODTAR+' -   '+transform(TARIFA->VALTAR,'999,999.99')" }
        W_HEADER := { "Codigo     Valor" }

mensagem("Selecione um dos itens do menu ou <ESC> para abandonar.")

abrir("TARIFA")

W_COR0130 := setcolor()
while .t.
   setcolor( W_COREDIT )
   tedit0130() // Tela para dbedit
   TARIFA->( dbedit( 04, 03, 15, 76, W_CAMPOS, "DB_0130",, W_HEADER ) )
   exit
end
dbcloseall()
setcolor( W_COR0130 )
return

/*
-----------------------------------------------------------------------------
Procedimento : DB_0130
Objetivo     : Controlar o dbedit modulo 0130, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0130( MODO, COLUNA )
private WRETMAIN :=2, W_SCRD:=savescreen(), W_COROLD := setcolor()

TECLA := upper( chr( lastkey()))

setcursor(1)
setcolor(W_CORGET)
do case
   case MODO < 4 // Nao reconhecida
      WRETMAIN := 1
   case lastkey() = K_ESC
      WRETMAIN := 0
   case TECLA = "I"
      push_but(17,07," Incluir ")
      T_INC130()
   case TECLA = "R"
      push_but(17,63,' Retornar ')
      WRETMAIN := 0
   case ! ( TARIFA->( eof() ) .OR. TARIFA->( bof() ) )
      do case
        case TECLA = "E"
           push_but(17,29," Excluir ")
           T_EXC130()
        case TECLA = "A"
           push_but(17,18," Alterar ")
           T_ALT130()
        case TECLA = "B"
           push_but(17,53," Buscar ")
           T_BUS130()
      endcase
endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_INC130
Objetivo     : Incluir TARIFA
-----------------------------------------------------------------------------
*/
procedure T_INC130()

   while .t.
      tela0130()
      zera0130() // zerando variaveis

      @ 04,20 get X_CODTAR picture "!!!!" valid ! empty( X_CODTAR )
      read

      if lastkey()=K_ESC; exit; end

      TARIFA->( dbsetorder(1))
      TARIFA->( dbseek( X_CODTAR ))
      if TARIFA->( found() )
         show0130()
         menswait("Codigo ja cadastrado. <ENTER>")
         loop
      end

      if get0130()
         grava0130("I")
         menstime("Incluido. <ENTER>",1)
      end
   end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_ALT130
Objetivo     : Alterar TARIFA
-----------------------------------------------------------------------------
*/
procedure T_ALT130()

while .t.
   tela0130()

   X_CODTAR := TARIFA->CODTAR
   X_VALTAR := TARIFA->VALTAR

   show0130()
   atrib0130() // atribui dados da base de dados

   if get0130()
      grava0130("A")
      menstime("Alterado. <ENTER>",1)
      exit
   else
      exit
   end
end
return

/*
-----------------------------------------------------------------------------
Procedimento : T_EXC130
Objetivo     : Excluir TARIFA
-----------------------------------------------------------------------------
*/
procedure T_EXC130()

tela0130()
show0130()
if pergunta("Confirma Exclusao (S/N) ?")
   while TARIFA->( ! rlock() );end
   TARIFA->( dbdelete() )
   menstime("Excluido.",1)
end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_CON130
Objetivo     : Consultar TARIFA
-----------------------------------------------------------------------------
*/
procedure T_CON130()

tela0130()
show0130()
menswait("Tecle <ENTER>.")

return

/*
-----------------------------------------------------------------------------
Procedimento : T_BUS130
Objetivo     : Buscar tarifa
-----------------------------------------------------------------------------
*/
procedure T_BUS130()
local WSCR := savescreen(10,10,13,65), W_OLDCOR := setcolor()

setcolor(W_CORWG)
@ 10,10 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 11,10 say '³ Tarifa :                                            ³'
@ 12,10 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
sombra(10,10,12,64)
X_TARBUSCA := 0.00
@ 11,21 get X_TARBUSCA picture "999,999.99"
read

if lastkey() != K_ESC
   TARIFA->( dbsetorder(2) )        // nome
   X_TARBUSCA := str(X_TARBUSCA,9,2)
   TARIFA->( dbseek( X_TARBUSCA))  //

   if TARIFA->( ! found() )
      menstime("Tarifa nao encontrada. <ENTER>",3)
   end

   TARIFA->( dbsetorder(1) )
end
restscreen(10,10,13,65,WSCR)
setcolor(W_OLDCOR)

return

/*
-------------------------------------------------------------------------------
Procedimento .: TELA0130
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tela0130()

   setcolor( W_COREDIT )
   @ 05,02 say '³'
   @ 05,77 say '³'
   setcolor( W_CORGET )
   @ 04,03 say ' Codigo Tarifa :                                                          '
   @ 05,03 say '                                                                          '
   @ 06,03 say ' Valor ........:                                                          '
   @ 07,03 say '                                                                          '
   @ 08,03 say '                                                                          '
   @ 09,03 say '                                                                          '
   @ 10,03 say '                                                                          '
   @ 11,03 say '                                                                          '
   @ 12,03 say '                                                                          '
   @ 13,03 say '                                                                          '
   @ 14,03 say '                                                                          '
   @ 15,03 say '                                                                          '


return

/*
-------------------------------------------------------------------------------
Procedimento .: TEDIT0130
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tedit0130()
   local W_OLDCOR := setcolor()

   setcolor(W_COREDIT)
   quadro(03,02,21,77," Cadastro de Tarifas ")
   @ 05,02 say 'Æ'
   @ 05,77 say 'µ'
   @ 16,03 to 16,77 double
   @ 16,02 say 'Æ'
   @ 16,77 say 'µ'

   sombra(02,02,21,77)

   cria_but( 17,07,' Incluir '  ,17,08,"I" )
   cria_but( 17,18,' Alterar '  ,17,19,"A" )
   cria_but( 17,29,' Excluir '  ,17,30,"E" )
   cria_but( 17,53,' Retornar ' ,17,54,"R" )

   setcolor( W_OLDCOR )
return

/*
-------------------------------------------------------------------------------
Procedimento .: GET0130
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
function get0130()
   local WRET := .T.
   setcolor( W_CORGET )

   @ 06,20 get X_VALTAR picture "999,999.99" valid ! empty( X_VALTAR )
   read

   if lastkey() = K_ESC; WRET := .F.; end

return WRET

/*
-------------------------------------------------------------------------------
Procedimento .: SHOW0130
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure show0130()

   @ 04,20 say TARIFA->CODTAR  picture "@!"
   @ 06,20 say TARIFA->VALTAR  picture "999,999.99"

return

/*
-------------------------------------------------------------------------------
Procedimento .: ATRIB0130
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure atrib0130()

  X_VALTAR := TARIFA->VALTAR

return

/*
-------------------------------------------------------------------------------
Procedimento .: ZERA0130
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure zera0130()

   X_CODTAR := space( 3)
   X_VALTAR := 0.00

return

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0130
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0130( MODO )

   if MODO = "A"
      while TARIFA->( ! rlock() ); end
   else
      TARIFA->( dbappend() )
   end

   TARIFA->CODTAR := X_CODTAR
   TARIFA->VALTAR := X_VALTAR

return
