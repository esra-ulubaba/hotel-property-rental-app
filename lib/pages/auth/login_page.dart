import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/pages/auth/signup_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/guest_home_page.dart';

import '../../common/common_functions.dart';
import '../../models/user_objects.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  static final String routeName= "/loginPageRoute";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController= TextEditingController();
  final _passwordController= TextEditingController();
  final _formKey= GlobalKey<FormState>();

  bool _isLoading= false;

  _signUp(){
    Navigator.pushNamed(context, SignupPage.routeName);
  }

  _logIn() async {
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoading=true;
      });

      String email= _emailController.text.trim();
      String password= _passwordController.text.trim();

      try{
        UserCredential firebaseUser= await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password
        );

        if(firebaseUser.user != null){
          final userID= firebaseUser.user!.uid;
          AppConstants.currentUser= UserModel(id: userID);

          await AppConstants.currentUser.getPersonalInfoFromFirestore();

          CommonFunctions.showSnackBar(context, "Oturumu başarıyla açtınız");

          _formKey.currentState!.reset();
          Navigator.pushReplacementNamed(context, GuestHomePage.routeName);
        }
      }
      on FirebaseAuthException catch(e){
        String errorMessage;
        switch(e.code) {
          case "email-already-in-use" :
            errorMessage = "Bu e-posta zaten kayıtlı";
            break;
          case "invalid-email" :
            errorMessage= "Lütfen geçerli bir e-posta adresi girin";
            break;
          case "weak-password" :
            errorMessage = "Parola çok zayıf. Lütfen daha güçlü bir parola kullanın. En az 6 karakter kullanın. " ;
            break;
          default:
            errorMessage = "Giriş başarısız. Lütfen daha sonra tekrar deneyin.";
        }
        CommonFunctions.showSnackBar(context, errorMessage );

      } catch(e){
        CommonFunctions.showSnackBar(context, e.toString());
      } finally{
        setState(() {
          _isLoading = false;
        });
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset(
                  "assets/images/logo.png",
                  width: MediaQuery.of(context).size.width * 0.8,
                ),

                SizedBox(height: 20),

                Text(
                  "Konaklama & Kiralık Yer Ara  ${AppConstants.appName}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26.0
                  ),
                ),

                SizedBox(height: 40),


                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(controller: _emailController, label: "Email", icon: Icons.email, isPassword: false,),
                      CustomTextField(controller: _passwordController, label: "Şifre", icon: Icons.lock, isPassword: true,),

                    ],
                  ),
                ),

                SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 15,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    onPressed: _isLoading ? null : _logIn,
                    child: _isLoading
                    ? const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                        : const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width:double.infinity,
                  height: MediaQuery.of(context).size.height /15,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                    onPressed: _isLoading ? null: _signUp,
                    child: const Text(
                      'Kaydol',
                      style: TextStyle(
                        fontSize: 22.0,
                      ),

                    ),
                  ),
                ),

                const SizedBox(height: 100),



              ],
            ) ,
          ),
        ) ,
      ),
    );
  }
}
