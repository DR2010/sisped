/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0440  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Recibo de entrega de vale-transporte.                        |
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

local   getlist:={}, FEZ_IMP := .F.

private WRESP_IMPR := ""         ,;
        W_COR440   := setcolor()

// variaveis para controle de impressoes geradas para arquivo
private ARQ_GERADO := "Nao Gera Arquivo"
private W_TITULO   := 'Recibo de Entrega de Vale-Transporte'
private W_COMP_MES := Space(09)
private W_COMP_ANO := 0

   // Tabela - Meio de transporte
   VET_MEIO := { { "O", " Onibus " } ,;
		 { "M", " Metro  " } ,;
		 { "T", " Trem   " } ,;
		 { "B", " Barca  " } ,;
		 { " ", "        " } }

   MEIO  := {|| VET_MEIO[ ascan(VET_MEIO, {|Busca| Busca[1] == PEDITEM->TRANSP }) ,2 ] }

   // Mostra a Origem->Destino do item

   VET_DEST := { { "R", " Residencia->Trabalho " } ,;
		 { "T", " Trabalho->Residencia " } ,;
		 { " ", "                      " } }

   ORIDEST := {|| VET_DEST[ ascan(VET_DEST, {|Busca| Busca[1] == PEDITEM->MODO }) ,2 ] }

abrir("FUNCIONARIO")
abrir("PEDIDO")
abrir("PEDITEM")
abrir("EMPRESA")
abrir("PARAMETRO")
abrir("IMPRESSAO")
abrir("TARIFA")

begin sequence
   setcolor(W_CORWG)
   @ 08,11 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 09,11 say '³              Impressao de Recibos de Entrega              ³'
   @ 10,11 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ 11,11 say '³                                                           ³'
   @ 12,11 say '³ Empresa :                                                 ³'
   @ 13,11 say '³                                                           ³'
   @ 14,11 say '³ Nome ...:                                                 ³'
   @ 15,11 say '³                                                           ³'
   @ 16,11 say '³ Competencia  :          /                                 ³'
   @ 17,11 say '³                                                           ³'
   @ 18,11 say '³ Ordenado por :      1- Nome Funcionario                   ³'
   @ 19,11 say '³                     2- Setor + Nome                       ³'
   @ 20,11 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,11,20,71)

   X_CODEMP := space(03)
   X_NOME   := space(25)
   X_ORDEM  := 1

   W_COMP_ANO := Year(Date())

   @ 12,23 get X_CODEMP picture "@!" valid busca_empresa(X_CODEMP,12,27)
   @ 14,23 get X_NOME   picture "@!" when  !empty(X_CODEMP)
   read

   if (lastkey() = K_ESC) .or.(Empty(X_NOME) .and. !Val_Faixa())
      break
   end

   @ 16,28 get W_COMP_MES picture "@!"
   read

   if (lastkey() = K_ESC) .or.(Empty(W_COMP_MES) .and. !Val_Mes())
      break
   else
      @ 16,28 Say W_COMP_MES picture "@!"
   end

   @ 16,38 get W_COMP_ANO picture "9999" valid !Empty(W_COMP_ANO)
   @ 18,28 get X_ORDEM    picture "9"    valid X_ORDEM = 1 .or. X_ORDEM = 2
   read

   if lastkey() = K_ESC
      break
   end

   EMPRESA->( dbsetorder(1) )

   If X_ORDEM = 1
      FUNCIONARIO->( dbsetorder(3))  // codemp + nome
   Else
      FUNCIONARIO->( dbsetorder(4))  // codemp + setor + nome
   EndIf

   do case

    * Marcio ----------------------------------------------------------
    * case empty( X_CODEMP )
    *    BL_IMPFUN := {|| FUNCIONARIO->( ! eof() ) }
    *    BL_IMPEMP := {|| EMPRESA->( ! eof()) }
    *    EMPRESA->( dbgotop() )
    * -----------------------------------------------------------------

      case ! empty( X_CODEMP ) .and. empty( X_NOME )

         BL_IMPEMP := {|| EMPRESA->CODEMP=X_CODEMP }

         EMPRESA->( dbseek(X_CODEMP) )
         if EMPRESA->( ! found())
            menstime("Empresa Nao Cadastrada.",2)
            break
         end

         IF X_ORDEM == 1 // codemp + nome

            BL_IMPFUN := {|| FUNCIONARIO->CODEMP       == X_CODEMP  .and. ;
                             Left(FUNCIONARIO->NOME,1) >= Letra_Ini .and. ;
                             Left(FUNCIONARIO->NOME,1) <= Letra_Fim .and. ;
                             FUNCIONARIO->( !Eof() )                      }

            Set SoftSeek On
            FUNCIONARIO->( dbseek( X_CODEMP + Letra_Ini ) )
            Set SoftSeek Off

            if (FUNCIONARIO->CODEMP       <> X_CODEMP)  .or. ;
               (Left(FUNCIONARIO->NOME,1)  > Letra_Fim) .or. ;
               FUNCIONARIO->(Eof())
               menstime("Nao ha' Funcionarios para estas iniciais.",2)
               break
            end

         ELSEIF X_ORDEM == 2 // codemp + setor + nome

            BL_IMPFUN := {|| FUNCIONARIO->CODEMP       == X_CODEMP  .and. ;
                             FUNCIONARIO->( !Eof() )                      }

            Set SoftSeek On
            FUNCIONARIO->( dbseek( X_CODEMP ) )
            Set SoftSeek Off

            if (FUNCIONARIO->CODEMP <> X_CODEMP)  .or. FUNCIONARIO->(Eof())
               menstime("Nao ha' Funcionarios para estas iniciais.",2)
               break
            end

         ENDIF

      case ! empty( X_CODEMP )  .and. ! empty( X_NOME )
         X_NOME := rtrim(X_NOME)
         BL_IMPFUN := {|| FUNCIONARIO->CODEMP= X_CODEMP .and. ;
                          FUNCIONARIO->NOME  = X_NOME   .and.;
                          FUNCIONARIO->(!eof())}
         BL_IMPEMP := {|| EMPRESA->CODEMP=X_CODEMP }

         EMPRESA->( dbseek(X_CODEMP) )
         if EMPRESA->( ! found())
            menstime("Empresa Nao Cadastrada.",2)
            break
         end
         FUNCIONARIO->( dbseek( X_CODEMP+X_NOME ))
         if FUNCIONARIO->( !Found() )
            menstime("Nao Ha Funcionarios com este Nome/ Inicial.",2)
            break
         end

   endcase

   mensagem("Tecle <ESC> para interromper impressao.")

   if dh_imprime("NORMAL","S")

      if ARQ_GERADO != "Nao Gera Arquivo"
         if WRESP_IMPR == "A"
            IMPRESSAO->( grava( ARQ_GERADO, date(), time(), W_TITULO, 80) )
         endif
      end

      FIM := .F.

      while eval( BL_IMPEMP )

         while eval( BL_IMPFUN )

            IF (X_ORDEM == 1)                           .or.  ;
              ((X_ORDEM == 2)                           .and. ;
               (Left(FUNCIONARIO->NOME,1) >= Letra_Ini  .and. ;
                Left(FUNCIONARIO->NOME,1) <= Letra_Fim))

                PEDIDO->( dbsetorder(1) )
                PEDIDO->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ) )

                // caso o numero de dias seja zero
                if PEDIDO->DIAUTILP > 0
                   FEZ_IMP := .T.
                   imp_cab440()
                end

            ENDIF

            FUNCIONARIO->( dbskip())

            if inkey() = K_ESC
               FIM := .T.
               exit
            end

         end

         EMPRESA->( dbskip() )
         if FIM
            exit
         end

      end

   end

   @ 00,00 say ''
   dh_impoff()

   if (!FEZ_IMP) .and. (LastKey() <> K_ESC)
      menstime("Nenhum pedido de Vale-Transporte para ser impresso.",2)
      while IMPRESSAO->( ! rlock() );end
      IMPRESSAO->( dbdelete() )
   endif

   mensagem("")
end sequence

dbcloseall()
setcolor( W_COR440 )
return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB440
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/

procedure imp_cab440

LOCAL vtotvalue := 0

EMPRESA->( dbseek(FUNCIONARIO->CODEMP) )

@ 01      ,00 say '+-----------------------------------------------------------------------------+'
@ prow()+1,00 say '|'+padc(alltrim(EMPRESA->RAZSOC),77)+'|'
@ prow()+1,00 say '|                                                                             |'
@ prow()+1,00 say '|-----------------------------------------------------------------------------|'
@ prow()+1,00 say '|                                                                             |'
@ prow()+1,00 say '|                      RECIBO DE ENTREGA DE VALE-TRANSPORTE                   |'
@ prow()+1,00 say '|                                                                             |'
@ prow()+1,00 say '+-----------------------------------------------------------------------------+'
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '   Interessado em receber o Vale-Transporte, ciente de minha participacao refe-'
@ prow()+1,00 say 'rente ao desconto e percentual que me cabe em meu contra-cheque,  nos termos da'
@ prow()+1,00 say 'Lei n.o7.418, de 16 de Dezembro de 1985, forneco abaixo as informacoes necessa-'
@ prow()+1,00 say 'rias para tanto:                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say 'Matricula do Funcionario: '+FUNCIONARIO->MATRICULA
@ prow()+1,00 say 'Nome do Funcionario     : '+FUNCIONARIO->NOME
@ prow()+1,00 say 'Endereco Residencial Completo: '+ FUNCIONARIO->ENDERECO
@ prow()+1,00 say 'Municipio: '+FUNCIONARIO->MUNICIPIO
@ prow()  ,45 say 'Bairro: '   +FUNCIONARIO->BAIRRO
@ prow()+1,00 say 'CEP      : '+transform(FUNCIONARIO->CEP,"@R 99999-999")
@ prow()  ,45 say 'Tel   : '   +FUNCIONARIO->DDD+'/'+FUNCIONARIO->TELEFONE
@ prow()+1,00 say 'Empresa  : '+EMPRESA->RAZSOC
@ prow()+1,00 say 'Setor    : '+FUNCIONARIO->SETOR
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                            TRANSPORTES UTILIZADOS                             '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '+--------------------------------------+-----------------------------+--------+'
@ prow()+1,00 say '|  MEIO DE TRANSPORTE  |    PRECO      |         SENTIDO             | No.    |'
@ prow()+1,00 say '|     UTILIZADO        | DA PASSAGEM   |                             |  VALES |'
@ prow()+1,00 say '|----------------------+---------------+-----------------------------+--------|'

PEDIDO->( dbsetorder(1) )
PEDIDO->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ) )

PEDITEM->( dbsetorder(1) )
PEDITEM->( dbseek( FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA ) )
while PEDITEM->CODEMP    +PEDITEM->MATRICULA = ;
      FUNCIONARIO->CODEMP+FUNCIONARIO->MATRICULA .and. PEDITEM->( ! eof() )

   @ prow()+1,00 say '|'
   @ prow(),  02 say eval( MEIO )
   @ prow(),  23 say '|'

   TARIFA->( dbseek(PEDITEM->CODTAR))
   @ prow(),  25 say TARIFA->VALTAR picture "999,999.99"

   @ prow(),  39 say '|'
   @ prow(),  41 say eval( ORIDEST )
   @ prow(),  69 say '|'

*-- Marcio - 27/05/96 ---------------------------------------------------------*
***@ prow(),  71 say if( PEDITEM->TRANSP = "M",STRZERO(1,2),PEDIDO->DIAUTILP )
   @ prow(),  71 say                                        PEDIDO->DIAUTILP
*------------------------------------------------------------------------------*

   @ prow(),  78 say '|'

*-- Marcio - 27/05/96 ---------------------------------------------------------*
***vtotvalue += TARIFA->VALTAR * if( PEDITEM->TRANSP=="M",1,PEDIDO->DIAUTILP )
   vtotvalue += TARIFA->VALTAR *                            PEDIDO->DIAUTILP
*------------------------------------------------------------------------------*

   PEDITEM->( dbskip() )

end

@ prow()+1,00 say '|----------------------+---------------+--------------------------------------|'
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '    Comprometo-me a utilizar o Vale-Transporte exclusivamente para os  desloca-'
@ prow()+1,00 say 'mentos residencia-trabalho-residencia, bem como a manter atualizadas as  infor-'
@ prow()+1,00 say 'macoes acima prestadas. Declaro, ainda, que as informacoes supra sao a  expres-'
@ prow()+1,00 say 'sao da verdade, ciente de que o erro nas mesmas, ou o  uso  indevido  do  Vale-'
@ prow()+1,00 say 'Transporte, constituira falta grave, ensejando punicao, nos termos da  legisla-'
@ prow()+1,00 say 'cao especifica.                                                                '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '    Recebi de ' + alltrim(EMPRESA->RAZSOC) + ','
@ prow()+1,00 say 'vales transporte no valor de R$ ' + TRANSFORM(vtotvalue,"@e 999,999,999.99" ) + '. Para utilizacao  durante a com-'
@ prow()+1,00 say 'petencia de '+Alltrim(W_COMP_MES)+"/"+Alltrim(Str(W_COMP_ANO))+'.                                                    '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '    Local  ------------------------------------------  Data    /   /           '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                  ------------------------------------------   '
@ prow()+1,00 say '                                                  Assinatura                   '

return

