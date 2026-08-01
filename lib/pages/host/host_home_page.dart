import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/account_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/inbox_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/booking_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/earnings_page.dart';

import 'my_postings_page.dart';


class HostHomePage extends StatefulWidget {
  static const String routeName= '/hostHomePageRoute';
  final int? index;

  const HostHomePage({super.key, this.index});

  @override
  State<HostHomePage> createState() => _HostHomePageState();
}

class _HostHomePageState extends State<HostHomePage> {

  int _selectedIndex= 0;

  final List<String> _pageTitles = const [
    'Rezervasyonlar',
    'Gönderilerim',
    'Gelen Kutusu',
    'Kazançlar',
    'Profil',
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedIndex= widget.index ?? 4;
    _pages = [
      BookingsPage(),
      MyPostingsPage(),
      InboxPage(),
      EarningsPage(),
      AccountPage(),
    ];
  }

  BottomNavigationBarItem _buildNavigationItem(int index, IconData iconData, String text) {
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
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: AppConstants.selectedIcon,
        unselectedItemColor: AppConstants.nonselectedIcon,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          _buildNavigationItem(0, Icons.calendar_today, _pageTitles[0]),
          _buildNavigationItem(1, Icons.home, _pageTitles[1]),
          _buildNavigationItem(2, Icons.message, _pageTitles[2]),
          _buildNavigationItem(3, Icons.currency_exchange, _pageTitles[3]),
          _buildNavigationItem(4, Icons.person_outline, _pageTitles[4]),
        ],
      ),
    );
  }
}
