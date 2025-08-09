BUILD:=./build

HD_IMG_NAME:= "hd.img"

all: ${BUILD}/boot/boot.o ${BUILD}/boot/setup.o
	$(shell rm -rf $(HD_IMG_NAME))
	bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $(HD_IMG_NAME)
	dd if=${BUILD}/boot/boot.o of=hd.img bs=512 seek=0 count=1 conv=notrunc
	dd if=${BUILD}/boot/setup.o of=hd.img bs=512 seek=1 count=2 conv=notrunc

${BUILD}/boot/%.o: boot/%.asm
	$(shell mkdir -p ${BUILD}/boot)
	nasm -f bin $< -o $@





all_test: ${BUILD}/boot/boot.bin ${BUILD}/boot/setup.bin
	$(shell rm -rf $(HD_IMG_NAME))
	bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $(HD_IMG_NAME)
	dd if=${BUILD}/boot/boot.bin of=hd.img bs=512 seek=0 count=1 conv=notrunc
	dd if=${BUILD}/boot/setup.bin of=hd.img bs=512 seek=1 count=2 conv=notrunc

${BUILD}/boot/%.bin: boot/%.asm
	$(shell mkdir -p ${BUILD}/boot)
	nasm -f bin $< -o $@


clean:
	$(shell rm -rf ${BUILD})

bochs_test: all_test
	bochs -q -f bochsrc

bochs: all
	bochs -q -f bochsrc


qemu : all
	qemu-system-x86_64 -hda hd.img