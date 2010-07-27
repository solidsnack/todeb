
F=example.tar.lzma

lzma: $F
$F:
	tar --lzma --create --file $F contents

hex: lzma
	xxd -p -c 32 < $F | pr -tFo 14 | sed -r '1 {s/^ +/   .tar.lzma: /}'

