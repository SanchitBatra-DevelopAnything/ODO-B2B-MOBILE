import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odo_mobile_v2/PlatformDialog.dart';
import 'package:odo_mobile_v2/PlatformTextField.dart';
import 'package:odo_mobile_v2/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'bottomSheetModal.dart';
import 'package:geolocator/geolocator.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  TextEditingController usernameController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController GSTController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController shopAddressController = TextEditingController();
  TextEditingController referrerController = TextEditingController();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  String? selectedArea;
  String? selectedReferrer;
  bool _isFirstTime = true;
  bool isSigningUp = false;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => BottomSheetModal(),
    );
  }

  Future<Position?> getUserLocation(BuildContext context) async {
    Position? position;

    // Always request permission each time the method is called
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showSnackBar(context, "Location permission is required for signup!");
      return null;
    }

    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      showSnackBar(context, "Unable to get your location. Please try again.");
      return null;
    }

    return position;
  }

  // ✅ Camera-only image picker
  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // reduce file size
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
      });
    }
  }

  Future<void> signUp(BuildContext context) async {

     // ✅ Check if image is captured
    if (_capturedImage == null) {
      showSnackBar(context, "Please capture your selfie with shop board for proper verification.");
      return;
    }

    Position? position = await getUserLocation(context);

    if (position == null) {
      showSnackBar(
        context,
        "Location not found. Please enable location services.",
      );
      return;
    }

    bool result = validateForm(context);

    if (result) {
      setState(() {
        isSigningUp = true;
      });

      await Provider.of<AuthProvider>(context, listen: false).distributorSignUp(
        usernameController.text.trim().toString().toUpperCase(),
        selectedArea.toString().trim().toUpperCase(),
        GSTController.text.trim(),
        shopController.text.trim().toString().toUpperCase(),
        contactController.text.trim(),
        shopAddressController.text.trim(),
        position.latitude.toString(),
        position.longitude.toString(),
        selectedReferrer.toString().trim().toUpperCase(),
      );

      setState(() {
        // showAlertDialog(context);
        isSigningUp = false;
        Navigator.pushReplacementNamed(context, '/afterSignUp');
      });
    }
  }

  showSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Fill All Fields!',
        message: msg,

        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.help,
      ),
    );

    // Show the snackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  validateForm(BuildContext context) {
    if (usernameController.text.trim() == "") {
      showSnackBar(context, "username should not be empty");
      return false;
    }
    if (shopAddressController.text.trim() == "") {
      showSnackBar(context, "shopAddress should not be empty");
      return false;
    }
    if (shopController.text.trim() == "") {
      showSnackBar(context, "shop name should not be empty");
      return false;
    }
    if (GSTController.text.trim() == "") {
      showSnackBar(context, "Please enter your GST Number");
      return false;
    }
    if (contactController.text.trim() == "" ||
        contactController.text.trim().length != 10) {
      showSnackBar(context, "Mobile number not valid");
      return false;
    }
    if (selectedArea == null) {
      showSnackBar(context, "Selecting your area is necessary!");
      return false;
    }
    return true;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isFirstTime) {
      Provider.of<AuthProvider>(context, listen: false).fetchAreasFromDB();
      Provider.of<AuthProvider>(context, listen: false).fetchReferrersFromDB();
      Provider.of<AuthProvider>(context, listen: false).setupNotifications();
    }
    _isFirstTime = false; //never run the above if again.
    super.didChangeDependencies();
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlatformDialog(
        title: "Signed Up!",
        content: "Please wait for the notification approval before you login.",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final areas = Provider.of<AuthProvider>(context).areaNames;
    final referrers = Provider.of<AuthProvider>(context).referrerNames;
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
                          "Get On Board!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Create your profile to join ODO!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PlatformTextField(
                      labelText: "YOUR NAME",
                      controller: usernameController,
                      type: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    PlatformTextField(
                      labelText: "YOUR SHOP",
                      controller: shopController,
                      type: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    PlatformTextField(
                      labelText: "CONTACT NUMBER",
                      controller: contactController,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    PlatformTextField(
                      labelText: "GST/PAN-CARD NO.",
                      controller: GSTController,
                      type: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 20),
                    PlatformTextField(
                      labelText: "Shop Address",
                      controller: shopAddressController,
                      type: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      child: DropdownButton<String>(
                        items: referrers.map(buildMenuItem).toList(),
                        isExpanded: true,
                        focusColor: const Color(0xffe6e3d3),
                        hint: const Text(
                          "Who Referred You?",
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
                        value: selectedReferrer,
                        style: const TextStyle(color: Colors.black),
                        onChanged: (value) => {
                          setState(() => selectedReferrer = value),
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: captureImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text(
                            "Capture Photo",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Show captured image preview (if available)
                        if (_capturedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _capturedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[100],
                            ),
                            child: const Center(
                              child: Text(
                                "No photo captured yet",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isSigningUp
                            ? CupertinoButton(
                                onPressed: () async {
                                  setState(() {
                                    isSigningUp = true;
                                  });
                                  await signUp(context);
                                  setState(() {
                                    isSigningUp = false;
                                  });
                                },
                                color: Colors.black,
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const SpinKitPulse(
                                color: Color(0xffDD0E1C),
                                size: 50.0,
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
                                text: 'Already Registered? ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    //open bottom sheet.
                                    _showBottomSheet(context);
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

DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
  value: item,
  child: Text(
    item,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  ),
);
