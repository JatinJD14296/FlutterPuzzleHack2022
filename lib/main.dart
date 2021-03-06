import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nokiapro/dialer.dart';
import 'package:nokiapro/snake/board.dart';
import 'package:nokiapro/styles/app_colors.dart';
import 'package:nokiapro/styles/app_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialer_model.dart';

import './menu.dart';
import 'game_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DialerModel>(create: (context) => DialerModel()),
        ChangeNotifierProvider<GameModel>(create: (context) => GameModel()),
      ],
      child: MaterialApp(
        title: 'Nokia Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'nokiaFonts',
          primarySwatch: Colors.grey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

enum AppState { GAME, HOME, MENU }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int menuIdx = 0;
  bool menuTapped = false;
  AppState appState = AppState.HOME;
  String _time;

  @override
  void initState() {
    _time = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 5), (Timer t) => _getTime());
    super.initState();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _time = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat("HH:mm").format(dateTime);
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch('tel:' + url)) {
      await launch('tel:' + url);
    } else {
      print('Could not launch $url');
    }
  }

  double dx = 0;
  double dy = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            dx += details.delta.dx/4;
            dy += details.delta.dy/4;
          });
        },
        child: Transform(
          origin: Offset(100, 100),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.01 * dy)
            ..rotateY(-0.01 * dx),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 165,
                left: 60,
                right: 60,
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width / 4,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  color: AppColors.greenScreenColor,
                  child: (appState == AppState.HOME)
                      ? buildHome()
                      : ((appState == AppState.MENU) ? menu() : Board()),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/nokiacutscreenv2.png'),
                        fit: BoxFit.contain)),
              ),
              Dialer(),
              // Menu Button
              Positioned(
                top: MediaQuery.of(context).size.height / 1.9,
                left: 150,
                right: 150,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextButton(
                    child: Text(''),
                    onPressed: () {
                      setState(() {
                        if (appState == AppState.HOME) {
                          if (Provider.of<DialerModel>(context, listen: false)
                                  .number
                                  .length >
                              0) {
                            _makePhoneCall(
                                Provider.of<DialerModel>(context, listen: false)
                                    .number);
                          } else {
                            appState = AppState.MENU;
                            menuTapped = true;
                          }
                        } else if (appState == AppState.MENU)
                          appState = AppState.GAME;
                        else if (appState == AppState.GAME) {
                          Provider.of<GameModel>(context, listen: false)
                              .moveFromSplashToRunningState();
                        }
                      });
                    },
                  ),
                ),
              ),
              // C Button
              Positioned(
                top: MediaQuery.of(context).size.height / 1.8,
                left: 100,
                right: 250,
                child: TextButton(
                  onPressed: () {
                    if (appState == AppState.MENU) {
                      setState(() {
                        menuTapped = false;
                        appState = AppState.HOME;
                      });
                    } else if (appState == AppState.GAME) {
                      setState(() {
                        appState = AppState.MENU;
                      });
                    } else {
                      Provider.of<DialerModel>(context, listen: false).delete();
                    }
                  },
                  onLongPress: () {
                    if (menuTapped) {
                      setState(() {
                        menuTapped = !menuTapped;
                      });
                    } else {
                      Provider.of<DialerModel>(context, listen: false).clear();
                    }
                  },
                  child: Text(""),
                ),
              ),
              // Forward Button
              Positioned(
                top: MediaQuery.of(context).size.height / 1.8,
                left: 270,
                right: 80,
                child: TextButton(
                  onPressed: () {
                    if (appState == AppState.GAME) {
                      Provider.of<GameModel>(context, listen: false)
                          .changeDirection(Direction.UP);
                    } else {
                      if (menuIdx == MenuItem.menuItems.length - 1) {
                        setState(() {
                          menuIdx = 0;
                        });
                      } else
                        setState(() {
                          menuIdx++;
                        });
                    }
                  },
                  child: Text(""),
                ),
              ),
              // Backward Button
              Positioned(
                top: MediaQuery.of(context).size.height / 1.7,
                left: 230,
                right: 130,
                child: TextButton(
                  onPressed: () {
                    if (appState == AppState.GAME) {
                      Provider.of<GameModel>(context, listen: false)
                          .changeDirection(Direction.DOWN);
                    } else {
                      if (menuIdx == 0) {
                        setState(() {
                          menuIdx = MenuItem.menuItems.length - 1;
                        });
                      } else
                        setState(() {
                          menuIdx--;
                        });
                    }
                  },
                  child: Text(""),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildHome() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barLargest, height: 24),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barLarge, height: 20),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barSmall, height: 16),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barMedium, height: 16),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              padding: const EdgeInsets.only(left: 5.0),
              child: AppSVG.getSVG(AppSVG.signal),
            ),
          ],
        ),
        Container(
          height: 400,
          width: 150,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned(
                top: 40.0,
                right: 0.0,
                child: Text(_time),
              ),
              Positioned(
                top: 50,
                child: Container(
                  height: 110,
                  width: 150,
                  child: Consumer<DialerModel>(
                    builder: (context, value, child) => value.number.length > 0
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              value.number,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 70,
                                width: 50,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/flutter logo.png'))),
                              ),
                              Text('#Nokia3310'),
                            ],
                          ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(Provider.of<DialerModel>(context).number.length > 0
                    ? 'Call'
                    : 'Menu'),
              )
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barLargest, height: 24),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barLarge, height: 20),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barSmall, height: 16),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              child: AppSVG.getSVG(AppSVG.barMedium, height: 16),
            ),
            Container(
              margin: const EdgeInsets.all(2.0),
              padding: const EdgeInsets.only(right: 5.0),
              child: AppSVG.getSVG(AppSVG.battery),
            ),
          ],
        ),
      ],
    );
  }

  Widget menu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 160,
          width: 200,
          color: AppColors.greenScreenColor,
          child: Stack(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          MenuItem.menuItems[menuIdx].name,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Icon(
                      MenuItem.menuItems[menuIdx].icon,
                      size: 40,
                    ),
                  ],
                ),
              ),
              Positioned(
                  top: 30.0,
                  right: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${menuIdx + 1}',
                      style: TextStyle(fontSize: 15),
                    ),
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Select',
                    style: TextStyle(fontSize: 18),
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
