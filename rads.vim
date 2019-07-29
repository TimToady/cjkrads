syntax match Comment /^\..*/
syntax match PreProc /^[^0-9f2.].*/
syntax match Visual /^#.*/
set isident=@,45,48-57,_,192-255
set iskeyword=@,45,48-57,_,192-255
map  :w
map  jmxk!!lstr
map  /^\.
map @a 0f.cf -epdE
map @d 0/\.[tloCM]/
map @s $BBf.cf -:s/\.\([a-z]\)\([a-z]*\)$/.\1/
map @e 0f.B"tdW!!reverse
map @r !!reverse