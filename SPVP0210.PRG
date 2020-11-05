/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0210  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Cadastro de empresas.                                        |
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

private  X_CODEMP   := space(03) ,;
         X_RAZSOC   := space(40) ,;
         X_ENDERECO := space(40) ,;
         X_CEP      := space(08) ,;
         X_BAIRRO   := space(20) ,;
         X_CIDADE   := space(20) ,;
         X_ESTADO   := space(02) ,;
         X_DDD      := space(04) ,;
         X_TELEFONE := space(07) ,;
         X_RAMAL    := space(04) ,;
         X_ATVPRI   := space(04) ,;
         X_CEI      := space(01) ,;
         X_CGC      := space(14) ,;
         X_QTDFUN   := 0.00

setcolor( W_PDCOR )
@ 08,00 clear to 20,79

// titulo("Cadastro de Empresas")

private W_CAMPOS := { "' '+EMPRESA->CODEMP+' - '+EMPRESA->RAZSOC+space(30)" }
        W_HEADER := { " Cod   Razao Social" }

mensagem("Selecione um dos itens do menu ou <ESC> para abandonar.")

abrir("EMPRESA")
abrir("FUNCIONARIO")

W_COR0210 := setcolor()
while .t.
   setcolor( W_COREDIT )
   tedit0210() // Tela para dbedit
   EMPRESA->( dbedit( 04, 03, 15, 76, W_CAMPOS, "DB_0210",, W_HEADER ) )
   exit
end
dbcloseall()
setcolor( W_COR0210 )
return

/*
-----------------------------------------------------------------------------
Procedimento : DB_0210
Objetivo     : Controlar o dbedit modulo 0210, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0210( MODO, COLUNA )
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
      T_I()
   case TECLA = "R"
      push_but(17,63,' Retornar ')
      WRETMAIN := 0
   case ! ( EMPRESA->( eof() ) .OR. EMPRESA->( bof() ) )
      do case
        case TECLA = "E"
           push_but(17,29," Excluir ")
           T_E()
        case TECLA = "A"
           push_but(17,18," Alterar ")
           T_A()
        case TECLA = "C"
           push_but(17,40," Consultar ")
           T_C()
        case TECLA = "B"
           push_but(17,53," Buscar ")
           T_B()
      endcase
endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_I
Objetivo     : Incluir empresa
-----------------------------------------------------------------------------
*/
procedure T_I()

while .t.
   tela0210()

   X_CODEMP := space(03)
   @ 04,19 get X_CODEMP picture "@!" valid ! empty( X_CODEMP )
   read
   if lastkey()=K_ESC; exit; end

   EMPRESA->( dbsetorder(1)) // codemp
   EMPRESA->( dbseek( X_CODEMP ))
   @ 04,68 say EMPRESA->QTDFUN    picture "9999"

   while .t.
      if EMPRESA->(found())
         show0210()
         menswait("Empresa ja cadastrada. <ENTER>")
         exit
      else
         zera0210() // zerando variaveis
      end

      if get0210()
         grava0210("I")
         menstime("Incluido. <ENTER>",1)
         exit
      else
         exit
      end
   end
end
return

/*
-----------------------------------------------------------------------------
Procedimento : T_A
Objetivo     : Alterar empresa
-----------------------------------------------------------------------------
*/
procedure T_A()

while .t.
   tela0210()

   X_CODEMP := EMPRESA->CODEMP
   show0210()
   atrib0210() // atribui dados da base de dados

   if get0210()
      grava0210("A")
      menstime("Alterado. <ENTER>",1)
      exit
   else
      exit
   end
end
return

/*
-----------------------------------------------------------------------------
Procedimento : T_E
Objetivo     : Excluir empresa
-----------------------------------------------------------------------------
*/
procedure T_E()

tela0210()
show0210()
if pergunta("Confirma Exclusao (S/N) ?")

   FUNCIONARIO->( dbsetorder(1))
   FUNCIONARIO->( dbseek( EMPRESA->CODEMP ))
   if FUNCIONARIO->( found() )
      mensbeep("Empresa possui funcionarios, nao pode ser Excluida. <ENTER>")
   else
      while EMPRESA->( ! rlock() );end
      EMPRESA->( dbdelete() )
      menstime("Excluido.",1)
   end

end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_C
Objetivo     : Consultar empresa
-----------------------------------------------------------------------------
*/
procedure T_C()

tela0210()
show0210()
menswait("Tecle <ENTER>.")

return

/*
-----------------------------------------------------------------------------
Procedimento : T_B
Objetivo     : Buscar empresa
-----------------------------------------------------------------------------
*/
procedure T_B()
local WSCR := savescreen(10,10,13,65), W_OLDCOR := setcolor()

setcolor(W_CORWG)
@ 10,10 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 11,10 say '³ Empresa :                                           ³'
@ 12,10 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
sombra(10,10,12,64)
X_EMPBUSCA := space(40)
@ 11,22 get X_EMPBUSCA picture "@!S30"
read

if lastkey() != K_ESC
   EMPRESA->( dbsetorder(2) )        // razao social
   X_EMPBUSCA := alltrim(X_EMPBUSCA)
   EMPRESA->( dbseek( X_EMPBUSCA))  //

   if EMPRESA->( ! found() )
      menstime("Empresa nao encontrada. <ENTER>",3)
   end

   EMPRESA->( dbsetorder(1) )
end
restscreen(10,10,13,65,WSCR)
setcolor(W_OLDCOR)

return

/*
-------------------------------------------------------------------------------
Procedimento .: TELA0210
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tela0210()

   setcolor( W_COREDIT )
   @ 05,02 say '³'
   @ 05,77 say '³'
   setcolor( W_CORGET )
   @ 04,03 say ' Empresa .....:                             Total Funcionarios :          '
   @ 05,03 say ' Razao Social :                                                           '
   @ 06,03 say '                                                                          '
   @ 07,03 say ' Endereco ....:                                           CEP :           '
   @ 08,03 say '                                                                          '
   @ 09,03 say ' Bairro ......:                      Cidade .:                            '
   @ 10,03 say '                                                                          '
   @ 11,03 say ' Estado ......:                      Tel ....: (    )    -     R.         '
   @ 12,03 say '                                                                          '
   @ 13,03 say ' Ativ. Princip:                      CEI ? ..:   (S/N)                    '
   @ 14,03 say '                                                                          '
   @ 15,03 say ' CGC .........:                                                           '

return

/*
-------------------------------------------------------------------------------
Procedimento .: TEDIT0210
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tedit0210()
   local W_OLDCOR := setcolor()

   setcolor(W_COREDIT)
   quadro(03,02,21,77," Cadastro de Empresas ")
   @ 05,02 say 'Æ'
   @ 05,77 say 'µ'
   @ 16,03 to 16,76 double
   @ 16,02 say 'Æ'
   @ 16,77 say 'µ'
   sombra(02,02,21,77)

   cria_but( 17,07,' Incluir '   ,17,08,"I" )
   cria_but( 17,18,' Alterar '   ,17,19,"A" )
   cria_but( 17,29,' Excluir '   ,17,30,"E" )
   cria_but( 17,40,' Consultar ' ,17,41,"C" )
   cria_but( 17,53,' Buscar '    ,17,54,"B" )
   cria_but( 17,63,' Retornar '  ,17,64,"R" )

   setcolor( W_OLDCOR )
return

/*
-------------------------------------------------------------------------------
Procedimento .: GET0210
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
function get0210()
   local WRET := .T.
   setcolor( W_CORGET )

   @ 05,19 get X_RAZSOC    picture "@!" valid ! empty( X_RAZSOC )
   @ 07,19 get X_ENDERECO  picture "@!" valid ! empty( X_ENDERECO )
   @ 07,67 get X_CEP       picture "@R 99999-999"
   @ 09,19 get X_BAIRRO    picture "@!"
   @ 09,50 get X_CIDADE    picture "@!"
   @ 11,19 get X_ESTADO    picture "@!"
   @ 11,51 get X_DDD       picture "9999"
   @ 11,57 get X_TELEFONE  picture "@R 999-9999"
   @ 11,69 get X_RAMAL     picture "@!"
   @ 13,19 get X_ATVPRI    picture "@!"  valid ! empty( X_ATVPRI )
   @ 13,50 get X_CEI       picture "!"   valid X_CEI $ "SN"

   @ 15,19 get   X_CGC            ;
           pict  "99999999999999" ;
           valid TT_Val_CGC_CPF(X_CGC) .and. IF(X_CEI="N",TT_CGCCPF(X_CGC),.T.)

   read
   if lastkey() = K_ESC
      WRET := .F.
   end

return WRET

/*
-------------------------------------------------------------------------------
Procedimento .: SHOW0210
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure show0210()
   local W_OLDCOR := setcolor()

   setcolor( W_CORSHOW )
   @ 04,68 say EMPRESA->QTDFUN    picture "9999"
   @ 04,19 say EMPRESA->CODEMP    picture "@!"
   @ 05,19 say EMPRESA->RAZSOC    picture "@!"
   @ 07,19 say EMPRESA->ENDERECO  picture "@!"
   @ 07,67 say EMPRESA->CEP       picture "@R 99999-999"
   @ 09,19 say EMPRESA->BAIRRO    picture "@!"
   @ 09,50 say EMPRESA->CIDADE    picture "@!"
   @ 11,19 say EMPRESA->ESTADO    picture "@!"
   @ 11,51 say EMPRESA->DDD       picture "9999"
   @ 11,57 say EMPRESA->TELEFONE  picture "@R 999-9999"
   @ 11,69 say EMPRESA->RAMAL     picture "@!"
   @ 13,19 say EMPRESA->ATVPRI    picture "@!"
   @ 13,50 say EMPRESA->CEI       picture "@!"
   @ 15,19 say EMPRESA->CGC       picture "@!"
   setcolor( W_OLDCOR )

return

/*
-------------------------------------------------------------------------------
Procedimento .: ATRIB0210
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure atrib0210()

   X_RAZSOC    := EMPRESA->RAZSOC
   X_ENDERECO  := EMPRESA->ENDERECO
   X_CEP       := EMPRESA->CEP
   X_BAIRRO    := EMPRESA->BAIRRO
   X_CIDADE    := EMPRESA->CIDADE
   X_ESTADO    := EMPRESA->ESTADO
   X_DDD       := EMPRESA->DDD
   X_TELEFONE  := EMPRESA->TELEFONE
   X_RAMAL     := EMPRESA->RAMAL
   X_ATVPRI    := EMPRESA->ATVPRI
   X_CEI       := EMPRESA->CEI
   X_CGC       := EMPRESA->CGC

return

/*
-------------------------------------------------------------------------------
Procedimento .: ZERA0210
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure zera0210()

   X_RAZSOC    :=  space(40)
   X_ENDERECO  :=  space(40)
   X_CEP       :=  space(08)
   X_BAIRRO    :=  space(20)
   X_CIDADE    :=  space(20)
   X_ESTADO    :=  space(02)
   X_DDD       :=  space(04)
   X_TELEFONE  :=  space(07)
   X_RAMAL     :=  space(04)
   X_ATVPRI    :=  space(04)
   X_CEI       :=  space(01)
   X_CGC       :=  space(14)

return

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0210
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0210( MODO )

   if MODO = "A"
      while EMPRESA->( ! rlock() ); end
   else
      EMPRESA->( dbappend() )
   end

   EMPRESA->CODEMP  := X_CODEMP
   EMPRESA->RAZSOC  := X_RAZSOC
   EMPRESA->ENDERECO:= X_ENDERECO
   EMPRESA->CEP     := X_CEP
   EMPRESA->CIDADE  := X_CIDADE
   EMPRESA->BAIRRO  := X_BAIRRO
   EMPRESA->ESTADO  := X_ESTADO
   EMPRESA->DDD     := X_DDD
   EMPRESA->TELEFONE:= X_TELEFONE
   EMPRESA->RAMAL   := X_RAMAL
   EMPRESA->ATVPRI  := X_ATVPRI
   EMPRESA->CEI     := X_CEI
   EMPRESA->CGC     := X_CGC
   EMPRESA->QTDFUN  := X_QTDFUN
   EMPRESA->( dbunlock())

return

