syntax match Comment /^\..*/
syntax match PreProc /^[^0-9f2.].*/
syntax match Visual /^#.*/
set isident=@,45,48-57,_,192-255
set iskeyword=@,45,48-57,_,192-255
map  :w!!str
map  jmxk!!lstr
map  /^\.?^\dz
map @a 0f.cf -epdE
map @d 0/\.[tloCM]/Byt.A pa-0/\.[bricm]/Byt.$pBi+
map @s $BBf.cf -:s/\.\([a-z]\)\([a-z]*\)$/.\1/$B
map @e 0f.B"tdW!!reverse0f.B"tP
map @r !!reverse
