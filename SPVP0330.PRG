/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0330  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | Sistema:								      |
  |---------------------------------------------------------------------------|
  | Descricao..: Relatorio de Controle de Registros = FETRANSPOR	      |
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
private W_COR330 := setcolor()

// variaveis para controle de impressoes geradas para arquivo
private ARQ_GERADO := space(12)
private W_TITULO := 'Relatorio de Controle - FETRANSPOR'

imprimiu := 0
cgcant	 := space(14)
empant	 := space(03)
qtdvale  := 0
totreg1  := 0
totreg2  := 0
totreg3  := 0
totqtd   := 0
totval   := 0
vpag     := 0
traco    :=replicate('=',80)

cab='LISTAGEM DE CONTROLE DE REGISTROS'
col=(80-len(cab))/2 + 1

abrir("EMPRESA")
abrir("CONFERE")
abrir("IMPRESSAO")

begin sequence
   setcolor(W_CORWG)
   @ 08,11 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 09,11 say '³      Impressao de Listagem de Controle de Registros       ³'
   @ 10,11 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ 11,11 say '³                                                           ³'
   @ 12,11 say '³ CGC ....:                                                 ³'
   @ 13,11 say '³                                                           ³'
   @ 14,11 say '³ Empresa :                                                 ³'
   @ 15,11 say '³                                                           ³'
   @ 16,11 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,11,16,71)

   X_CGC    := space(14)
   X_CODEMP := space(03)
   @ 12,23 get X_CGC    picture "99999999999999"
   @ 14,23 get X_CODEMP picture "@!" when ! empty ( X_CGC )
   read

   if lastkey()=K_ESC; break; end

   EMPRESA->( dbsetorder(1))
   CONFERE->( dbsetorder(1))

   do case
      case empty ( X_CGC )
         BL_IMPCGC := {|| CONFERE->( ! eof()) }
         CONFERE->( dbgotop() )

      case ! empty ( X_CGC ) .and. empty( X_CODEMP )
         BL_IMPCGC := {|| CONFERE->CGC=X_CGC }
         CONFERE->( dbseek( X_CGC ))

      case ! empty ( X_CGC ) .and. ! empty( X_CODEMP )
         BL_IMPCGC := {|| CONFERE->CGC=X_CGC .and. EMPRESA->CODEMP=X_CODEMP }
         CONFERE->( dbseek( X_CGC+X_CODEMP ))

   endcase

   if dh_imprime("NORMAL","S")
      if ARQ_GERADO != "Nao Gera Arquivo"
         IMPRESSAO->( grava( ARQ_GERADO, date(), time(), W_TITULO, 80) )
      end
      while eval( BL_IMPCGC )
            if cgcant # CONFERE->CGC
               cgcant := CONFERE->CGC
               imprimiu  := 1
               imp_cab330()
            endif

            if imprimiu > 11
               imprimiu  := 1
               imp_cab330()
            endif

            EMPRESA->(dbseek( CONFERE->codemp ))

            @ prow()+2,05 say 'EMPRESA - '+ EMPRESA->razsoc
            @ prow()+2,20 say 'QUANTIDADE DE REGISTROS TIPO 2   :             '+ transform(CONFERE->qtdereg2,'@E 99,999')
            @ prow()+1,20 say 'QUANTIDADE DE VALES              :        '+ transform(CONFERE->qtdevale,'@E 999,999,999')
            @ prow()+1,20 say 'VALOR TOTAL                      :   '+ transform(CONFERE->totalcmp,'@E 9,999,999,999.99')

            imprimiu = imprimiu + 1
            totreg1  = totreg1  + 1
            totreg3  = totreg3  + 1
            totreg2  = totreg2  + CONFERE->qtdevale
            totqtd   = totqtd   + CONFERE->qtdevale
            totval   = totval   + CONFERE->totalcmp

            CONFERE->( dbskip())

      end
   end

   if imprimiu > 0
      if imprimiu < 10
         @ prow()+2,00 say traco
         imptot()
      else
         imp_cab330()
         imptot()
      end
   end
   @ 00,00 say ''
   dh_impoff()

end sequence

dbcloseall()
setcolor( W_COR330 )
return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB330
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/

procedure imp_cab330

vpag = vpag + 1
@ 01,25 say 'F E T R A N S P O R'
@ 01,68 say 'PAGINA: ' + str(vpag,3)
@ 03,col say cab
@ 03,65 say 'DATA: ' + dtoc(date())
@ 05,02 say 'INFORMANTE - '+transform(CONFERE->CGC,"@R 99999999/9999-99")

return

*-------------------------
procedure imptot

@ prow()+2,20 say 'TOTAL GERAL :'
@ prow()  ,34 say 'REGISTRO TIPO 1    :        '+transform(totreg1,'@E 999,999,999')
@ prow()+1,34 say 'REGISTRO TIPO 2    :        '+transform(totreg2,'@E 999,999,999')
@ prow()+1,34 say 'REGISTRO TIPO 3    :        '+transform(totreg3,'@E 999,999,999')
@ prow()+1,34 say 'QUANTIDADE DE VALES:        '+transform(totqtd ,'@E 999,999,999')
@ prow()+1,34 say 'VALOR              : '+transform(totval ,'@E 999,999,999,999.99')

return
