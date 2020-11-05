/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0430  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
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
private WRESP_IMPR := ""
private W_COR430 := setcolor()

// variaveis para controle de impressoes geradas para arquivo
private ARQ_GERADO := space(12)
private W_TITULO := 'Relatorio de Controle - FETRANSPOR'

IMPRIMIU := 0
CGCANT   := space(14)
EMPANT   := space(03)
QTDVALE  := 0
TOTREG1  := 0
TOTREG2  := 0
TOTREG3  := 0
TOTQTD   := 0
TOTVAL   := 0
VPAG     := 0
TOTVALES := 0
TOTVALOR := 0
TRACO    :=replicate('=',80)

cab='LISTAGEM DE CONTROLE DE REGISTROS'
col=(80-len(cab))/2 + 1

abrir("EMPRESA")
abrir("CONFERE")
abrir("IMPRESSAO")
abrir("PARAMETRO")

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
         BL_IMPCGC := {|| CONFERE->CGC=X_CGC .and. CONFERE->CODEMP=X_CODEMP }
         CONFERE->( dbseek( X_CGC+X_CODEMP ))

   endcase

   if dh_imprime("NORMAL","S")
      if ARQ_GERADO != "Nao Gera Arquivo"
         if WRESP_IMPR == "A"
            IMPRESSAO->( grava( ARQ_GERADO, date(), time(), W_TITULO, 80) )
         endif
      end

      IMPRIMIU := 12
      while eval( BL_IMPCGC )

         if imprimiu > 11
            imprimiu  := 1
            imp_cab430()
         endif

         EMPRESA->( dbseek( CONFERE->codemp ))

         @ prow()+1, 00 say EMPRESA->CGC
         @ prow()  , 15 say left( EMPRESA->RAZSOC, 15)
         @ prow()  , 32 say EMPRESA->TELEFONE
         @ prow()  , 45 say CONFERE->QTDEVALE picture '@E 999,999,999'
         @ prow()  , 57 say CONFERE->TOTALCMP picture '@E 9,999,999,999.99'
         @ prow()  , 74 say CONFERE->QTDEREG2  picture '@E 99,999'

         IMPRIMIU++
         TOTREG1++
         TOTREG3++
         TOTREG2  += CONFERE->QTDEREG2
         TOTQTD   += CONFERE->QTDEVALE
         TOTVAL   += CONFERE->TOTALCMP
         TOTVALES += CONFERE->QTDEVALE
         TOTVALOR += CONFERE->TOTALCMP

         CONFERE->( dbskip())
      end
   end

   if TOTVALES > 0 .or. TOTVALOR > 0
      @ prow()+1,45 say replicate("-",28)
      @ prow()+1,45 say TOTVALES picture '@E 999,999,999'
      @ prow()  ,57 say TOTVALOR picture '@E 9,999,999,999.99'
   endif

   if imprimiu > 0
      if imprimiu < 10
         @ prow()+2,00 say traco
         imptot()
      else
         imp_cab430()
         imptot()
      end
   end
   @ 00,00 say ''
   dh_impoff()

end sequence

dbcloseall()
setcolor( W_COR430 )
return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB430
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure IMP_CAB430

vpag = vpag + 1
@ 01      ,00 say 'FETRANSPOR - Sistema de Pedido de Vale-Transporte'
@ prow()  ,72 say date()
@ prow()+1,00 say CAB
@ prow()  ,70 say 'Pag .: '+strzero( ++VPAG,3 )
@ prow()+2,00 say 'Informante : '
@ prow()  ,15 say PARAMETRO->CGC + ' - ' + PARAMETRO->NOMEFANT
@ prow()+1,00 say '--------------------------------------------------------------------------------'

@ prow()+2, 00 say 'CGC'
@ prow()  , 15 say 'RAZAO SOCIAL'
@ prow()  , 32 say 'TELEFONE'
@ prow()  , 47 say 'QTD VALES'
@ prow()  , 62 say 'VALOR TOTAL'
@ prow()  , 75 say 'TIPO2'
return

/*
-------------------------------------------------------------------------------
Procedimento .: IMPTOT
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure imptot

@ prow()+1,00 say '-------------------------------------------------------------------------------'
@ prow()+2,20 say 'QUANTIDADE DE REGISTROS'
@ prow()+2,01 say 'REGISTRO DE IDENTIFICACAO TIPO 1    :'
@ prow()  ,40 say TOTREG1  picture '@E 999,999,999'
@ prow()+2,01 say 'REGISTRO DE IDENTIFICACAO TIPO 2    :'
@ prow()  ,40 say TOTREG2  picture '@E 999,999,999'
@ prow()+2,01 say 'REGISTRO DE IDENTIFICACAO TIPO 3    :'
@ prow()  ,40 say TOTREG3  picture '@E 999,999,999'
@ prow()+2,01 say 'TOTAL DE SUBARQUIVOS :'
@ prow()  ,24 say TOTREG1  picture '@E 999,999,999'
@ prow()+1,00 say '-------------------------------------------------------------------------------'

return
