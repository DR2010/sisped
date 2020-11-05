/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0211  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
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

/*
-----------------------------------------------------------------------------
Procedimento : EDIT_PEDIDO
Objetivo     : Controlar o dbedit modulo 0211, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function EDIT_PEDIDO( P_MODO )
   local WRET:=.T.
   private W_SCR210 := savescreen()
   private W_CAM211 := { "space(8)+'('+eval( MEIO )+') - ('+PEDITEM->CODTAR+' - '+"+;
                         "transform(TARIFA->VALTAR,'999,999.99')+ ') - ('+"+;
                         "eval( ORIDEST )+' )'+space(8)" }

   private W_HEA211 := { space(8)+" Transporte    Tarifa                Origem  ->  Destino"}

   // Tabela - Meio de transporte
   VET_MEIO := { { "O", " Onibus " } ,;
                 { "M", " Metro  " } ,;
                 { "T", " Trem   " } ,;
                 { "B", " Barca  " } ,;
                 { " ", "        " } }

   MEIO := {|| VET_MEIO[ ascan(VET_MEIO, {|Busca| Busca[1] == PEDITEM->TRANSP }) ,2 ] }

   // Mostra a Origem->Destino do item

   VET_DEST := { { "R", " Residencia->Trabalho " } ,;
                 { "T", " Trabalho->Residencia " } ,;
                 { " ", "                      " } }

   ORIDEST := {|| VET_DEST[ ascan(VET_DEST, {|Busca| Busca[1] == PEDITEM->MODO }) ,2 ] }


   if P_MODO = NIL; P_MODO := "Edit"; end

   if P_MODO = "Edit"
      limpa_but()
      setcolor(W_COREDIT)

      cria_but( 17,07,' Incluir '  ,17,08,"I" )
      cria_but( 17,18,' Alterar '  ,17,19,"A" )
      cria_but( 17,29,' Excluir '  ,17,30,"E" )
      cria_but( 17,63,' Retornar ' ,17,64,"R" )
   else
      keyboard chr(27)
   end


   PEDITEM->( dbsetorder(1))
   PEDITEM->( dbsetfilter( {|| PEDITEM->CODEMP+PEDITEM->MATRICULA =;
                               X_CODEMP+X_MATRICULA } ))
   PEDITEM->( dbsetrelation( "TARIFA", {|| PEDITEM->CODTAR }))
   PEDITEM->( dbgotop() )

   if P_MODO = "Edit"
      PEDITEM->( dbedit( 08, 03, 15, 76, W_CAM211, "DB_0211",, W_HEA211))
   else
      PEDITEM->( dbedit( 08, 03, 15, 76, W_CAM211,,, W_HEA211))
   end

   PEDITEM->( dbclearfilter())
   PEDITEM->( dbclearrelation())

return WRET

/*
-----------------------------------------------------------------------------
Procedimento : DB_0211
Objetivo     : Controlar o dbedit modulo 0211, Cadastro de RODOVIARIOs
-----------------------------------------------------------------------------
*/
function DB_0211( MODO, COLUNA )
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
      push_but( 17,07,' Incluir '   )
      T_INC211()

   case TECLA = "R"
      push_but( 17,63,' Retornar '  )
      WRETMAIN := 0

   case ! ( PEDITEM->( eof() ) .OR. PEDITEM->( bof() ) )
      do case
        case TECLA = "A"
           push_but( 17,18,' Alterar '   )
           T_ALT211()
        case TECLA = "E"
           push_but( 17,29,' Excluir '   )
           T_EXC211()
      endcase
endcase

setcursor(0)
restscreen(,,,,W_SCRD)
setcolor(W_COROLD)

return WRETMAIN

/*
-----------------------------------------------------------------------------
Procedimento : T_INC211
Objetivo     : Incluir item de pedido
-----------------------------------------------------------------------------
*/
procedure T_INC211()
   private X_TRANSP:="O", X_CODTAR:=space(3), X_MODO:=space(1)
   private W_OLDSCR := savescreen(08,16,14,66), W_OLDCOR := setcolor()

   setcolor(W_CORGET)
   zera0211() // zerando variaveis

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
   @ 11,31 get X_MODO   picture "!"  valid busca_sentido(X_MODO,11,35)
   read

   if lastkey()#K_ESC
      grava0211("I")
   end

   restscreen(08,16,14,66,W_OLDSCR)
   setcolor(W_OLDCOR)
return

/*
-----------------------------------------------------------------------------
Procedimento : T_ALT211
Objetivo     : Alterar PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_ALT211()

   private W_OLDSCR := savescreen(08,16,14,66), W_OLDCOR := setcolor()
   private X_TRANSP, X_CODTAR, X_MODO

   zera0211()
   atrib0211() // atribui dados da base de dados

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
   @ 11,31 get X_MODO   picture "!" valid busca_sentido(X_MODO,11,35)
   read

   if lastkey()#K_ESC
      grava0211("A")
   end

   restscreen(08,16,14,66,W_OLDSCR)
   setcolor(W_OLDCOR)

return

/*
-----------------------------------------------------------------------------
Procedimento : T_EXC211
Objetivo     : Excluir PEDIDO
-----------------------------------------------------------------------------
*/
procedure T_EXC211()

if pergunta("Confirma Exclusao (S/N) ?")
   while PEDITEM->( ! rlock() );end
   PEDITEM->( dbdelete() )
   menstime("Excluido.",1)
end
return

/*
-------------------------------------------------------------------------------
Procedimento .: ATRIB0211
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure atrib0211()

   X_TRANSP  :=  PEDITEM->TRANSP
   X_CODTAR  :=  PEDITEM->CODTAR
   X_MODO    :=  PEDITEM->MODO

return

/*
-------------------------------------------------------------------------------
Procedimento .: ZERA0211
Objetivo .....:
-------------------------------------------------------------------------------
*/
procedure zera0211()

   X_TRANSP    := "O"
   X_CODTAR    := "001"
   X_MODO      := " "

return

/*
-------------------------------------------------------------------------------
Procedimento .: GRAVA0211
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/
procedure grava0211( MODO )

   if MODO = "A"
      while PEDITEM->( ! rlock() ); end
   else
      PEDITEM->( dbappend() )
   end

   PEDITEM->CODEMP    := X_CODEMP
   PEDITEM->MATRICULA := X_MATRICULA
   PEDITEM->TRANSP    := X_TRANSP
   PEDITEM->CODTAR    := X_CODTAR
   PEDITEM->MODO      := X_MODO

return



