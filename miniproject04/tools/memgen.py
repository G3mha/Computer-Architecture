#!/usr/bin/env python3
"""
Memory file generator for RISC-V processor.
This tool takes assembled binary files and converts them to memory initialization 
files compatible with the processor's memory modules.
"""

import argparse
import os
import re
import subprocess
import tempfile
from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser(description='Generate memory initialization files from RISC-V assembly')
    parser.add_argument('input', help='Input assembly file (.S) or ELF file (.elf)')
    parser.add_argument('-o', '--output', help='Output memory file')
    parser.add_argument('-f', '--format', choices=['hex', 'bin'], default='hex',
                        help='Output format: hex (default) or binary')
    parser.add_argument('-s', '--size', type=int, default=2048,
                        help='Memory size in words (default: 2048)')
    return parser.parse_args()

def assemble_file(asm_file):
    """Assemble an assembly file into an ELF file using RISC-V GCC toolchain."""
    base_name = os.path.splitext(asm_file)[0]
    elf_file = f"{base_name}.elf"
    
    # Create a temporary linker script
    with tempfile.NamedTemporaryFile(mode='w', suffix='.ld', delete=False) as f:
        linker_script = f.name
        f.write('''
MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

SECTIONS
{
    .text :
    {
        *(.text)
    } > RAM

    .data :
    {
        *(.data)
    } > RAM

    .bss :
    {
        *(.bss)
    } > RAM
}
''')
    
    try:
        cmd = [
            'riscv-none-elf-gcc',
            '-march=rv32i',
            '-mabi=ilp32',
            '-nostartfiles',
            '-nostdlib',
            '-Wl,-T,' + linker_script,
            '-o', elf_file,
            asm_file
        ]
        subprocess.run(cmd, check=True)
        print(f"Assembled {asm_file} to {elf_file}")
        return elf_file
    finally:
        os.unlink(linker_script)

def extract_binary(elf_file):
    """Extract binary data from an ELF file using objcopy."""
    bin_file = os.path.splitext(elf_file)[0] + '.bin'
    cmd = [
        'riscv-none-elf-objcopy',
        '-O', 'binary',
        elf_file,
        bin_file
    ]
    subprocess.run(cmd, check=True)
    print(f"Extracted binary from {elf_file} to {bin_file}")
    return bin_file

def create_mem_file(bin_file, output_file, format='hex', size=2048):
    """Create a memory initialization file from binary data."""
    with open(bin_file, 'rb') as f:
        data = f.read()
    
    # Process 4 bytes (one word) at a time
    words = []
    for i in range(0, len(data), 4):
        if i + 4 <= len(data):
            # Little-endian to big-endian conversion
            word = (data[i+3] << 24) | (data[i+2] << 16) | (data[i+1] << 8) | data[i]
            words.append(word)
    
    # Pad with zeros to reach the specified size
    words.extend([0] * (size - len(words)))
    
    with open(output_file, 'w') as f:
        if format == 'hex':
            # Write as hex
            for i, word in enumerate(words):
                f.write(f"{word:08x}\n")
        else:
            # Write as binary
            for i, word in enumerate(words):
                f.write(f"{word:032b}\n")
    
    print(f"Created memory file {output_file} with {len(words)} words")

def main():
    args = parse_args()
    input_file = args.input
    
    # Determine if the input is assembly or ELF
    if input_file.endswith('.S') or input_file.endswith('.s'):
        # Assemble the file
        elf_file = assemble_file(input_file)
    elif input_file.endswith('.elf'):
        elf_file = input_file
    else:
        print(f"Unsupported input file format: {input_file}")
        return 1
    
    # Extract binary from ELF
    bin_file = extract_binary(elf_file)
    
    # Determine output file name if not specified
    if not args.output:
        output_file = os.path.splitext(input_file)[0] + '.mem'
    else:
        output_file = args.output
    
    # Create memory file
    create_mem_file(bin_file, output_file, args.format, args.size)
    
    return 0

if __name__ == '__main__':
    main()
