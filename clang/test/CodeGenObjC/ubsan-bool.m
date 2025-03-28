// RUN: %clang_cc1 -no-enable-noundef-analysis -x objective-c -emit-llvm -triple x86_64-apple-macosx10.10.0 -fsanitize=bool -o - -w < %s | FileCheck %s -check-prefixes=SHARED,OBJC
// RUN: %clang_cc1 -no-enable-noundef-analysis -x objective-c++ -emit-llvm -triple x86_64-apple-macosx10.10.0 -fsanitize=bool -o - -w < %s | FileCheck %s -check-prefixes=SHARED,OBJC
// RUN: %clang_cc1 -no-enable-noundef-analysis -x c -emit-llvm -triple x86_64-apple-macosx10.10.0 -fsanitize=bool -o - < %s | FileCheck %s -check-prefixes=SHARED,C

typedef signed char BOOL;

// SHARED-LABEL: define{{.*}}f1
BOOL f1(void) {
  // OBJC: call void @__ubsan_handle_load_invalid_value
  // C-NOT: call void @__ubsan_handle_load_invalid_value
  BOOL a = 2;
  return a + 1;
  // SHARED: ret i8
}

struct S1 {
  BOOL b1 : 1;
};

// SHARED-LABEL: define{{.*}}f2
BOOL f2(struct S1 *s) {
  // OBJC: [[LOAD:%.*]] = load i8, ptr {{.*}}
  // OBJC: [[SHL:%.*]] = shl i8 [[LOAD]], 7
  // OBJC: [[ASHR:%.*]] = ashr i8 [[SHL]], 7
  // OBJC: icmp ule i8 [[ASHR]], 1, !nosanitize
  // OBJC: call void @__ubsan_handle_load_invalid_value

  // C-NOT: call void @__ubsan_handle_load_invalid_value
  return s->b1;
  // SHARED: ret i8
}

#ifdef __OBJC__
@interface SuperClass
@end

@interface I1 : SuperClass {
@public
  BOOL b1 : 1;
}
@property (nonatomic) BOOL b1;
@end
@implementation I1
@synthesize b1;
@end

// Check the synthesized getter.
// OBJC-LABEL: define internal signext i8 @"\01-[I1 b1]"
// OBJC: [[IVAR:%.*]] = load i64, ptr @"OBJC_IVAR_$_I1.b1"
// OBJC: [[ADDR:%.*]] = getelementptr inbounds i8, ptr {{.*}}, i64 [[IVAR]]
// OBJC: [[LOAD:%.*]] = load i8, ptr {{.*}}
// OBJC: [[SHL:%.*]] = shl i8 [[LOAD]], 7
// OBJC: [[ASHR:%.*]] = ashr i8 [[SHL]], 7
// OBJC: icmp ule i8 [[ASHR]], 1, !nosanitize
// OBJC: call void @__ubsan_handle_load_invalid_value

// Also check direct accesses to the ivar.
// OBJC-LABEL: define{{.*}}f3
BOOL f3(I1 *i) {
  // OBJC: [[LOAD:%.*]] = load i8, ptr {{.*}}
  // OBJC: [[SHL:%.*]] = shl i8 [[LOAD]], 7
  // OBJC: [[ASHR:%.*]] = ashr i8 [[SHL]], 7
  // OBJC: icmp ule i8 [[ASHR]], 1, !nosanitize
  // OBJC: call void @__ubsan_handle_load_invalid_value

  return i->b1;
  // OBJC: ret i8
}
#endif /* __OBJC__ */
