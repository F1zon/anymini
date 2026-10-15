# AnyMini

Неофициальная минималистичная WebView-обёртка над публичным сайтом
[anichat.ru](https://anichat.ru/) — аниме-чатом для знакомств и общения.
Приложение открывает сайт во встроенном браузере, сохраняет сессию/куки и
даёт удобную мобильную навигацию.

> ⚠️ Это **не** официальное приложение. Автор обёртки не связан с владельцем
> сайта. Все права на сайт, контент и бренд принадлежат их владельцу.

## Возможности

- Встроенный WebView с включённым JavaScript (движок сайта на JS).
- Сохранение кук и сессии — авторизация работает.
- Нижняя панель навигации: назад / вперёд / обновить / домой.
- Сторонние ссылки открываются во внешнем браузере (куки не покидают WebView).
- Тёмная тема, индикатор загрузки, экран ошибки сети с кнопкой «Повторить».

## Платформы

- **Android** — работает, собранный APK в `release`.
- **iOS** — код готов; сборка требует macOS + Xcode.

## Используемые технологии

- [Flutter](https://flutter.dev/) 3.29+ / Dart 3.7+
- [`webview_flutter`](https://pub.dev/packages/webview_flutter) — встроенный WebView
- [`url_launcher`](https://pub.dev/packages/url_launcher) — внешний браузер
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) — генерация иконок

## Сборка

```bash
# Установить зависимости
flutter pub get

# Сгенерировать иконки (обязательно после изменения assets/icons/app_icon_1024.png)
dart run flutter_launcher_icons

# Проверка кода и тесты
flutter analyze
flutter test

# Android APK (debug)
flutter build apk --debug

# Android APK (release) — без ключа fallback на debug-подпись
flutter build apk --release
```

### Подписанный release (для публикации)

Создайте keystore и передайте его через переменные окружения:

```bash
keytool -genkeypair -v -keystore release-key.p12 -storetype pkcs12 \
  -alias anymini -keyalg RSA -keysize 2048 -validity 10000

# Linux/macOS
export ANIMINI_KEYSTORE=/path/to/release-key.p12
export ANIMINI_KEYSTORE_PASSWORD=your-secret-password
# Windows (PowerShell)
$env:ANIMINI_KEYSTORE="C:\path\to\release-key.p12"
$env:ANIMINI_KEYSTORE_PASSWORD="your-secret-password"

flutter build apk --release
```

Без переменных окружения release-сборка подписывается debug-ключом (удобно
для локальной проверки). Для публикации в Google Play / RuStore обязательно
создайте свой keystore и храните его в надёжном месте — потеря ключа не
позволит обновлять приложение.

## Безопасность

- Запрещён незашифрованный (http) трафик — только https
  (`network_security_config.xml`, `android:usesCleartextTraffic="false"`).
- Отключены авто-бэкапы (`android:allowBackup="false"`).
- Сторонние ссылки не загружаются внутри WebView — открываются во внешнем
  браузере, куки anichat.ru не передаются третьим лицам.
- Ключи подписи исключены из репозитория (`.gitignore`).

## Структура

```
lib/main.dart          — код приложения (WebView + навигация)
assets/icons/          — исходник иконки (1024×1024, PNG с прозрачностью)
tool/make_icon.py      — скрипт генерации исходной иконки (Pillow)
android/               — настройки Android
ios/                   — настройки iOS
```

## Публикация

Приложение распространяется через GitHub-релизы (заранее собранный APK).
Оно не выкладывается в Google Play, поскольку у автора нет прав на контент
сайта anichat.ru; магазин отклонит неофициальную обёртку по DMCA/жалобе
владельца.