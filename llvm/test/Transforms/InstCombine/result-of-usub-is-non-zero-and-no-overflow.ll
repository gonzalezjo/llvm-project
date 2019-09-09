; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -instcombine -S | FileCheck %s

; Here we subtract two values, check that subtraction did not overflow AND
; that the result is non-zero. This can be simplified just to a comparison
; between the base and offset.

declare void @use8(i8)
declare void @use1(i1)

declare {i8, i1} @llvm.usub.with.overflow(i8, i8)
declare void @useagg({i8, i1})

; There is a number of base patterns..

define i1 @t0_noncanonical_ignoreme(i8 %base, i8 %offset) {
; CHECK-LABEL: @t0_noncanonical_ignoreme(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp uge i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %no_underflow = icmp ule i8 %adjusted, %base
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

define i1 @t1(i8 %base, i8 %offset) {
; CHECK-LABEL: @t1(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp uge i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %no_underflow = icmp uge i8 %base, %offset
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

define i1 @t2(i8 %base, i8 %offset) {
; CHECK-LABEL: @t2(
; CHECK-NEXT:    [[AGG:%.*]] = call { i8, i1 } @llvm.usub.with.overflow.i8(i8 [[BASE:%.*]], i8 [[OFFSET:%.*]])
; CHECK-NEXT:    call void @useagg({ i8, i1 } [[AGG]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = extractvalue { i8, i1 } [[AGG]], 0
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = extractvalue { i8, i1 } [[AGG]], 1
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = xor i1 [[UNDERFLOW]], true
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %agg = call {i8, i1} @llvm.usub.with.overflow(i8 %base, i8 %offset)
  call void @useagg({i8, i1} %agg)
  %adjusted = extractvalue {i8, i1} %agg, 0
  call void @use8(i8 %adjusted)
  %underflow = extractvalue {i8, i1} %agg, 1
  call void @use1(i1 %underflow)
  %no_underflow = xor i1 %underflow, -1
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

; Commutativity

define i1 @t3_commutability0(i8 %base, i8 %offset) {
; CHECK-LABEL: @t3_commutability0(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp uge i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %no_underflow = icmp ule i8 %offset, %base ; swapped
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}
define i1 @t4_commutability1(i8 %base, i8 %offset) {
; CHECK-LABEL: @t4_commutability1(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp ule i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NO_UNDERFLOW]], [[NOT_NULL]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %no_underflow = icmp ule i8 %base, %offset ; swapped
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %r = and i1 %no_underflow, %not_null ; swapped
  ret i1 %r
}
define i1 @t5_commutability2(i8 %base, i8 %offset) {
; CHECK-LABEL: @t5_commutability2(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp uge i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NO_UNDERFLOW]], [[NOT_NULL]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %no_underflow = icmp ule i8 %offset, %base ; swapped
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %r = and i1 %no_underflow, %not_null ; swapped
  ret i1 %r
}

define i1 @t6_commutability(i8 %base, i8 %offset) {
; CHECK-LABEL: @t6_commutability(
; CHECK-NEXT:    [[AGG:%.*]] = call { i8, i1 } @llvm.usub.with.overflow.i8(i8 [[BASE:%.*]], i8 [[OFFSET:%.*]])
; CHECK-NEXT:    call void @useagg({ i8, i1 } [[AGG]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = extractvalue { i8, i1 } [[AGG]], 0
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = extractvalue { i8, i1 } [[AGG]], 1
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = xor i1 [[UNDERFLOW]], true
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %agg = call {i8, i1} @llvm.usub.with.overflow(i8 %base, i8 %offset)
  call void @useagg({i8, i1} %agg)
  %adjusted = extractvalue {i8, i1} %agg, 0
  call void @use8(i8 %adjusted)
  %underflow = extractvalue {i8, i1} %agg, 1
  call void @use1(i1 %underflow)
  %no_underflow = xor i1 %underflow, -1
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  %r = and i1 %no_underflow, %not_null ; swapped
  ret i1 %r
}

; What if we were checking the opposite question, that we either got null,
; or overflow happened?

define i1 @t7(i8 %base, i8 %offset) {
; CHECK-LABEL: @t7(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = icmp ult i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NULL:%.*]] = icmp eq i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NULL]])
; CHECK-NEXT:    [[R:%.*]] = or i1 [[NULL]], [[UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %underflow = icmp ugt i8 %adjusted, %base
  call void @use1(i1 %underflow)
  %null = icmp eq i8 %adjusted, 0
  call void @use1(i1 %null)
  %r = or i1 %null, %underflow
  ret i1 %r
}

define i1 @t8(i8 %base, i8 %offset) {
; CHECK-LABEL: @t8(
; CHECK-NEXT:    [[AGG:%.*]] = call { i8, i1 } @llvm.usub.with.overflow.i8(i8 [[BASE:%.*]], i8 [[OFFSET:%.*]])
; CHECK-NEXT:    call void @useagg({ i8, i1 } [[AGG]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = extractvalue { i8, i1 } [[AGG]], 0
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = extractvalue { i8, i1 } [[AGG]], 1
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NULL:%.*]] = icmp eq i8 [[ADJUSTED]], 0
; CHECK-NEXT:    [[R:%.*]] = or i1 [[NULL]], [[UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %agg = call {i8, i1} @llvm.usub.with.overflow(i8 %base, i8 %offset)
  call void @useagg({i8, i1} %agg)
  %adjusted = extractvalue {i8, i1} %agg, 0
  call void @use8(i8 %adjusted)
  %underflow = extractvalue {i8, i1} %agg, 1
  call void @use1(i1 %underflow)
  %null = icmp eq i8 %adjusted, 0
  %r = or i1 %null, %underflow
  ret i1 %r
}

; And these patterns also have commutative variants

define i1 @t9_commutative(i8 %base, i8 %offset) {
; CHECK-LABEL: @t9_commutative(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = icmp ult i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NULL:%.*]] = icmp eq i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NULL]])
; CHECK-NEXT:    [[R:%.*]] = or i1 [[NULL]], [[UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %underflow = icmp ult i8 %base, %adjusted ; swapped
  call void @use1(i1 %underflow)
  %null = icmp eq i8 %adjusted, 0
  call void @use1(i1 %null)
  %r = or i1 %null, %underflow
  ret i1 %r
}

;-------------------------------------------------------------------------------

; If we are checking that we either did not get null or got no overflow,
; this is tautological and is always true.

define i1 @t10(i8 %base, i8 %offset) {
; CHECK-LABEL: @t10(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp uge i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[R:%.*]] = or i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %no_underflow = icmp uge i8 %base, %offset
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %r = or i1 %not_null, %no_underflow
  ret i1 %r
}

define i1 @t11(i8 %base, i8 %offset) {
; CHECK-LABEL: @t11(
; CHECK-NEXT:    [[AGG:%.*]] = call { i8, i1 } @llvm.usub.with.overflow.i8(i8 [[BASE:%.*]], i8 [[OFFSET:%.*]])
; CHECK-NEXT:    call void @useagg({ i8, i1 } [[AGG]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = extractvalue { i8, i1 } [[AGG]], 0
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = extractvalue { i8, i1 } [[AGG]], 1
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = xor i1 [[UNDERFLOW]], true
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    [[R:%.*]] = or i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %agg = call {i8, i1} @llvm.usub.with.overflow(i8 %base, i8 %offset)
  call void @useagg({i8, i1} %agg)
  %adjusted = extractvalue {i8, i1} %agg, 0
  call void @use8(i8 %adjusted)
  %underflow = extractvalue {i8, i1} %agg, 1
  call void @use1(i1 %underflow)
  %no_underflow = xor i1 %underflow, -1
  call void @use1(i1 %no_underflow)
  %not_null = icmp ne i8 %adjusted, 0
  %r = or i1 %not_null, %no_underflow
  ret i1 %r
}

; Likewise, if we are checking that we both got null and overflow happened,
; it makes no sense and is always false.

define i1 @t12(i8 %base, i8 %offset) {
; CHECK-LABEL: @t12(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = sub i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = icmp ult i8 [[BASE]], [[OFFSET]]
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NULL:%.*]] = icmp eq i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NULL]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NULL]], [[UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = sub i8 %base, %offset
  call void @use8(i8 %adjusted)
  %underflow = icmp ugt i8 %adjusted, %base
  call void @use1(i1 %underflow)
  %null = icmp eq i8 %adjusted, 0
  call void @use1(i1 %null)
  %r = and i1 %null, %underflow
  ret i1 %r
}

define i1 @t13(i8 %base, i8 %offset) {
; CHECK-LABEL: @t13(
; CHECK-NEXT:    [[AGG:%.*]] = call { i8, i1 } @llvm.usub.with.overflow.i8(i8 [[BASE:%.*]], i8 [[OFFSET:%.*]])
; CHECK-NEXT:    call void @useagg({ i8, i1 } [[AGG]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = extractvalue { i8, i1 } [[AGG]], 0
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[UNDERFLOW:%.*]] = extractvalue { i8, i1 } [[AGG]], 1
; CHECK-NEXT:    call void @use1(i1 [[UNDERFLOW]])
; CHECK-NEXT:    [[NULL:%.*]] = icmp eq i8 [[ADJUSTED]], 0
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NULL]], [[UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %agg = call {i8, i1} @llvm.usub.with.overflow(i8 %base, i8 %offset)
  call void @useagg({i8, i1} %agg)
  %adjusted = extractvalue {i8, i1} %agg, 0
  call void @use8(i8 %adjusted)
  %underflow = extractvalue {i8, i1} %agg, 1
  call void @use1(i1 %underflow)
  %null = icmp eq i8 %adjusted, 0
  %r = and i1 %null, %underflow
  ret i1 %r
}