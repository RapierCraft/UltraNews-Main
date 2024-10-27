import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/../utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  static String tag = '/WebViewScreen';
  final String? mInitialUrl;
  final bool isAdsLoad;
  final String? name;

  WebViewScreen({this.mInitialUrl, this.isAdsLoad = false, this.name});

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool? isLoading = true;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: true,
        useOnDownloadStart: true,
        javaScriptEnabled: true,
        userAgent: "Mozilla/5.0 (Linux; Android 4.2.2; GT-I9505 Build/JDQ39) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.59 Mobile Safari/537.36",
        javaScriptCanOpenWindowsAutomatically: true,
      ),
      android: AndroidInAppWebViewOptions(useHybridComposition: true),
      ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true));

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    init();
  }

  init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget mBody() {
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest: URLRequest(url: Uri.parse(widget.mInitialUrl == null ? 'https://www.google.com' : widget.mInitialUrl!)),
      initialOptions: options,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        log("onLoadStart");
        setState(() {
          isLoading = true;
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var url = navigationAction.request.url.toString();
        log("URL  ---> " + url.toString());

        if (Platform.isAndroid && url.contains("intent")) {
          if (url.contains("maps")) {
            var mNewURL = url.replaceAll("intent://", "https://");
            if (await canLaunchUrl(Uri.parse(mNewURL))) {
              await launchUrl(Uri.parse(mNewURL));
              return NavigationActionPolicy.CANCEL;
            }
          } else {
            String id = url.substring(url.indexOf('id%3D') + 5);
            log(id);
            var data = id.splitBefore(';');
            log(data.splitBefore(';'));
            data = data.splitBefore(';');
            finish(context);
            await StoreRedirect.redirect(androidAppId: data);

            return NavigationActionPolicy.CANCEL;
          }
        } else if (url.contains("linkedin.com") ||
            url.contains("market://") ||
            url.contains("whatsapp://") ||
            url.contains("truecaller://") ||
            url.contains("pinterest.com") ||
            url.contains("snapchat.com") ||
            url.contains("instagram.com") ||
            url.contains("play.google.com") ||
            url.contains("mailto:") ||
            url.contains("tel:") ||
            url.contains("share=telegram") ||
            url.contains("messenger.com")) {
          if (url.contains("https://api.whatsapp.com/send?phone=+")) {
            url = url.replaceAll("https://api.whatsapp.com/send?phone=+", "https://api.whatsapp.com/send?phone=");
          } else if (url.contains("whatsapp://send/?phone=%20")) {
            url = url.replaceAll("whatsapp://send/?phone=%20", "whatsapp://send/?phone=");
          }
          if (!url.contains("whatsapp://")) {
            url = Uri.encodeFull(url);
          }
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              log("Step4 " + url.toString());
              launchUrl(Uri.parse(url));
            } else {
              log("Step25 " + url.toString());

              launchUrl(Uri.parse(url));
            }
            return NavigationActionPolicy.CANCEL;
          } catch (e) {
            log("Step6" + url);
            launchUrl(Uri.parse(url));
            return NavigationActionPolicy.CANCEL;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
      onLoadStop: (controller, url) async {
        log("onLoadStop");
        setState(() {
          isLoading = false;
        });
      },
      onLoadError: (controller, url, code, message) {
        log("onLoadError" + message);
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(widget.name != null && widget.name!.isNotEmpty ? widget.name! : "", showBack: true,systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white, color: colorPrimary),
      body: mBody(),
    );
  }
}
