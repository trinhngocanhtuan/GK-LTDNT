import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gk_ltdd/main.dart'; // Đảm bảo rằng đây là đường dẫn chính xác

void main() {
  testWidgets('Thêm sản phẩm vào danh sách', (WidgetTester tester) async {
    // Build ứng dụng và tạo khung hình đầu tiên.
    await tester.pumpWidget(MyApp());

    // Xác minh rằng không có sản phẩm nào trong danh sách ban đầu.
    expect(find.text('Dữ liệu sản phẩm'), findsOneWidget);

    // Nhập dữ liệu sản phẩm vào các trường văn bản.
    await tester.enterText(find.byType(TextField).at(0), 'Sản phẩm A'); // Tên sản phẩm
    await tester.enterText(find.byType(TextField).at(1), 'Loại A'); // Loại sản phẩm
    await tester.enterText(find.byType(TextField).at(2), '100'); // Giá sản phẩm
    await tester.enterText(find.byType(TextField).at(3), 'https://example.com/image.png'); // Hình ảnh sản phẩm

    // Nhấn nút Thêm.
    await tester.tap(find.text('THÊM SẢN PHẨM'));
    await tester.pump(); // Đợi cho giao diện được cập nhật.

    // Xác minh rằng sản phẩm đã được thêm vào danh sách.
    expect(find.text('Tên sp: Sản phẩm A'), findsOneWidget);
    expect(find.text('Giá sp: 100'), findsOneWidget);
    expect(find.text('Loại sp: Loại A'), findsOneWidget);
  });
}
