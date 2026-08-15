; 6.0d end-to-end check -- exercises every pseudo-instruction on the CPU.
;
; Expected final state:
;   r1 = 0x0005
;   r2 = 0xFFFB   (-5)
;   r3 = 0x0005
;   r4 = 0x0000   <- stays 0 only if the bgt is taken

        li16 r1, 0x0005      ; 2 words -> addr 0, 1
        neg  r2, r1          ; 2 words -> addr 2, 3   r2 = -5
        mov  r3, r1          ; addr 4                 r3 = 5
        nop                  ; addr 5
        bgt  r3, r2, done    ; addr 6    5 > -5 signed, must be TAKEN
        addi r4, r4, 1       ; addr 7    must NOT execute
done:   j    done            ; addr 8
