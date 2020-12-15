W4-Hacks

This is a firmware dump of the Wansview W4 Cloud Camera. There's a serial thru holes on the mainboard of the camera, so I soldered a set of headers to investigate the camera's internals and possibly create a local aka non cloud version of the firmware.

Captured Hex Dump from Wansview W4 camera: Wansview-W4.cap

Converted Hex dump to bin file with [uboot-mdb-dump](https://github.com/gmbnomis/uboot-mdb-dump): Wansview-W4.bin

Used [Binwalk](https://github.com/ReFirmLabs/binwalk) to extract contents of bin: Wansview-W4/