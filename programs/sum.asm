        li   r4, hi, 1
        lw   r1, 0(r4)
loop:   addi r3, r3, 1
        add  r2, r2, r3
        bne  r3, r1, loop
done:   j    done