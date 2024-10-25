#!/usr/bin/env python
"""
Assemble ELF segments into a single mbn file.
Usage: pil-squasher.py <mbn output> <mdt header>
This script reads an ELF header and program headers from the specified mdt
file and combines the corresponding segments from .bXX files or the mdt file
itself into a single mbn file.
If a segment is a hash chunk (type 2), it attempts to read the segment data
directly from the mdt file following the ELF header and program headers.
Otherwise, it reads the segment data from the corresponding .bXX file.
"""

import sys
import struct
import os

def usage():
    print("Usage: %s <mbn output> <mdt header>" % sys.argv[0])
    sys.exit(1)

def die(message):
    print(message)
    sys.exit(1)

def is_elf(file):
    """Verifies a file as being an ELF file"""
    file.seek(0)
    magic = file.read(4)
    file.seek(0)
    return magic == b'\x7fELF'

if __name__ == "__main__":
    if len(sys.argv) != 3:
        usage()
    mbn_file = sys.argv[1]
    mdt_file = sys.argv[2]

    if not mdt_file.endswith('.mdt'):
        die("%s is not an mdt file" % mdt_file)

    try:
        mbn = open(mbn_file, 'wb')
    except IOError as e:
        die("Failed to open %s: %s" % (mbn_file, e))

    try:
        mdt = open(mdt_file, 'rb')
    except IOError as e:
        die("Failed to open %s: %s" % (mdt_file, e))

    if not is_elf(mdt):
        die("Not an ELF file %s" % mdt_file)

    e_ident = mdt.read(16)
    EI_CLASS = 4
    ELFCLASS32 = 1
    ELFCLASS64 = 2

    if e_ident[EI_CLASS] == ELFCLASS32:
        is_64bit = False
    elif e_ident[EI_CLASS] == ELFCLASS64:
        is_64bit = True
    else:
        die("Unsupported ELF class %d" % e_ident[EI_CLASS])

    # Rewind the file to read the full ELF header
    mdt.seek(0)

    # Read the ELF header
    if is_64bit:
        elf_hdr_format = "<16sHHIQQQIHHHHHH"
    else:
        elf_hdr_format = "<16sHHIIIIIHHHHHH"

    elf_hdr_size = struct.calcsize(elf_hdr_format)
    elf_hdr_data = mdt.read(elf_hdr_size)
    if len(elf_hdr_data) != elf_hdr_size:
        die("Failed to read ELF header from %s" % mdt_file)

    # Write the ELF header to the mbn file
    mbn.write(elf_hdr_data)

    # Unpack the ELF header
    elf_hdr = struct.unpack(elf_hdr_format, elf_hdr_data)

    # Get e_phoff, e_phnum, and e_phentsize
    if is_64bit:
        e_phoff = elf_hdr[5]
        e_phentsize = elf_hdr[9]
        e_phnum = elf_hdr[10]
    else:
        e_phoff = elf_hdr[5]
        e_phentsize = elf_hdr[9]
        e_phnum = elf_hdr[10]

    # Compute program header size
    if is_64bit:
        phdr_format = "<IIQQQQQQ"
    else:
        phdr_format = "<IIIIIIII"

    phdr_size = struct.calcsize(phdr_format)

    # Set hashoffset to the offset after the ELF header and program headers
    hashoffset = elf_hdr_size + e_phnum * phdr_size

    # Read and write the program headers
    for i in range(e_phnum):
        offset = e_phoff + i * phdr_size
        mdt.seek(offset)
        phdr_data = mdt.read(phdr_size)
        if len(phdr_data) != phdr_size:
            die("Failed to read program header %d from %s" % (i, mdt_file))

        # Write the program header to mbn
        mbn.seek(offset)
        mbn.write(phdr_data)

        # Unpack the program header
        phdr = struct.unpack(phdr_format, phdr_data)

        if is_64bit:
            # 64-bit ELF program header fields:
            # p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align
            p_type = phdr[0]
            p_flags = phdr[1]
            p_offset = phdr[2]
            p_filesz = phdr[5]
        else:
            # 32-bit ELF program header fields:
            # p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align
            p_type = phdr[0]
            p_offset = phdr[1]
            p_filesz = phdr[4]
            p_flags = phdr[6]

        if p_filesz == 0:
            continue

        segment_data = b''

        # Check if the segment is a hash chunk (type 2)
        segment_type = (p_flags >> 24) & 7

        if segment_type == 2:
            # Hash chunk
            mdt.seek(hashoffset)
            segment_data = mdt.read(p_filesz)
            hashoffset += p_filesz
            if len(segment_data) != p_filesz:
                die("Failed to load segment %d: read %d bytes, expected %d" % (i, len(segment_data), p_filesz))
        else:
            # Try to read from .bXX file
            base_name, ext = os.path.splitext(mdt_file)
            bxx_file = "%s.b%02d" % (base_name, i)
            try:
                with open(bxx_file, 'rb') as bxx:
                    segment_data = bxx.read()
                    segment_size = len(segment_data)
                    if segment_size < p_filesz:
                        # Pad the segment_data with zeros
                        segment_data += b'\x00' * (p_filesz - segment_size)
                    elif segment_size > p_filesz:
                        # Truncate the segment_data
                        segment_data = segment_data[:p_filesz]
            except IOError as e:
                die("Failed to open %s: %s" % (bxx_file, e))

        # Write the segment data to mbn at p_offset
        mbn.seek(p_offset)
        mbn.write(segment_data)

    # Close files
    mdt.close()
    mbn.close()