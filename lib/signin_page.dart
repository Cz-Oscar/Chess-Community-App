import 'package:chess_openings_trainer/main.dart';
import 'package:chess_openings_trainer/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:chess_openings_trainer/reusable_widget.dart';
//import 'package:chess_openings_trainer/home_page.dart';
import 'package:chess_openings_trainer/reset_password.dart';
import 'package:chess_openings_trainer/signup_page.dart';
//import 'package:firebase_signin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  bool isRememberMe = false; // tu dodałem

  @override
  void initState() {
    super.initState();
    _loadUserEmailAndPassword(); //load saved email and password
  }

  void _loadUserEmailAndPassword() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailTextController.text = (prefs.getString('email') ?? '');
      _passwordTextController.text = (prefs.getString('password') ?? '');
      isRememberMe = (prefs.getBool('isRememberMe') ?? false);
    });
  }

  Future<void> _saveUserEmailAndPassword() async {
    final prefs = await SharedPreferences.getInstance();
    if (isRememberMe) {
      await prefs.setString('email', _emailTextController.text);
      await prefs.setString('password', _passwordTextController.text);
      await prefs.setBool('isRememberMe', isRememberMe);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('isRememberMe');
    }
  }

  void _signIn() async {
    await _saveUserEmailAndPassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(
                  height: 5,
                ),
                CheckboxListTile(
                  title: const Text('Remember me'),
                  value: isRememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      isRememberMe = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", () async {
                  try {
                    //proba logowania
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    );

                    if (isRememberMe) {
                      await _saveUserEmailAndPassword();
                    } else {
                      await _clearSavedUserEmailAndPassword();
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyHomePage(title: "Chess Openings Trainer")),
                    );
                  } catch (error, stackTrace) {
                    print("Error ${error.toString()}");
                  }
                }),
                signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('isRememberMe');
  }

  Future<void> _clearSavedUserEmailAndPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('isRememberMe');
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
