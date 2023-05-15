import 'package:flutter/services.dart';

class NativeChannel  {
  //jjyp的自有通信频道，暂自实现通信，信任flutter sdk
  static const MethodChannel methodChannel = MethodChannel('sk_channel');

  static final String GET_VERSION = "getNativeVersion";
  static final String OPEN_WEBVIEW = "openWebView";

  static final String HTTP = "http";
}