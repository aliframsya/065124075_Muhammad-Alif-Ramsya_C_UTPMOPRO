import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:utp_mopro/database/database_helper.dart';
import 'package:utp_mopro/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App should build and show catalog title', (WidgetTester tester) async {
    DatabaseHelper.ensureInitialized();
    await tester.pumpWidget(const KopiNusantaraApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Kopi Nusantara'), findsOneWidget);
  });
}
