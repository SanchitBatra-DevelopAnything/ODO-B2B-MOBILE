import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:odo_mobile_v2/cartScreen.dart';
import 'package:odo_mobile_v2/categories.dart';
import 'package:odo_mobile_v2/home.dart';
import 'package:odo_mobile_v2/login.dart';
import 'package:odo_mobile_v2/myOrders.dart';
import 'package:odo_mobile_v2/myProfile.dart';
import 'package:odo_mobile_v2/afterSignUp.dart';
import 'package:odo_mobile_v2/orderDone.dart';
import 'package:odo_mobile_v2/otp.dart';
import 'package:odo_mobile_v2/providers/auth.dart';
import 'package:odo_mobile_v2/providers/cart.dart';
import 'package:odo_mobile_v2/providers/categories_provider.dart';
import 'package:odo_mobile_v2/providers/banner.dart';
import 'package:odo_mobile_v2/providers/orders.dart';
import 'package:odo_mobile_v2/signUp.dart';
import 'package:odo_mobile_v2/termsAndConditions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'items.dart';
import 'orderSummary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => CategoriesProvider()),
      ChangeNotifierProvider(create: (context) => CartProvider()),
      ChangeNotifierProvider(create: (context) => OrderProvider()),
      ChangeNotifierProvider(create : (context)=> BannerProvider()),
    ], child: const MaterialAppWithInitialRoute());
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MaterialAppWithInitialRoute extends StatelessWidget {
  const MaterialAppWithInitialRoute({Key? key}) : super(key: key);

  Future<String> getInitialRoute() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey('loggedInDistributor')) {
      String loggedIncontact = sp.getString('loggedIncontact') ?? '';
      if(loggedIncontact == '' || loggedIncontact.isEmpty){
        return '/';
      }
      else
      {
        //call authProvider to check if contact is still valid
        AuthProvider authProvider = AuthProvider();
        bool isValid = await authProvider.checkDistributorContact(loggedIncontact);
        if(!isValid){
          //clear shared preferences
          sp.clear();
          return '/';
        }
        else
        {
          return '/categories';
        }
      }
    }
    return '/';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getInitialRoute(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            print(snapshot.data);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'ODO',
              theme: ThemeData(primarySwatch: Colors.blue),
              initialRoute: snapshot.data.toString(),
              routes: {
                '/': (context) => const HomePage(),
                '/termsAndConditions': (context) => TermsAndConditionsPage(),
                '/signup': (context) => const SignUpForm(),
                '/login': (context) => const LoginPage(),
                '/categories': (context) => const Categories(),
                '/items': (context) => const Items(),
                '/cart': (context) => const CartScreen(),
                '/orderPlaced': (context) => const OrderPlaced(),
                '/myOrders': (context) => const MyOrders(),
                '/orderSummary': (context) => OrderSummary(),
                '/profile': (context) => const MyProfile(),
                '/afterSignUp':(context) => SignUpCompleted(),
                '/otp':(context) => OTPScreen(),
              },
            );
          } else {
            print("idhar aaya");
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'ODO',
              theme: ThemeData(primarySwatch: Colors.blue),
              initialRoute: '/',
              routes: {
                '/': (context) => const HomePage(),
                '/termsAndConditions': (context) => TermsAndConditionsPage(),
                '/signup': (context) => const SignUpForm(),
                '/login': (context) => const LoginPage(),
                '/categories': (context) => const Categories(),
                '/items': (context) => const Items(),
                '/cart': (context) => const CartScreen(),
                '/orderPlaced': (context) => const OrderPlaced(),
                '/myOrders': (context) => const MyOrders(),
                '/orderSummary': (context) => OrderSummary(),
                '/afterSignUp' : (context) => SignUpCompleted(),
                '/otp' : (context)=> OTPScreen(),
              },
            );
          }
        } else {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              // Black screen bold letters text telling "Setting up ODO..",
              body: Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Checking your credentials... Please wait.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}
