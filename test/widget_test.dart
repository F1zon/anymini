import 'package:flutter_test/flutter_test.dart';

import 'package:anymini/main.dart';

void main() {
  test('App targets the correct site', () {
    expect(AniChatWebViewApp.targetUrl, 'https://anichat.ru/');
  });

  test('App can be constructed', () {
    expect(AniChatWebViewApp(), isA<AniChatWebViewApp>());
  });
}