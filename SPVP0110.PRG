/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0110  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Cadastro de pedidos.                                         |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED                     | Ultima Alteracao                |
  | Analista...: Daniel Machado             | Autor : Daniel Machado          |
  | Programador: Daniel Machado             | Dt/Hr : 13/10/94 - 11:30        |
  | Inicio.....: 21/10/1994                 | Motivo: Inicio.                 |
  |                                         |                                 |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"
#include "sic.ch"
local getlist:={}

private X_CODEMP      := space(03),;
        X_MATRICULA   := space(08),;
        X_DIAUTILP    := 0.00     ,;
        X_USAPADRAO   := "S"

setcolor( W_PDCOR )
@ 08,00 clear to 20,79

private W_CAMPOS := { "' '+PEDIDO->CODEMP+space(10)+PEDIDO->MATRICULA+"+;
                      "space(6)+FUNCIONARIO->NOME+" +;
                      "space(6)+str(PEDIDO->DIAUTILP,2)+space(21)" }
        W_HEADER := { " Empresa      Matricula     Nome "+space(20)+"Dias Uteis" }
mensagem("Selecione um dos itens do menu ou <ESC> para abandonar.")

abrir("EMPRESA")
abrir("FUNCIONARIO")
abrir("PEDIDO")
abrir("PEDITEM")
abrir("TARIFA")
abrir("PARAMETRO")

// busca numero de dias uteis
PARAMETRO->( dbgotop())
private X_DIASUTIL := PARAMETRO->DIASUTIL

FUNCIONARIO->( dbsetorder(1))
PEDIDO->( dbsetorder(1))

PEDIDO->(dbsetrelation("FUNCIONARIO",{|| PEDIDO->CODEMP+PEDIDO->MATRICULA } ))

W_COR0110 := setcolor()
while .t.
   setcolor( W_COREDIT )
   tedit0110() // Tela para dbedit
   PEDIDO->( dbedit( 04, 03, 15, 76, W_CAMPOS, "DB_0110",, W_HEADER ) )
   exit
end
dbcloseall()
setcolor( W_COR0110 )
return

/*
-----------------------------------------------------------------------------
Procedimento : DB_0110
Objetivo     : Controlar o dbedit modulo 0110, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0110( MODO, COLUNA )
private WRETMAIN :=2, W_SCRD:=savescreen(), W_COROLD := setcolor()

TECLA := upper( chr( lastkey()))

setcursor(1)
setcolor(W_CORGET)
do case
   case MODO < 4 // Nao reconhecida
      WRETMAIN := 1
   case lastkey() = K_ESC
      WRETMAIN := 0
   case TECLA = "I"
      push_but(17,07," Incluir ")
      T_INC110()
   case TECLA = "R"
      push_but(17,63,' Retornar ')
      WRETMAIN := 0
   case ! ( PEDIDO->( eof() ) .OR. PEDIDO->( bof() ) )
      do case
        case TECLA = "E"
           push_but(17,29," Excluir ")
           T_EXC110()
        case TECLA = "A"
            push_but(17,18," Alterar ")
           T_ALT110()
        case TECLA = "C"
           push_but(17,40," Consultar ")
           T_CON110()
        case TECLA = "B"
           push_but(17,53," Buscar ")
           T_BUS110()
      endcase
endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_INC110
Objetivo     : Incluir PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_INC110()

   while .t.
      tela0110()
      zera0110() // zerando variaveis

      @ 04,19 get X_CODEMP picture "@K@!" valid busca_empresa(X_CODEMP,04,23)
      @ 05,19 get X_MATRICULA picture "@!K@" valid busca_matricula(X_MATRICULA,05,28,X_CODEMP)
      read
      if lastkey()=K_ESC; exit; end

      FUNCIONARIO->( dbsetorder(1))
      FUNCIONARIO->( dbseek( X_CODEMP+X_MATRICULA ))
      if FUNCIONARIO->( ! found() )
         menswait("Funcionario nao cadastrado.")
         loop
      end

      PEDIDO->( dbsetorder(1))
      PEDIDO->( dbseek( X_CODEMP+X_MATRICULA ))

      if PEDIDO->( found() )
         menswait("Pedido ja cadastrado.")
         loop
      end

      if get0110("I")
         grava0110("I")
         menstime("Incluido.",1)
         exit
      else
         exit
      end
   end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_ALT110
Objetivo     : Alterar PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_ALT110()

while .t.
   tela0110()

   X_CODEMP    := PEDIDO->CODEMP
   X_MATRICULA := PEDIDO->MATRICULA

   show0110()
   atrib0110() // atribui dados da base de dados

   if get0110("A")
      grava0110("A")
      menstime("Alterado.",1)
      exit
   else
      exit
   end
end
return

/*
-----------------------------------------------------------------------------
Procedimento : T_EXC110
Objetivo     : Excluir PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_EXC110()

X_CODEMP    := PEDIDO->CODEMP
X_MATRICULA := PEDIDO->MATRICULA
tela0110()
atrib0110()
show0110()
if pergunta("Confirma Exclusao (S/N) ?")

   PEDITEM->( dbsetorder(1))
   PEDITEM->( dbseek(X_CODEMP+X_MATRICULA) )

   while PEDITEM->CODEMP+PEDITEM->MATRICULA=PEDIDO->CODEMP+PEDIDO->MATRICULA;
        .and. PEDITEM->( ! eof())
      while PEDITEM->( ! rlock() ); end
      PEDITEM->( dbdelete() )
      PEDITEM->( dbskip() )
   end

   while PEDIDO->( ! rlock() );end
   PEDIDO->( dbdelete() )
   menstime("Excluido.",1)
end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_CON110
Objetivo     : Consultar PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_CON110()

X_CODEMP    := PEDIDO->CODEMP
X_MATRICULA := PEDIDO->MATRICULA
tela0110()
atrib0110()
show0110()
menswait("Tecle <ENTER>.")

return

/*
-----------------------------------------------------------------------------
Procedimento : T_BUS110
Objetivo     : Buscar empresa
-----------------------------------------------------------------------------
*/
procedure T_BUS110()
local WSCR := savescreen(10,10,14,65), W_OLDCOR := setcolor()

setcolor(W_CORWG)
@ 10,10 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 11,10 say '³ Empresa   :                                         ³'
@ 12,10 say '³ Matricula :                                         ³'
@ 13,10 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
sombra(10,10,13,64)

begin sequence

   X_CODEMP := space(3)
   X_MATRICULA := space(8)
   @ 11,24 get X_CODEMP picture "@K@!" valid busca_empresa(X_CODEMP)
   @ 12,24 get X_MATRICULA picture "@!K@" valid busca_matricula(X_MATRICULA,,,X_CODEMP)
   read
   if lastkey()=K_ESC; break; end

   FUNCIONARIO->( dbsetorder(1))
   FUNCIONARIO->( dbseek( X_CODEMP+X_MATRICULA ))
   if FUNCIONARIO->( ! found() )
      menswait("Funcionario nao cadastrado.")
      break
   end

   PEDIDO->( dbsetorder(1))
   PEDIDO->( dbseek( X_CODEMP+X_MATRICULA ))

   if PEDIDO->( ! found() )
      menswait("Pedido nao cadastrado.")
      break
   end

end sequence

restscreen(10,10,13,65,WSCR)
setcolor(W_OLDCOR)

return
/*
-------------------------------------------------------------------------------
Procedimento .: TELA0110
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tela0110()

   setcolor( W_COREDIT )
   @ 05,02 say '³'
   @ 05,77 say '³'
   setcolor( W_CORGET )
   @ 04,03 say ' Empresa .....:                                                           '
   @ 05,03 say ' Matricula ...:                                                           '
   @ 06,03 say ' Dias Uteis ..:                                                           '
   setcolor( W_COREDIT )
   @ 07,03 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ 07,02 say 'Ã'
   @ 07,77 say '´'
   setcolor( W_CORGET )
   @ 08,03 say '                                                                          '
   @ 09,03 say '                                                                          '
   @ 10,03 say '                                                                          '
   @ 11,03 say '                                                                          '
   @ 12,03 say '                                                                          '
   @ 13,03 say '                                                                          '
   @ 14,03 say '                                                                          '
   @ 15,03 say '                                                                          '

return

/*
-------------------------------------------------------------------------------
Procedimento .: TEDIT0110
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tedit0110()
   local W_OLDCOR := setcolor()

   setcolor(W_COREDIT)
   quadro(03,02,21,77," Cadastro de Pedidos ")
   @ 05,02 say 'Æ'
   @ 05,77 say 'µ'
   @ 16,03 to 16,76 double
   @ 16,02 say 'Æ'
   @ 16,77 say 'µ'

   sombra(02,02,21,77)

   cria_but( 17,07,' Incluir '   ,17,08,"I")
   cria_but( 17,18,' Alterar '   ,17,19,"A")
   cria_but( 17,29,' Excluir '   ,17,30,"E")
   cria_but( 17,40,' Consultar ' ,17,41,"C")
   cria_but( 17,53,' Buscar '    ,17,54,"B")
   cria_but( 17,63,' Retornar '  ,17,64,"R")

   setcolor( W_OLDCOR )
return

/*
-------------------------------------------------------------------------------
Procedimento .: GET0110
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
function get0110( P_MODO )

   local WRET := .F.
   setcolor( W_CORGET )
   atrib0110()

   if P_MODO = "I"
      X_DIAUTILP := X_DIASUTIL
   end

   @ 06,19 get X_DIAUTILP picture "99" valid X_DIAUTILP<32
   read
   if lastkey() # K_ESC
      X_USAPADRAO := if(X_DIAUTILP=X_DIASUTIL,"S","N")
      WRET := edit_pedido()
   end

return WRET

/*
-------------------------------------------------------------------------------
Procedimento .: SHOW0110
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure show0110()

   X_PEDIDO    := PEDIDO->CODEMP
   X_MATRICULA := PEDIDO->MATRICULA

   @ 04,19 say PEDIDO->CODEMP    picture "@!"
   @ 05,19 say PEDIDO->MATRICULA picture "@!"

   busca_empresa(X_PEDIDO,04,23)
   busca_matricula(X_MATRICULA,05,28,X_CODEMP)

   @ 06,19 say PEDIDO->DIAUTILP  picture "@!"

   if PEDITEM->( dbseek( X_CODEMP+X_MATRICULA ) ) .or. TECLA = "E"
      edit_pedido("Show")
   else
      edit_pedido()
   endif

return

/*
-------------------------------------------------------------------------------
Procedimento .: ATRIB0110
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure atrib0110()

  X_DIAUTILP  := PEDIDO->DIAUTILP

return

/*
-------------------------------------------------------------------------------
Procedimento .: ZERA0110
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure zera0110()

   X_CODEMP      := space(03)
   X_MATRICULA   := space(08)
   X_DIAUTILP    := X_DIASUTIL
   X_USAPADRAO   := "S"

return

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0110
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0110( MODO )

   if MODO = "A"
      while PEDIDO->( ! rlock() ); end
   else
      PEDIDO->( dbappend() )
   end

   PEDIDO->CODEMP    := X_CODEMP
   PEDIDO->MATRICULA := X_MATRICULA
   PEDIDO->DIAUTILP  := X_DIAUTILP
   PEDIDO->USAPADRAO := X_USAPADRAO

return

