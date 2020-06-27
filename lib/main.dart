import 'package:flutter/material.dart';
import 'package:nokiapro/dialer.dart';
import 'package:nokiapro/styles/app_colors.dart';
import 'package:provider/provider.dart';

import 'dialer_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DialerModel>(
      create: (context) => DialerModel(),
      child: MaterialApp(
        title: 'Nokia Pro',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 100,
            left: 50,
            right: 50,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 2,
              color: AppColors.greenScreenColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Consumer<DialerModel>(
                    builder: (context, value, child) => Text(
                      value.number,
                      style: TextStyle(color: Colors.black, fontSize: 25),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/nokiabig.png'),
                    fit: BoxFit.contain)),
          ),
          Dialer(),
        ],
      ),
    );
  }
}
