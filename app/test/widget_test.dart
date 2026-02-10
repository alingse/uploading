// This is a basic Flutter widget test for the 记忆上传 (Memory Upload) app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uploading/main.dart';

void main() {
  testWidgets('App启动测试', (WidgetTester tester) async {
    // 构建应用并触发一帧
    await tester.pumpWidget(const MyApp());

    // 验证应用显示欢迎页面
    expect(find.text('欢迎使用记忆上传'), findsOneWidget);
    expect(find.text('记录您的物品、照片和时间事件'), findsOneWidget);
    expect(find.byType(Icon), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('FloatingActionButton点击测试', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(const MyApp());

    // 验证FloatingActionButton存在且可点击
    expect(find.byType(FloatingActionButton), findsOneWidget);
    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.onPressed, isNotNull);
  });
}
