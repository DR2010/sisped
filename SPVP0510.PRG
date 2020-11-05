/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0510  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Cadastro de Parametros.                                      |
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

private  X_NOMEFANT := space(40) ,;
         X_DIASUTIL := 0.00      ,;
         X_CGC      := space(14) ,;
         X_USOEMP   := space(25) ,;
         X_ALTPAD   := space(01)

abrir("PEDIDO")
abrir("PARAMETRO")
PARAMETRO->( dbgotop())

X_NOMEFANT := PARAMETRO->NOMEFANT
X_DIASUTIL := PARAMETRO->DIASUTIL
X_CGC      := PARAMETRO->CGC
X_USOEMP   := PARAMETRO->USOEMP
X_ALTPAD   := PARAMETRO->ALTPAD

setcolor( W_PDCOR )
@ 08,00 clear to 20,79

tela0510()
if get0510()
   grava0510()
endif
dbcloseall()
return

/*
-------------------------------------------------------------------------------
Procedimento .: TELA0510
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tela0510()
   setcolor(W_COREDIT)
   quadro(07,02,21,77," Parametros Basicos ")
   sombra(07,02,21,77)

   setcolor( W_CORGET )
   @ 08,03 say '                                                                          '
   @ 09,03 say ' Numero de dias uteis :      CGC Informante :                             '
   @ 10,03 say '                                                                          '
   @ 11,03 say ' Nome Fantasia/ Razao Social :                                            '
   @ 12,03 say '                                                                          '
   @ 13,03 say ' Alterar o padrao de Impressao (S/N) :                                    '
   @ 14,03 say '                                                                          '
   @ 15,03 say ' Padrao de impressao nos vales                                            '
   @ 16,03 say '                                                                          '
   @ 17,03 say '           FETRANSPOR : Nome do Funcionario + Setor                       '
   @ 18,03 say '           Usuario ...:                                                   '
   @ 19,03 say '                                                                          '
   setcolor( W_CORGET )

return

/*
-------------------------------------------------------------------------------
Procedimento .: GET0510
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
function get0510()
   local WRET := .T.
   setcolor( W_CORGET )

   @ 09,27 get X_DIASUTIL  picture "99"
   @ 09,50 get X_CGC       picture "99999999999999"
   @ 11,34 get X_NOMEFANT  picture "@!"
   @ 13,42 get X_ALTPAD    picture "!" valid X_ALTPAD $ "SN"
   @ 18,27 get X_USOEMP    picture "@!" when X_ALTPAD = "S"
   read
   if lastkey() = K_ESC
      WRET := .F.
   else
      if X_ALTPAD = "N"
         X_USOEMP := space(25)
      endif
   endif

return WRET

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0510
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0510()

   PARAMETRO->( dbgotop())
   if PARAMETRO->(eof()); PARAMETRO->(dbappend()); end

   // lock
   while PARAMETRO->( ! rlock() ); end

   PARAMETRO->DIASUTIL := X_DIASUTIL
   PARAMETRO->NOMEFANT := X_NOMEFANT
   PARAMETRO->ALTPAD   := X_ALTPAD
   PARAMETRO->CGC      := X_CGC
   PARAMETRO->USOEMP   := X_USOEMP

   // unlock
   PARAMETRO->( dbunlock())

   mensagem( "Aguarde... Atualizando pedidos...")
   // atualizando pedidos
   PEDIDO->( dbsetorder(1))
   PEDIDO->( dbgotop() )

   while PEDIDO->( ! eof())

      if PEDIDO->USAPADRAO = "S"
         while PEDIDO->( ! rlock()); end
         PEDIDO->DIAUTILP := PARAMETRO->DIASUTIL
         PEDIDO->( dbunlock() )
      end
      PEDIDO->( dbskip() )
   end
   mensagem("")
return

