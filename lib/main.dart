import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'آموزشگاه موسیقی شمشال',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade600),
        fontFamily: 'IRANYekan',
      ),

      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'آموزشگاه موسیقی شمشال'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController controller;
  bool _webviewError = false;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) async {
            try {
              final can = await controller.canGoBack();
              setState(() {
                _canGoBack = can;
              });
            } catch (e) {}
          },
          onPageFinished: (String url) async {
            try {
              final can = await controller.canGoBack();
              setState(() {
                _canGoBack = can;
              });
              final css =
                  '.nextui-navbar-container { margin-top: 38px !important; }';
              final js =
                  "(function(){var s=document.createElement('style');s.type='text/css';s.appendChild(document.createTextNode(${jsonEncode(css)}));document.head.appendChild(s);})();";
              await controller.runJavaScript(js);
            } catch (e) {
              // ignore
            }
          },
          onWebResourceError: (WebResourceError error) {
            // mark error and allow fallback
            setState(() {
              _webviewError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://shemshalmusic.ir'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          if (await controller.canGoBack()) {
            await controller.goBack();
            return false; // don't pop the app
          }
        } catch (e) {
          // if anything goes wrong, allow pop
        }
        return true; // pop app
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: _canGoBack
            ? FloatingActionButton(
                onPressed: () async {
                  if (await controller.canGoBack()) {
                    await controller.goBack();
                    final can = await controller.canGoBack();
                    setState(() {
                      _canGoBack = can;
                    });
                  }
                },
                child: const Icon(Icons.arrow_back_ios),
              )
            : null,
        body: _webviewError
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 400,
                      width: 400,
                      child: Image(image: AssetImage("assets/no_internet.jpg")),
                    ),
                    const SizedBox(height: 12),
                    const Text('خطا در برقراری ارتباط'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // retry: clear error and reload
                            setState(() {
                              _webviewError = false;
                            });
                            try {
                              await controller.reload();
                            } catch (e) {
                              // if reload fails, set error again
                              setState(() {
                                _webviewError = true;
                              });
                            }
                          },
                          child: const Text('تلاش مجدد'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : WebViewWidget(controller: controller),
      ),
    );
  }
}
