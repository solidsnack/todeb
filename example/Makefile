
F=example.tar.lzma

lzma: $F
$F:
	tar --lzma --create --file $F contents

hex: $F.hex
$F.hex: $F
	xxd -p -c 32 < $F | pr -tFo 14 > $F.hex

