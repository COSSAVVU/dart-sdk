// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/async_helper.dart";
import "package:expect/expect.dart";
import '../helpers/compiler_helper.dart';

// Test for emitting JavaScript pre- and post-increment and assignment ops.

const String TEST_1 = """
class A {
  var a = 42;
  int foo() { var r = a; a = a + 1; return r; }  // this.a++
}

void main() {
  var a = A();
  print(a.foo());
}
""";

const String TEST_2 = """
class A {
  var a = 42;
  int foo() { var r = a; a = a + 1; return a; }  // ++this.a
}

void main() {
  var a = A();
  print(a.foo());
}
""";

const String TEST_3 = """
class A {
  var a = 42;
  int foo() { var r = a; a = a - 1; return r; }  // this.a--
}

void main() {
  var a = A();
  print(a.foo());
}
""";

const String TEST_4 = """
class A {
  var a = 42;
  int foo() { var r = a; a = a - 1; return a; }  // --this.a
}

void main() {
  var a = A();
  print(a.foo());
}
""";

const String TEST_5 = """
class A {
  var a = 42;
  int foo() { var r = a; a = a - 2; return a; }  // this.a -= 2
}

void main() {
  var a = A();
  print(a.foo());
}
""";

const String TEST_6 = """
class A {
  var a = 42;
  int foo() { var r = a; a = a * 2; return a; }  // this.a *= 2
}

void main() {
  var a = A();
  print(a.foo());
}
""";

main() {
  asyncTest(() async {
    print('--test from kernel------------------------------------------------');
    await runTests();
  });
}

runTests() async {
  test(String code, Function f) async {
    String generated = await compileAll(code, disableInlining: true);
    Expect.isTrue(f(generated));
  }

  await test(TEST_1, (generated) => generated.contains(r'return this.a++;'));
  await test(TEST_2, (generated) => generated.contains(r'return ++this.a;'));
  await test(TEST_3, (generated) => generated.contains(r'return this.a--;'));
  await test(TEST_4, (generated) => generated.contains(r'return --this.a;'));
  await test(TEST_5, (generated) => generated.contains(r' this.a -= 2;'));
  await test(TEST_6, (generated) => generated.contains(r' this.a *= 2;'));
}
