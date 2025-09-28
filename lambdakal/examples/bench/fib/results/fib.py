# define i32 @fib.32(i32 %x_0) local_unnamed_addr #4 {
#   %1 = icmp slt i32 %x_0, 3
#   br i1 %1, label %if.end_0, label %if.else_0

# if.else_0:                                        ; preds = %0, %if.else_0
#   ; iterador, es la entrada - 2 o el numero. Itera de a dos pasos
#   %x_0.tr2 = phi i32 [ %4, %if.else_0 ], [ %x_0, %0 ]
#   ; acumulador, es %5 de la iteracion, comienza en 0
#   %accumulator.tr1 = phi i32 [ %5, %if.else_0 ], [ 0, %0 ]
#   %2 = add nsw i32 %x_0.tr2, -1
#   ; llamada recursiva
#   %3 = tail call i32 @fib.32(i32 %2)
#   %4 = add nsw i32 %x_0.tr2, -2
#   ; sumamos el resultado de la llamada recursiva al acumulador
#   %5 = add i32 %3, %accumulator.tr1
#   %6 = icmp slt i32 %x_0.tr2, 5
#   br i1 %6, label %if.end_0.loopexit, label %if.else_0

# if.end_0.loopexit:                                ; preds = %if.else_0
#   %phi.bo = add i32 %5, 1
#   br label %if.end_0

# if.end_0:                                         ; preds = %if.end_0.loopexit, %0
#   %accumulator.tr.lcssa = phi i32 [ 1, %0 ], [ %phi.bo, %if.end_0.loopexit ]
#   ret i32 %accumulator.tr.lcssa
# }


# python3 examples/bench/fib/results/fib.py
def fib(n):
    if n < 3:
        return 1

    iter = n
    accumulator = 0
    while True:
        accumulator += fib(iter - 1)
        if iter < 5:
            break
        iter -= 2
    return accumulator + 1

# fib(10) = fib(9) + fib(7) + fib(5) + fib(3) + 1
# 55 = 34 + 13 + 5 + 2 + 1
    
    
if __name__ == "__main__":
    for i in range(1, 36):
        print(f"fib({i}) = {fib(i)}")

    