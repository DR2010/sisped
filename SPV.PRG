***************************************************************************
*  Programa SISPED.PRG  -  Parte integrante do Sistema SISPED
*  Objetivo : Menu principal do Sistema SISPED
*  Primeira Versao : 17:00:47  20/01/1993
*  Ultima Atualizacao : 11:57:44  3/2/1993
*  Autor : Ricardo Rito
*  Escrito Originariamente em Clipper 5.01
***************************************************************************

external spcadfun, spcademp, spcadped, sptrans, sprel, sputil, spconf
set procedure to sproc

Set exclusive on         &&  Provisorio

Public telados, m1, m2, vfantasy

W_PDCOR     := "W/B,W+/BG,N/N,N/N,N/W"       // Cor padrao
W_CORWIND   := "W+/GR, W+/BG,N/N,N/N,W/GR"   // Cor janela sem get's
W_CORGET    := "N/BG, W+/BG,N/N,N/N,W+/B"    // Cor gets com fundo basico
W_CORWG     := "N/W, W/B, N, N, B/W"         // Cor window com gets
W_CORPERG   := "N/BG,BG+/N,N,N,R/BG"         // Cor das perguntas
W_CORMENS   := "W/R, R/W, N, N, W/R"         // Cor das Mensagen

set date brit
set dele on
nosnow()

// testa a existencia da variavel de ambiente SET CLIPPER
V_CL := getenv("CLIPPER")
if empty( V_CL )
   CLS
   qout('Falta variavel de ambiente SET CLIPPER=F100.')
   qout('')
   qout('Inclua no AUTOEXEC.BAT a linha :')
   qout('     SET CLIPPER=F100')
   qout('')
   qout('e inclua no CONFIG.SYS a linha :')
   qout('     FILES=100')
   qout('')
   qout('Em caso de duvida, contacte a FETRANSPOR.')
   inkey(0)
   quit
end

setcolor('w/n')
resp := 'N'
set dele on
set score off
set cursor off
clear

declare WIND := { "CODATNOM.NTX" ,;
                  "CODEMP.NTX"   ,;
                  "CODTNSET.NTX" ,;
                  "EMPDATA.NTX"  ,;
                  "EMPMAT.NTX"   ,;
                  "EMPNOM.NTX"   ,;
                  "MATREF.NTX"   ,;
                  "PEDSET.NTX"   ,;
                  "RAZSOC.NTX"   ,;
                  "SETNOM.NTX"   ,;
                  "TARIFA1.NTX"  ,;
                  "TRACGCTP.NTX" ,;
                  "TRARE01.NTX"   }

for x := 1 to LEN( WIND )
   if ! file( WIND[x] )
      sput03()
      dbcloseall()
      exit
   end
next

Sele 0
Use spconf1
vfantasy := fantasy
use

tela()
op=2
do while .t.
   textosai="DESEJA ABANDONAR O SISTEMA ? (S/N) : "
   clear
   corini=setcolor()
   setcolor('w/rb')
   m1='Entre com os Dados Requeridos - <ESC> p/ Abortar a Operacao'
   m2=space(50)
   @ 0,0 clear to 3,79
   tx1="menu"
   tx2="de abertura"
   @ 0,0 to 3,79 double
   @ 1,63 say chr(186)
   @ 2,63 say chr(186)
   @ 0,63 say chr(203)
   @ 3,63 say chr(202)
   @ 1,2  say "R O D O T E C  -  Sistemas de Controle Ltda.  (V 1.7) "

   // Versoes
   // 1.6 - 16/09/94 - Daniel Machado
   // 1.7 - 27/09/94 - Daniel Machado
   //
   // Previsao de Novas Versoes
   // 2.0 - 27/10/94 -

   @ 2,2  say "Empresa : " + vfantasy   &&  "FETRANSPOR  -  Controle de Pedidos de Vale Transporte"
   modulo(tx1,tx2)
   setcolor('&corini')
   @ 4,0 to 07,79
   @ 21,0 to 24,79
   @ 24,60 say ' Data : ' + dtoc(date()) + ' '
   @ 22,2 say "Mensagens : "
   tms1="Escolha a Sua Op‡„o ( 1¦ Letra ) -  Para Finalizar <ESC>"
   msg1(tms1)
   set message to 23 center

   @ 05,06 prompt "   FUNCIONARIOS  " message "*  CADASTRO DE FUNCIONARIOS  *"
   @ 05,23 prompt "     PEDIDOS     " message "*  CADASTRO DE PEDIDOS DE VALE *"
   @ 05,40 prompt "     DISKETTE    " message "*  GERACAO DO DISKETE P/ FETRANSPOR *"
   @ 05,57 prompt "    UTILITARIOS  " message "*  UTILITARIOS DO SISTEMA *"
   @ 06,57 prompt "     EMPRESAS    " message "*  CADASTRO DE EMPRESAS *"
   @ 06,40 prompt "    RELATORIOS   " message "*  LISTAGEM DE RELATORIOS *"
   @ 06,23 prompt "   CONFIGURA€ŽO  " message "*  CONFIGURA€ŽO DO SISTEMA *"
   @ 06,06 prompt "    TERMINAR     " message "*  SAIDA DO SISTEMA  *"

   set wrap on
   menu to op
   set escape on
   mens= "  OPCAO POR IMPLEMENTAR !"

   do case
      case op=1
         do spcadfun
      case op=2
         do spcadped
      case op=3
         do sptrans
      case op=4
         do sputil
      case op=5
         do spcademp
      case op=6
         do sprel
      case op=7
         do spconf
      case op=8
         if confirma( TEXTOSAI ) =='S'
            exit
         endif
      otherwise
         if lastkey()=27
            if confirma( TEXTOSAI ) =='S'
               exit
            endif
         endif
endcase
op=2
enddo

close all
RESTORE SCREEN FROM TELADOS
mensend= "¯  SISTEMA DESATIVADO  ®"
col=(80-len(mensend))/2 + 1
@ 22,col say mensend
set score on
return
****************************************    END PROG   *********************
