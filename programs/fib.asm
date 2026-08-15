        li   r4, hi, 1
        lw   r1, 0(r4)        
        li   r3, lo, 1        

loop:   beq  r5, r1, done     
        add  r7, r2, r3       
        mov  r2, r3           
        mov  r3, r7           
        addi r5, r5, 1
        j    loop

done:   j    done
