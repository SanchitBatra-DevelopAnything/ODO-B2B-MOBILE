import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:odo_mobile_v2/providers/auth.dart';
import 'package:pinput/pinput.dart';
import 'package:odo_mobile_v2/models/distributor.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late Distributor distributorToValidate;
  late String verificationID;
  String code = '';
  bool _isLoading = false; // Loading state

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    distributorToValidate = args['distributorToValidate'];
    verificationID = args['verificationID'];
  }

  void signIn() async {
    if (_isLoading) return; // Prevent multiple triggers

    setState(() {
      _isLoading = true;
    });

    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verificationID, smsCode: code);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        // Valid login scenario
        Provider.of<AuthProvider>(context, listen: false)
            .setActiveDistributor(distributorToValidate);

        Provider.of<AuthProvider>(context, listen: false)
            .setLoggedInDistributorAndArea(distributorToValidate);

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/categories', (route) => false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during sign-in: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/odo.png',
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                'Enter OTP sent to +91${distributorToValidate.contact}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Pinput(
                length: 6,
                controller: _pinController,
                focusNode: _focusNode,
                defaultPinTheme: defaultPinTheme,
                onChanged: (value) {
                  setState(() {
                    code = value; // Updates code while typing
                  });
                },
                onCompleted: (pin) {
                  code = pin;
                  signIn(); // Automatically triggers signIn on completion
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signIn, // Disable while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black, // Spinner color
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify & Proceed',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
