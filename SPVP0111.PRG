/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0111  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |									      |
  | Sistema:								      |
  |---------------------------------------------------------------------------|
  | Descricao..: Cadastro de pedidos.					      |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED 		    | Ultima Alteracao		      |
  | Analista...: Daniel Machado 	    | Autor : Daniel Machado	      |
  | Programador: Daniel Machado 	    | Dt/Hr : 13/10/94 - 11:30	      |
  | Inicio.....: 21/10/1994		    | Motivo: Inicio.		      |
  |					    |				      |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"
#include "sic.ch"
local getlist:={}

/*
-----------------------------------------------------------------------------
Procedimento : EDIT_PEDIDO
Objetivo     : Controlar o dbedit modulo 0111, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function EDIT_PEDIDO( P_MODO )
   local WRET:=.T. , WTEC:=.F.
   private W_SCR210 := savescreen()
   private W_CAM111 := { "space(8)+'('+eval( MEIO )+') - ('+PEDITEM->CODTAR+' - '+"+;
			 "transform(TARIFA->VALTAR,'999,999.99')+ ') - ('+"+;
			 "eval( ORIDEST )+' )'+space(8)" }

   private W_HEA111 := { space(8)+" Transporte    Tarifa                Origem  ->  Destino"}

   // Tabela - Meio de transporte
   VET_MEIO := { { "O", " Onibus " } ,;
		 { "M", " Metro  " } ,;
		 { "T", " Trem   " } ,;
		 { "B", " Barca  " } ,;
		 { " ", "        " } }

   MEIO  := {|| VET_MEIO[ ascan(VET_MEIO, {|Busca| Busca[1] == PEDITEM->TRANSP }) ,2 ] }
   VMEIO := {|| VET_MEIO[ ascan(VET_MEIO, {|Busca| Busca[1] == X_TRANSP }) ,2 ] }

   // Mostra a Origem->Destino do item

   VET_DEST := { { "R", " Residencia->Trabalho " } ,;
		 { "T", " Trabalho->Residencia " } ,;
		 { " ", "                      " } }

   ORIDEST := {|| VET_DEST[ ascan(VET_DEST, {|Busca| Busca[1] == PEDITEM->MODO }) ,2 ] }
   VORIDEST := {|| VET_DEST[ ascan(VET_DEST, {|Busca| Busca[1] == X_MODO }) ,2 ] }

   if P_MODO = NIL; P_MODO := "Edit"; end

   // Modo Show ou Edit

   if P_MODO = "Edit"
      limpa_but()
      setcolor(W_COREDIT)

      cria_but( 17,07,' Incluir '  ,17,08,"I" )
      cria_but( 17,18,' Alterar '  ,17,19,"A" )
      cria_but( 17,29,' Excluir '  ,17,30,"E" )
      cria_but( 17,63,' Retornar ' ,17,64,"R" )
   else
      // Show
      keyboard chr(27)
   end

   PEDITEM->( dbsetorder(1))
   PEDITEM->( dbsetrelation( "TARIFA", {|| PEDITEM->CODTAR }))

   private V_REG,V_TRANSP:={}, V_CODTAR:={}, V_MODO:={},V_VALTAR:={},;
           V_ITENS:={}, V_CODEMP:={}, V_MATRICULA:={}

   while .t.

      PEDITEM->( dbseek( X_CODEMP+X_MATRICULA ) )

      V_REG:={}
      V_TRANSP:={}
      V_CODTAR:={}
      V_MODO:={}
      V_VALTAR:={}
      V_ITENS:={}
      V_CODEMP:={}
      V_MATRICULA:={}

      //  Iniciando testes...
      while PEDITEM->CODEMP+PEDITEM->MATRICULA =X_CODEMP+X_MATRICULA .and.;
                                                PEDITEM->( ! eof() )

         TARIFA->( dbseek( PEDITEM->CODTAR ) )
         aadd( V_REG,       PEDITEM->(recno()) )
         aadd( V_CODEMP,    PEDITEM->CODEMP    )
         aadd( V_MATRICULA, PEDITEM->MATRICULA )
         aadd( V_TRANSP,    PEDITEM->TRANSP    )
         aadd( V_CODTAR,    PEDITEM->CODTAR    )
         aadd( V_MODO,      PEDITEM->MODO      )
         aadd( V_VALTAR,    TARIFA->VALTAR     )

         aadd( V_ITENS, space(8)+'('+eval( MEIO )+') - ('+PEDITEM->CODTAR+' - '+;
                        transform(TARIFA->VALTAR,'999,999.99')+ ') - ('+;
                        eval( ORIDEST )+' )'+space(8) )

         PEDITEM->( dbskip() )
      end

      if empty( V_ITENS )

         if T_INC111()
            loop
         else
            WRET := .F.
            exit
         end
      endif

      @ 08, 03 clear to 15, 76
      WAC := achoice( 08, 03, 15, 76, V_ITENS,, "DB_0111" )
      if WAC = 0; exit; end

   end

   PEDITEM->( dbclearfilter())
   PEDITEM->( dbclearrelation())

return WRET

/*
-----------------------------------------------------------------------------
Procedimento : DB_0111
Objetivo     : Controlar o dbedit modulo 0111, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0111( MODO, LINHA, TESTE )
private WRETMAIN :=2, W_SCRD:=savescreen(), W_COROLD := setcolor()
private REGATUAL := LINHA
REGATUAL := if(REGATUAL=0,1,REGATUAL)

TECLA := upper( chr( lastkey()))

setcursor(1)
setcolor(W_CORGET)

do case
   case lastkey() = K_ESC
      WRETMAIN := 0

   case TECLA = "I"
      push_but( 17,07,' Incluir '   )
      T_INC111()
      WRETMAIN := 1

   case ! empty( V_ITENS[REGATUAL] )
      do case
         case TECLA = "R"
            push_but( 17,63,' Retornar '  )
            WRETMAIN := 0
	case TECLA = "A"
	   push_but( 17,18,' Alterar '   )
	   T_ALT111()
	case TECLA = "E"
	   push_but( 17,29,' Excluir '   )
           T_EXC111()
           cria_but( 17,29,' Excluir '  ,17,30,"E" )
           W_SCRD:=savescreen()
           WRETMAIN := 1
      endcase

endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_INC111
Objetivo     : Incluir item de pedido
-----------------------------------------------------------------------------
*/
function T_INC111()
   private WINCRET := .F.
   private X_TRANSP:="O", X_CODTAR:=space(3), X_MODO:=space(1)
   private W_OLDSCR := savescreen(08,16,14,66), W_OLDCOR := setcolor()

   setcolor(W_CORGET)
   zera0111() // zerando variaveis

   setcolor(W_CORWG)
   @ 08,16 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 09,16 say '³ Transporte.:                                   ³'
   @ 10,16 say '³ Tarifa ....:                                   ³'
   @ 11,16 say '³ Sentido ...:                                   ³'
   @ 12,16 say '³ Valor .....:                                   ³'
   @ 13,16 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,16,13,65)

   @ 09,31 get X_TRANSP picture "!"  valid busca_transp(X_TRANSP,09,35)
   @ 10,31 get X_CODTAR picture "@!" valid busca_tarifa(X_CODTAR,12,31)
   @ 11,31 get X_MODO	picture "!"  valid busca_sentido(X_MODO,11,35)
   read

   if lastkey()#K_ESC
      WINCRET := .T.
      grava0111("I")
   end

   restscreen(08,16,14,66,W_OLDSCR)
   setcolor(W_OLDCOR)
return WINCRET

/*
-----------------------------------------------------------------------------
Procedimento : T_ALT111
Objetivo     : Alterar PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_ALT111()

   private W_OLDSCR := savescreen(08,16,14,66), W_OLDCOR := setcolor()
   private X_TRANSP, X_CODTAR, X_MODO

   zera0111()
   atrib0111() // atribui dados da base de dados

   setcolor(W_CORWG)
   @ 08,16 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 09,16 say '³ Transporte.:                                   ³'
   @ 10,16 say '³ Tarifa ....:                                   ³'
   @ 11,16 say '³ Sentido ...:                                   ³'
   @ 12,16 say '³ Valor .....:                                   ³'
   @ 13,16 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,16,13,65)

   busca_transp(X_TRANSP,09,35)
   busca_tarifa(X_CODTAR,12,31)
   busca_sentido(X_MODO,11,35)
   @ 09,31 get X_TRANSP picture "!" valid busca_transp(X_TRANSP,09,35)
   @ 10,31 get X_CODTAR picture "@!" valid busca_tarifa(X_CODTAR,12,31)
   @ 11,31 get X_MODO	picture "!" valid busca_sentido(X_MODO,11,35)
   read

   if lastkey()#K_ESC
      grava0111("A")
   end

   restscreen(08,16,14,66,W_OLDSCR)
   setcolor(W_OLDCOR)

return

/*
-----------------------------------------------------------------------------
Procedimento : T_EXC111
Objetivo     : Excluir PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_EXC111()

if len(V_ITENS) == 1
   menswait("N„o pode excluir o £nico item do pedido. Excluir o pedido!")
   mensagem("Selecione um dos itens do menu ou <ESC> para abandonar.")
else
   if pergunta("Confirma Exclusao (S/N) ?")
      PEDITEM->( dbgoto( V_REG[REGATUAL] ))
      while PEDITEM->( ! rlock() );end
      PEDITEM->( dbdelete() )
      menstime("Exclu¡do.",1)
   end
endif
return

/*
-------------------------------------------------------------------------------
Procedimento .: ATRIB0111
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure atrib0111()

   X_TRANSP  :=  V_TRANSP[ REGATUAL ]
   X_CODTAR  :=  V_CODTAR[ REGATUAL ]
   X_MODO    :=  V_MODO[ REGATUAL ]

return

/*
-------------------------------------------------------------------------------
Procedimento .: ZERA0111
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure zera0111()

   X_TRANSP    := "O"
   X_CODTAR    := "   "
   X_MODO      := " "

return

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0111
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0111( MODO )

   TARIFA->( dbseek( X_CODTAR ))

   if MODO = "A"

      // atualiza vetor
      V_CODEMP[REGATUAL]    := X_CODEMP
      V_MATRICULA[REGATUAL] := X_MATRICULA
      V_TRANSP[REGATUAL]    := X_TRANSP
      V_CODTAR[REGATUAL]    := X_CODTAR
      V_MODO[REGATUAL]      := X_MODO

      V_ITENS[REGATUAL] := space(8)+'('+eval( VMEIO )+') - ('+X_CODTAR+' - '+;
                     transform(TARIFA->VALTAR,'999,999.99')+ ') - ('+;
                     eval( VORIDEST )+' )'+space(8)

      PEDITEM->( dbgoto( V_REG[REGATUAL] ))
      while PEDITEM->( ! rlock() ); end
   else

      PEDITEM->( dbappend() )
   end

   PEDITEM->CODEMP    := X_CODEMP
   PEDITEM->MATRICULA := X_MATRICULA
   PEDITEM->TRANSP    := X_TRANSP
   PEDITEM->CODTAR    := X_CODTAR
   PEDITEM->MODO      := X_MODO
   PEDITEM->( dbcommit() )

   PEDITEM->( dbunlock() )
   keyboard chr(K_RIGHT)

return
