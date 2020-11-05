/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0220  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema: Sietema de Pedido de Vale-Transporte.                            |
  |---------------------------------------------------------------------------|
  | Descricao..: Geracao de Disquete.                                         |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED                     | Ultima Alteracao                |
  | Analista...: Daniel Machado             | Autor : Daniel Machado          |
  | Programador: Daniel Machado             | Dt/Hr : 13/10/94 - 11:30        |
  | Inicio.....: 13/10/1994                 | Motivo: Inicio.                 |
  |                                         |                                 |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"

private AC_QTDEVALE := 0         ,;
        CNT_REG2    := 0         ,;
        VL_TOTALCMP := 0         ,;
        VCODEMP     := "001"     ,;
        VREFER      := date()    ,;
        VDRIVE      := "A"       ,;
        X_MES       := strzero( month( date()), 2) ,;
        X_ANO       := strzero( year( date()),  4) ,;
        W_ORDEM     := 1         ,;
        W_QTDEREG   := 0

// Abre Arquivos

abrir("EMPRESA")
abrir("FUNCIONARIO")
abrir("PEDIDO")
abrir("PEDITEM")
abrir("PARAMETROS")
abrir("TARIFAS")

abrir("UNICO")      // arquivo de transferencia
abrir("CONFERE")    // arquivo que armazena dados para rel. de conferencia
abrir("FINAL")      // arquivo de transferencia 2, layout final.

UNICO->( __dbzap())
CONFERE->( __dbzap())
FINAL->( __dbzap())

begin sequence

   W_TELASCR := savescreen(09,14,14,60)
   tela0220()
   if ! get0220()
      break
   end

   WSCREEN := savescreen( 10, 13, 14, 64 )
   W_COROLD:=setcolor()
   setcolor( W_CORWIND )

   @ 10,13 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´          ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 11,13 say '³  0%        25%        50%        75%       100% ³'
   @ 12,13 say '³                                                 ³'
   @ 13,13 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra( 10, 13, 13, 63 )
   setcolor( W_COROLD )

   // Gera o primeiro arquivo temporario... UNICO

   if empty( VCODEMP )
      EMPRESA->( dbgotop() )
      BL_EMP := {|| EMPRESA->( ! eof() ) }
   else
      EMPRESA->( dbseek( VCODEMP ))
      BL_EMP := {|| EMPRESA->CODEMP = VCODEMP .and. ! EMPRESA->( eof() ) }
   end

   while eval( BL_EMP )
      X_CGC    := EMPRESA->CGC
      X_CODEMP := EMPRESA->CODEMP
      registro1()
      PEDIDO->( dbseek( EMPRESA->CODEMP ) )
      while ( PEDIDO->( ! eof() ) .and. PEDIDO->CODEMP = EMPRESA->CODEMP )

         registro2()
         if empty( VCODEMP )
            PEDIDO->( showbar() )
         else
            passatempo(12,15)
         end
         PEDIDO->( dbskip() )
      end

      registro3()
      EMPRESA->( dbskip() )
   end

   // Geracao ordenada de arquivo, segundo temporario...FINAL

   UNICO->( dbgotop() )
   select UNICO
   index on CODEMP + TIPO + USOEMP to UNICOIDX

   UNICO->( dbgotop() )

   X_SEQ := 1
   ULT_CGC := space(14)

   while UNICO->( ! eof() )
      FINAL->( dbappend() )

      if empty( PARAMETRO->USOEMP )
         X_USOEMP := UNICO->VALEWR // o que sai no vale
      else
         X_USOEMP := PARAMETRO->USOEMP
      end

      FINAL->REG_UNI := strzero( X_SEQ, 5 ) +;
                      UNICO->CGC       +;
                      UNICO->TIPO      +;
                      UNICO->RESTO     +;
                        X_USOEMP

      X_SEQ++
      UNICO->( dbskip() )

   end
   FINAL->( dbappend() )
   FINAL->REG_UNI := replicate( "9", 207)

   // Gera disquete

   if pergunta("Continua com geracao de disquete (S/N) ? ")
      mensbeep("Insira disquete no drive e tecle <ENTER>.")
      FINAL->( dbgotop() )
      gera_disco()
      mensbeep("Disquete gerado com sucesso. <ENTER>")
   else
      mensbeep("Disquete nao gerado. <ENTER>")
   end
   restscreen( 10, 13, 14, 64, WSCREEN )
end sequence

dbcloseall()
return
return

/*
-------------------------------------------------------------------------------
Procedimento .: GET0220
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
function GET0220
   local WRET := .T.

   @ 09,15 get VCODEMP picture '@K@!'       valid ( empty(VCODEMP) .or. busca_empresa(VCODEMP,09,20) )
   @ 11,26 get VREFER
   @ 13,41 get VDRIVE  picture "!"          valid VDRIVE $ "AB"
   @ 15,19 get W_ORDEM picture "9"          valid W_ORDEM=1 .or. W_ORDEM=2
   read

   if lastkey() = K_ESC
      WRET := .F.
   end

return WRET

/*
-------------------------------------------------------------------------------
Procedimento .: TELA0220
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tela0220()

   setcolor(W_COREDIT)
   quadro(07,02,21,78," Geracao de Disquete ")
   sombra(07,02,21,78)
   @ 08,03 say '                                                                           '
   @ 09,03 say ' Empresa .:          (Em branco para todas as empresas)                    '
   @ 10,03 say '                                                                           '
   @ 11,03 say ' Data de Referencia :                                                      '
   @ 12,03 say '                                                                           '
   @ 13,03 say ' Drive Onde sera gerado o Disquete :                                       '
   @ 14,03 say '                                                                           '
   @ 15,03 say ' Ordenado por :     1- Setor+Matricula                                     '
   @ 16,03 say '                    2- Setor+Nome                                          '
   @ 17,03 say '                                                                           '
   @ 18,03 say '                                                                           '
   @ 19,03 say '                                                                           '
   setcolor( W_CORGET )

return



/*
------------------------------------------------------------------------------
  Procedimento ..: REGISTRO1
  Objetivo ......: Gera registro tipo 1 no arquivo UNICO...
------------------------------------------------------------------------------
*/
procedure REGISTRO1

   UNICO->( dbappend() )

   UNICO->SEQUENCIA := '00000'
   UNICO->CODEMP    := X_CODEMP
   UNICO->CGC       := padl( alltrim( EMPRESA->CGC ), 14, "0" )
   UNICO->TIPO      := '1'
   UNICO->RESTO     := space(7)                       + ;
                       EMPRESA->RAZSOC                + ;
                       EMPRESA->ENDERECO              + ;
                       X_MES+X_ANO                    + ;
                       strzero( EMPRESA->QTDFUN, 5)   + ;
                       EMPRESA->CEP                   + ;
                       Left(EMPRESA->BAIRRO,17)       + ;
                       EMPRESA->CIDADE                + ;
                       EMPRESA->ESTADO                + ;
                       EMPRESA->ATVPRI                + ;
                       EMPRESA->TELEFONE              + ;
                       EMPRESA->RAMAL


return

/*
------------------------------------------------------------------------------
  Procedimento ..: REGISTRO2
  Objetivo ......: Gera registro tipo 2 no arquivo UNICO...
------------------------------------------------------------------------------
*/
procedure REGISTRO2

   FUNCIONARIO->( dbsetorder(1) )
   FUNCIONARIO->( dbseek(PEDIDO->CODEMP + PEDIDO->MATRICULA) )

   if W_ORDEM = 1
      X_USOEMP := FUNCIONARIO->NOME
      X_VALEWR := FUNCIONARIO->MATRICULA+left(FUNCIONARIO->NOME,14)+;
                  FUNCIONARIO->SETOR
   else
      X_USOEMP := FUNCIONARIO->SETOR+FUNCIONARIO->NOME
      X_VALEWR := FUNCIONARIO->MATRICULA+left(FUNCIONARIO->NOME,14)+;
                  FUNCIONARIO->SETOR
   end

   PEDITEM->( dbseek( PEDIDO->CODEMP + PEDIDO->MATRICULA ))

   if PEDITEM->( found() )
      while PEDITEM->CODEMP+PEDITEM->MATRICULA = ;
            PEDIDO->CODEMP+PEDIDO->MATRICULA .and. PEDITEM->( ! eof() )

         TARIFA->( dbseek( PEDITEM->CODTAR ) )

      *-- Marcio - 27/05/96 ---------------------------------------------------*
      *                                                                        *
      * // quantidade de dias uteis                                            *
      * X_QTDE_VALE := if( PEDITEM->TRANSP = "M", 1, ( PEDIDO->DIAUTILP * 2 )) *

        X_QTDE_VALE :=                                 PEDIDO->DIAUTILP
      *                                                                        *
      *------------------------------------------------------------------------*

         // acumula quantidade de vales
         AC_QTDEVALE += X_QTDE_VALE

         // acumula o total da compra
         VL_TOTALCMP += ( TARIFA->VALTAR * X_QTDE_VALE )

         // grava registro em temporario
         UNICO->( dbappend() )
         CNT_REG2++
         UNICO->SEQUENCIA := '00000'
         UNICO->CGC       := padl( alltrim( X_CGC ), 14, "0" )
         UNICO->CODEMP    := X_CODEMP
         UNICO->TIPO      := '2'
         UNICO->RESTO     := PEDITEM->TRANSP           +;
                             strzero( X_QTDE_VALE, 9 ) +;
                             strzero( TARIFA->VALTAR*100,  8 )
         UNICO->USOEMP    := X_USOEMP // ordem de impressao dos vales
         UNICO->VALEWR    := X_VALEWR // o que sai no vale

         PEDITEM->( dbskip() )
      end
   end
return

/*
------------------------------------------------------------------------------
  Procedimento ..: REGISTRO3
  Objetivo ......: Gera registro tipo 3 no arquivo UNICO...
------------------------------------------------------------------------------
*/
procedure REGISTRO3

   UNICO->( dbappend() )
   X_USOEMP := space(25)

   UNICO->SEQUENCIA := '00000'
   UNICO->CGC       := padl( alltrim( X_CGC ), 14, "0" )
   UNICO->CODEMP    := X_CODEMP
   UNICO->TIPO      := '3'

   UNICO->RESTO     := strzero( CNT_REG2,        5 ) +;
                       strzero( AC_QTDEVALE,     9 ) +;
                       strzero( VL_TOTALCMP*100,15 )

   UNICO->USOEMP  := X_USOEMP

   // gera arquivo para impressao do relatorio de conferencia

   CONFERE->( dbappend() )
   CONFERE->CGC      := X_CGC
   CONFERE->CODEMP   := X_CODEMP
   CONFERE->QTDEREG2 := CNT_REG2
   CONFERE->QTDEVALE := AC_QTDEVALE
   CONFERE->TOTALCMP := VL_TOTALCMP

   // zera acumuladores
   AC_QTDEVALE := 0
   VL_TOTALCMP := 0
   CNT_REG2    := 0

return

/*
------------------------------------------------------------------------------
  Procedimento ..: GERA_DISCO
  Objetivo ......: Gera disquete
------------------------------------------------------------------------------
*/
procedure GERA_DISCO()
   local W_ARQ := VDRIVE+":\VALE.TXT"

   if VDRIVE = "A"
      W_DISCO = 1
   else
      W_DISCO = 2
   end

   // direciona impressao para arquivo
   set device to print
   set console off
   set printer to ( W_ARQ )

   W_FIM := .F.; W_NDISK := 0

   // Verifica se primeiro disco tem espaco.
   TAM := len( FINAL->REG_UNI )
   if diskspace( W_DISCO ) < ( TAM + 50 )
      while diskspace( W_DISCO ) < ( TAM + 50 )
         mensbeep("Insira outro disquete e tecle <ENTER>. (1 DSK)")
      end
   end

   while FINAL->( ! eof() )
      FINAL->( showbarp() )
      TAM := len( FINAL->REG_UNI )

      if diskspace( W_DISCO ) < ( TAM + 50 )
         // @ prow()+1,00 say "C - CONTINUA"

         while diskspace( W_DISCO ) < ( TAM + 50 )

            set device to screen
            set printer to        // fecha arquivo
            mensbeep("Insira outro disquete e tecle <ENTER>.")
            set printer to ( W_ARQ )
            set device to print
            if lastkey()=27
               W_FIM := .T.
               exit
            end
         end
      end

      if W_FIM
         exit
      end

      @ prow()+1, 00 say FINAL->REG_UNI
      FINAL->( dbskip() )

   end
   // @ prow()+1,00 say "F - ULTIMO DISCO"
   FINAL->( dbclosearea() )

   dh_impoff()
return

