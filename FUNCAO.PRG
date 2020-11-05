*---------------------------------------------------------------------------*
* >>>>>>>>>>>>>>>>>>>>>>>>>>>  F U N C A O <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< *
*                                                                           *
* Sistema...:                                                               *
* Modulo....:                                                               *
* Descricao.: Conjunto de rotinas e funcoes comuns a todos os modulos       *
* Chamador..: *                                                             *
* Chamados..: *                                                             *
*---------------------------------------------------------------------------*
* Cliente...:                                                               *
* Analistas.: Daniel Luiz Guimaraes Machado                                 *
* Autor.....: Daniel Luiz Guimaraes Machado                                 *
* Inicio....: 01/08/93                                                      *
*---------------------------------------------------------------------------*
/*

--> Procedimentos ou funcoes do sistema contidos neste modulo <---

ABRE_ARQ     - Abre arquivo
BUSCA        - Busca determinado conteudo em determinado arquivo
BUSCAIMP     - Faz busca em arquivo e mostra conteudo do campo
CENTRO       - Retorna coluna para impressao
CONFIRMAIMP  - Pergunta de confirma impressao
CONS_CONS    - Consulta consorcios.
DH_CABEC1    - Cabecalho principal dos relatorios.
DH_CABEC80   - Cabecalho principal dos relatorios (80 cols).
DH_DECTIME   - Mostra tempo decorrido.
DH_FILES     - Seta todas as ordens para um (1).
DH_HORPROJ   - Projeta tempo final.
DH_IMPRIME   - Envia impressao para arquivo ou impressora.
DH_IMPOFF    - Desliga impressora.
DH_SHOWTIME  - Mostra relogios de projecao.
DH_TEMPDEC   - Calcula tempo decorrido.
DH_ERRO      - Mostra mensagem de erro em local padrao
DESCRIPT     - Descriptografar
ENCRIPT      - Encriptografar
ESPERA       - Emite mensagem e espera usuario teclar ENTER
ESTADO       - Valida estados brasileiros
FTOTDEB      - Calcula debitos do associado no mes indicado.
GETSENHA     - Pede senha.
GCONSULTA    - Consultar arquivo em funcao get. Tecla F5.
IMP_SIT_ASS  - Imprime situacao do associado.
LER_REL      - mostra relatorio no video.
MENU         - Cria menu estilo pop-up
MENSAGEM     - Mostra mensagem em local padrao
MENSBEEP     - Mostra mensagem de advertencia ou conclusao de procedimento
NET_USE      - Abre arquivo para rede
NET_RLOCK    - Bloqueia registro
NET_FLOCK    - Bloqueia arquivo
PERGUNTA     - Faz pergunta com resposta sim/nao
PERGRESP     - Faz pergunta para qualquer resposta
P_EDIT       - Get de nome em dbedit - invocado pela tecla "C".
QUADRO       - Desenha quadro
ROT          - Mostra rotina que esta sendo executada
SHOW_BAR     - Mostra barra horizontal de acordo com arquivo.
TOTAL_PE     - Calcula o total de debitos de determinado item.
TOTAL_TX     - Calcula o total de taxa.
TELA         - Monta tela padrao
ZERO         - Retorna caracter com zeros a esquerda
Val_Faixa    - Valida a entrada de uma faixa ( a ... z ).
Val_Mes      - Valida a entrada do Mes do ano.
*/

#include "inkey.ch"
#include "sic.ch"
#define ATTR_CONV( FORE, BACK ) (BACK)*16+(FORE)
#define BLACK 0
#define WHITE 7
#define DK_GRAY 8
#define COL_SHADOW_ATTRIBUTE ATTR_CONV(DK_GRAY, BLACK)
#define BW_SHADOW_ATTRIBUTE  ATTR_CONV(WHITE,       BLACK)

*---------------------------------------------------------------------------*
* Funcao ......: BUSCA
* Finalidade ..: Fazer uma busca em arquivo
* Parametros ..: <ExpC> Alias do arquivo
*               <ExpC> Chave
*               <ExpN> Ordem
* Retorno .....: <ExpL> .T. = Chave encontrada
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
FUNCTION Busca(pArq,pChave,pOrdem)
LOCAL wRet
SELECT &pArq
SET ORDER TO pOrdem
SEEK pChave
wRet = .T.
IF ! FOUND()
   wRet = .F.
ENDIF
RETURN(wRet)

*---------------------------------------------------------------------------*
* Funcao ......: BUSCAIMP
* Finalidade ..: Fazer uma busca em arquivo e mostrar conteudo de um campo
* Parametros ..: <ExpC> Chave
*               <ExpC> Alias do arquivo
*               <ExpN 1,2> Linha,coluna onde vai ser impresso o campo
*               <ExpC> Campo a ser impresso
* Retorno .....: <ExpL> .T. = Chave encontrada
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
FUNCTION BuscaImp(pChave, pArq, pLin, pCol, pCampo)
LOCAL wRet
SELECT &pArq
SEEK pChave
wRet := .F.
IF FOUND()
   wRet := .T.
   @ pLin, pCol SAY &pCampo
ENDIF
RETURN(wRet)

*---------------------------------------------------------------------------*
* Funcao ......: CENTRO
* Finalidade ..: Fornecer col. inicial para centralizar uma msg.
* Parametros ..: <ExpC> Msg. a ser centralizada
* Retorno .....: <ExpN> Coluna inicial
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
FUNCTION Centro(pMsg)
RETURN (80 - LEN(pMsg))/2

*---------------------------------------------------------------------------*
* Funcao ......:
* Finalidade ..:
* Parametros ..:
* Retorno .....:
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
Function LOC(n)
local WRET := .T.

for X:=1 to n
   if rlock()
      WRET := .T.
      exit
   end
next

return WRET


*---------------------------------------------------------------------------*
* Funcao ......: ConfirmaImp
* Finalidade ..: Confirmar se a impressora esta pronta para imprimir
* Parametros ..: <ExpC> Mensagem
* Retorno .....: <ExpL> .T. = Impressora pronta
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
FUNCTION CONFIRMAIMP(pMsg)
LOCAL wTelaImp := SAVESCREEN(24,00,24,79), ;
      wMsg := IF(pMsg = NIL,'Coloque a impressora em linha ou tecle ESC para abortar.',pMsg)

IF .NOT. ISPRINTER() .AND. LASTKEY() # 27
   @ 24,00 CLEAR
       Mensagem(wMsg)
       DO WHILE .NOT. ISPRINTER() .AND. INKEY() # 27
       ENDDO
   RESTSCREEN(24,00,24,79,wTelaImp)
ENDIF

RETURN IF(LASTKEY() = 27,.F.,.T.)

*---------------------------------------------------------------------------*
* Procedure ...: dh_impoff
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function dh_impoff()
   set print off
   set device to screen
   set console on
   set printer to
return NIL

*---------------------------------------------------------------------------*
* Procedure ...: dh_tempdec
* Finalidade ..: Calcula tempo decorrido
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function dh_tempdec( t_ini, t_fim )

local  sec_ini := val( substr( t_ini, 7, 2 ) )                      ,;
       min_ini := val( substr( t_ini, 4, 2 ) )                      ,;
       hor_ini := val( substr( t_ini, 1, 2 ) )                      ,;
       sec_fim := val( substr( t_fim, 7, 2 ) )                      ,;
       min_fim := val( substr( t_fim, 4, 2 ) )                      ,;
       hor_fim := val( substr( t_fim, 1, 2 ) )

    total_ini := hor_ini*60*60 + min_ini*60 + sec_ini
    total_fim := hor_fim*60*60 + min_fim*60 + sec_fim

    dif      := total_fim - total_ini
    hor_ger  := int( dif / (60*60) )
    totcal   := dif % (60*60)
    min_ger  := int( totcal / 60 )
    sec_ger  := totcal % 60
    dec_time := str( hor_ger, 2) + ":" + str( min_ger, 2) + ":" +;
              str( sec_ger, 2)

return dec_time

*---------------------------------------------------------------------------*
* Procedure ...: dh_horproj
* Finalidade ..: Projeta tempo final
* Parametros ..: INICIO - hora de inicio
*                TEMPO  - tempo em que ocorreu um ciclo
*                VEZES  - numero de vezes que ocorrera o ciclo
* Retorna .....: NEW_TEMPO - a hora em que se encerrara o processo baseado
*                            no tempo de execucao do primeiro ciclo.
*                            Como os ciclos podem ser diferentes, pode-se
*                            a cada ciclo executar esta funcao novamente para
*                            uma avaliacao media. Nao sendo necessario execu-
*                            tar em todos os ciclos.
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function dh_horproj( inicio, tempo, vezes )

// inicio = 08:40:40
// tempo = 00:10:30
// vezes = 103

local  sec := val( substr( tempo, 7, 2 ) )                   ,;
       min := val( substr( tempo, 4, 2 ) )                   ,;
       hor := val( substr( tempo, 1, 2 ) )                   ,;
       sec_i := val( substr( inicio, 7, 2 ) )                     ,;
       min_i := val( substr( inicio, 4, 2 ) )                     ,;
       hor_i := val( substr( inicio, 1, 2 ) )

    total := hor*60*60 + min*60 + sec
    total_i := hor_i*60*60 + min_i*60 + sec_i

    new_total := total * vezes + total_i

    NEW_HOR  := int( new_total / ( 60 * 60 ) )
    TOTCAL   := new_total % ( 60 * 60 )
    NEW_MIN  := int( totcal / 60 )
    NEW_SEC  := totcal % 60
    NEW_TEMPO := strzero( NEW_HOR, 2) + ":" + strzero( NEW_MIN, 2) + ":" +;
               strzero( NEW_SEC, 2)

return new_tempo

*---------------------------------------------------------------------------*
* Procedure ...: dh_showtime
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function dh_showtime( pini, pdec, pter, pprev, plin )

@ plin,04 say 'Inicio .....: ' + pini
@ ++plin,04 say 'Decorrido ..: ' + pdec
@ ++plin,04 say 'Termino ....: ' + pter
@ ++plin,04 say 'Previsao ...: ' + pprev
return NIL

*---------------------------------------------------------------------------*
* Funcao ......: Net_Use
* Finalidade ..: Abrir arquivo em rede no modo compartilhado ou exclusivo
* Parametros ..: <ExpC> Nome completo do arquivo
*               <ExpC> Alias do arquivo a ser aberto
*                     se nao for passado considera nome do arquivo
*               <ExpN> Modo de abertura. 0 = SHARED, 1 = EXCLUSIVE
*                     se nao for passado considera 0
* Retorno .....: <ExpL> .T. = Arquivo aberto com sucesso
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
FUNCTION NET_USE(pNome,pNomeAlias,pModo)
LOCAL wErro := .t., wTelaNet := SAVESCREEN(24,00,24,79),wUltTecla := 0,;
      wNomeAlias := IF(PCOUNT() <= 1,pNome,pNomeAlias),;
      wModo := IF(PCOUNT() <=2,0,pModo)
Mensagem('Abrindo arquivo ' + pNome + ' ...')
DO WHILE wUltTecla # 27
   IF wModo = 0
      USE(pNome) SHARED    ALIAS (wNomeAlias) NEW
   ELSE
      USE(pNome) EXCLUSIVE ALIAS (wNomeAlias) NEW
   ENDIF
   IF ! (wErro := NETERR())
      EXIT
   ENDIF
   wUltTecla = INKEY(2) // temporizador para nao sobrecarrecar a rede
ENDDO
RESTSCREEN(24,00,24,79,wTelaNet)
Return !wErro

*---------------------------------------------------------------------------*
* Funcao ......: Net_RLock
* Finalidade ..: Travar e/ou adicionar registro em branco
* Parametros ..: <ExpL> .T. = Incluir registro em branco
*                se este parametro nao for passado, nao inclui registro branco
*               <ExpC> Alias do arquivo a ser travado
*                se este parametro nao for passado, trava area atual
* Retorno .....: <ExpL> .T. = Registro travado com sucesso
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
FUNCTION NET_RLOCK(pDarAppend,pArea)
LOCAL wSucesso := .F., wTelaNet := SAVESCREEN(24,00,24,79),;
      wOrdemAnt := IndexOrd(), wKey := 0, wAreaAnt := SELECT()
wDarAppend = IF(pDarAppend = NIL,.F.,pDarAppend)
wArea = IF(pArea = NIL,SELECT(),pArea)
SELECT(wArea)
SET ORDER TO 0
DO WHILE wKey # 27
   IF wDarAppend
      APPEND BLANK
       ENDIF
       IF NETERR() .OR. ! RLOCK()
      Mensagem('Aguardando travamento do registro...')
              wKey = INKEY(2) // Usa temporizador de 2 s para nao sobrecarregar rede
              LOOP
       ENDIF
       wSucesso := .t.
   EXIT
ENDDO
SET ORDER TO wOrdemAnt
SELECT(wAreaAnt)
RESTSCREEN(24,00,24,79,wTelaNet)
RETURN wSucesso

*---------------------------------------------------------------------------*
* Funcao ......: Net_FLock
* Finalidade ..: Travar um arquivo
* Parametros ..: <ExpC> Alias do arquivo a ser travado
*                se este parametro nao for passado, trava area atual
* Retorno .....: <ExpL> .T. = Arquivo travado com sucesso
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
FUNCTION NET_FLOCK(pArea)
LOCAL wSucesso := .f.,wTelaNet := SAVESCREEN(24,00,24,79), wKey := 0,;
      wAreaAnt := SELECT(), wArea := IF(pArea = NIL,SELECT(),pArea)
SELECT(wArea)
DO WHILE wkey # 27
       IF .NOT. FLOCK()
      Mensagem('Aguardando travamento de arquivo...')
              wKey = INKEY(2)
              LOOP
       ENDIF
       wSucesso := .T.
   EXIT
ENDDO
SELECT(wAreaAnt)
RESTSCREEN(24,00,24,79,wTelaNet)
RETURN wSucesso

*---------------------------------------------------------------------------*
* Procedimento : Mensagem
* Finalidade ..: Mostrar mensagem, em local padrao, ao usuario.
* Parametros ..: <ExpC> - Mensagem
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
PROCEDURE mensagem(pMsg)
   local W_COR := setcolor()
   setcolor( W_CORMENS )
   @ 24,02 say space(76)
   @ 24,02 say ' > '+pMsg
   setcolor( W_COR )
RETURN

*---------------------------------------------------------------------------*
* Procedimento : MensWait
* Finalidade ..: Mostrar mensagem, em local padrao, ao usuario.
* Parametros ..: <ExpC> - Mensagem
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
PROCEDURE menswait(pMsg)
   local W_COR := setcolor()
   set cursor off
   setcolor( W_CORMENS )
   @ 24,02 say space(76)
   @ 24,02 say ' > '+pMsg
   ?? chr(7)
   inkey(0)
   @ 24,01 say space(78)
   setcolor( W_COR )
   set cursor on
RETURN

*---------------------------------------------------------------------------*
* Procedimento : MensImp
* Finalidade ..: Mostrar mensagem, enquanto imprime
* Parametros ..: <ExpC> - Mensagem
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
PROCEDURE mensimp(pMsg)
   local W_COR := setcolor()
   set device to screen
   setcolor( W_PDCOR )
   @ 24,02 say space(76)
   @ 24,02 say ' > '+pMsg
   setcolor( W_COR )
   set device to print
RETURN

*---------------------------------------------------------------------------*
* Procedimento : dh_erro
* Finalidade ..: Mostrar mensagem de erro, em local padrao, ao usuario.
* Parametros ..: <ExpC> - Mensagem de erro.
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
PROCEDURE dh_erro(pMsg)
LOCAL wLinha24 := SAVESCREEN(24,00,24,79)
@ 24,00 CLEAR
@ 24,00 SAY 'ERRO > '+pMsg
@ 00,00 SAY ''
? CHR(7)
INKEY(0)
RESTSCREEN(24,00,24,79,wLinha24)
RETURN

*---------------------------------------------------------------------------*
* Procedure ...: pergunta
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function pergunta( MSG, IMP )
static WTOP, WLEFT
private WRET := "*"
private  WBOTTOM, WRIGHT, WRET := .T., WVAR := " ", WMEIO, getlist := {}
private  W_OLDCOR := setcolor(); W_OLDCURS := setcursor()

if IMP = NIL
   IMP := "N"
end

// pergunta enquanto imprime

if IMP = "S"
   set device to screen
end
set cursor on

WTOP    := 10
WLEFT   := int( (80-len( MSG ))/2 )
WBOTTOM := WTOP + 4
WRIGHT  := WLEFT + len(MSG) + 3
WMEIO   := WLEFT + 2

setcolor( W_CORPERG  )
ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

_box(WTOP,WLEFT,WBOTTOM,WRIGHT,"EX")
sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )

@ WTOP+2, WMEIO say MSG

WHAT_WALK := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

while .t.
   setcolor( W_PDCOR ) // C_PADRAO
   @ WTOP+2, WRIGHT-2 say ''
   inkey(0)

   do case
   case lastkey()=5 // cima

      if WTOP > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP--
        WBOTTOM--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=24 // baixo

      if WBOTTOM < 23
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP++
        WBOTTOM++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=4 // direita

      if WRIGHT < 78
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT++
        WRIGHT++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=19 // esquerda
      if WLEFT > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT--
        WRIGHT--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case chr( lastkey() ) = "S" .or. chr( lastkey() ) = "s"
      WRET := .T.
      exit

   case chr( lastkey() ) = "N" .or. chr( lastkey() ) = "n"
      WRET := .F.
      exit
   endcase
end

restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
setcursor( W_OLDCURS )
setcolor( W_OLDCOR )

if IMP = "S"
   set device to print
end

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: pergresp
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function pergresp( MSG, PCONDICAO )
static WTOP, WLEFT
private WRET := "*"
private  WBOTTOM, WRIGHT, WRET := "", WVAR := " ", WMEIO, getlist := {}
private  W_OLDCOR := setcolor(); W_OLDCURS := setcursor()

set cursor on

WTOP    := 10
WLEFT   := int( (80-len( MSG ))/2 )
WBOTTOM := WTOP + 4
WRIGHT  := WLEFT + len(MSG) + 3
WMEIO   := WLEFT + 2

setcolor( W_CORPERG  )

ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

_box(WTOP,WLEFT,WBOTTOM,WRIGHT,"EX")
sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )

@ WTOP+2, WMEIO say MSG

WHAT_WALK := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

while .t.
   setcolor( W_PDCOR )
   @ WTOP+2, WRIGHT-2 say ''
   /*
   @ 23,04 CLEAR to 23,67
   @ 23,03 SAY '> ' + pPerg GET wResp PICTURE '!' VALID wResp $ pCondicao
   READ
   @ 23,04 CLEAR to 23,67
   IF LASTKEY() = 27
      wResp := '*'
   ENDIF
   */
   inkey(0)

   do case
   case lastkey()=5 // cima

      if WTOP > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP--
        WBOTTOM--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=24 // baixo

      if WBOTTOM < 23
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP++
        WBOTTOM++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=4 // direita

      if WRIGHT < 78
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT++
        WRIGHT++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=19 // esquerda
      if WLEFT > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT--
        WRIGHT--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case upper( chr( lastkey() )) $ pCondicao
      WRET := upper( chr( lastkey() ))
      exit

   case lastkey() = K_ESC
      WRET := "*"
      exit

   endcase
end

restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
setcursor( W_OLDCURS )
setcolor( W_OLDCOR )

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: WINDOW
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
procedure window( WTOP, WLEFT, WBOTTOM, WRIGHT, FSOMBRA, FEX )
local W_OLDCOR := setcolor()

if FEX = NIL;     FEX     := .F.; end
if FSOMBRA = NIL; FSOMBRA := .F.; end

setcolor( "N/N" )
@ WTOP, WLEFT CLEAR TO WBOTTOM, WRIGHT

setcolor( W_CORMENS  )
if FEX
   _box( WTOP, WLEFT, WBOTTOM, WRIGHT, "EX")
else
   @ WTOP, WLEFT CLEAR TO WBOTTOM, WRIGHT
   @ WTOP, WLEFT to WBOTTOM, WRIGHT
end

if FSOMBRA
   sombra( WTOP, WLEFT, WBOTTOM, WRIGHT )
end

setcolor( W_OLDCOR )
return
*---------------------------------------------------------------------------*
* Procedure ...: ESPERA
* Finalidade ..: Apresentar mensagem na tela e aguadar usuario
* Parametros ..: <ExpC> Mensagem
* Autor .......: Hugo Bastos Peixoto
*---------------------------------------------------------------------------*
PROCEDURE ESPERA(pMsg)
LOCAL wTelaAnt := SAVESCREEN(24,00,24,79)
Mensagem(pMsg)
INKEY(0)
RESTSCREEN(24,00,24,79,wTelaAnt)
RETURN

*---------------------------------------------------------------------------*
* Procedure ...: QUADRO
* Finalidade ..: Montar moldura com titulo
* Parametros ..: <ExpN 1,2,3,4> Coordenadas para montar moldura
*               <ExpC> Titulo
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
PROCEDURE QUADRO(pX1,pY1,pX2,pY2,pTitulo)
@ pX1,pY1 CLEAR TO pX2,pY2
@ pX1,pY1 TO pX2,pY2
IF !EMPTY(pTitulo)
   wMeio = pY1+INT(((pY2-pY1)-LEN(pTitulo))/2)
   @ pX1,wMeio SAY pTitulo
   @ pX1,wMeio-1 SAY CHR(180)
   @ pX1,wMeio+LEN(pTitulo) SAY CHR(195)
ENDIF
RETURN

*---------------------------------------------------------------------------*
* Funcao ......: ESTADO
* Finalidade ..: Validar a entrada de uma UF
* Parametros ..: <ExpC> UF a ser validada
* Retorno .....: <ExpL> .T. = UF valida ou vazia
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
FUNCTION ESTADO(pUF)
LOCAL wRetorno := .T.
LOCAL wEstados := 'ACºALºAPºAMºBAºCEºDFºESºGOºMAºMTºMSºMGºPAºPBºPRºPEºPIºRJºRNºRSºRDºRRºSCºSPºSEºTO'
IF ! (pUF $ wEstados .OR. EMPTY(pUF))
   MensBeep('Estado inv lido.')
   wRetorno := .F.
ENDIF
RETURN wRetorno

*---------------------------------------------------------------------------*
* Funcao ......: dh_imprime
* Finalidade ..: Envia impressao para arquivo ou impressora
* Parametros ..:
* Retorno .....:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function DH_IMPRIME( P_MODO, P_DBF )
local wresp :=  pergresp('(I)mpressora/ (A)rquivo /(R)etorna ?','IAR') ,;
      wret := .T.                                                  ,;
      vet_tudo[adir("*.prn")]                                            ,;
      wnum

WRESP_IMPR := ""
P_DBF := if( P_DBF=NIL,"N", "S")

adir("*.prn",vet_tudo)
wnum := len( vet_tudo ) + 1
arq_ger := "REL"+strzero(wnum,3)+".prn"

if P_DBF = "S"
   ARQ_GERADO := ARQ_GER
else
   ARQ_GERADO := "Nao Gera Arquivo"
end

do case
case  wresp = 'I'
   set device to print
   set console off
   if P_MODO = NIL .or. P_MODO = "NORMAL"
      @ prow(),pcol() say chr(18)
   else
      @ prow(),pcol() say chr(15)
   end
   WRESP_IMPR := "I"

case wresp = 'A'
   set device to print
   set console off
   set printer to &arq_ger
   WRESP_IMPR := "A"

otherwise
   wret := .F.
endcase

return wret

*---------------------------------------------------------------------------*
* Funcao ......: ler_rel
* Finalidade ..: mostrar relatorio no video
* Parametros ..:
* Retorno .....:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
procedure LER_REL
private VET_TUDO[adir("*.prn")], ANTES := savescreen(), WRESP, ARQ
private W_OLDCOR := setcolor()

adir("*.prn",vet_tudo)

if ! len( vet_tudo ) = 0
   @ 10,10 clear to 20,25
   @ 10,10 to 20,25
   sombra(10,10,20,25)
   WRESP := achoice(11,11,19,24,vet_tudo)

   if WRESP > 0
      setcursor(1)
      ARQ := vet_tudo[WRESP]
      mensagem("Aguarde ... ")
      LARQ := memoread( ARQ )
      cls
      memoedit( LARQ, 0, 0, 24, 79, .F.,, 132 )
      setcursor(0)
   end
end
restscreen(,,,,antes)
return

*---------------------------------------------------------------------------*
* Funcao ......: PASSATEMPO
* Finalidade ..: Passar o tempo
* Parametros ..:
* Retorno .....:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
Procedure PassaTempo( P_LIN, P_COL )
static W_CONTATEMPO
local W_PASSATEMPO := "-"

if W_CONTATEMPO = NIL
   W_CONTATEMPO := 1
else
   W_CONTATEMPO++
end

@ P_LIN, P_COL say replicate(".", W_CONTATEMPO) + space(47-W_CONTATEMPO)

Return

*---------------------------------------------------------------------------*
* Funcao ......: SHOWBAR
* Finalidade ..: Mostra barra percentual.
* Parametros ..:
* Retorno .....:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
Function ShowBar( P_TOTREC )
local Perc, titulo

if P_TOTREC = NIL
   P_TOTREC = LastRec()
end

Perc   := Recno()/P_TOTREC
titulo := 'Indexing :'

pol1 := Int( (Perc*100) )
pol  := Int( (pol1*45)/100 )

if recno()=1
   @ 12,16 say space(45)
end
@ 12,16 say Replicate('²',pol)

Return .T.

*---------------------------------------------------------------------------*
* Funcao ......: SHOWBARP
* Finalidade ..: Mostra barra percentual enquanto imprime
* Parametros ..:
* Retorno .....:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
Function ShowBarP()
local Perc, titulo

set device to screen

Perc   := Recno()/LastRec()
titulo := 'Indexing :'

pol1 = Int((Perc*100))
pol = Int((pol1*45)/100)

if recno()=1
   @ 12,16 say space(45)
end
@ 12,16 say Replicate('²',pol)

set device to print

Return .T.

*---------------------------------------------------------------------------*
* Procedimento : TELA
* Finalidade ..: Monta tela padrao
* Parametros ..: <ExpC> Nome do programa chamador
*               <ExpC> Nome da usuario
*               <ExpC> Titulo do sistema
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
PROCEDURE Tela(pProg,pFuncao,pTitulo)
@ 00,00 CLEAR TO 03,79
@ 00,00 TO 03,79
@ 23,00 TO 23,79
@ 01,02 SAY pProg
@ 02,02 SAY pFuncao
@ 01,36 SAY 'PROCESSOS'
@ 02,Centro(pTitulo) SAY pTitulo
@ 01,70 SAY TIME()
@ 02,70 SAY DTOC(DATE())
RETURN

*---------------------------------------------------------------------------*
* Funcao ......: TOTAL_PE
* Finalidade ..: Calcula o total geral
* Parametros ..: <Exp C> Tipo do total ( Ex. 10 - Consorcio )
*               <Exp C> Numero de inscricao do associado
*               <Exp C> Ano
*               <Exp C> Mes
*
* Retorno .....: <Exp N> Total
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function TOTAL_PE( PBL_CODEVE, PINSCRICAO, PANO, PMES )
local WTOTAL := 0                                           ,;
BL_ANOMES:={|| Pano+Pmes >= right(alltrim(str(year(EVENTO->DtIniEve),4)),2) + ;
                         strzero( month( EVENTO->DtIniEve ), 2) .and.      ;
          Pano+Pmes <= right(alltrim(str(year( EVENTO->DtFIMEve ),4 )), 2) + ;
                         strzero( month( EVENTO->DtFIMEve ), 2) .and.      ;
          ( ! EVENTO->encerrado ) }

INSCEVENTO->( dbclearrelation() )

EVENTO->( dbsetorder( 1 ))     // Numeve + codeve
INSCEVENTO->( dbsetorder( 2 )) // Inscricao + Numeve

INSCEVENTO->( dbsetrelation( "EVENTO",  {|| INSCEVENTO->NUMEVE } ) )
INSCEVENTO->( dbsetrelation( "VLEVENTO",{|| INSCEVENTO->NUMEVE } ) )
INSCEVENTO->( dbseek( PINSCRICAO ))

while ( INSCEVENTO->INSCRICAO = PINSCRICAO )

   if eval( PBL_CODEVE ) .AND. eval( BL_ANOMES )

      VLEVENTO->( dbseek( INSCEVENTO->numeve+PANO+PMES ) )
      WTOTAL += VLEVENTO->VALORPAR
   end

   INSCEVENTO->( dbskip() )
end

return( WTOTAL )


*---------------------------------------------------------------------------*
* Funcao ......: TOTAL_TX
* Finalidade ..: Total de taxas
* Parametros ..: <Exp C> Numero de inscricao do associado
*               <Exp C> Ano
*               <Exp C> Mes
*
* Retorno .....: <Exp N> Total
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function TOTAL_TX( PINSCRICAO, PANO, PMES )
local WTAXAS := 0

TAXA->( dbseek( PInscricao+PAno+PMes ) )
if TAXA->( found() )
   WTAXAS = ( 3 * TAXA->Adit_Mes )
end

return WTAXAS

*---------------------------------------------------------------------------*
* Funcao ......: Zero
* Finalidade ..: Retornar uma cadeia de caract. preenchida por '0'
* Parametros ..: <ExpC> Variavel
*               <ExpN> Nro. de posicoes
* Retorno .....: <ExpL> .T.
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
FUNCTION ZERO(pVar,pTam)
LOCAL wVar
wVar  := READVAR()
&wVar := strzero( val( pVar), pTam )
RETURN .T.

*---------------------------------------------------------------------------*
* Funcao ......: GETSENHA
* Finalidade ..: Aceitar senha do usuario
* Parametros ..: <ExpN> Linha
*               <ExpN> Coluna
*               <ExpC> Nome do usuario
* Retorno .....: <ExpL> .T. = Validacao da senha OK
* Autor .......: Hugo B. Peixoto
*---------------------------------------------------------------------------*
FUNCTION GETSENHA(pLin,pCol,pUser)
LOCAL wTecla := 0, wCol, wSenha, wSenhaOk
SELECT USERS
// Se nao existir usuarios cadastrados, cria usuario 'MESTRE' senha 'MESTRE'
IF EOF() .AND. BOF()
   APPEND BLANK
   REPLACE USERS->UserName WITH 'MESTRE',;
          USERS->Senha WITH Encript('MESTRE')
ENDIF

DO WHILE LASTKEY() # 27
   wCol := pCol
   wSenha := ''
   @ 24,00 CLEAR
   @ pLin,pCol SAY SPACE(30)
   Mensagem('Favor informar sua senha.')
   DO WHILE LEN(wSenha) <= 15
      wTecla := INKEY(0)
      IF wTecla < 0 .OR. wTecla > 195
        LOOP
      ENDIF
      IF wTecla = 27 .OR. wTecla = 13
        EXIT
      ENDIF
      @ pLin,wCol SAY 'X'
      wCol ++
      wSenha := wSenha + CHR(wTecla)
   ENDDO

   // Verifica senha
   SELECT USERS
   SEEK pUser
   wSenhaOk := .F.
   IF !EOF()
      wSenhaReal := Descript(USERS->Senha)
      wSenhaOk := (wSenhaReal = wSenha)
      //  Atrib. a wSenhaOk o valor da comparacao entre a senha descript.
      //  gravada no arq. de usuarios e a senha digitada pelo usuario
   ENDIF

   @ 24,00 CLEAR
   IF wSenhaOk
      Mensagem('Bem-vindo ao Sistema Integrado CRESENI ! Pressione ENTER')
      INKEY(3)
      @ 24,00 CLEAR
      EXIT
   ENDIF

   dh_Erro('Senha inv lida ou usu rio n„o cadastrado.')

ENDDO

RETURN wSenhaOk

*---------------------------------------------------------------------------*
* Funcao ......: ENCRIPT
* Finalidade ..: Criptografar sequencia de carcateres
* Parametros ..: <ExpC> Expressao A SER criptografada
* Observacao ..: Recebe faixa de caracteres com cod. ASC entre 0 e 195
* Retorno .....: <ExpC> Expressao criptigrafada
* Autor .......: Hugo Bastos Peixoto
*---------------------------------------------------------------------------*
FUNCTION ENCRIPT(pExpressao)
LOCAL wSemente, wExpCript, wCont
// wSemente recebe o valor em segundos do momento da criptografia para ser
// adicionado ao codigo ASCII da expressao a ser criptografada. O caract. ASC
// desta semente ocupara sempre a primeira posicao da expressao criptografada
wSemente := VAL(RIGHT(TIME(),2))
wExpCript := CHR(wSemente)
FOR wCont = 1 TO LEN(TRIM(pExpressao))
   wExpCript := wExpCript + CHR(ASC(SUBSTR(pExpressao,wCont,1)) + wSemente)
NEXT
RETURN wExpCript

*---------------------------------------------------------------------------*
* Funcao ......: DESCRIPT
* Finalidade ..: Descriptografar sequencia de caracteres
* Parametros ..: <ExpC> Expressao A SER descriptografada
* Retorno .....: <ExpC> Expressao descriptografada
* Autor .......: Daniel Luiz Machado
*---------------------------------------------------------------------------*
FUNCTION DESCRIPT(pExpressao)
LOCAL wSemente, wExpDescript := '', wCont
wSemente := ASC(LEFT(pExpressao,1))  // Le o valor da semente
FOR wCont = 2 TO LEN(TRIM(pExpressao))
   wExpDescript := wExpDescript + CHR(ASC(SUBSTR(pExpressao,wCont,1)) - wSemente)
NEXT
RETURN wExpDescript


*---------------------------------------------------------------------------*
* Funcao ......: SOMBRA
* Finalidade ..:
* Parametros ..:
* Retorno .....:
* Autor .......:
*---------------------------------------------------------------------------*
function sombra( tw, lw, bw, rw )
   local W_OLDCOR := setcolor()

   sha_attr( BW+1, LW+1, BW+1, RW+1 )
   sha_attr( TW+1, RW+1, BW+1, RW+1 )

   setcolor( W_OLDCOR )
return NIL

*---------------------------------------------------------------------------*
* Funcao ......: MEIASOMBRA
* Finalidade ..:
* Parametros ..:
* Retorno .....:
* Autor .......:
*---------------------------------------------------------------------------*
function meiasombra( tw, lw, bw, rw )
   local W_OLDCOR := setcolor()

   setcolor("N/BG")
   for X:=LW+1 to RW+1
      @ BW+1,X say 'ß'
   next

   for X:=TW to BW
      @ X,RW+1 say 'Ü'
   next

   setcolor( W_OLDCOR )
return NIL


*---------------------------------------------------------------------------*
* Funcao ......: SHA_ATTR
* Finalidade ..:
* Parametros ..:
* Retorno .....:
* Autor .......:
*---------------------------------------------------------------------------*
static function sha_attr( t, l, b, r )

local OLD_SCR_AREA, NEW_SCR_AREA, I, NEW_ATTR := 8

OLD_SCR_AREA := savescreen( t, l, b, r )
NEW_SCR_AREA := ""

for I = 1 to len( OLD_SCR_AREA ) step 2
   NEW_SCR_AREA := NEW_SCR_AREA + substr( OLD_SCR_AREA, I, 1 )+ chr( NEW_ATTR )
next

restscreen( t, l, b, r, NEW_SCR_AREA )

return NIL

*---------------------------------------------------------------------------*
* Funcao ......: _BOX
* Finalidade ..:
* Parametros ..:
* Retorno .....:
* Autor .......:
*---------------------------------------------------------------------------*
procedure _box( T, L, B, R, HOW )

   if ( how = "EX" ) // explode

      MC := int((R-L)/2)+L ; MR := int((B-T)/2)+T
      DIFROW := B-T          ; DIFCOL := R-L

      VT:=VB:=MR          ; VL:=VR:=MC

      if ( difcol >= difrow )
        razcol := int( (difcol/difrow) )
        razrow := 1
      else
        razrow := int( (difcol/difrow) )
        razcol := 1
      end

      while .t.
       @ vt,vl clear to vb,vr
       @ vt,vl to vb,vr
       inkey(.01)
       @ vt,vl to vb,vr color "W/W,N/G,N/N,N/N,N/G"

       if vt<=t .or. vb>=b .or. vr>=r .or. vl<=l
          exit
       end

       vt-=razrow ; vl-=razcol
       vb+=razrow ; vr+=razcol
      end

      vt:=t ; vb:=b ; vl:=l ; vr := r
      @ vt,vl clear to vb,vr
      @ vt,vl to vb,vr
   else

      pr:=l-1

      while .t.
        @ t,l to b,++pr
        @ t,l to b,pr color "W/W,N/G,N/N,N/N,N/G"
        if ( pr=r )
           exit
        end
      end
      @ t,l to b,pr
   end
return

*---------------------------------------------------------------------------*
* Funcao ......: EXT_DAY
* Finalidade ..:
* Parametros ..:
* Retorno .....:
* Autor .......:
*---------------------------------------------------------------------------*

function EXT_DAY( PDATA )
local WRET := " "

do case
   case dow( PDATA ) = 1
      WRET := "Domingo"

   case dow( PDATA ) = 2
      WRET := "Segunda"

   case dow( PDATA ) = 3
      WRET := "Terca"

   case dow( PDATA ) = 4
      WRET := "Quarta"

   case dow( PDATA ) = 5
      WRET := "Quinta"

   case dow( PDATA ) = 6
      WRET := "Sexta"

   case dow( PDATA ) = 7
      WRET := "Sabado"

endcase

return WRET

/*
-----------------------------------------------------------------------------
Procedimento : ERR_BEEP
Parametros   : nenhum
Retorno      : nenhum
Objetivo     :
-----------------------------------------------------------------------------
*/
function err_beep()
   mensbeep("Voce nao possui direitos para executar esta rotina. <ENTER>")
return

*---------------------------------------------------------------------------*
* Procedure ...: mensboxv
* Finalidade ..: Mensagem em box com vetor
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
procedure mensboxv( V_MSG )
static WTOP, WLEFT
private  WBOTTOM, WRIGHT, WRET := .T., WVAR := " ", WMEIO, getlist := {}
private  W_OLDCOR := setcolor(); W_OLDCURS := setcursor()

setcursor(0)

WTOP  := int( (24-len( V_MSG ) )/2 )
WBOTTOM := WTOP + 3 + len( V_MSG )

MAIOR := len( V_MSG[1] )
for x := 1 to len( V_MSG )
    if len( V_MSG[x] ) > MAIOR
       MAIOR := len( V_MSG[x] )
    end
next

WLEFT := int( (80-MAIOR)/2 )
WRIGHT := WLEFT + MAIOR + 3
WMEIO := WLEFT + 2

if WRIGHT > 79 .or. WLEFT < 0
   WTOP := 10
   WLEFT := 20
   WBOTTOM := WTOP + 4
   WRIGHT := WLEFT + len( MSG ) + 3
   WMEIO := WLEFT + 2
end

// setcolor( "N/W,N/G,N/N,N/N,N/G"  )
setcolor( W_CORMENS  )

ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

//@ WTOP,WLEFT clear to WBOTTOM, WRIGHT
// @ WTOP,WLEFT       to WBOTTOM, WRIGHT double

_box(WTOP,WLEFT,WBOTTOM,WRIGHT,"EX")
sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )

for x := 1 to len( V_MSG )
   @ WTOP+x+1, WMEIO say V_MSG[x]
end

WHAT_WALK := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

while .t.
   setcolor( "W/B,W+/BG,N/N,N/N,N/W" ) // C_PADRAO
   @ WTOP+2, WRIGHT-2 say ''
   inkey(0)

   do case
   case lastkey()=5 // cima

      if WTOP > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP--
        WBOTTOM--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=24 // baixo

      if WBOTTOM < 23
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP++
        WBOTTOM++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=4 // direita

      if WRIGHT < 78
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT++
        WRIGHT++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=19 // esquerda
      if WLEFT > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT--
        WRIGHT--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=13 // enter
      exit
   endcase
//   sombra( WTOP, WLEFT, WBOTTOM, WRIGHT )
end

restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
setcursor( W_OLDCURS )
setcolor( W_OLDCOR )

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: mensbeep
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
procedure mensbeep( MSG, W_BEEP )
static WTOP, WLEFT
private  WBOTTOM, WRIGHT, WRET := .T., WVAR := " ", WMEIO, getlist := {}
private  W_OLDCOR := setcolor(); W_OLDCURS := setcursor()

setcursor(0)

if W_BEEP = NIL
   W_BEEP := "BEEP"
end

WTOP    := 10
WLEFT   := int( (80-len( MSG ))/2 )
WBOTTOM := WTOP + 4
WRIGHT  := WLEFT + len( MSG ) + 3
WMEIO   := WLEFT + 2

setcolor( W_CORMENS  )

SSAVT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
SSAV  := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

_box( WTOP, WLEFT, WBOTTOM, WRIGHT, "EX")
sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )

@ WTOP+2, WMEIO say MSG

if W_BEEP = "BEEP"
   tone(250, 2)
   tone(650, 2)
   tone(450, 3)
end
WHAT_WALK := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

while .t.
   setcolor( W_PDCOR )
   @ WTOP+2, WRIGHT-2 say ''
   inkey(0)

   do case
   case lastkey()=5 // cima

      if WTOP > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP--
        WBOTTOM--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=24 // baixo

      if WBOTTOM < 23
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WTOP++
        WBOTTOM++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=4 // direita

      if WRIGHT < 78
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT++
        WRIGHT++
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey()=19 // esquerda
      if WLEFT > 0
        restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
        WLEFT--
        WRIGHT--
        ssav := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )
        ssavT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
        restscreen( WTOP, WLEFT, WBOTTOM, WRIGHT, WHAT_WALK )
        sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )
      end

   case lastkey() = 13 .or. lastkey()=27
      exit

   endcase
end

restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
setcursor( W_OLDCURS )
setcolor( W_OLDCOR )

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: menstime
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
procedure menstime( MSG, DURACAO )
static WTOP, WLEFT
private  WBOTTOM, WRIGHT, WRET := .T., WVAR := " ", WMEIO, getlist := {}
private  W_OLDCOR := setcolor(); W_OLDCURS := setcursor()

setcursor(0)

WTOP    := 10
WLEFT   := int( (80-len( MSG ))/2 )
WBOTTOM := WTOP + 4
WRIGHT  := WLEFT + len( MSG ) + 3
WMEIO   := WLEFT + 2

setcolor( W_CORPERG  )

SSAVT := savescreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1 )
SSAV  := savescreen( WTOP, WLEFT, WBOTTOM, WRIGHT )

_box( WTOP, WLEFT, WBOTTOM, WRIGHT, "EX")
sombra( WTOP,WLEFT, WBOTTOM, WRIGHT )

@ WTOP+2, WMEIO say MSG

setcolor( W_PDCOR )
@ WTOP+2, WRIGHT-2 say ''
inkey( DURACAO )

restscreen( WTOP, WLEFT, WBOTTOM+1, WRIGHT+1, SSAVT )
setcursor( W_OLDCURS )
setcolor( W_OLDCOR )

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: TESTA_CGC
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function Testa_CGC( NUMERO )
   local WRET := .T., NUMAUX := alltrim( NUMERO )

   if empty( NUMERO )
      mensbeep("Nao e permitido CGC em branco. <ENTER> ", "NOBEEP")
      WRET := .F.
   else
      if ! Val_CGC( NUMAUX )
         mensbeep("CGC Invalido. <ENTER>","NOBEEP")
         WRET := .F.
      end
   end

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: VAL_CGC
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function val_cgc( NUMBER )

   local POSICAO[12], INDICE, CALCULO, RESTO, DIGITO1, DIGITO2, NUM
   local WRET := .T.

   INDICE:=CALCULO:=RESTO:=DIGITO1:=DIGITO2:=0

   // CGC := 99.999.999/9999-99

   //NUM := left( NUMBER,2 )      +;
   //       substr( NUMBER,4,3 )  +;
   //       substr( NUMBER,8,3 )  +;
   //       substr( NUMBER,12,4 ) +;
   //       substr( NUMBER,17,2 )

   //NUMBER := NUM

   for INDICE = 1 to 12
      POSICAO[INDICE] := val( substr( NUMBER, INDICE, 1 ))
   next

   //  primeiro digito

   for INDICE = 1 to 12
      if INDICE < 5
         CALCULO+=( POSICAO[INDICE] * (6-INDICE) )
      else
         CALCULO+=( POSICAO[INDICE] * (14-INDICE) )
      end
   next

   RESTO := CALCULO%11

   if RESTO=0 .or. RESTO=1
      DIGITO1 := 0
   else
      DIGITO1 := 11-RESTO
   end

   //  segundo digito

   CALCULO := 0
   for INDICE = 1 to 12
      if INDICE < 6
         CALCULO+=( POSICAO[INDICE] * (7-INDICE) )
      else
         CALCULO+=( POSICAO[INDICE] * (15-INDICE) )
      end
   next

   CALCULO+=( DIGITO1 * 2 )

   RESTO := CALCULO%11

   if RESTO=0 .or. RESTO=1
      DIGITO2 := 0
   else
      DIGITO2 := 11-RESTO
   end

   if DIGITO1 <> val( substr( NUMBER,13,1)) .or. ;
      DIGITO2 <> val( substr( NUMBER,14,1))
      WRET := .F.
   end

return WRET

*******************************************************************************
* Val_CPF()- Valida digito verificador do CPF
*******************************************************************************
function val_cpf( NUMBER )
local WRET := .T.

Private Posicao[9],;
        Indice    ,;
        Calculo   ,;
        Resto     ,;
        Digito1   ,;
        Digito2

For Indice = 1 to 9
    Posicao[Indice] = Val(SubStr(Number,Indice,1))
Next

****  TESTE DO PRIMEIRO DIGITO (UNIDADE)

Calculo = 0

For Indice = 1 to 9
    Calculo = Calculo + (Posicao[Indice] * (11 - Indice))
Next

Resto = Calculo%11

If Resto = 0 .Or. Resto = 1
   Digito1 = 0
Else
   Digito1 = 11 - Resto
EndIf

****  TESTE DO SEGUNDO DIGITO (DEZENA)

Calculo = 0

For Indice = 1 to 9
    Calculo = Calculo + (Posicao[Indice] * (12 - Indice))
Next

Calculo = Calculo + (Digito1 * 2)
Resto   = Calculo%11

If Resto = 0 .Or. Resto = 1
   Digito2 = 0
Else
   Digito2 = 11 - Resto
EndIf

If Digito1 <> Val(SubStr(Number,10,1)) .Or. Digito2 <> Val(SubStr(Number,11,1))
   WRET := .F.
EndIf

Return WRET


*---------------------------------------------------------------------------*
* Procedure ...: TESTA_PIS
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function Testa_PIS( NUMERO )
   local WRET := .T., NUMAUX := alltrim( NUMERO )

   if empty( NUMERO )
      // mensbeep("Nao e permitido PIS em branco. <ENTER> ", "NOBEEP")
      WRET := .T.
   else
      if ! Val_PIS( NUMAUX )
         mensbeep("PIS Invalido. <ENTER>","NOBEEP")
         WRET := .F.
      end
   end

return WRET

*---------------------------------------------------------------------------*
* Procedure ...: VAL_PIS
* Finalidade ..:
* Parametros ..:
* Autor .......: Daniel Luiz Guimaraes Machado
*---------------------------------------------------------------------------*
function val_PIS( NUMBER )

   local POSICAO[12], INDICE, CALCULO, RESTO, DIGITO1, DIGITO2, NUM
   local WRET := .T.

   INDICE:=CALCULO:=RESTO:=DIGITO1:=DIGITO2:=0

   // CGC := 99.999.999/9999-99

   NUM := left( NUMBER,2 )      +;
          substr( NUMBER,4,3 )  +;
          substr( NUMBER,8,3 )  +;
          substr( NUMBER,12,4 ) +;
          substr( NUMBER,17,2 )

   NUMBER := NUM

   for INDICE = 1 to 12
      POSICAO[INDICE] := val( substr( NUMBER, INDICE, 1 ))
   next

   //  primeiro digito

   for INDICE = 1 to 12
      if INDICE < 5
         CALCULO+=( POSICAO[INDICE] * (6-INDICE) )
      else
         CALCULO+=( POSICAO[INDICE] * (14-INDICE) )
      end
   next

   RESTO := CALCULO%11

   if RESTO=0 .or. RESTO=1
      DIGITO1 := 0
   else
      DIGITO1 := 11-RESTO
   end

   //  segundo digito

   CALCULO := 0
   for INDICE = 1 to 12
      if INDICE < 6
         CALCULO+=( POSICAO[INDICE] * (7-INDICE) )
      else
         CALCULO+=( POSICAO[INDICE] * (15-INDICE) )
      end
   next

   CALCULO+=( DIGITO1 * 2 )

   RESTO := CALCULO%11

   if RESTO=0 .or. RESTO=1
      DIGITO2 := 0
   else
      DIGITO2 := 11-RESTO
   end

   if DIGITO1 <> val( substr( NUMBER,13,1)) .or. ;
      DIGITO2 <> val( substr( NUMBER,14,1))
      WRET := .F.
   end
return WRET

/*
-----------------------------------------------------------------------------
Procedimento : VER_PIS
Parametros   : K_PIS  -  numero do PIS
Retorno      : .T./.F.
Objetivo     : validar o PIS
-----------------------------------------------------------------------------
*/
FUNCTION VER_PIS( K_PIS )
   local NUM  := {}, WRET := .F., WAC := 0, X
   local PESO := {3,2,9,8,7,6,5,4,3,2}, WLASTNUM

   if empty( K_PIS )
      WRET := .T.
   else
      WLASTNUM := val( substr( K_PIS, 11) )

      for x := 1 to len( K_PIS )-1
         WAC+= ( val( substr( K_PIS,X,1) ) * PESO[X] )
      next

      WTOT := (WAC*10)%11
      if WTOT = WLASTNUM
         WRET:= .T.
      else
         mensbeep("PIS invalido. <ENTER>")
      end
   end

return WRET

*****************************************************************************
* ARQUIVO LOCPROC.PRG  -  PROCEDIMENTOS E FUNCOES                           *
*                                                                           *
* MODULO INTEGRANTE DO SISTEMA LOCTEL   -   GOMES & NUNES ADVOGADOS         *
*                                                                           *
* Data inicial: NOVEMBRO/1993                                               *
*                                                                           *
* Autores: - Roberto Peter                                                  *
*          - Marcio Nunes                                                   *
*****************************************************************************



***************************************************************************
FUNCTION REALCA
***************************************************************************

PARAMETERS x,y,msg,mascara

SET COLOR TO W+/N

IF VALTYPE(msg)="C" .OR. VALTYPE(msg)="D"
   @ x,y SAY msg
ELSEIF VALTYPE(msg)="N"
   @ x,y SAY msg PICT "&mascara."
ENDIF

SET COLOR TO

RETURN (.T.)

***************************************************************************
FUNCTION EXTENSO
***************************************************************************

   PARAMETERS numero

   IF  numero <= 0
        STORE " " TO linha1,linha2,linha3
       RETURN(.F.)
   ENDIF
   n01="UM "
   n02="DOIS "
   n03="TRES "
   n04="QUATRO "
   n05="CINCO "
   n06="SEIS "
   n07="SETE "
   n08="OITO "
   n09="NOVE "
   n00=" "
   n10="DEZ "
   n11="ONZE "
   n12="DOZE "
   n13="TREZE "
   n14="QUATORZE "
   n15="QUINZE "
   n16="DEZESSEIS "
   n17="DEZESSETE "
   n18="DEZOITO "
   n19="DEZENOVE "
   n20="VINTE "
   n30="TRINTA "
   n40="QUARENTA "
   n50="CINQUENTA "
   n60="SESSENTA "
   n70="SETENTA "
   n80="OITENTA "
   n90="NOVENTA "
   n000=" "
   n100="CENTO "
   n200="DUZENTOS "
   n300="TREZENTOS "
   n400="QUATROCENTOS "
   n500="QUINHENTOS "
   n600="SEISCENTOS "
   n700="SETECENTOS "
   n800="OITOCENTOS "
   n900="NOVECENTOS "
   mil="MIL "
   milhao="MILHAO "
   milhoes="MILHOES "
   moeda="REAIS "
   moeda1="REAL "
   centavo="CENTAVO "
   centavos="CENTAVOS "
   numero1=STR(numero,13,2)
   cents=STR((numero-INT(numero))*100,2)
   numero=INT(numero)
   contador=1
   p1=SUBSTR(numero1,2,3)
   p2=SUBSTR(numero1,5,3)
   p3=SUBSTR(numero1,8,3)
   p4=CENTS
   texto1=""
   texto2=""
   texto3=""
   texto4=""
   linha1=""
   linha2=""
   linha3=""
   IF VAL(p1)>0
      status1=IIF(VAL(p1)>1,"2","1")
   ELSE
      status1=" "
   ENDIF
   DO WHILE contador <=4
      item=STR(contador,1)
      grupo= "P"+STR(contador,1)
      extenso=IIF(&grupo="000","",LTRIM(&grupo))
      DO CASE
         CASE LEN(extenso)=3
            IF extenso="100"
               texto&item=texto&item+"CEM "
               contador=contador+1
               LOOP
            ENDIF
            IF SUBSTR(extenso,LEN(extenso)-2+1)="00"
               tab="n"+SUBSTR(extenso,1,1)+"00"
               texto&item=texto&item+&tab
               contador=contador+1
               LOOP
            ENDIF
            tab="n"+SUBSTR(extenso,1,1)+"00"
            texto&item=&tab +"E "
            dezena=VAL(SUBSTR(extenso,LEN(extenso)-2+1))
            IF dezena <20
               tab="n"+SUBSTR(extenso,LEN(extenso)-2+1)
               texto&item=texto&item+&tab
               contador=contador+1
               LOOP
            ELSE
               tab="n"+SUBSTR(extenso,2,1)+"0"
               texto&item=texto&item+ &tab
               tab="n0"+SUBSTR(extenso,LEN(extenso)-1+1)
               unidade_ext=VAL(SUBSTR(extenso,LEN(extenso)-1+1))
               IF unidade_ext > 0
                  texto&item=texto&item +IIF(VAL(extenso)>10,"E ","")
               ENDIF
               texto&item=texto&item+IIF(TAB="n00"," ",&tab)
            ENDIF
         CASE LEN(extenso)=2
            dezena=VAL(SUBSTR(extenso,LEN(extenso)-2+1))
            IF dezena < 20
               tab="n"+ SUBSTR(extenso,LEN(extenso)-2+1)
               texto&item=texto&item+&tab
               contador=contador+1
               LOOP
            ELSE
               tab="n"+ SUBSTR(extenso,1,1)+"0"
               texto&item=texto&item + &tab
               tab="n0" + SUBSTR(extenso,LEN(extenso)-1+1)
               unidade_ext1=VAL(SUBSTR(extenso,LEN(extenso)-1+1))
               IF unidade_ext1 > 0
                  texto&item=texto&item + "E "
               ENDIF
               texto&item=texto&item+IIF(tab="n00"," ",&tab)
            ENDIF
         CASE LEN(extenso)=1
            tab="n0" + SUBSTR(extenso,LEN(extenso)-1+1)
            texto&item=texto&item + IIF(tab="n00"," ",&tab)
         OTHERWISE
            texto&item=""
      ENDCASE
      contador=contador+1
   ENDDO
   final = IIF(LEN(texto1)=0,"",texto1 + ;
           IIF(status1="1",milhao,milhoes)) +;
           IIF(LEN(texto2)=0,"", texto2 + mil ) +;
      texto3 + IIF(VAL(p2+p3)=0,"DE ","")
   final = final + IIF(VAL(p1+p2+p3)=0,"",IIF(VAL(P1+P2+P3)=1,moeda1,moeda))
   final = final + IIF(VAL(p4)=0,"",;
                   IIF(val(P1+P2+P3)=0,"","E ") + ;
   texto4 + (IIF(VAL(p4)=1,centavo,centavos)))

   ********************* AJUSTA EXTENSO ********************
   M->linha=66
   texto1=final
   pinicial=1
   pfinal=M->linha
   teste=.T.
   item="1"
   IF LEN(texto&item) > M->linha
      DO WHILE VAL(item)<=3
         DO WHILE pfinal<LEN(texto&item)
            branco=SUBSTR(texto&item,pfinal,1)
            IF branco <> " "
               pfinal=pfinal-1
               LOOP
            ELSE
               EXIT
            ENDIF
         ENDDO
         linha&item=SUBSTR(texto&item,1,pfinal)
         itemv=item
         item=STR(VAL(item)+1,1)
         texto&item=SUBSTR(texto&itemv,LEN(texto&itemv)-(LEN(texto&itemv)-pfinal)+1)
      ENDDO
   ELSE
      linha1=final
   ENDIF
   linha1=linha1+REPLICATE(" ",M->LINHA-len(LINHA1))
   linha2=linha2+REPLICATE(" ",M->LINHA-len(LINHA2))
   linha3=linha3+REPLICATE(" ",M->LINHA-len(LINHA3))

RETURN(.T.)

*************************************************************************
FUNCTION BACKUP
*************************************************************************
*
* Autor: Marcio da Cunha Nunes
* Data : 31/08/1993
*
* Objetivo: Realizar rotina de backup de arquivos do tipo [.DBF] sem a
*   necessidade de recorrer ao programa Backup.Com do DOS, que pode ser
*   inexistente como tambem dar problema de versao de Sistema Operacional.
*
* Obs.: 1) Esta funcao esta' executando o comando PACK antes da copia.
*       2) Esta funcao tem que obrigatoriamente ser compilada pelo Clipper 5.0
*
* Sintaxe: BACKUP(<vetor_nome_arquivos> , <drive_destino> , <arq_informacao>)
*
* Exemplo de utilizacao:
*
*                          DECLARE arqs[3]
*                                  arqs[1] = "A.DBF"
*                                  arqs[2] = "B.DBF"
*                                  arqs[3] = "C.DBF"
*
*                          BACKUP(arqs,"A:\","INFO_BR.DBF")
*
*                             -----------//------------
*
* Vetor montado pela funcao (ex.):
*
*      Nome    Drive+Nome   Tamanho  Tamanho Minimo
*     ----------------------------------------------
*      A.DBF   A:\A.DBF      100         08
*      B.DBF   A:\B.DBF      540         25
*      C.DBF   A:\C.DBF      320         14
*
*-----------------------------------------------------------------------*

PARAMETERS NomeArqs, Drive, ArqInfo


IF drive="A:\"
   STORE 1 TO num
ELSE
   STORE 2 TO num
ENDIF

IF !FILE(ArqInfo)
   DECLARE vetarq[3]
   vetarq[1] = "N_DISCO   /N/03/00"
   vetarq[2] = "NOME_ARQ  /C/12/00"
   vetarq[3] = "INICIO    /C/01/00"
   CRIADBF(ArqInfo,vetarq)
ELSE
   USE (ArqInfo)
   ZAP
   USE
ENDIF

STORE LEN(NomeArqs) TO N_Arqs

DECLARE vetor[N_Arqs,4],linha_aux[1,4]

STORE 0 TO Tam_Total,flag

* Monta o vetor 4x4 - Ainda desordenado.
FOR x=1 TO N_Arqs

  STORE NomeArqs[x] TO vetor[x,1]

  STORE (UPPER(drive)+NomeArqs[x]) TO vetor[x,2]

   USE (NomeArqs[x])
   PACK
   GO TOP

   STORE HEADER()+(RECSIZE()*LASTREC())+1 TO vetor[x,3]

   STORE HEADER()+RECSIZE()+1 TO vetor[x,4]

   STORE (vetor[x,3] + Tam_Total) TO Tam_Total

   CLOSE

NEXT

RELEASE NomeArqs


* Ordena o vetor por ordem ascendente de tamanho; assim realizamos o menor
* numero de quebras em disco dos arquivos a serem copiados. - Metodo Bolha.
*
FOR i=1 TO N_Arqs-1

       IF (vetor[i,3] > vetor[i+1,3])

          * Gera um vetor (linha_aux) p/ uso do metodo bolha.
         FOR x=1 TO 4
              STORE vetor[i,x] TO linha_aux[1,x]
          NEXT

          * Transfere os dados da proxima linha corrente p/ a linha corrente.
            FOR y=1 TO 4
              STORE vetor[i+1,y] TO vetor[i,y]
          NEXT

        * Transfere os dados contidos no vetor linha_aux p/ a posicao
          * correta - proxima linha do vetor principal.
        FOR z=1 TO 4
              STORE linha_aux[1,z] TO vetor[i+1,z]
          NEXT

       ENDIF

NEXT

RELEASE linha_aux


* Realiza copia dos arquivos do vetor ja' ordenado e N discos.
*
STORE 1 TO Cont_Arqs, Cont_Byte
STORE 1 TO vn_disco
STORE .T. TO troca,continua

DO WHILE  (Cont_Byte < Tam_Total)

   USE (ArqInfo)
   APPEND BLANK
   REPLACE N_DISCO  WITH vn_disco
   REPLACE NOME_ARQ WITH vetor[Cont_Arqs,1]
   REPLACE INICIO   WITH "S"

   USE (vetor[Cont_Arqs,1])

   IF (troca)
      TROCA_DISCO(vn_disco,"BACKUP")

      IF (continua=.F.)
                        RETURN(.F.)
      ENDIF

      * Apaga todo o conteudo do diskette................
      DECLARE vetdir[ADIR(drive+"*.*")]
      ADIR(drive+"*.*",vetdir)
     STORE ADIR(drive+"*.*") TO TAM_VETOR
       FOR x=1 TO TAM_VETOR
         DELETE FILE (drive+vetdir[x])
      NEXT
      RELEASE vetdir
      *..................................................

   ENDIF

   STORE .F. TO troca

   DO WHILE !EOF()

      IF (troca=.T.)

         STORE (vn_disco +1) TO vn_disco
         TROCA_DISCO(vn_disco,"BACKUP")

         IF (continua=.F.)
                             RETURN(.F.)
         ENDIF

         * Apaga todo o conteudo do diskette................
         DECLARE vetdir[ADIR(drive+"*.*")]
         ADIR(drive+"*.*",vetdir)
        STORE ADIR(drive+"*.*") TO TAM_VETOR
           FOR x=1 TO TAM_VETOR
            DELETE FILE (drive+vetdir[x])
         NEXT
         RELEASE vetdir
         *..................................................

        STORE RECNO() TO flag
        USE (ArqInfo)
         APPEND BLANK
          REPLACE N_DISCO  WITH vn_disco,;
                NOME_ARQ WITH vetor[Cont_Arqs,1],;
                INICIO WITH "N"
         USE (vetor[Cont_Arqs,1])
         GO (flag)

      ENDIF

     * Calcula o numero de registros a ser copiado no diskette, deixando
     * 10 Kbytes de margem de espaco.
     *
     STORE ((DISKSPACE(num)-10000)-HEADER())/RECSIZE() TO N_Registros

      STORE vetor[Cont_Arqs,2] TO nome_arq

      COPY NEXT N_Registros TO &nome_arq.

      SKIP

      STORE .T. TO TROCA

   ENDDO

    STORE (Cont_Byte + vetor[Cont_Arqs,3]) TO Cont_Byte

   IF (Cont_Arqs = N_Arqs)
      EXIT
   ELSE
      STORE (Cont_Arqs + 1) TO Cont_Arqs
   ENDIF

   * Se o espaco do disco A for menor que a estrutura+registro do proximo
   * arquivo, executar aviso 'coloque disco numero (x) no drive (y)...
   *
   IF DISKSPACE(num) < vetor[Cont_Arqs,4]
      STORE .T. TO troca
   ELSE
      STORE .F. TO troca
      LOOP
   ENDIF

ENDDO

RETURN(.T.)


*************************************************************************
FUNCTION RESTORE
*************************************************************************
*
* Autor: Marcio da Cunha Nunes
* Data : 31/08/1993
*
* Objetivo: Realizar rotina de restore de arquivos do tipo [.DBF] sem a
*   necessidade de recorrer ao programa Restore.Com do DOS, que pode ser
*   inexistente como tambem dar problema de versao de Sistema Operacional.
*
* Sintaxe: RESTORE (<arquivo_informacao> , <drive_origem> , <drive_destino>)
*
* Exemplo de utilizacao:
*
*                       RESTORE("INFO_BR.DBF","A:\","C:\TESTE")
*
*-----------------------------------------------------------------------*
PARAMETERS Arq_Info, DrvOrigem, DrvDestino

STORE .T. TO troca,continua

USE (Arq_Info)

DO WHILE !EOF()

   STORE N_DISCO TO vn_disco

   IF (troca=.T.)
      TROCA_DISCO(vn_disco,"RESTORE")

      IF (continua=.F.)
                        RETURN(.F.)
      ENDIF

   ENDIF

    STORE ALLTRIM(DrvOrigem+NOME_ARQ)      TO nome_arq_origem
    STORE ALLTRIM(DrvDestino+"\"+NOME_ARQ) TO nome_arq_destino

   IF (INICIO="S")
       COPY FILE (nome_arq_origem) TO (nome_arq_destino)
   ELSEIF (INICIO="N")
       STORE RECNO() TO flag_info
       USE (nome_arq_destino)
       APPEND FROM (nome_arq_origem)
      USE (Arq_Info)
        GO (flag_info)
   ENDIF

   SKIP

   IF (N_DISCO<>vn_disco)
      STORE .T. TO troca
   ELSE
      STORE .F. TO troca
   ENDIF

ENDDO

RETURN(.T.)


*****************************************************************************
FUNCTION TROCA_DISCO
*****************************************************************************
*
* Parametros:  Numero---> numero do disco.
*              Processo-> Backup ou Restore.

PARAMETERS numero,processo

CAIXA(09,15,13,64)
@ 10,34 SAY "             "
@ 11,18 SAY "Coloque disco numero " + ALLTRIM(STR(numero))+" e tecle <Enter>..."
TONE(200,1)
TONE(200,1)
INKEY(0)

IF LASTKEY()=27
   STORE .F. TO continua
        ERRO("PROCESSO INTEROMPIDO !!!")
   RETURN(continua)
ENDIF

SET COLOR TO W+*/N
@ 10,34 SAY "A G U A R D E"
SET COLOR TO

if upper(PROCESSO)="BACKUP"
     @ 11,18 SAY "Copiando arquivos p/ disco numero " + ALLTRIM(STR(numero)) + "...     "
elseif upper(PROCESSO)="RESTORE"
     @ 11,18 SAY "Restaurando arquivos do disco numero " + ALLTRIM(STR(numero)) + "...    "
endif

return(.t.)

***********************************************************************
FUNCTION CRIADBF
***********************************************************************

PARAMETERS arquivo,vetor

n_campos = LEN(vetor)

CREATE arqtemp

PUBLIC vcampo, vtipo, vcomp, vdec

x=1
FOR x=1 TO N_CAMPOS

    NOME_CAMPO = SUBSTR(vetor[x],1,10)

   TIPO_CAMPO = SUBSTR(vetor[x],12,1)

    TAM_CAMPO  = SUBSTR(vetor[x],14,2)

   DEC_CAMPO  = SUBSTR(vetor[x],17,2)

    APPEND BLANK

    REPLACE Field_Name  WITH NOME_campo

    REPLACE Field_Type  WITH TIPO_campo

    REPLACE Field_Len   WITH VAL(TAM_campo)

    REPLACE Field_Dec   WITH VAL(DEC_campo)

NEXT x

CREATE (arquivo) FROM arqtemp

DELETE FILE arqtemp.dbf

RETURN(.T.)

*******************************************************************************
FUNCTION CAIXA
PARAMETERS ls,cs,li,ci
*
* Objetivo..: Desenha uma caixa com sombra nas coordenadas.
* Parƒmetros:
*   ls, cs  -> coordenadas do cando superior direito
*   li, ci  -> coordenadas do canto inferior esquerdo
*
* Obs.: Declarar variavel 'carac_sombra' no modulo principal como publica.
*       e atribuir um numero a ela.
*******************************************************************************

vtela=SAVESCREEN(ls+1,cs+2,li+1,ci+2)

IF LEN(vtela)>2048
   vtela=TRANSFORM(SUBSTR(vtela,1,2048),REPLICATE("X"+CHR(carac_sombra),1000))+;
          TRANSFORM(SUBSTR(vtela,2049),REPLICATE("X"+CHR(carac_sombra),1000))
ELSE
   vtela=TRANSFORM(vtela,REPLICATE("X"+CHR(carac_sombra),LEN(vtela)/2))
ENDIF

RESTSCREEN(ls+1,cs+2,li+1,ci+2,vtela)

@ ls,cs CLEAR TO li,ci
@ ls,cs TO li,ci

RETURN(.T.)

***************************************************************************
FUNCTION ERRO
***************************************************************************

PARAMETERS msg

STORE 12 TO li
STORE 20 TO ci
STORE 17TO lf
STORE 60 TO cf
STORE 14 TO li_msg
tela_anterior=SAVESCREEN(li,ci,lf+1,cf+2)
SET CURSOR OFF
STORE LEN(ALLTRIM(msg)) TO tam_msg
STORE "Tecle algo p/ retornar..." TO msg_aux
STORE LEN(msg_aux) TO tam_tecle_algo
STORE (cf-ci) TO coluna_central
STORE INT( tam_msg/2 ) TO centro_msg
STORE INT( tam_tecle_algo/2 ) TO centro_tecle_algo
SET COLOR TO (cor_erro)
CAIXA(li,ci,lf,cf)
@ li_msg,(coluna_central - centro_msg) SAY msg
@ (lf-1),(coluna_central - centro_tecle_algo) SAY msg_aux
TONE(200,2)
INKEY(0)
SET COLOR TO
RESTSCREEN(li,ci,lf+1,cf+2,tela_anterior)
SET CURSOR ON
RETURN(.T.)

********************************************************************************
* Val_Faixa() - Valida a entrada de uma faixa ( a ... z ).
********************************************************************************

// Obs.: As variaveis Letra_Ini e Letra_Fim devem estar declaradas no modulo
//       principal do sistema, pois sao utilizadas em tres relatorios.

Function Val_Faixa()

Local Tela, Retorno := .t.

Tela_Old := SaveScreen(00,00,24,78)

Do While .t.

   Letra_Ini := " "
   Letra_Fim := " "

   @ 14,35 Say "ÚÄÄÄ Faixa de Impressao ÄÄÄ¿"
   @ 15,35 Say "³                          ³"
   @ 16,35 Say "³  Letra Inicial : _       ³"
   @ 17,35 Say "³                          ³"
   @ 18,35 Say "³  Letra Final   : _       ³"
   @ 19,35 Say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
   Sombra( 14,35,19,62 )

   @ 16,54 Get Letra_Ini Pict "@!A" Valid !Empty( Letra_Ini )
   @ 18,54 Get Letra_Fim Pict "@!A" Valid !Empty( Letra_Fim )
   Read

   If (LastKey() = K_ESC)
      RestScreen(00,00,24,78,Tela_Old)
      Retorno := .F.
      Exit
   Else
      If Val_Letras()
         RestScreen(00,00,24,78,Tela_Old)
         @ 14,23 Say "( de " + Letra_Ini + " `a " + Letra_Fim + " )"
         Exit
      Endif
   Endif

Enddo

Return( retorno )

********************************************************************************
* Val_Letras() - Valida as letras inicial e final digitadas.
********************************************************************************

Function Val_Letras()

Local Retorno := .T.

If (Letra_Fim < Letra_Ini)
   Mensagem("Letra final nao pode ser menor que inicial. Tecle algo ...")
   Inkey(0)
   Mensagem("")
   Retorno := .F.
End

Return (Retorno)

********************************************************************************
* Val_Mes() - Valida a entrada de mes do ano.
********************************************************************************

Function Val_Mes()

Local Tela_Old := SaveScreen(00,00,24,78) ,;
      Meses    := {}                      ,;
      Retorno  := .t.                     ,;
      Mes      := 0

AADD( Meses, '   Janeiro      ')
AADD( Meses, '   Fevereiro    ')
AADD( Meses, '   Marco        ')
AADD( Meses, '   Abril        ')
AADD( Meses, '   Maio         ')
AADD( Meses, '   Junho        ')
AADD( Meses, '   Julho        ')
AADD( Meses, '   Agosto       ')
AADD( Meses, '   Setembro     ')
AADD( Meses, '   Outubro      ')
AADD( Meses, '   Novembro     ')
AADD( Meses, '   Dezembro     ')

@ 08,35 Say "ÚÄ Meses do Ano Ä¿"
@ 09,35 Say "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
@ 10,35 Say "³   Janeiro      ³"
@ 11,35 Say "³   Fevereiro    ³"
@ 12,35 Say "³   Marco        ³"
@ 13,35 Say "³   Abril        ³"
@ 14,35 Say "³   Maio         ³"
@ 15,35 Say "³   Junho        ³"
@ 16,35 Say "³   Julho        ³"
@ 17,35 Say "³   Agosto       ³"
@ 18,35 Say "³   Setembro     ³"
@ 19,35 Say "³   Outubro      ³"
@ 20,35 Say "³   Novembro     ³"
@ 21,35 Say "³   Dezembro     ³"
@ 22,35 Say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
Sombra(08,35,22,52)

Mes := Achoice(10,36,21,51,Meses)

If LastKey() <> K_ENTER
   Retorno := .F.
Else
   W_COMP_MES := Substr( Meses[ Mes ] , 4, 9 )
Endif

RestScreen(00,00,24,78,Tela_Old)

Return ( Retorno )
