/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVP0410  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..: Pedido para concessao de vale-transporte.                    |
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
private WRESP_IMPR := ""
private W_COR410 := setcolor()

// variaveis para controle de impressoes geradas para arquivo
private ARQ_GERADO := "Nao Gera Arquivo"
private W_TITULO   := 'Pedido para Concessao de Vale-Transporte'

abrir("FUNCIONARIO")
abrir("EMPRESA")
abrir("PARAMETRO")
abrir("IMPRESSAO")

begin sequence
   setcolor(W_CORWG)
   @ 08,11 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ 09,11 say '³   Impressao de Pedido para Concessao de Vale-Transporte   ³'
   @ 10,11 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ 11,11 say '³                                                           ³'
   @ 12,11 say '³ Empresa :                                                 ³'
   @ 13,11 say '³                                                           ³'
   @ 14,11 say '³ Nome ...:                               <Enter> = Faixa   ³'
   @ 15,11 say '³                                                           ³'
   @ 16,11 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   sombra(08,11,16,71)

   X_CODEMP := space(03)
   X_NOME   := space(25)

   @ 12,23 get      X_CODEMP         ;
           picture  "@!"             ;
           valid    busca_empresa(X_CODEMP,12,27)

   @ 14,23 get      X_NOME           ;
           picture  "@!"             ;
           when     !empty(X_CODEMP)
   read

   if (lastkey() = K_ESC) .or.(Empty(X_NOME) .and. !Val_Faixa())
      break
   end

   EMPRESA->( dbsetorder(1))
   FUNCIONARIO->( dbsetorder(3))

   do case

    * ------------------------------------------------------------------
    * Quando se tecla <enter> abre um box para se escolher a empresa.
    * case empty( X_CODEMP )
    *    BL_IMPFUN := {|| FUNCIONARIO->( ! eof() ) }
    *    BL_IMPEMP := {|| EMPRESA->( ! eof()) }
    *    EMPRESA->( dbgotop() )
    * ------------------------------------------------------------------

      case ! empty( X_CODEMP ) .and. empty( X_NOME )

         BL_IMPEMP := {|| EMPRESA->CODEMP=X_CODEMP }

         BL_IMPFUN := {|| FUNCIONARIO->CODEMP       == X_CODEMP  .and. ;
                          Left(FUNCIONARIO->NOME,1) >= Letra_Ini .and. ;
                          Left(FUNCIONARIO->NOME,1) <= Letra_Fim .and. ;
                          FUNCIONARIO->( !Eof() )                      }

         EMPRESA->( dbseek(X_CODEMP) )
         if EMPRESA->( ! found())
            menstime("Empresa Nao Cadastrada.",2)
            break
         end

         Set SoftSeek On
         FUNCIONARIO->( dbseek( X_CODEMP + Letra_Ini ) )
         Set SoftSeek Off

         if (FUNCIONARIO->CODEMP       <> X_CODEMP)  .or. ;
            (Left(FUNCIONARIO->NOME,1)  > Letra_Fim) .or. ;
            FUNCIONARIO->(Eof())
            menstime("Nao ha' Funcionarios para estas iniciais.",2)
            break
         end

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
         if FUNCIONARIO->( ! found())
            menstime("N„o H  Funcion rios com este Nome Inicial.",2)
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
            imp_cab410()
            FUNCIONARIO->( dbskip())
            if inkey() = K_ESC
               FIM := .T.
               exit
            end
         end
         EMPRESA->( dbskip() )
         if FIM; exit; end
      end
   end
   @ 00,00 say ''
   dh_impoff()
   mensagem("")
end sequence

dbcloseall()
setcolor( W_COR410 )
return

/*
-------------------------------------------------------------------------------
Procedimento .: IMP_CAB410
Objetivo .....: Menu rapido
-------------------------------------------------------------------------------
*/

procedure imp_cab410

EMPRESA->( dbseek(FUNCIONARIO->CODEMP) )

@ 01      ,00 say '+-----------------------------------------------------------------------------+'
@ prow()+1,00 say '|'+padc(alltrim(EMPRESA->RAZSOC),77)+'|'
@ prow()+1,00 say '|                                                                             |'
@ prow()+1,00 say '|-----------------------------------------------------------------------------|'
@ prow()+1,00 say '|                                                                             |'
@ prow()+1,00 say '|                      PEDIDO PARA CONCESSAO DE VALE-TRANSPORTE               |'
@ prow()+1,00 say '|                                                                             |'
@ prow()+1,00 say '+-----------------------------------------------------------------------------+'
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '   Interessado em receber o Vale-Transporte, ciente de minha participacao refe-'
@ prow()+1,00 say 'rente ao desconto e percentual que me cabe em meu contra-cheque, nos termos  da'
@ prow()+1,00 say 'Lei n.o7.418, de 16 de Dezembro de 1985, forneco abaixo as informacoes necessa-'
@ prow()+1,00 say 'rias para tanto:                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say 'Nome do Funcionario: '+FUNCIONARIO->NOME
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
@ prow()+1,00 say '+--------------------------------------+--------------------------------------+'
@ prow()+1,00 say '|   DA RESIDENCIA PARA O TRABALHO      |   DO TRABALHO PARA A RESIDENCIA      |'
@ prow()+1,00 say '|--------------------------------------+--------------------------------------|'
@ prow()+1,00 say '|  MEIO DE TRANSPORTE  |    PRECO      |  MEIO DE TRANSPORTE  |   PRECO       |'
@ prow()+1,00 say '|     UTILIZADO        | DA PASSAGEM   |      UTILIZADO       | DA PASSAGEM   |'
@ prow()+1,00 say '|----------------------+---------------+----------------------+---------------|'
@ prow()+1,00 say '|                      |               |                      |               |'
@ prow()+1,00 say '|----------------------+---------------+----------------------+---------------|'
@ prow()+1,00 say '|                      |               |                      |               |'
@ prow()+1,00 say '|----------------------+---------------+----------------------+---------------|'
@ prow()+1,00 say '|                      |               |                      |               |'
@ prow()+1,00 say '|----------------------+---------------+----------------------+---------------|'
@ prow()+1,00 say '|                      |               |                      |               |'
@ prow()+1,00 say '+-----------------------------------------------------------------------------+'
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '    Comprometo-me a utilizar o Vale-Transporte exclusivamente para os  desloca-'
@ prow()+1,00 say 'mentos residencia-trabalho-residencia, bem como a manter atualizadas as  infor-'
@ prow()+1,00 say 'macoes acima prestadas. Declaro, ainda,  que  as informacoes supra  sao  a  ex-'
@ prow()+1,00 say 'pressao da verdade, ciente de que o erro nas  mesmas,  ou o  uso  indevido   do'
@ prow()+1,00 say 'Vale-Transporte, constituira falta grave,  ensejando  punicao,  nos  termos  da'
@ prow()+1,00 say 'legislacao especifica.                                                         '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '    Obs.:  (Opcional)                                                          '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say ' ----------------------------------------------------------------------------- '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say ' ----------------------------------------------------------------------------- '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '    Local  ------------------------------------------  Data    /   /           '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                                                               '
@ prow()+1,00 say '                                  ------------------------------------------   '
@ prow()+1,00 say '                                                  Assinatura                   '

return
