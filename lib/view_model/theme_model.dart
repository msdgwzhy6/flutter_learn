import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learn/generated/i18n.dart';

///主题管理
class ThemeModel with ChangeNotifier {
  ///颜色主题列表
  static const List<MaterialColor> themeValueList = <MaterialColor>[
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple
  ];

  ///字体列表
  static const fontValueList = ['system', 'StarCandy'];

  /// 当前主题颜色
  static MaterialColor _themeColor = Colors.blue;
  static Color _accentColor = _themeColor;

  /// 用户选择的明暗模式
  static bool _userDarkMode = false;

  static bool get darkMode => _userDarkMode;

  /// 当前字体索引
  static int _fontIndex = 0;

  int get fontIndex => _fontIndex;

  /// 当前主题索引
  static int _themeIndex = 0;

  int get themeIndex => _themeIndex;

  static MaterialColor get themeColor => _themeColor;

  ///白色主题状态栏及导航栏颜色
  Color colorWhiteTheme = Color(0x66000000);

  static Color colorBlackTheme = Colors.grey[900];

  static Color get accentColor => _accentColor;

  /// 切换字体
  switchFont(int index) {
    _fontIndex = index;
    switchTheme();
  }

  static String fontFamily() {
    return fontValueList[_fontIndex];
  }

  String fontFamilyIndex({int index}) {
    return fontValueList[index ?? _fontIndex];
  }

  /// 切换指定色彩
  ///
  /// 没有传[brightness]就不改变brightness,color同理
  void switchTheme({bool userDarkMode, int themeIndex, MaterialColor color}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;
    _themeIndex = themeIndex ?? _themeIndex;
    _themeColor = color ?? themeValueList[_themeIndex];
    debugPrint("_userDarkMode" +
        _userDarkMode.toString() +
        "_themeIndex:" +
        _themeIndex.toString() +
        "_themeColor:" +
        _themeColor.toString());
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _userDarkMode ? Colors.transparent : colorWhiteTheme,
      systemNavigationBarColor:
          _userDarkMode ? colorBlackTheme : colorWhiteTheme,
    ));
    notifyListeners();
  }

  /// 随机一个主题色彩
  ///
  /// 可以指定明暗模式,不指定则保持不变
  void switchRandomTheme({Brightness brightness}) {
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(
      userDarkMode: Random().nextBool(),
      themeIndex: colorIndex,
    );
  }

  /// 根据主题 明暗 和 颜色 生成对应的主题
  /// [dark]系统的Dark Mode
  themeData({bool platformDarkMode: false}) {
    var isDark = platformDarkMode || _userDarkMode;
    var themeColor = _themeColor;
    _accentColor = isDark ? themeColor[600] : _themeColor;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    var themeData = ThemeData(
      brightness: brightness,
      primaryColorBrightness: Brightness.dark,
      accentColorBrightness: Brightness.dark,
      primarySwatch: themeColor,
      accentColor: accentColor,
      primaryColor: accentColor,

      ///类苹果跟随滑动返回-修改后返回箭头及主标题iOS风格
      platform: TargetPlatform.iOS,
      errorColor: Colors.red,
      toggleableActiveColor: accentColor,

      ///输入框光标
      cursorColor: accentColor,

      ///字体
      fontFamily: fontValueList[_fontIndex],
    );

    themeData = themeData.copyWith(
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: themeColor,
      ),
      appBarTheme: themeData.appBarTheme.copyWith(
        ///设置主题决定状态栏icon颜色
//        brightness: _userDarkMode ? Brightness.dark : Brightness.light,
        color: _userDarkMode ? colorBlackTheme : Colors.white,
        elevation: 0,
        textTheme: TextTheme(
          title: TextStyle(
            color: isDark ? Colors.white : accentColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,

            ///字体
            fontFamily: fontValueList[_fontIndex],
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : accentColor,
        ),
      ),
      iconTheme: themeData.iconTheme.copyWith(
        color: accentColor,
      ),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      textTheme: themeData.textTheme.copyWith(
          subhead: themeData.textTheme.subhead.copyWith(
        textBaseline: TextBaseline.alphabetic,
      )),
      textSelectionColor: accentColor.withAlpha(60),
      textSelectionHandleColor: accentColor.withAlpha(60),
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 6),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),

      ///TabBar样式设置
      tabBarTheme: themeData.tabBarTheme.copyWith(
        ///标签内边距
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      floatingActionButtonTheme: themeData.floatingActionButtonTheme.copyWith(
        backgroundColor: themeAccentColor,
        splashColor: themeColor.withAlpha(50),
      ),
    );
    return themeData;
  }

  static Color get themeAccentColor =>
      _userDarkMode ? colorBlackTheme : accentColor;

  /// 根据索引获取字体名称,这里牵涉到国际化
  static String fontName(context, {int i}) {
    int index = i ?? _fontIndex;
    switch (index) {
      case 0:
        return S.of(context).autoBySystem;
      case 1:
        return S.of(context).starCandy;
      default:
        return '';
    }
  }

  /// 根据索引获取颜色名称,这里牵涉到国际化
  static String themeName(context, {int i}) {
    int index = i ?? _themeIndex;
    switch (index) {
      case 0:
        return S.of(context).blue;
      case 1:
        return S.of(context).green;
      case 2:
        return S.of(context).orange;
      case 3:
        return S.of(context).red;
      case 4:
        return S.of(context).purple;
      default:
        return '';
    }
  }
}
