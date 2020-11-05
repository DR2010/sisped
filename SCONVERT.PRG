Cls
// Variaveis
Declare W_ARQOLD[4], W_ARQNEW[5]

W_OLDSIS := "C:\SISPED.OLD\                                         "
W_NEWSIS := "C:\SISPED\                                             "

@ 00,01 say 'Conversao SISPED 1.xx para 2.0'
@ 01,01 say 'Sistema antigo => (Drive:Diretorio) :' get W_OLDSIS
@ 02,01 say 'Sistema novo   => (Drive:Diretorio) :' get W_NEWSIS
read

if lastkey()=27; break; end

W_OLDSIS := alltrim( W_OLDSIS)
W_NEWSIS := alltrim( W_NEWSIS)

W_OLDEMP := W_OLDSIS + "ARQEMPSA.DBF"
W_OLDFUN := W_OLDSIS + "ARQFUNC.DBF"
W_OLDPED := W_OLDSIS + "PEDVALE.DBF"
W_OLDTAR := W_OLDSIS + "TARGER.DBF"

W_NEWEMP := W_NEWSIS + "EMPRESAS.DBF"
W_NEWFUN := W_NEWSIS + "FUNCIONA.DBF"
W_NEWPED := W_NEWSIS + "PEDIDO.DBF"
W_NEWPDI := W_NEWSIS + "PEDITENS.DBF"
W_NEWTAR := W_NEWSIS + "TARIFA.DBF"

cls
@ 01,01 Say 'Conversao de dados SISPED 2.2'
@ 03,01 say 'Aguarde... analisando bases antigas...'

//-------------------------------------------------------------------------//
//                                                                         //
//                                                                         //
//                              Empresas                                   //
//                                                                         //
//                                                                         //
//-------------------------------------------------------------------------//

@ 04,01 say 'Convertendo Empresas ...'
use &W_OLDEMP alias OLDEMP new
OLDEMP->( dbgotop() )

use &W_NEWEMP alias NEWEMP new
NEWEMP->( __dbzap() )

// Le e Grava dados da empresa antigos do sistema novo
while OLDEMP->( ! eof() )

   NEWEMP->( dbappend() )

   NEWEMP->CODEMP   :=       OLDEMP->CODEMP  // C- 3 => C- 2     dif -1
   NEWEMP->RAZSOC   :=       OLDEMP->RAZSOC  // C-40 => C-40
   NEWEMP->ENDERECO :=       OLDEMP->ENDEMP  // C-40 => C-40
   NEWEMP->CEP      :=       OLDEMP->CEPEMP  // C- 8 => C- 5
   NEWEMP->BAIRRO   :=       OLDEMP->BAIEMP  // C-20 => C-20
   NEWEMP->CIDADE   :=       OLDEMP->CIDEMP  // C-20 => C-20
   NEWEMP->ESTADO   :=       OLDEMP->UFEMP   // C- 2 => C- 2
   NEWEMP->DDD      := left(  OLDEMP->TELEMP, 4 )
   NEWEMP->TELEFONE := right( OLDEMP->TELEMP, 7 )
   NEWEMP->RAMAL    :=       OLDEMP->RAMALEMP // C- 4 => C- 4
   NEWEMP->ATVPRI   :=       OLDEMP->ATVPRIN  // C- 4 => C- 4
   NEWEMP->CGC      :=       OLDEMP->CGCEMP   // C-14 => C-14
   NEWEMP->QTDFUN   :=       OLDEMP->QUANTFUN // N- 4 => N- 5

   OLDEMP->( dbskip() )

end

dbcloseall()

//-------------------------------------------------------------------------//
//                                                                         //
//                                                                         //
//                              Tarifas                                    //
//                                                                         //
//                                                                         //
//-------------------------------------------------------------------------//

@ 06,01 say 'Convertendo Tarifas ...'
use &W_OLDTAR alias OLDTAR new
OLDTAR->( dbgotop() )

use &W_NEWTAR alias NEWTAR new
NEWTAR->( __dbzap() )

// Le e Grava dados de tarifas antigos para o sistema novo
while OLDTAR->( ! eof() )

   NEWTAR->( dbappend() )

   NEWTAR->CODTAR := OLDTAR->CODTAR
   NEWTAR->VALTAR := OLDTAR->VALTAR

   OLDTAR->( dbskip() )

end

dbcloseall()

//-------------------------------------------------------------------------//
//                                                                         //
//                                                                         //
//                             Funcionarios                                //
//                                                                         //
//                                                                         //
//-------------------------------------------------------------------------//

@ 08,01 say 'Convertendo Funcionarios ...'

// Funcionarios
use &W_OLDFUN alias OLDFUN new
OLDFUN->( dbgotop() )

use &W_NEWFUN alias NEWFUN new
NEWFUN->( __dbzap() )

// Le e Grava dados dos funcionarios antigos no sistema novo
// Controla sistema 1.6 em diante
W_VARIA := if( len( OLDFUN->MATFUNC )=10, 8, 6 )

while OLDFUN->( ! eof() )

   NEWFUN->( dbappend() )

   NEWFUN->CODEMP    :=  OLDFUN->CODEMP
   NEWFUN->MATRICULA :=  right( OLDFUN->MATFUNC, W_VARIA )
   NEWFUN->NOME      := OLDFUN->NOMEFUNC
   NEWFUN->ENDERECO  := OLDFUN->ENDEFUNC
   NEWFUN->CEP       := OLDFUN->CEPFUNC
   NEWFUN->MUNICIPIO := OLDFUN->MUNFUNC
   NEWFUN->BAIRRO    := OLDFUN->BAIFUNC
   NEWFUN->DDD       := left( OLDFUN->TELFUNC, 4 )
   NEWFUN->TELEFONE  := right( OLDFUN->TELFUNC, 7 )
   NEWFUN->SETOR     := OLDFUN->SETOR

   OLDFUN->( dbskip() )

end

dbcloseall()

//-------------------------------------------------------------------------//
//                                                                         //
//                                                                         //
//                               Pedido                                    //
//                                                                         //
//                                                                         //
//-------------------------------------------------------------------------//

@ 10,01 say 'Convertendo Pedidos ...'

// Pedido
use &W_OLDPED
Index on CODEMP+MATFUNC to PEDIDO
Dbcloseall()
use &W_OLDPED index PEDIDO alias OLDPED new
OLDPED->( dbgotop() )

// Novo pedido
use &W_NEWPED alias NEWPED new
NEWPED->( __dbzap() )

// Item de Pedido
use &W_NEWPDI alias NEWPDI new
NEWPDI->( __dbzap() )

// Le e Grava dados dos pedidos antigos no sistema novo
while OLDPED->( ! eof() )

   DUPLIC_PED()  // Verifica duplicidade no arquivo de PEDVALE.DBF

   NEWPED->( dbappend() )

   NEWPED->CODEMP    :=  OLDPED->CODEMP
   NEWPED->MATRICULA :=  right( OLDPED->MATFUNC, W_VARIA )
   NEWPED->USAPADRAO  :=  'S'

   for X:=1 to 16
      W_TRANSP := "OLDPED->TRANSP"+ alltrim( str( X ) )
      W_TIPO   := "OLDPED->TIPO"  + alltrim( str( X ) )
      W_CODTAR := "OLDPED->CODTAR"+ alltrim( str( X ) )
      C_CODTAR := &W_CODTAR

      if empty( C_CODTAR ); exit; end

      NEWPDI->( dbappend() )
      NEWPDI->CODEMP    := OLDPED->CODEMP
      NEWPDI->MATRICULA :=  right( OLDPED->MATFUNC, W_VARIA )
      NEWPDI->TRANSP    := &W_TRANSP
      NEWPDI->CODTAR    := &W_CODTAR
      NEWPDI->MODO      := if( X/2=int(X/2), "T", "R" )

   next
   OLDPED->( dbskip() )
end
dbcloseall()
@ 12,01 say 'Conversao bem sucedida.'



//-------------------------------------------------------------------------//
// DUPLIC_PED() - Verifica duplicidade de pedidos no arquivo PEDVALE.DBF   //
//-------------------------------------------------------------------------//
Function DUPLIC_PED()

Local CHAVE := OLDPED->CODEMP + OLDPED->MATFUNC

OLDPED->( Dbskip() )
Do While ! OLDPED->( Eof() ) .and. ;
           CHAVE == OLDPED->CODEMP + OLDPED->MATFUNC
   OLDPED->( Dbskip() )
Enddo

OLDPED->( Dbskip(-1) )

Return( Nil )
