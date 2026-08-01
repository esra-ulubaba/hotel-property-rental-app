import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/guest_home_page.dart';

import '../../constants/app_constants.dart';


class ProfileInfoPage extends StatefulWidget {
  static final String routeName = '/personalInfoPageRoute';

  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  File? _newImageFile;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _firstNameController = TextEditingController(text: AppConstants.currentUser.firstName);
    _lastNameController = TextEditingController(text: AppConstants.currentUser.lastName);
    _emailController = TextEditingController(text: AppConstants.currentUser.email);
    _cityController = TextEditingController(text: AppConstants.currentUser.city);
    _countryController = TextEditingController(text: AppConstants.currentUser.country);
    _bioController = TextEditingController(text: AppConstants.currentUser.bio);
  }


  _updateInfo() {
    if(!_formKey.currentState!.validate()){return;}

    AppConstants.currentUser.firstName = _firstNameController.text;
    AppConstants.currentUser.lastName = _lastNameController.text;
    AppConstants.currentUser.city = _cityController.text;
    AppConstants.currentUser.country= _countryController.text;
    AppConstants.currentUser.bio = _bioController.text;

    AppConstants.currentUser.updateUserInFirestore().whenComplete((){
      if(_newImageFile != null){
        AppConstants.currentUser.addImageToFirestore(_newImageFile!).whenComplete((){
          Navigator.pushNamed(context, GuestHomePage.routeName);
        });
      } else{
        Navigator.pushNamed(context, GuestHomePage.routeName);
      }
    });
  }

  _chooseImage() async {
    var imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(imageFile != null){
      _newImageFile = File(imageFile.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kişisel Bilgiler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as_outlined, color: Colors.white),
            onPressed: _updateInfo,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Adınız"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _firstNameController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Lütfen adınızı giriniz";
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Soyadınız"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _lastNameController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Lütfen soyadınızı giriniz";
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Email"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          enabled: false,
                          controller: _emailController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Şifre"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          enabled: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Şehir"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _cityController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Lütfen geçerli bir şehir girin.";
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Ülke"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _countryController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Lütfen geçerli bir ülke girin.";
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Biyografi"
                          ),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          maxLines: 3,
                          controller: _bioController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Lütfen biyografinizi girin.";
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:40.0, bottom:40.0,),
                  child: MaterialButton(
                    onPressed: _chooseImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: MediaQuery.of(context).size.width/4.8,
                      child: CircleAvatar(
                        backgroundImage: (_newImageFile != null)
                            ? FileImage(_newImageFile!) as ImageProvider
                            : AppConstants.currentUser.displayImage,
                        radius: MediaQuery.of(context).size.width/5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
