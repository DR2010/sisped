/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0320  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Relatorio de Conferencia de Pedidos.                         |
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
private W_COR320 := setcolor()

// variaveis para controle de impressoes geradas para arquivo
private ARQ_GERADO := "Nao Gera Arquivo"
private W_TITULO   := 'Conferencia de Pedidos'

codempant := space(3)

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
   @ 09,11 say '³   Impressao de Pedido para Concessao de Vale-Transporte   ³'
   @ 10,11 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ 11,11 say '³                                                           ³'
   @ 12,11 say '³ Empresa :                                                 ³'
   @ 13,11 say '³                                                           ³'
   @ 14,11 say '³ Nome ...:                                                 ³'
   @ 15,11 say '³                                                           ³'
   @ 16,11 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,11,16,71)

   X_CODEMP := space(03)
   X_NOME   := space(25)
   @ 12,23 get X_CODEMP picture "@!" valid busca_empresa(X_CODEMP,12,27)
   @ 14,23 get X_NOME   picture "@!" when ! empty(X_CODEMP)
   read
   if lastkey() = K_ESC; break; end

   EMPRESA->( dbsetorder(1))
   FUNCIONARIO->( dbsetorder(3))

   do case
      case empty( X_CODEMP )
         BL_IMPFUN := {|| FUNCIONARIO->( ! eof() ) }
         BL_IMPEMP := {|| EMPRESA->( ! eof()) }
         EMPRESA->( dbgotop() )
         FUNCIONARIO->( dbgotop() )

      case ! empty( X_CODEMP ) .and. empty( X_NOME )
         BL_IMPFUN := {|| FUNCIONARIO->CODEMP=X_CODEMP .and. FUNCIONARIO->(!eof())}
         BL_IMPEMP := {|| EMPRESA->CODEMP=X_CODEMP }
         EMPRESA->( dbseek(X_CODEMP) )
         FUNCIONARIO->( dbseek(X_CODEMP) )

      case ! empty( X_CODEMP )  .and. ! empty( X_NOME )
         X_NOME := alltrim(X_NOME)
         BL_IMPFUN := {|| FUNCIONARIO->CODEMP=X_CODEMP        .and. ;
                          FUNCIONARIO->NOME  =X_NOME .and.;
                          FUNCIONARIO->(!eof())}
         BL_IMPEMP := {|| EMPRESA->CODEMP=X_CODEMP }
         FUNCIONARIO->( dbseek( X_CODEMP+X_NOME ))
         EMPRESA->( dbseek(X_CODEMP) )

   endcase

   declare SUBTOTAL[4], QTDEVALES[4]

   if dh_imprime("NORMAL","S")

      if ARQ_GERADO != "Nao Gera Arquivo"
         IMPRESSAO->( grava( ARQ_GERADO, date(), time(), W_TITULO, 80) )
      end

      while eval( BL_IMPEMP )
         while eval( BL_IMPFUN )
            if codempant # FUNCIONARIO->CODEMP
               codempant := FUNCIONARIO->CODEMP
               EMPRESA->( dbseek(codempant) )
               imprimiu  := 0
               @ 01      ,00 say '+-----------------------------------------------------------------------------+'
               @ prow()+1,00 say '|'+padc(alltrim(EMPRESA->RAZSOC),77)+'|'
               @ prow()+1,00 say '|                                                                             |'
               @ prow()+1,00 say '|-----------------------------------------------------------------------------|'
            endif

            if imprimiu > 3
               imprimiu  := 0
               EMPRESA->( dbseek(codempant) )
               @ 01      ,00 say '+-----------------------------------------------------------------------------+'
               @ prow()+1,00 say '|'+padc(alltrim(EMPRESA->RAZSOC),77)+'|'
               @ prow()+1,00 say '|                                                                             |'
               @ prow()+1,00 say '|-----------------------------------------------------------------------------|'
            endif

            PEDIDO->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ))
            X_DIASUTEIS := PEDIDO->DIAUTILP

            SUBTOTAL[1] := total_vales("O",1)
            SUBTOTAL[2] := total_vales("M",1)
            SUBTOTAL[3] := total_vales("T",1)
            SUBTOTAL[4] := total_vales("B",1)

            QTDEVALES[1] := total_vales("O",2)
            QTDEVALES[2] := total_vales("M",2)
            QTDEVALES[3] := total_vales("T",2)
            QTDEVALES[4] := total_vales("B",2)
            imp_cab320()
            imprimiu = imprimiu + 1
            FUNCIONARIO->( dbskip())
         end
         EMPRESA->( dbskip() )
      end
      @ 00,00 say ''
   end

   dh_impoff()
end sequence
dbcloseall()
setcolor( W_COR320 )

return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB320
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/

procedure imp_cab320

@ prow()+2,05 say ' Empresa ....: '+FUNCIONARIO->CODEMP
@ prow()+1,05 say ' Funcionario.: '+FUNCIONARIO->NOME
@ prow()+1,05 say ' Matricula ..: '+FUNCIONARIO->MATRICULA
@ prow()  ,38 say ' Setor ......: '+FUNCIONARIO->SETOR
@ prow()+1,05 say ''
@ prow()+1,05 say '                     No.Vales       Total R$'
@ prow()+1,05 say ''
@ prow()+1,05 say ' Onibus/ Bonde.:'
@ prow()  ,26 say QTDEVALES[1]
@ prow()  ,39 say SUBTOTAL[1]   picture '999,999.99'
@ prow()+1,05 say '         Metro :'
@ prow()  ,26 say QTDEVALES[2]
@ prow()  ,39 say SUBTOTAL[2]   picture '999,999.99'
@ prow()+1,05 say '         Trem .:'
@ prow()  ,26 say QTDEVALES[3]
@ prow()  ,39 say SUBTOTAL[3]   picture '999,999.99'
@ prow()+1,05 say '         Barca :'
@ prow()  ,26 say QTDEVALES[4]
@ prow()  ,39 say SUBTOTAL[4]   picture '999,999.99'
@ prow()+1,05 say '                   -----------------------------'
@ prow()+1,26 say QTDEVALES[1]+QTDEVALES[2]+QTDEVALES[3]+QTDEVALES[4]
@ prow()  ,39 say SUBTOTAL[1]+SUBTOTAL[2]+SUBTOTAL[3]+SUBTOTAL[4] picture '999,999.99'
@ prow()+1,05 say ''

return

/*
-------------------------------------------------------------------------------
Procedimento .: TOTAL_VALES
Objetivo .....:
-------------------------------------------------------------------------------
*/
function total_vales( P_TIPO, P_POSIC )
local WRET := 0          ,;
      W_VALOR_VALES := 0 ,;
      W_CONTA_VALES := 0

PEDITEM->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA+P_TIPO ))

if PEDITEM->( found() )
   while PEDITEM->CODEMP+PEDITEM->MATRICULA+PEDITEM->TRANSP = ;
         FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA+P_TIPO .and. ;
         PEDITEM->( ! eof())

      TARIFA->( dbseek(PEDITEM->CODTAR))


*---- Marcio - 27/05/96 - Comentarios ---------------------------------------*
*.....if P_TIPO = "M"
*.....   W_VALOR_VALES += ( 1 * TARIFA->VALTAR )
*.....   W_CONTA_VALES += 1
*.....else
         W_VALOR_VALES += ( X_DIASUTEIS * TARIFA->VALTAR )
         W_CONTA_VALES += X_DIASUTEIS
*.....end
*----------------------------------------------------------------------------*

      PEDITEM->( dbskip() )

   end
end

if P_POSIC = 1
   WRET := W_VALOR_VALES
else
   WRET := W_CONTA_VALES
end

return WRET
