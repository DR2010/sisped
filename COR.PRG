cls

WCOR := "W/B,B/W,G/R,,,N          "

while .t.

   @ 01,01 say 'WCOR :' get WCOR
   read

   setcolor( WCOR )
   @ 10,10 say "旼컴컴컴컴컴컴컴컴컴커"
   @ 11,10 say "� Get :              �"
   @ 12,10 say "� Get :              �"
   @ 13,10 say "� Get :              �"
   @ 14,10 say "읕컴컴컴컴컴컴컴컴컴켸"
   var1:=var2:=var3:=space(4)
   @ 11,18 get var1
   @ 12,18 get var2
   @ 13,18 get var3
   read

   @ 16,10 PROMPT "TESTE"
   @ 17,10 PROMPT "TESTE"
   MENU TO OP
   setcolor("W/N,N/W,N/B,,,N")


end

