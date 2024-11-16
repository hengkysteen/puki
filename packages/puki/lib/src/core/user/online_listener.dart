import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:puki/puki.dart';
import 'package:puki/src/core/settings/settings.dart';

import 'package:universal_html/html.dart' as html;
import '../helper/log.dart';

class OnlineStatusListener {
  // 1. Create a static variable that serves as the singleton _instance of this class.
  static final OnlineStatusListener _instance = OnlineStatusListener._internal();
  // 2. Create a private constructor to prevent the creation of additional instances of this class.
  OnlineStatusListener._internal();
  // 3. Create a factory method that returns the single instance (_instance) of this class.

  factory OnlineStatusListener() => _instance;

  static html.EventListener _getWebListener() => (html.Event event) => OnlineStatusListener._instance._visibilitychange(event);

  final html.EventListener _webListener = _getWebListener();

  PmUser? get currentUser => Puki.user.currentUser;

  int get debounceDuration => PukiSettings().client.onlineStatusDebounceDuration;

  bool lastStatus = true;
  bool statusFromDB = true;
  bool _isOnline = true;
  Timer? _debounceTimer;

  void _visibilitychange(html.Event e) {
    if (html.document.hidden!) {
      _setOffline();
    } else {
      _setOnline();
    }
  }

  void _beforeunload(html.Event e) {
    print("_beforeunload");
    Puki.user.setOnline(false);
  }

  void _setOnline() {
    lastStatus = true;
    if (!_isOnline) {
      _isOnline = true;
      _debounce(() {
        if (lastStatus != statusFromDB) {
          Puki.user.setOnline(true);
          statusFromDB = true;
        }
      });
    }
  }

  void _setOffline() {
    lastStatus = false;
    if (_isOnline) {
      _isOnline = false;
      _debounce(() {
        if (lastStatus != statusFromDB) {
          Puki.user.setOnline(false);
          statusFromDB = false;
        }
      });
    }
  }

  void _debounce(Function() action) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: debounceDuration), action);
  }

  void addOnlineStatusListener() {
    devLog("OnlineStatusListener > addOnlineStatusListener");
    if (kIsWeb) {
      html.document.addEventListener('visibilitychange', _webListener);
      html.window.addEventListener('beforeunload', _beforeunload);
    } else {
      WidgetsBinding.instance.addObserver(_OnlineStatusListenerObserver());
    }
  }

  void removeOnlineStatusListener() {
    devLog("OnlineStatusListener > removeOnlineStatusListener");
    if (kIsWeb) {
      html.document.removeEventListener('visibilitychange', _webListener);
      html.window.removeEventListener('beforeunload', _beforeunload);
    } else {
      WidgetsBinding.instance.removeObserver(_OnlineStatusListenerObserver());
    }
  }
}

class _OnlineStatusListenerObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OnlineStatusListener()._setOnline();
    }
    if (state == AppLifecycleState.paused) {
      OnlineStatusListener()._setOffline();
    }
    if (state == AppLifecycleState.detached) {
      OnlineStatusListener()._setOffline();
    }
    if (state == AppLifecycleState.detached) {
      Puki.user.setOnline(false);
    }
  }
}
