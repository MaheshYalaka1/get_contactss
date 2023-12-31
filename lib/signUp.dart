import 'package:flutter/material.dart';
import 'package:get_contacts/TabBar.dart';
import 'package:get_contacts/login.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController phoneController = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController emailID = TextEditingController();

  String verificationId = "";
  String otpPin = "";
  String countryDial = "+1";
  int screenState = 0; // 0 for registration, 1 for OTP
  Color primaryColor = const Color(0xff0074E4);

  Future<void> verifyPhone(String number) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 30),
      verificationCompleted: (PhoneAuthCredential credential) async {
        showSnackBarText("Authentication complete");
      },
      verificationFailed: (e) {
        showSnackBarText('Error: ${e.code}');
      },
      codeSent: (String verificationId, int? resendToken) {
        showSnackBarText("OTP sent!");
        this.verificationId = verificationId;
        setState(() {
          screenState = 1;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showSnackBarText("TimeOut!");
      },
    );
  }

  Future<void> verifyOTP() async {
    try {
      await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otpPin,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TabScreen(),
        ),
      );
    } catch (e) {
      showSnackBarText("Error: Incorrect OTP. Please try again.");
    }
  }

  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    screenState == 0 ? stateRegister() : stateOTP(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (screenState == 0) {
                          if (phoneController.text.isEmpty) {
                            showSnackBarText("Phone number is empty!");
                          } else {
                            verifyPhone("$countryDial${phoneController.text}");
                          }
                        } else {
                          if (otpPin.length >= 6) {
                            verifyOTP();
                          } else {
                            showSnackBarText("Enter OTP correctly");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("allready have an account ?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stateRegister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        const Text(
          "First Name",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextField(
          controller: firstName,
          decoration: InputDecoration(
            hintText: 'Enter your first name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Last Name",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextField(
          controller: lastName,
          decoration: InputDecoration(
            hintText: 'Enter your last name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Email Id",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextField(
          controller: emailID,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Phone Number",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        IntlPhoneField(
          controller: phoneController,
          showCountryFlag: false,
          showDropdownIcon: false,
          initialValue: countryDial,
          onCountryChanged: (Country) {
            setState(() {
              countryDial = "+" + Country.dialCode;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget stateOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Enter OTP",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              const TextSpan(
                text: "We just sent a code to",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: "$countryDial${phoneController.text}",
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const TextSpan(
                text: "\nEnter the code here to continue",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 6,
          onChanged: (value) {
            setState(() {
              otpPin = value;
            });
          },
          pinTheme: PinTheme(
            activeColor: primaryColor,
            selectedColor: primaryColor,
            inactiveColor: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(children: [
            const TextSpan(
              text: "Didn't receive the code?",
              style: TextStyle(
                color: Colors.black38,
                fontSize: 12,
              ),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    screenState = 0;
                  });
                },
                child: Text(
                  'Resend',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
