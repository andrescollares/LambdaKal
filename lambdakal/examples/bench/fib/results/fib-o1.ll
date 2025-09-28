define i32 @fib.32(i32 %x_0) local_unnamed_addr #4 {
  %1 = icmp slt i32 %x_0, 3
  br i1 %1, label %if.end_0, label %if.else_0

if.else_0:                                        ; preds = %0
  %2 = add i32 %x_0, -1
  %3 = call i32 @fib.32(i32 %2)
  %4 = add i32 %x_0, -2
  %5 = call i32 @fib.32(i32 %4)
  %6 = add i32 %5, %3
  br label %if.end_0

if.end_0:                                         ; preds = %0, %if.else_0
  %7 = phi i32 [ %6, %if.else_0 ], [ 1, %0 ]
  ret i32 %7
}

