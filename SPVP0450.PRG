/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0450  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | Sistema:								      |
  |---------------------------------------------------------------------------|
  | Descricao..: Relatorio de Compras de vale.                                |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED 		    | Ultima Alteracao		      |
  | Analista...: Celita                     | Autor :                         |
  | Programador: Marcos Aurelio             | Dt/Hr :                         |
  | Inicio.....: 26/12/1994                 | Motivo:                         |
  |					    |				      |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"
#include "sic.ch"
local getlist:={}
local FEZ_IMP := .F.
private WRESP_IMPR := ""
private W_COR520 := setcolor()

// variaveis para controle de impressoes geradas para arquivo
private ARQ_GERADO := "Nao Gera Arquivo"
private W_TITULO   := 'Relat¢rio Total de Compras'

abrir("FUNCIONARIO")
abrir("EMPRESA")
abrir("PEDIDO")
abrir("PEDITEM")
abrir("PARAMETRO")
abrir("TARIFA")
abrir("IMPRESSAO")

begin sequence
   setcolor(W_CORWG)
   @ 08,11 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 09,11 say '³                 Relat¢rio Total de Compras                ³'
   @ 10,11 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ 11,11 say '³                                                           ³'
   @ 12,11 say '³ Empresa :                                                 ³'
   @ 13,11 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,11,13,71)

   X_CODEMP := space(03)
   @ 12,23 get X_CODEMP picture "@!" valid busca_empresa(X_CODEMP,12,27)
   read
   if lastkey() = K_ESC; break; end

   If X_CODEMP == "000"
      X_CODEMP := SPACE(03)
   EndIf

   EMPRESA->( dbsetorder(1))       // codemp
   FUNCIONARIO->( dbsetorder(3))   // codemp+nome

   do case
      case empty( X_CODEMP )
	 W_OPCAO := 1
	 BL_IMPFUN := {|| FUNCIONARIO->( ! eof() ) }
         FUNCIONARIO->( dbgotop() )

      case ! empty( X_CODEMP )
	 W_OPCAO := 2
         BL_IMPFUN := {|| FUNCIONARIO->CODEMP==X_CODEMP .and. FUNCIONARIO->(!eof())}
         FUNCIONARIO->( dbseek(X_CODEMP) )

   endcase

   declare SUBTOTAL[4], QTDEVALES[4], PAGINA := 0

   SUBTOTAL[1]  := SUBTOTAL[2]  := SUBTOTAL[3]  := SUBTOTAL[4]  := 0
   QTDEVALES[1] := QTDEVALES[2] := QTDEVALES[3] := QTDEVALES[4] := 0

   mensagem("Tecle <ESC> para interromper impressao.")
   if dh_imprime("NORMAL","S")

      if ARQ_GERADO != "Nao Gera Arquivo"
         if WRESP_IMPR == "A"
            IMPRESSAO->( grava( ARQ_GERADO, date(), time(), W_TITULO, 80) )
         endif
      end

      X_CODEMP := FUNCIONARIO->CODEMP
      while eval( BL_IMPFUN )
         if inkey()=K_ESC; break; end

         FEZ_IMP := .T.

         PEDIDO->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ))
         X_DIASUTEIS := PEDIDO->DIAUTILP

         if PEDIDO->( found() ) .and. PEDIDO->DIAUTILP > 0
            SUBTOTAL[1]  += total_vales("O",1)
            SUBTOTAL[2]  += total_vales("M",1)
            SUBTOTAL[3]  += total_vales("T",1)
            SUBTOTAL[4]  += total_vales("B",1)

            QTDEVALES[1] += total_vales("O",2)
            QTDEVALES[2] += total_vales("M",2)
            QTDEVALES[3] += total_vales("T",2)
            QTDEVALES[4] += total_vales("B",2)
         end
         FUNCIONARIO->( dbskip())

      end

      If FEZ_IMP
         cab0520()
         imp_cab520()
      EndIf

   end

   if FEZ_IMP
      eject
   endif

   dh_impoff()

   if ! FEZ_IMP
      menstime("Nenhum pedido encontrado para conferˆncia.",2)
      while IMPRESSAO->( ! rlock() );end
      IMPRESSAO->( dbdelete() )
   endif

   mensagem("")
end sequence
dbcloseall()
setcolor( W_COR520 )

return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB520
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/

procedure imp_cab520

@ prow()+1,05 say ''
@ prow()+1,05 say '                     No.Vales       Total R$'
@ prow()+1,05 say ''
@ prow()+1,05 say ' Onibus/ Bonde.:'
@ prow()  ,26 say QTDEVALES[1]
@ prow()  ,39 say SUBTOTAL[1]	picture '999,999.99'
@ prow()+1,05 say '         Metro :'
@ prow()  ,26 say QTDEVALES[2]
@ prow()  ,39 say SUBTOTAL[2]	picture '999,999.99'
@ prow()+1,05 say '         Trem .:'
@ prow()  ,26 say QTDEVALES[3]
@ prow()  ,39 say SUBTOTAL[3]	picture '999,999.99'
@ prow()+1,05 say '         Barca :'
@ prow()  ,26 say QTDEVALES[4]
@ prow()  ,39 say SUBTOTAL[4]	picture '999,999.99'
@ prow()+1,05 say '                   -----------------------------'
@ prow()+1,26 say QTDEVALES[1]+QTDEVALES[2]+QTDEVALES[3]+QTDEVALES[4]
@ prow()  ,39 say SUBTOTAL[1]+SUBTOTAL[2]+SUBTOTAL[3]+SUBTOTAL[4] picture '999,999.99'
@ prow()+1,05 say ''

return

/*
-------------------------------------------------------------------------------
Procedimento .: CAB0520
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure cab0520()

   @ 01      ,00 say 'FETRANSPOR - Sistema de Pedido de Vale-Transporte'
   @ prow()  ,71 say date()
   @ prow()+1,00 say 'RELACAO PARA CONFERENCIA DOS PEDIDOS DE VALE-TRANSPORTE'
   @ prow()  ,69 say 'Pag .: '+strzero( ++PAGINA,3 )
   @ prow()+1,00 say ''
   @ prow()+1,00 say padc(alltrim(EMPRESA->RAZSOC),77)
   @ prow()+1,00 say '-------------------------------------------------------------------------------'

return
