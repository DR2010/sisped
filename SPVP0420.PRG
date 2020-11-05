/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0420  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | Sistema:								      |
  |---------------------------------------------------------------------------|
  | Descricao..: Relatorio de Conferencia de Pedidos.			      |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED 		    | Ultima Alteracao		      |
  | Analista...: Daniel Machado 	    | Autor : Daniel Machado	      |
  | Programador: Daniel Machado 	    | Dt/Hr : 13/10/94 - 11:30	      |
  | Inicio.....: 13/10/1994		    | Motivo: Inicio.		      |
  |					    |				      |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"
#include "sic.ch"
local getlist:={}
local FEZ_IMP := .F.
private WRESP_IMPR := ""
private W_COR420 := setcolor()

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
   @ 09,11 say '³         Listagem para Conferencia de Pedidos              ³'
   @ 10,11 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ 11,11 say '³                                                           ³'
   @ 12,11 say '³ Empresa :                                                 ³'
   @ 13,11 say '³                                                           ³'
   @ 14,11 say '³ Nome ...:                               <Enter> = Faixa   ³'
   @ 15,11 say '³                                                           ³'
   @ 16,11 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,11,16,71)

   X_CODEMP := space(03)
   X_NOME   := space(25)
   @ 12,23 get X_CODEMP picture "@!" valid busca_empresa(X_CODEMP,12,27)
   @ 14,23 get X_NOME	picture "@!" when ! empty(X_CODEMP)
   read

   if (lastkey() = K_ESC) .or.(Empty(X_NOME) .and. !Val_Faixa())
      break
   end

   EMPRESA->( dbsetorder(1))       // codemp
   FUNCIONARIO->( dbsetorder(3))   // codemp+nome

   do case

    *- Marcio ----------------------------------------------------
    * case empty( X_CODEMP )
    *    W_OPCAO := 1
    *    BL_IMPFUN := {|| FUNCIONARIO->( ! eof() ) }
    *    BL_IMPEMP := {|| EMPRESA->( ! eof()) }
    *    EMPRESA->( dbgotop() )
    *-------------------------------------------------------------

      case ! empty( X_CODEMP ) .and. empty( X_NOME )

         W_OPCAO := 2
         BL_IMPFUN := {|| FUNCIONARIO->CODEMP       == X_CODEMP  .and. ;
                          Left(FUNCIONARIO->NOME,1) >= Letra_Ini .and. ;
                          Left(FUNCIONARIO->NOME,1) <= Letra_Fim .and. ;
                          FUNCIONARIO->( !Eof() )                      }

         BL_IMPEMP := {|| EMPRESA->CODEMP=X_CODEMP }

         EMPRESA->( dbseek(X_CODEMP) )

         Set SoftSeek On
         FUNCIONARIO->( dbseek( X_CODEMP + Letra_Ini ) )
         Set SoftSeek Off

         if (FUNCIONARIO->CODEMP       <> X_CODEMP)  .or. ;
            (Left(FUNCIONARIO->NOME,1)  > Letra_Fim) .or. ;
            FUNCIONARIO->(Eof())
            menstime("Nao ha' Funcionarios para estas iniciais.",2)
            break
         end

      case ! empty( X_CODEMP )	.and. ! empty( X_NOME )

         W_OPCAO := 3
         X_NOME  := alltrim(X_NOME)

         BL_IMPFUN := {|| FUNCIONARIO->CODEMP == X_CODEMP        .and. ;
                          alltrim(FUNCIONARIO->NOME) == X_NOME   .and. ;
                          FUNCIONARIO->(!eof())                        }

         BL_IMPEMP := {|| EMPRESA->CODEMP == X_CODEMP }

         EMPRESA->( dbseek(X_CODEMP) )
	 FUNCIONARIO->( dbseek( X_CODEMP+X_NOME ))

   endcase

   declare SUBTOTAL[4], QTDEVALES[4], PAGINA := 0

   mensagem("Tecle <ESC> para interromper impressao.")

   if dh_imprime("NORMAL","S")

      if ARQ_GERADO != "Nao Gera Arquivo"
         if WRESP_IMPR == "A"
            IMPRESSAO->( grava( ARQ_GERADO, date(), time(), W_TITULO, 80) )
         endif
      end

      FIM := .F.
      begin sequence
      while eval( BL_IMPEMP )

	 X_CODEMP := EMPRESA->CODEMP; IMPRIMIU := 4

********* if W_OPCAO <> 3
*********    FUNCIONARIO->( dbseek( EMPRESA->CODEMP ) )
********* end

	 while eval( BL_IMPFUN )

            if inkey()=K_ESC
               break
            end

            FEZ_IMP := .T.
	    if IMPRIMIU > 3
	       IMPRIMIU := 0
	       CAB0420()
	    end

	    PEDIDO->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ))
	    X_DIASUTEIS := PEDIDO->DIAUTILP

            if PEDIDO->( found() ) .and. PEDIDO->DIAUTILP > 0
	       SUBTOTAL[1] := total_vales("O",1)
	       SUBTOTAL[2] := total_vales("M",1)
	       SUBTOTAL[3] := total_vales("T",1)
	       SUBTOTAL[4] := total_vales("B",1)

	       QTDEVALES[1] := total_vales("O",2)
	       QTDEVALES[2] := total_vales("M",2)
	       QTDEVALES[3] := total_vales("T",2)
	       QTDEVALES[4] := total_vales("B",2)
	       imp_cab420()
	       imprimiu = imprimiu + 1
	    end
	    FUNCIONARIO->( dbskip())

            if W_OPCAO = 3
               EMPRESA->( dbgobottom() )
            end

	 end
	 EMPRESA->( dbskip() )
      end
      end sequence
      @ 00,00 say ''
   end

   dh_impoff()

   if (!FEZ_IMP) .and. (LastKey() <> K_ESC)
      menstime("Nenhum pedido encontrado para conferˆncia.",2)
      while IMPRESSAO->( ! rlock() );end
      IMPRESSAO->( dbdelete() )
   endif

   mensagem("")
end sequence
dbcloseall()
setcolor( W_COR420 )

return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB420
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/

procedure imp_cab420

@ prow()+1,05 say ' Funcionario.: '+FUNCIONARIO->NOME
@ prow()+1,05 say ' Matricula ..: '+FUNCIONARIO->MATRICULA
@ prow()  ,38 say ' Setor ......: '+FUNCIONARIO->SETOR
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
Procedimento .: TOTAL_VALES
Objetivo .....:
-------------------------------------------------------------------------------
*/
function total_vales( P_TIPO, P_POSIC )
local WRET := 0 	 ,;
      W_VALOR_VALES := 0 ,;
      W_CONTA_VALES := 0

PEDITEM->( dbsetorder(3) )
PEDITEM->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA+P_TIPO ) )

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


/*
-------------------------------------------------------------------------------
Procedimento .: CAB0420
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure cab0420()

   @ 01      ,00 say 'FETRANSPOR - Sistema de Pedido de Vale-Transporte'
   @ prow()  ,71 say date()
   @ prow()+1,00 say 'RELACAO PARA CONFERENCIA DOS PEDIDOS DE VALE-TRANSPORTE'
   @ prow()  ,69 say 'Pag .: '+strzero( ++PAGINA,3 )
   @ prow()+1,00 say ''
   @ prow()+1,00 say padc(alltrim(EMPRESA->RAZSOC),77)
   @ prow()+1,00 say '-------------------------------------------------------------------------------'

return
