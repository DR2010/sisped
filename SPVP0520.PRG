/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0520  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Controle de Impressao.                                       |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED                     | Ultima Alteracao                |
  | Analista...: Daniel Machado             | Autor : Daniel Machado          |
  | Programador: Daniel Machado             | Dt/Hr : 13/10/94 - 11:30        |
  | Inicio.....: 13/10/1994                 | Motivo: Inicio.                 |
  |                                         |                                 |
  +---------------------------------------------------------------------------+
*/

#include "inkey.ch"
#include "sic.ch"
local getlist:={}

private  X_DTEMISSAO := ctod(' ') ,;
         X_TITULO    := space(40) ,;
         X_HORA      := space(04) ,;
         X_STATUS    := space(01) ,;
         X_PADRAO    := space(03) ,;
         X_ARQPRN    := space(12)

setcolor( W_PDCOR )
@ 08,00 clear to 20,79

private W_CAMPOS := { "space(10)+dtoc(IMPRESSAO->DTEMISSAO)+' - '+" +;
                      "IMPRESSAO->TITULO+' / '+IMPRESSAO->HREMISSAO+"+;
                      "IMPRESSAO->STATUS+space(10)" }
        W_HEADER := { space(10)+"Data       Titulo                         Hora " }

mensagem("Selecione um dos itens do menu ou <ESC> para abandonar.")

abrir("IMPRESSAO")

W_COR0520 := setcolor()
while .t.
   setcolor( W_COREDIT )
   tedit0520() // Tela para dbedit
   IMPRESSAO->( dbedit( 04, 03, 15, 76, W_CAMPOS, "DB_0520",, W_HEADER ) )
   exit
end
dbcloseall()
setcolor( W_COR0520 )
return

/*
-----------------------------------------------------------------------------
Procedimento : DB_0520
Objetivo     : Controlar o dbedit modulo 0520, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0520( MODO, COLUNA )
private WRETMAIN :=2, W_SCRD:=savescreen(), W_COROLD := setcolor()

TECLA := upper( chr( lastkey()))

setcursor(1)
setcolor(W_CORGET)
do case
   case MODO < 4 // Nao reconhecida
      WRETMAIN := 1
   case lastkey() = K_ESC
      WRETMAIN := 0
   case TECLA = "R"
      push_but(17,58,' Retornar ')
      WRETMAIN := 0
   case ! ( IMPRESSAO->( eof() ) .OR. IMPRESSAO->( bof() ) )
      do case
        case TECLA = "E"
           push_but(17,05," Excluir ")
           T_EXC520()
        case TECLA = "X"
           push_but(17,16," eXcluir Todos ")
           T_EXT520()
        case TECLA = "I"
           push_but(17,33," Imprimir ")
           T_IMP520()
        case TECLA = "C"
           push_but(17,45," Consultar ")
           T_CON520()
      endcase
endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_EXC520
Objetivo     : Excluir relatorio
Obs          : Nao exclui o .PRN, somente no exclui todos.
-----------------------------------------------------------------------------
*/
procedure T_EXC520()

while IMPRESSAO->( ! rlock() );end
IMPRESSAO->( dbdelete() )

return

/*
-----------------------------------------------------------------------------
Procedimento : T_IMP520
Objetivo     : Marcar relatorio
-----------------------------------------------------------------------------
*/
procedure T_IMP520()

local P_PADRAO := IMPRESSAO->PADRAO, X:=1 ,;
      W_FILES := directory( ARQ := upper( alltrim( IMPRESSAO->ARQPRN )) )

if ! empty( W_FILES )
   ARQ := IMPRESSAO->ARQPRN
   LARQ := memoread( ARQ )
   set device to print
   set console off
   while x <= mlcount( LARQ )
      @ prow()+1,00 say memoline(LARQ,P_PADRAO,x)
      x++
   enddo
   set console on
   set device to screen
else
   mensbeep("Arquivo temporario foi excluido externamente.")
   while IMPRESSAO->( ! rlock() ) ; end
   IMPRESSAO->( dbdelete() )
endif

return

/*
-----------------------------------------------------------------------------
Procedimento : T_EXT520
Objetivo     : Excluir todos os relatorios
-----------------------------------------------------------------------------
*/
procedure T_EXT520()

IMPRESSAO->( dbgotop() )
while IMPRESSAO->( ! eof() )
   delete file &(IMPRESSAO->ARQPRN)
   while IMPRESSAO->( ! rlock()); end
   IMPRESSAO->( dbdelete())
   IMPRESSAO->( dbskip())
end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_CON520
Objetivo     : Consultar relatorio
-----------------------------------------------------------------------------
*/
procedure T_CON520()

local ANTES := savescreen(,,,,), ;
      W_FILES := directory( ARQ := upper( alltrim( IMPRESSAO->ARQPRN )) )

if ! empty( W_FILES )
   if  W_FILES[1,2] < 65530
      LARQ := memoread( ARQ )
      cls
      memoedit( LARQ, 0, 0, 24, 79, .F.,, 132 )
   else
      mensbeep("Arquivo grande demais para ser consultado. <ENTER>")
   end
else
   mensbeep("Arquivo temporario foi excluido externamente.")
   while IMPRESSAO->( ! rlock() ) ; end
   IMPRESSAO->( dbdelete() )
end

restscreen(,,,,ANTES)

return

/*
-------------------------------------------------------------------------------
Procedimento .: TEDIT0520
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tedit0520()
   local W_OLDCOR := setcolor()

   setcolor(W_COREDIT)
   quadro(03,02,21,77," Cadastro de Relatorios ")
   @ 05,02 say '�'
   @ 05,77 say '�'
   @ 16,03 to 16,77 double
   @ 16,02 say '�'
   @ 16,77 say '�'

   sombra(02,02,21,77)

   cria_but( 17,05,' Excluir '          ,17,06,"E" )
   cria_but( 17,16,' eXcluir Todos '    ,17,18,"X" )
   cria_but( 17,33,' Imprimir '         ,17,34,"I" )
   cria_but( 17,45,' Consultar '        ,17,46,"C" )
   cria_but( 17,58,' Retornar '         ,17,59,"R" )

/*
    Excluir     eXcluir Todos    Imprimir    Consultar    Retornar
    5          16               33          45           58
*/
   setcolor( W_OLDCOR )

return
