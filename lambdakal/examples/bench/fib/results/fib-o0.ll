define i32 @fib.32(i32 %x_0) {
  %1 = icmp slt i32 %x_0, 3
  br i1 %1, label %if.then_0, label %if.else_0

if.then_0:                                        ; preds = %0
  br label %if.if_exit_0

if.else_0:                                        ; preds = %0
  %2 = sub i32 %x_0, 1
  %3 = call i32 @fib.32(i32 %2)
  %4 = sub i32 %x_0, 2
  %5 = call i32 @fib.32(i32 %4)
  %6 = add i32 %3, %5
  br label %if.else_exit_0

if.if_exit_0:                                     ; preds = %if.then_0
  br label %if.end_0

if.else_exit_0:                                   ; preds = %if.else_0
  br label %if.end_0

if.end_0:                                         ; preds = %if.else_exit_0, %if.if_exit_0
  %7 = phi i32 [ 1, %if.if_exit_0 ], [ %6, %if.else_exit_0 ]
  ret i32 %7
}