syntax match Comment /^\..*/
syntax match PreProc /^[^0-9f2.].*/
syntax match Visual /^#.*/
set isident=@,45,48-57,_,192-255
set iskeyword=@,45,48-57,_,192-255
map @n /^2.*\t[a-zA-Z_0-9.]* *$/mx$
map  :w!!str
map  jmxk!!lstr
map  j/\.t.*\.b.*\.b/zkkjj
map <f8> !!reverse
map @a 0f.cf -epdE
map @d 0/\.[tloCM]/Byt.A pa-0/\.[bricm]/Byt.$pBi+
map @s $BBf.cf -:s/\.\([a-z]\)\([a-z]*\)$/.\1/$B
map @e 0f.B"tdW!!reverse0f.B"tP
map @r !!reverse
