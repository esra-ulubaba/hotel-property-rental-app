import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/pages/auth/login_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/guest_home_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/profile_info_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/host_home_page.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  String _hostingTitle = 'Ev Sahibi Panelini Göster';



  _showPersonalInfo() {
    Navigator.pushNamed(context, ProfileInfoPage.routeName);
  }

  _changeHosting() {
    if (AppConstants.currentUser.isHost!) {
      if (AppConstants.currentUser.isCurrentlyHosting!) {
        AppConstants.currentUser.isCurrentlyHosting = false;
        Navigator.pushNamed(context, GuestHomePage.routeName);
      } else {
        AppConstants.currentUser.isCurrentlyHosting = true;
        Navigator.pushNamed(context, HostHomePage.routeName);
      }
    } else {
      AppConstants.currentUser.becomeHost().whenComplete(() {
        AppConstants.currentUser.isCurrentlyHosting = true;
        Navigator.pushNamed(context, HostHomePage.routeName);
      });
    }
  }

  _logOutUser() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, LoginPage.routeName);
  }

  Widget _buildActionTile(BuildContext context, String text, IconData icon, VoidCallback onTap) {
    return Container(
      color: Colors.white12,
      child: MaterialButton(
        height: MediaQuery.of(context).size.height / 9.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: onTap,
        child: ListTile(
          leading: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          trailing: Icon(icon, size: 32,),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (AppConstants.currentUser.isHost!) {
      _hostingTitle = AppConstants.currentUser.isCurrentlyHosting!
          ? 'Misafir Panelini Göster'
          : 'Ev Sahibi Panelini Göster';
    } else {
      _hostingTitle = 'Ev Sahibi Ol';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 50, 20, 0),
          child: Column(
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        radius: MediaQuery.of(context).size.width / 4.5,
                        child: CircleAvatar(
                          backgroundImage: AppConstants.currentUser!.displayImage,
                          radius: MediaQuery.of(context).size.width / 4.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    AutoSizeText(
                      AppConstants.currentUser.getFullName(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AutoSizeText(
                      AppConstants.currentUser.email!,
                      minFontSize: 15,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildActionTile(
                context,
                'Kişisel Bilgiler',
                Icons.person_pin,
                _showPersonalInfo,
              ),
              const SizedBox(height: 15),
              _buildActionTile(
                context,
                _hostingTitle,
                Icons.add_business,
                _changeHosting,
              ),
              const SizedBox(height: 15),
              _buildActionTile(
                context,
                'Çıkış Yap',
                Icons.logout_outlined,
                _logOutUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
