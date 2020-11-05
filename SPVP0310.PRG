/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0310  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Cadastro de funcionarios.                                    |
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

private X_CODEMP    :=   space(03) ,;
        X_MATRICULA :=   space(08) ,;
        X_NOME      :=   space(25) ,;
        X_ENDERECO  :=   space(30) ,;
        X_CEP       :=   space(08) ,;
        X_MUNICIPIO :=   space(15) ,;
        X_BAIRRO    :=   space(15) ,;
        X_DDD       :=   space(04) ,;
        X_TELEFONE  :=   space(07) ,;
        X_SETOR     :=   space(03)

setcolor( W_PDCOR )
@ 08,00 clear to 20,79

private W_CAMPOS := { "' '+FUNCIONARIO->CODEMP+space(10)+FUNCIONARIO->MATRICULA+"+;
                      "space(6)+FUNCIONARIO->NOME+space(20)" }
        W_HEADER := { " Empresa      Matricula     Nome" }

mensagem("Selecione um dos itens do menu ou <ESC> para abandonar.")

abrir("EMPRESA")
abrir("FUNCIONARIO")
abrir("PEDIDO")
abrir("PEDITEM")

W_COR0310 := setcolor()
while .t.
   setcolor( W_COREDIT )
   tedit0310() // Tela para dbedit
   FUNCIONARIO->( dbedit( 04, 03, 15, 76, W_CAMPOS, "DB_0310",, W_HEADER ) )
   exit
end
dbcloseall()
setcolor( W_COR0310 )
return

/*
-----------------------------------------------------------------------------
Procedimento : DB_0310
Objetivo     : Controlar o dbedit modulo 0310, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0310( MODO, COLUNA )
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
      T_INC310()
   case TECLA = "R"
      push_but(17,63,' Retornar ')
      WRETMAIN := 0
   case ! ( FUNCIONARIO->( eof() ) .OR. FUNCIONARIO->( bof() ) )
      do case
        case TECLA = "E"
           push_but(17,29," Excluir ")
           T_EXC310()
        case TECLA = "A"
           push_but(17,18," Alterar ")
           T_ALT310()
        case TECLA = "C"
           push_but(17,40," Consultar ")
           T_CON310()
        case TECLA = "B"
           push_but(17,53," Buscar ")
           T_BUS310()
      endcase
endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_INC310
Objetivo     : Incluir funcionario
-----------------------------------------------------------------------------
*/
procedure T_INC310()

   while .t.
      tela0310()
      zera0310()
      @ 04,19 get X_CODEMP picture "@!" valid busca_empresa(X_CODEMP,04,23)
      read
      if lastkey()=K_ESC; exit; end

      EMPRESA->( dbsetorder(1)) // codemp
      EMPRESA->( dbseek( X_CODEMP ))

      if EMPRESA->( ! found())
         menswait("Empresa nao cadastrada.")
         loop
      end

      @ 05,19 get X_MATRICULA picture "@!" valid ! empty( X_MATRICULA )
      read
      if lastkey()=K_ESC; loop; end

      FUNCIONARIO->( dbsetorder(1)) // empresa+matricula
      FUNCIONARIO->( dbseek( X_CODEMP+X_MATRICULA ))
      if FUNCIONARIO->( found())
         show0310()
         menswait("Funcionario ja cadastrado. <ENTER>")
         loop
      end

      if get0310()
         grava0310("I")
         menstime("Incluido. <ENTER>",1)
      end
   end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_ALT310
Objetivo     : Alterar funcionario
-----------------------------------------------------------------------------
*/
procedure T_ALT310()

while .t.
   tela0310()

   X_CODEMP    := FUNCIONARIO->CODEMP
   X_MATRICULA := FUNCIONARIO->MATRICULA

   @ 04,19 say X_CODEMP     picture "@!"
   @ 05,19 say X_MATRICULA  picture "@!"

   show0310()
   atrib0310() // atribui dados da base de dados

   if get0310()
      grava0310("A")
      menstime("Alterado. <ENTER>",1)
      exit
   else
      exit
   end
end
return

/*
-----------------------------------------------------------------------------
Procedimento : T_EXC310
Objetivo     : Excluir funcionario
-----------------------------------------------------------------------------
*/
procedure T_EXC310()

tela0310()
show0310()

if pergunta("Confirma Exclusao (S/N) ?")

   // Exclui Itens de Pedido
   PEDITEM->( dbsetorder(1) )
   PEDITEM->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ))

   while PEDITEM->CODEMP+PEDITEM->MATRICULA =;
      FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA
      while PEDITEM->( ! rlock()); end
      PEDITEM->( dbdelete() )
      PEDITEM->( dbskip() )
   end

   // Exclui Pedido
   PEDIDO->( dbsetorder(1))
   PEDIDO->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ))
   while PEDIDO->( ! rlock() ); end
   PEDIDO->( dbdelete())
   PEDIDO->( dbskip())

   // atualiza quantidade de funcionarios
   EMPRESA->( dbsetorder(1))
   EMPRESA->( dbseek( FUNCIONARIO->CODEMP ))
   if EMPRESA->( found())
      while EMPRESA->( ! rlock() ); end
      EMPRESA->QTDFUN := ( EMPRESA->QTDFUN - 1 )
      if ( EMPRESA->QTDFUN < 0 )
         EMPRESA->QTDFUN := 0
      end
      EMPRESA->( dbunlock())
   end

   while FUNCIONARIO->( ! rlock() );end
   FUNCIONARIO->( dbdelete() )
   menstime("Excluido.",1)

end

return

/*
-----------------------------------------------------------------------------
Procedimento : T_CON310
Objetivo     : Consultar funcionario
-----------------------------------------------------------------------------
*/
procedure T_CON310()

tela0310()
show0310()
menswait("Tecle <ENTER>.")

return

/*
-----------------------------------------------------------------------------
Procedimento : T_BUS310
Objetivo     : Buscar empresa
-----------------------------------------------------------------------------
*/
procedure T_BUS310()
local WSCR := savescreen(10,10,14,65), W_OLDCOR := setcolor()

setcolor(W_CORWG)
@ 10,10 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ 11,10 say '³ Empresa   :                                         ³'
@ 12,10 say '³ Nome      :                                         ³'
@ 13,10 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
sombra(10,10,13,64)

begin sequence

   X_CODEMP := space(3)
   X_NOME   := space(25)
   @ 11,24 get X_CODEMP picture "@K@!" valid busca_empresa(X_CODEMP)
   @ 12,24 get X_NOME   picture "@S20@!"
   read
   if lastkey()=K_ESC; break; end

   X_NOME := alltrim( X_NOME )

   FUNCIONARIO->( dbsetorder(3))
   FUNCIONARIO->( dbseek( X_CODEMP+X_NOME ))
   if FUNCIONARIO->( ! found() )
      menswait("Funcionario nao cadastrado.")
      break
   end

end sequence

restscreen(10,10,13,65,WSCR)
setcolor(W_OLDCOR)

return
/*
-------------------------------------------------------------------------------
Procedimento .: TELA0310
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tela0310()

   setcolor( W_COREDIT )
   @ 05,02 say '³'
   @ 05,77 say '³'
   setcolor( W_CORGET )
   @ 04,03 say ' Empresa .....:                                                           '
   @ 05,03 say ' Matricula    :                                                           '
   @ 06,03 say '                                                                          '
   @ 07,03 say ' Nome ........:                                                           '
   @ 08,03 say '                                                                          '
   @ 09,03 say ' Endereco.....:                                           CEP :           '
   @ 10,03 say '                                                                          '
   @ 11,03 say ' Bairro ......:                      Cidade .:                            '
   @ 12,03 say '                                                                          '
   @ 13,03 say ' Setor .......:                      Tel ....: (    )    -                '
   @ 14,03 say '                                                                          '
   @ 15,03 say '                                                                          '

return

/*
-------------------------------------------------------------------------------
Procedimento .: TEDIT0310
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure tedit0310()
   local W_OLDCOR := setcolor()

   setcolor(W_COREDIT)
   quadro(03,02,21,77," Cadastro de Funcionarios ")
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
Procedimento .: GET0310
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
function get0310()
   local WRET := .T.
   setcolor( W_CORGET )

   @ 07,19 get X_NOME      picture "@!" valid ! empty( X_NOME )
   @ 09,19 get X_ENDERECO  picture "@!"
   @ 09,67 get X_CEP       picture "@R 99999-999"
   @ 11,19 get X_BAIRRO    picture "@!"
   @ 11,50 get X_MUNICIPIO picture "@!"
   @ 13,19 get X_SETOR     picture "@!" valid ! empty( X_SETOR )
   @ 13,51 get X_DDD       picture "9999"
   @ 13,57 get X_TELEFONE  picture "@R 999-9999"
   read

   if lastkey() = K_ESC; WRET := .F.; end

return WRET

/*
-------------------------------------------------------------------------------
Procedimento .: SHOW0310
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure show0310()
   local W_OLDCOR := setcolor()

   setcolor( W_CORSHOW )
   @ 04,19 say FUNCIONARIO->CODEMP    picture "@!"
   @ 05,19 say FUNCIONARIO->MATRICULA picture "@!"
   @ 07,19 say FUNCIONARIO->NOME      picture "@!"
   @ 09,19 say FUNCIONARIO->ENDERECO  picture "@!"
   @ 09,67 say FUNCIONARIO->CEP       picture "@R 99999-999"
   @ 11,19 say FUNCIONARIO->BAIRRO    picture "@!"
   @ 11,50 say FUNCIONARIO->MUNICIPIO picture "@!"
   @ 13,19 say FUNCIONARIO->SETOR     picture "@!"
   @ 13,51 say FUNCIONARIO->DDD       picture "9999"
   @ 13,57 say FUNCIONARIO->TELEFONE  picture "@R 999-9999"
   setcolor( W_OLDCOR )

return

/*
-------------------------------------------------------------------------------
Procedimento .: ATRIB0310
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure atrib0310()

  X_MATRICULA := FUNCIONARIO->MATRICULA
  X_NOME      := FUNCIONARIO->NOME
  X_ENDERECO  := FUNCIONARIO->ENDERECO
  X_CEP       := FUNCIONARIO->CEP
  X_MUNICIPIO := FUNCIONARIO->MUNICIPIO
  X_BAIRRO    := FUNCIONARIO->BAIRRO
  X_DDD       := FUNCIONARIO->DDD
  X_TELEFONE  := FUNCIONARIO->TELEFONE
  X_SETOR     := FUNCIONARIO->SETOR

return

/*
-------------------------------------------------------------------------------
Procedimento .: ZERA0310
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure zera0310()

   X_CODEMP    :=   space( 3)
   X_MATRICULA :=   space( 8)
   X_NOME      :=   space(25)
   X_ENDERECO  :=   space(30)
   X_CEP       :=   space( 8)
   X_MUNICIPIO :=   space(15)
   X_BAIRRO    :=   space(15)
   X_DDD       :=   space( 4)
   X_TELEFONE  :=   space( 7)
   X_SETOR     :=   space( 3)

return

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0310
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0310( MODO )

   if MODO = "A"
      while FUNCIONARIO->( ! rlock() ); end
   else
      FUNCIONARIO->( dbappend() )

      // atualiza quantidade de funcionarios no arquivo de empresas
      EMPRESA->( dbsetorder(1))
      EMPRESA->( dbseek( X_CODEMP ))
      if EMPRESA->( found())
         while EMPRESA->( ! rlock()); end
         EMPRESA->QTDFUN := EMPRESA->QTDFUN + 1
      end

   end

   FUNCIONARIO->CODEMP    := X_CODEMP
   FUNCIONARIO->MATRICULA := X_MATRICULA
   FUNCIONARIO->NOME      := X_NOME
   FUNCIONARIO->ENDERECO  := X_ENDERECO
   FUNCIONARIO->CEP       := X_CEP
   FUNCIONARIO->MUNICIPIO := X_MUNICIPIO
   FUNCIONARIO->BAIRRO    := X_BAIRRO
   FUNCIONARIO->DDD       := X_DDD
   FUNCIONARIO->TELEFONE  := X_TELEFONE
   FUNCIONARIO->SETOR     := X_SETOR


return

