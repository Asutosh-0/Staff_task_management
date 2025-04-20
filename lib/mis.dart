import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatelessWidget {
  final String url = "https://creativecollege.in/MIS/MIS/Note%20and%20assignment%20project%201/index.php";

  void _launchURL() async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Open in Browser")),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchURL,
          child: Text("Open in Chrome"),
        ),
      ),
    );
  }
}
