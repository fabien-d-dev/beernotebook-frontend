import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutView extends StatefulWidget {
  final String url;
  const CheckoutView({super.key, required this.url});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('payment_success')) {
              Navigator.of(context).pop('success');
              return NavigationDecision.prevent;
            } else if (request.url.contains('payment_cancel')) {
              Navigator.of(context).pop('cancel');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement sécurisé")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
