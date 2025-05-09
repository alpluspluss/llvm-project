; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S --passes=slp-vectorizer -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512dq -slp-threshold=-99999 < %s | FileCheck %s

define i32 @test(i32 %arg, i32 %arg1) {
; CHECK-LABEL: define i32 @test(
; CHECK-SAME: i32 [[ARG:%.*]], i32 [[ARG1:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  [[BB:.*:]]
; CHECK-NEXT:    [[ZEXT:%.*]] = zext i32 [[ARG1]] to i64
; CHECK-NEXT:    [[ZEXT2:%.*]] = zext i32 [[ARG]] to i64
; CHECK-NEXT:    [[SEXT:%.*]] = sext i32 [[ARG]] to i64
; CHECK-NEXT:    br label %[[BB3:.*]]
; CHECK:       [[BB3]]:
; CHECK-NEXT:    [[GETELEMENTPTR:%.*]] = getelementptr i64, ptr addrspace(1) null, i64 [[ZEXT]]
; CHECK-NEXT:    [[GETELEMENTPTR4:%.*]] = getelementptr i64, ptr addrspace(1) null, i64 [[ZEXT2]]
; CHECK-NEXT:    [[GETELEMENTPTR5:%.*]] = getelementptr i64, ptr addrspace(1) null, i64 [[SEXT]]
; CHECK-NEXT:    [[ZEXT6:%.*]] = zext i32 0 to i64
; CHECK-NEXT:    [[GETELEMENTPTR7:%.*]] = getelementptr i64, ptr addrspace(1) null, i64 [[ZEXT6]]
; CHECK-NEXT:    ret i32 0
;
bb:
  %zext = zext i32 %arg1 to i64
  %zext2 = zext i32 %arg to i64
  %sext = sext i32 %arg to i64
  br label %bb3

bb3:
  %getelementptr = getelementptr i64, ptr addrspace(1) null, i64 %zext
  %getelementptr4 = getelementptr i64, ptr addrspace(1) null, i64 %zext2
  %getelementptr5 = getelementptr i64, ptr addrspace(1) null, i64 %sext
  %zext6 = zext i32 0 to i64
  %getelementptr7 = getelementptr i64, ptr addrspace(1) null, i64 %zext6
  ret i32 0
}
