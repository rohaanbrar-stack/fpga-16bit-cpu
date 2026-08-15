        li   r4, hi, 1        
        lw   r2, 0(r4)
        li   r3, lo, 1

loop:   beq  r2, r3, done     
        and  r5, r2, r3       
        beq  r5, r3, odd
        shr  r2, r2, r3       
        j    loop

odd:    add  r5, r2, r2       
        add  r2, r5, r2       
        addi r2, r2, 1        
        j    loop

done:   j    done
