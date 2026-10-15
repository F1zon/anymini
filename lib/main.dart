import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const AniChatWebViewApp());
}

/// Неофициальная WebView-обёртка над публичным сайтом anichat.ru.
/// Открывает сайт во встроенном браузере приложения с включённым JS,
/// управлением куками и обработкой ссылок внутри приложения.
class AniChatWebViewApp extends StatelessWidget {
  const AniChatWebViewApp({super.key});

  static const String targetUrl = 'https://anichat.ru/';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnyMini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AniChatHome(title: 'AnyMini'),
    );
  }
}

class AniChatHome extends StatefulWidget {
  const AniChatHome({super.key, required this.title});

  final String title;

  @override
  State<AniChatHome> createState() => _AniChatHomeState();
}

class _AniChatHomeState extends State<AniChatHome> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _loading = progress < 100);
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _loading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (WebResourceError error) {
            // Показываем ошибку только для главного документа, не для суб-ресурсов.
            if (mounted && (error.isForMainFrame ?? false)) {
              setState(() {
                _loading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            // Сторонние домены открываем во внешнем браузере — так куки
            // и сессия anichat.ru не покидают WebView.
            if (uri.host == 'anichat.ru') {
              return NavigationDecision.navigate;
            }
            if (request.isMainFrame) {
              _launchExternal(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AniChatWebViewApp.targetUrl));
  }

  Future<void> _launchExternal(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _showToast('Не удалось открыть ссылку');
    } catch (_) {
      if (mounted) _showToast('Не удалось открыть ссылку');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _retry() {
    _controller.loadRequest(Uri.parse(AniChatWebViewApp.targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _hasError ? _errorView() : WebViewWidget(controller: _controller),
            if (_loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Не удалось загрузить страницу.\nПроверьте подключение к интернету.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retry,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  /// Нижняя панель с навигацией: назад, вперёд, перезагрузка, домой.
  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navButton(Icons.arrow_back, _goBack),
              _navButton(Icons.arrow_forward, _goForward),
              _navButton(Icons.refresh, _reload),
              _navButton(Icons.home, _goHome),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
      tooltip: '',
    );
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  Future<void> _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
    }
  }

  Future<void> _reload() async {
    await _controller.reload();
  }

  Future<void> _goHome() async {
    await _controller.loadRequest(Uri.parse(AniChatWebViewApp.targetUrl));
  }
}