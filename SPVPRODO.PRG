/*
  +---------------------------------------------------------------------------+
  | >>>>>>>>>>>>>>>>>>>>>> RODOTEC SISTEMAS DE CONTROLE <<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  SPVPRODO  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
  |                                                                           |
  | Sistema:                                                                  |
  |---------------------------------------------------------------------------|
  | Descricao..:                                                              |
  |---------------------------------------------------------------------------|
  | Cliente....: SISPED                     | Ultima Alteracao                |
  | Analista...: Daniel Machado             | Autor : Daniel Machado          |
  | Programador: Daniel Machado             | Dt/Hr : 13/10/94 - 11:30        |
  | Inicio.....: 21/10/1994                 | Motivo: Inicio.                 |
  |                                         |                                 |
  +---------------------------------------------------------------------------+
*/
#include "inkey.ch"
private W_OLDCOR := setcolor(), W_SUB
private W_VET := { "letra_e()"   ,;
                   "letra_s2()"  ,;
                   "letra_d()"   ,;
                   "letra_i()"   ,;
                   "letra_p()"   ,;
                   "letra_s1()"  ,;
                   "letra_e()"   ,;
                   "letra_s2()"  ,;
                   "letra_d()"   ,;
                   "letra_i()"   ,;
                   "letra_p()"   ,;
                   "letra_s1()"  }

setcursor(0)
telaback()

setcolor("R*+/B,R/B+,B")
for x := 1 to 6
   eval( {|| &(W_SUB := W_VET[X]) } )
   if inkey(.5) = K_ESC; exit; end
next

if lastkey() != K_ESC
   setcolor("B+/B,R/B+,B")
   for x := 1 to 6
      eval( {|| &(W_SUB := W_VET[X]) } )
      if inkey(.5)=K_ESC; exit; end
   next
   inkey(4)
end

setcolor(W_OLDCOR)
setcursor(1)
return

procedure telaback

@ 00,07 say '                                                                   '
@ 01,07 say '                                                                   '
@ 02,07 say '浜様様様様様� 浜融  浜様様様様様� 浜様様様様� 浜様様様� 浜様様様融 '
@ 03,07 say '�           � �  �  �           � �  浜様�  � �       � �        隼'
@ 04,07 say '�  浜様様様夕 �  隼 �  浜様様様夕 �  藩様�  � � 浜様様� 藩� 浜�   �'
@ 05,07 say '�  藩様様様融 �   � �  藩様様様融 �  浜様様夕 � 藩�       � � 隼  �'
@ 06,07 say '藩様融      � �   � 藩様融      � �  隼       �   �       � �  �  �'
@ 07,07 say '     �      � �   �      �      � �   �       � 浜�       � �  �  �'
@ 08,07 say '浜様夕      � �   � 浜様夕      � �   �       � 藩様様� 浜� 藩夕  �'
@ 09,07 say '�           � �   � �           � �   �       �       � �         �'
@ 10,07 say '藩様様様様様� 藩様� 藩様様様様様� 藩様�       藩様様様� 藩様様様様�'
@ 11,07 say '                                                                   '
@ 12,07 say '                浜様様様様融       浜様様様様融                    '
@ 13,07 say '                �          隼      �          隼                   '
@ 14,07 say '                �  浜様様�  �      �   浜融    �                   '
@ 15,07 say '                藩夕     �  �      �   �  隼   �                   '
@ 16,07 say '                         �  �      �   �   �   �                   '
@ 17,07 say '                浜様様様夕  �      �   �   �   �                   '
@ 18,07 say '                �           �      �   �   �   �                   '
@ 19,07 say '                �   浜様様様�      �   �   �   �                   '
@ 20,07 say '                �   藩様様様� 浜融 �   藩様�   �                   '
@ 21,07 say '                �           � �  � �           �                   '
@ 22,07 say '                藩様様様様様� 藩夕 藩様様様様様�                   '
@ 23,07 say '                                                                   '
@ 24,07 say ' FETRANSPOR                Release 2.6                     RODOTEC '

return

procedure LETRA_S1

@ 02,07 say '浜様様様様様�'
@ 03,07 say '�           �'
@ 04,07 say '�  浜様様様夕'
@ 05,07 say '�  藩様様様融'
@ 06,07 say '藩様融      �'
@ 07,07 say '     �      �'
@ 08,07 say '浜様夕      �'
@ 09,07 say '�           �'
@ 10,07 say '藩様様様様様�'
return

procedure LETRA_I
@ 02,21 say '浜融'
@ 03,21 say '�  �'
@ 04,21 say '�  隼'
@ 05,21 say '�   �'
@ 06,21 say '�   �'
@ 07,21 say '�   �'
@ 08,21 say '�   �'
@ 09,21 say '�   �'
@ 10,21 say '藩様�'
return

procedure LETRA_S2

@ 02,27 say '浜様様様様様�'
@ 03,27 say '�           �'
@ 04,27 say '�  浜様様様夕'
@ 05,27 say '�  藩様様様融'
@ 06,27 say '藩様融      �'
@ 07,27 say '     �      �'
@ 08,27 say '浜様夕      �'
@ 09,27 say '�           �'
@ 10,27 say '藩様様様様様�'
return

procedure LETRA_P

@ 02,41 say '浜様様様様�'
@ 03,41 say '�  浜様�  �'
@ 04,41 say '�  藩様�  �'
@ 05,41 say '�  浜様様夕'
@ 06,41 say '�  隼'
@ 07,41 say '�   �'
@ 08,41 say '�   �'
@ 09,41 say '�   �'
@ 10,41 say '藩様�'
return

procedure LETRA_E

@ 02,53 say '浜様様様�'
@ 03,53 say '�       �'
@ 04,53 say '� 浜様様�'
@ 05,53 say '� 藩�'
@ 06,53 say '�   �'
@ 07,53 say '� 浜�'
@ 08,53 say '� 藩様様�'
@ 09,53 say '�       �'
@ 10,53 say '藩様様様�'
return

procedure LETRA_D

@ 02,63 say '浜様様様融'
@ 03,63 say '�        隼'
@ 04,63 say '藩� 浜�   �'
@ 05,63 say '  � � 隼  �'
@ 06,63 say '  � �  �  �'
@ 07,63 say '  � �  �  �'
@ 08,63 say '浜� 藩夕  �'
@ 09,63 say '�         �'
@ 10,63 say '藩様様様様�'

return
