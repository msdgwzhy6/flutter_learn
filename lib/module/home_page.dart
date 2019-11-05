import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn/generated/i18n.dart';
import 'package:flutter_learn/model/web_view_model.dart';
import 'package:flutter_learn/router_manger.dart';
import 'package:flutter_learn/util/log_util.dart';
import 'package:flutter_learn/util/platform_util.dart';
import 'package:flutter_learn/util/toast_util.dart';
import 'package:flutter_learn/view_model/locale_model.dart';
import 'package:flutter_learn/view_model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

///主页面
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime _lastPressedAt; //上次点击时间
  @override
  void initState() {
    super.initState();

    ///添加监听用于监控前后台转换
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactive");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");

    ///移除监听
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    print("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    LogUtil.e(
        "didChangeAppLifecycleState:" +
            state.toString() +
            ";isAndroid:" +
            Platform.isAndroid.toString(),
        tag: "didChangeAppLifecycleState");
    if (state == AppLifecycleState.paused) {
      ///应用后台
    } else if (state == AppLifecycleState.resumed) {
      ///应用前台
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt) >
                Duration(milliseconds: 1500)) {
          //两次点击间隔超过1秒则重新计时
          _lastPressedAt = DateTime.now();
          ToastUtil.show(S.of(context).quitApp,
              position: ToastPosition.bottom,
              duration: Duration(milliseconds: 1500));
          return false;
        }
        return true;
      },
      child: ContainerWidget(),
    );
  }
}

///主干
// ignore: must_be_immutable
class ContainerWidget extends StatelessWidget {
  Color iconColor;

  @override
  Widget build(BuildContext context) {
    iconColor = Theme.of(context).iconTheme.color;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appName),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: FadeInImage.assetNetwork(
                width: 32,
                placeholder: "assets/image/start/ic_launcher.png",
                image:
                    "https://avatars0.githubusercontent.com/u/19605922?s=460&v=4",
                fit: BoxFit.cover,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(RouteName.webView,
                  arguments: WebViewModel.getModel("Aries Hoo's jian shu",
                      "https://www.jianshu.com/u/a229eee96115"));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        primary: true,
        child: ListTileTheme(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ///选择字体
              ChoiceFontWidget(),

              ///选择语言
              ChoiceLanguageWidget(),

              ///黑夜模式
              Material(
                color: Theme.of(context).cardColor,
                child: ListTile(
                  title: Text(S.of(context).darkMode),
                  leading: Icon(
                    Theme.of(context).brightness == Brightness.light
                        ? Icons.brightness_5
                        : Icons.brightness_2,
                    color: iconColor,
                  ),
                  trailing: CupertinoSwitch(
                    activeColor: Theme.of(context).accentColor,
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (bool checked) => switchDarkMode(context),
                  ),
                  onTap: () => switchDarkMode(context),
                ),
              ),

              ///选择颜色主题
              ChoiceThemeWidget(),
              _getButtonWidget(
                  context, S.of(context).moviePage, RouteName.movie, null),
              _getButtonWidget(
                  context, S.of(context).loginPage, RouteName.login, null),
              _getButtonWidget(
                  context,
                  S.of(context).webViewPage,
                  RouteName.webView,
                  WebViewModel.getModel(
                      "Aries Hoo's Github", "https://github.com/AriesHoo")),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  RaisedButton _getButtonWidget(
      BuildContext context, String text, String router, Object arguments) {
    return RaisedButton(
      elevation: 1,
      color: ThemeModel.themeAccentColor,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onPressed: () {
        Navigator.of(context).pushNamed(router, arguments: arguments);
      },
    );
  }

  void switchDarkMode(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      ToastUtil.show("检测到系统为暗黑模式,已为你自动切换");
    } else {
      Provider.of<ThemeModel>(context).switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }
}

///字体选择
class ChoiceFontWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(S.of(context).choiceFont),
            Text(
              ThemeModel.fontName(context),
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
        leading: Icon(
          Icons.font_download,
          color: Theme.of(context).iconTheme.color,
        ),
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              itemCount: ThemeModel.fontValueList.length,
              itemBuilder: (context, index) {
                var model = Provider.of<ThemeModel>(context);
                return RadioListTile(
                  value: index,
                  onChanged: (index) {
                    model.switchFont(index);
                  },
                  groupValue: model.fontIndex,
                  title: Text(
                    ThemeModel.fontName(context, i: index),
                    style: TextStyle(
                      fontFamily: model.fontFamilyIndex(index: index),
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}

///系统语言选择
class ChoiceLanguageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              S.of(context).choiceLanguage,
              style: TextStyle(),
            ),
            Text(
              LocaleModel.localeName(
                  Provider.of<LocaleModel>(context).localeIndex, context),
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
        leading: Icon(
          Icons.public,
          color: Theme.of(context).iconTheme.color,
        ),
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              itemCount: LocaleModel.localeValueList.length,
              itemBuilder: (context, index) {
                var model = Provider.of<LocaleModel>(context);
                return RadioListTile(
                  value: index,
                  onChanged: (index) {
                    model.switchLocale(index);
                  },
                  groupValue: model.localeIndex,
                  title: Text(LocaleModel.localeName(index, context)),
                );
              })
        ],
      ),
    );
  }
}

///颜色主题选择
class ChoiceThemeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              S.of(context).choiceTheme,
            ),
            Text(
              ThemeModel.themeName(context),
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
        leading: Icon(
          Icons.color_lens,
          color: Theme.of(context).iconTheme.color,
        ),
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              itemCount: ThemeModel.themeValueList.length,
              itemBuilder: (context, index) {
                var model = Provider.of<ThemeModel>(context);
                return RadioListTile(
                  value: index,
                  onChanged: (index) {
                    model.switchTheme(themeIndex: index);
                  },
                  groupValue: model.themeIndex,
                  title: Text(
                    ThemeModel.themeName(context, i: index),
                    style: TextStyle(
                      color: ThemeModel.themeValueList[index],
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}

///抽屉栏
class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.network(
            "https://avatars0.githubusercontent.com/u/19605922?s=460&v=4",
            width: 100.0,
          ),
        ],
      ),
    );
  }
}
