define i32 @fib.32(i32 %x_0) local_unnamed_addr #4 {
  %1 = icmp slt i32 %x_0, 3
  br i1 %1, label %if.end_0, label %if.else_0

if.else_0:                                        ; preds = %0, %if.else_0
  ; iterador, es la entrada - 2 o el entrada. Itera de a dos pasos
  %x_0.tr2 = phi i32 [ %4, %if.else_0 ], [ %x_0, %0 ]
  ; acumulador, es %5 de la iteracion, comienza en 0
  %accumulator.tr1 = phi i32 [ %5, %if.else_0 ], [ 0, %0 ]
  %2 = add nsw i32 %x_0.tr2, -1
  ; llamada recursiva
  %3 = tail call i32 @fib.32(i32 %2)
  %4 = add nsw i32 %x_0.tr2, -2
  ; sumamos el resultado de la llamada recursiva al acumulador
  %5 = add i32 %3, %accumulator.tr1
  %6 = icmp slt i32 %x_0.tr2, 5
  br i1 %6, label %if.end_0.loopexit, label %if.else_0

if.end_0.loopexit:                                ; preds = %if.else_0
  %phi.bo = add i32 %5, 1
  br label %if.end_0

if.end_0:                                         ; preds = %if.end_0.loopexit, %0
  %accumulator.tr.lcssa = phi i32 [ 1, %0 ], [ %phi.bo, %if.end_0.loopexit ]
  ret i32 %accumulator.tr.lcssa
}

1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946 17711 28657 46368 75025 121393 196418 317811 514229 832040 1346269 2178309 3524578

fib(6):

accumulator = 0, x = 6
accumulator = fib(5) = 5
x = 4
accumulator = 5 + fib(3) = 7
res = accumulator + 1 = 8

