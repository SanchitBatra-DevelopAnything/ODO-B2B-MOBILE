import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odo_mobile_v2/providers/auth.dart';
import 'package:odo_mobile_v2/signUp.dart';
import 'package:provider/provider.dart';

import 'PlatformDialog.dart';
import 'PlatformTextField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController contactController = TextEditingController();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  String? selectedArea;
  bool _isFirstTime = true;
  bool isLoading = true;
  bool _invalidLogin = false;
  

 

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (!mounted) {
      return;
    }
    if (_isFirstTime) {
      Provider.of<AuthProvider>(context, listen: false).fetchAreasFromDB();
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      Provider.of<AuthProvider>(context, listen: false)
          .fetchDistributorsFromDB()
          .then((value) => {
                setState(
                  () => isLoading = false,
                )
              });
    }
    _isFirstTime = false; //never run the above if again.
    super.didChangeDependencies();
  }

  void startLoginProcess(BuildContext context) {
    var isPresent = false;
    var distributorKey = "";
    var distributors =
        Provider.of<AuthProvider>(context, listen: false).distributors;
    distributors.asMap().forEach((index , distributor) {
      if (contactController.text.trim() ==
              distributor.contact.trim() &&
          selectedArea.toString().toLowerCase() ==
              distributor.area.toLowerCase()) {
        isPresent = true;
        Provider.of<AuthProvider>(context , listen:false).setActiveDistributorIndex(index);
        distributorKey = distributor.id;
      }
      if (isPresent) {
        if (mounted) {
          setState(() {
            _invalidLogin = false;
          });
        }
        Provider.of<AuthProvider>(context, listen: false)
            .setLoggedInDistributorAndArea(distributorKey);

        Navigator.of(context).pushNamedAndRemoveUntil(
  '/categories',
  (Route<dynamic> route) => false,
);

      } else {
        if (mounted) {
          setState(() {
            _invalidLogin = true;
          });
        }
      }
    });

    if (_invalidLogin) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => PlatformDialog(
            title: "Invalid Login!",
            content:
                "It might be that you provided correct credentials , but admin has not approved you yet. Try logging in after some time , if already registered!"));
  }

  @override
  Widget build(BuildContext context) {
    final areas = Provider.of<AuthProvider>(context).areaNames;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0XFFf5f5f5),
        body: GestureDetector(
          onTap: () {
            // Unfocus the TextFormField when the user taps outside
            if (_focusScopeNode.hasFocus) {
              _focusScopeNode.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: FocusScope(
                node: _focusScopeNode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/odo.png",
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const Text("Please Login Below To Get Started!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))
                      ],
                    ),
                    const SizedBox(height: 20),
                    PlatformTextField(
                      labelText: "MOBILE NUMBER",
                      controller: contactController,
                      type: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      child: DropdownButton<String>(
                          items: areas.map(buildMenuItem).toList(),
                          isExpanded: true,
                          focusColor: const Color(0xffe6e3d3),
                          hint: const Text(
                            "Select Area",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          dropdownColor: const Color(0XFFf5f5f5),
                          iconSize: 36,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          value: selectedArea,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (value) => {
                                setState(
                                  () => selectedArea = value,
                                )
                              }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isLoading
                            ? CupertinoButton(
                                onPressed: () {
                                  startLoginProcess(context);
                                },
                                color: Colors.black,
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : const SpinKitPulse(
                                color: Color(0xffDD0E1C),
                                size: 50.0,
                              ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Not Registered yet? ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'Sign Up',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    //open bottom sheet.
                                    Navigator.of(context)
                                        .pushReplacementNamed('/signup');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
