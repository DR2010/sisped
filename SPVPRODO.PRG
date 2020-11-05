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
@ 02,07 say '�����������ͻ ��ͻ  �����������ͻ ���������ͻ �������ͻ ��������ͻ '
@ 03,07 say '�           � �  �  �           � �  ���ͻ  � �       � �        Ȼ'
@ 04,07 say '�  ��������ͼ �  Ȼ �  ��������ͼ �  ���ͼ  � � �����ͼ �ͻ �ͻ   �'
@ 05,07 say '�  ��������ͻ �   � �  ��������ͻ �  ������ͼ � �ͻ       � � Ȼ  �'
@ 06,07 say '����ͻ      � �   � ����ͻ      � �  Ȼ       �   �       � �  �  �'
@ 07,07 say '     �      � �   �      �      � �   �       � �ͼ       � �  �  �'
@ 08,07 say '����ͼ      � �   � ����ͼ      � �   �       � �����ͻ �ͼ ��ͼ  �'
@ 09,07 say '�           � �   � �           � �   �       �       � �         �'
@ 10,07 say '�����������ͼ ���ͼ �����������ͼ ���ͼ       �������ͼ ���������ͼ'
@ 11,07 say '                                                                   '
@ 12,07 say '                ����������ͻ       ����������ͻ                    '
@ 13,07 say '                �          Ȼ      �          Ȼ                   '
@ 14,07 say '                �  �����ͻ  �      �   ��ͻ    �                   '
@ 15,07 say '                ��ͼ     �  �      �   �  Ȼ   �                   '
@ 16,07 say '                         �  �      �   �   �   �                   '
@ 17,07 say '                ��������ͼ  �      �   �   �   �                   '
@ 18,07 say '                �           �      �   �   �   �                   '
@ 19,07 say '                �   �������ͼ      �   �   �   �                   '
@ 20,07 say '                �   �������ͻ ��ͻ �   ���ͼ   �                   '
@ 21,07 say '                �           � �  � �           �                   '
@ 22,07 say '                �����������ͼ ��ͼ �����������ͼ                   '
@ 23,07 say '                                                                   '
@ 24,07 say ' FETRANSPOR                Release 2.6                     RODOTEC '

return

procedure LETRA_S1

@ 02,07 say '�����������ͻ'
@ 03,07 say '�           �'
@ 04,07 say '�  ��������ͼ'
@ 05,07 say '�  ��������ͻ'
@ 06,07 say '����ͻ      �'
@ 07,07 say '     �      �'
@ 08,07 say '����ͼ      �'
@ 09,07 say '�           �'
@ 10,07 say '�����������ͼ'
return

procedure LETRA_I
@ 02,21 say '��ͻ'
@ 03,21 say '�  �'
@ 04,21 say '�  Ȼ'
@ 05,21 say '�   �'
@ 06,21 say '�   �'
@ 07,21 say '�   �'
@ 08,21 say '�   �'
@ 09,21 say '�   �'
@ 10,21 say '���ͼ'
return

procedure LETRA_S2

@ 02,27 say '�����������ͻ'
@ 03,27 say '�           �'
@ 04,27 say '�  ��������ͼ'
@ 05,27 say '�  ��������ͻ'
@ 06,27 say '����ͻ      �'
@ 07,27 say '     �      �'
@ 08,27 say '����ͼ      �'
@ 09,27 say '�           �'
@ 10,27 say '�����������ͼ'
return

procedure LETRA_P

@ 02,41 say '���������ͻ'
@ 03,41 say '�  ���ͻ  �'
@ 04,41 say '�  ���ͼ  �'
@ 05,41 say '�  ������ͼ'
@ 06,41 say '�  Ȼ'
@ 07,41 say '�   �'
@ 08,41 say '�   �'
@ 09,41 say '�   �'
@ 10,41 say '���ͼ'
return

procedure LETRA_E

@ 02,53 say '�������ͻ'
@ 03,53 say '�       �'
@ 04,53 say '� �����ͼ'
@ 05,53 say '� �ͻ'
@ 06,53 say '�   �'
@ 07,53 say '� �ͼ'
@ 08,53 say '� �����ͻ'
@ 09,53 say '�       �'
@ 10,53 say '�������ͼ'
return

procedure LETRA_D

@ 02,63 say '��������ͻ'
@ 03,63 say '�        Ȼ'
@ 04,63 say '�ͻ �ͻ   �'
@ 05,63 say '  � � Ȼ  �'
@ 06,63 say '  � �  �  �'
@ 07,63 say '  � �  �  �'
@ 08,63 say '�ͼ ��ͼ  �'
@ 09,63 say '�         �'
@ 10,63 say '���������ͼ'

return
