# RGB Cycle Program for RISC-V Processor
# This program cycles through RGB LED patterns by manipulating 
# memory-mapped PWM registers at 0xFFFFFFFC

.section .text
.globl _start

_start:
    # Initialize registers
    li x1, 0              # Initialize counter
    li x2, 255            # Max PWM value
    li x3, 0xFFFFFFFC     # Address of RGB PWM registers
    
    # Set initial color (R=255, G=0, B=0)
    li x4, 0xFF000000     # R=255, G=0, B=0, LED=0
    sw x4, 0(x3)          # Write to LED registers
    
    # Wait initialization
    li x10, 500          # Wait counter
wait_init:
    addi x10, x10, -1
    bnez x10, wait_init
    
main_loop:
    # Read current time (milliseconds)
    li x5, 0xFFFFFFF8    # Address of millisecond timer
    lw x6, 0(x5)         # Read current time
    
    # Create a slower counter (divide by 8)
    srli x7, x6, 3       
    
    # Compute R value: fade based on counter
    andi x8, x7, 0xFF    # Get lower 8 bits
    
    # G value: offset by 85
    addi x9, x7, 85      
    andi x9, x9, 0xFF
    
    # B value: offset by 170
    addi x10, x7, 170
    andi x10, x10, 0xFF
    
    # Build RGB value (user LED always off = 0)
    slli x11, x8, 24     # Red component
    slli x12, x9, 16     # Green component
    slli x13, x10, 8     # Blue component
    or x14, x11, x12     # Combine R and G
    or x14, x14, x13     # Add B component
    
    # Write to RGB LED registers
    sw x14, 0(x3)
    
    # Small delay loop 
    li x15, 100
delay:
    addi x15, x15, -1
    bnez x15, delay
    
    j main_loop          # Repeat forever
