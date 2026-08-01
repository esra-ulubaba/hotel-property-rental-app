import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/account_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/explore_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/inbox_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/saved_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/trips_page.dart';

class GuestHomePage extends StatefulWidget {
  static final String routeName= "/guestHomePageRoute";

  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePagesState();
}

class _GuestHomePagesState extends State<GuestHomePage> {

  int _selectedIndex=0; //seçilen indexler sayfayı belirliyor. Örneğin keşfet için 1

  final List<String> _pageTitles= [
    'Keşfet', // 0 explore
    'Favoriler',
    'Geziler',
    'Gelen Kutusu',
    'Profil'
  ];

  final List<Widget> _pages = [
    ExplorePage(),
    SavedPage(),
    TripsPage(),
    InboxPage(),
    AccountPage(),
 ];

  BottomNavigationBarItem _buildNavigationItem(int index, IconData iconData, String text){
    return BottomNavigationBarItem(
      icon: Icon(iconData, color: AppConstants.nonselectedIcon),
      activeIcon: Icon(iconData, color: AppConstants.selectedIcon),
      label: text,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ana Sayfa",
        ),
        automaticallyImplyLeading: false, //bu sayfanın bir navigasyon yığını üzerinde bile olsa AppBar'ın sol tarafına otomatik olarak eklenen varsayılan geri butonunu veya menü ikonunu engellemektir.
        centerTitle: true ,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedIndex= index;
          });
        },
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          _buildNavigationItem(0,Icons.search, _pageTitles[0]),
          _buildNavigationItem(1,Icons.favorite_border, _pageTitles[1]),
          _buildNavigationItem(2,Icons.hotel, _pageTitles[2]),
          _buildNavigationItem(3,Icons.message, _pageTitles[3]),
          _buildNavigationItem(4,Icons.person_outline, _pageTitles[4]),


      ],
      ),
    );
  }
}
