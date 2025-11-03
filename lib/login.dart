import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odo_mobile_v2/providers/auth.dart';
import 'package:odo_mobile_v2/signUp.dart';
import 'package:provider/provider.dart';

import 'PlatformDialog.dart';
import 'PlatformTextField.dart';
import 'package:odo_mobile_v2/providers/auth.dart';

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
  bool isLoading = false;
  bool _invalidLogin = false;
  bool _showLoginMessage = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (!mounted) {
      return;
    }
    if (_isFirstTime) {
      Provider.of<AuthProvider>(context, listen: false).fetchAreasFromDB();
    }
    _isFirstTime = false; //never run the above if again.
    super.didChangeDependencies();
  }

  void startLoginProcess(BuildContext context) async {
    setState(() {
      //shows setting things up wali screen.
      _showLoginMessage = true;
    });
    final contact = contactController.text.trim();
    final area = selectedArea.toString().toLowerCase();

    if (contact == null || area == null || contact.length != 10) {
      setState(() {
        _invalidLogin = true;
        isLoading = false;
        _showLoginMessage = false;
      });
      showAlertDialog(
        context,
        "Invalid Login!",
        "It might be that you provided correct credentials , but admin has not approved you yet. Try logging in after some time , if already registered!",
      );
      return;
    }

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).fetchDistributorsFromDB();

      final distributors = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).distributors;

      // Check if contact exists as a key
      if (distributors.containsKey(contact)) {
        final distributor = distributors[contact]!;

        // Check if area matches
        if (distributor.area.toLowerCase() == area) {
          await sendOTP(distributor);
          return; // ✅ Stop further execution
        }
      }

      // If no match found
      if (mounted) {
        setState(() {
          _invalidLogin = true;
          isLoading = false;
          _showLoginMessage = false;
        });
      }

      showAlertDialog(
        context,
        "Invalid Login!",
        "It might be that you provided correct credentials , but admin has not approved you yet. Try logging in after some time , if already registered!",
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _invalidLogin = false;
          isLoading = false;
          _showLoginMessage = false;
        });
      }
      showAlertDialog(context, "Unable to login!", e.toString());
    }
  }

  sendOTP(distributor) async {

    if((distributor.contact == '8888888888' && distributor.distributorName == 'NO-ORDER-USER') || distributor.contact == '8585988825'){
      //bypass OTP for no-order-user.
       Provider.of<AuthProvider>(context, listen: false)
            .setActiveDistributor(distributor);

        Provider.of<AuthProvider>(context, listen: false)
            .setLoggedInDistributorAndArea(distributor);

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/categories', (route) => false);
      return;
    }

      setState(() {
    _showLoginMessage = true; // Show loader when verification starts
  });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91' + contactController.text.trim(),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credentials) {
        if (mounted) setState(() => _showLoginMessage = false);

        //agar OTP apne aap pakad liya to..
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/categories',
          (Route<dynamic> route) => false,
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        //Scaffold snackbar to show what failed
       if (mounted) setState(() => _showLoginMessage = false);

        showAlertDialog(
          context,
          "OTP Verification Failed!",
          e.message.toString(),
        );
      },
      codeSent: (String vid, int? token) {
       if (mounted) setState(() => _showLoginMessage = false);

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/otp',
          (Route<dynamic> route) => false,
          arguments: {
            'distributorToValidate': distributor,
            'verificationID': vid,
          },
        );
      },
      codeAutoRetrievalTimeout: (String vid) {
        //Scaffold snackbar to tell OTP timedout , please re-login again to generate a new OTP.
        if (mounted) setState(() => _showLoginMessage = false);

        showAlertDialog(
          context,
          "OTP Timed Out!",
          "Please re-login again to generate a new OTP.",
        );
      },
    );
  }

  showAlertDialog(
    BuildContext context,
    String title_alert,
    String content_alert,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          PlatformDialog(title: title_alert, content: content_alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    final areas = Provider.of<AuthProvider>(context).areaNames;
    return SafeArea(
      child: _showLoginMessage == true
          ? Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitPouringHourGlass(
                      color: Colors.white,
                      size: 50.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Getting things ready! Please wait..",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            )
          : Scaffold(
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
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                fit: BoxFit.contain,
                              ),
                              const Text(
                                "Welcome Back!",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Please Login Below To Get Started!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PlatformTextField(
                            labelText: "MOBILE NUMBER",
                            controller: contactController,
                            type: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              dropdownColor: const Color(0XFFf5f5f5),
                              iconSize: 36,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                              value: selectedArea,
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) => {
                                setState(() => selectedArea = value),
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                        "GET OTP",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                          Navigator.of(
                                            context,
                                          ).pushReplacementNamed('/signup');
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
