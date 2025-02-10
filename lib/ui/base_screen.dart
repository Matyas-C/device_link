import 'package:flutter/material.dart';
import 'navigation/navigation_bar.dart';
import 'navigation/navigation_rail.dart';
import 'pages/home_page.dart';
import 'pages/devices_page.dart';
import 'pages/settings_page.dart';
import 'package:device_link/udp_discovery.dart';
import 'dialog/response_dialog.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => BaseScreenState();
}

class BaseScreenState extends State<BaseScreen> {
  int currentPageIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    void navigateTo(int index) {
      setState(() {
        currentPageIndex = index;
      });
    }

    _pages = [
      HomePage(navigateTo: navigateTo),
      const DevicesPage(),
      const SettingsPage(),
    ];
    super.initState();
    UdpDiscovery().onConnectionRequest =
        (String uuid, String name, String deviceType) async {
      bool? wasAccepted = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResponseDialog(uuid: uuid, name: name, deviceType: deviceType);
        },
      );
      return wasAccepted;
    };
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavRail(
              selectedIndex: currentPageIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
            ),
          Expanded(
            child: _pages[currentPageIndex],
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? NavBar(
              currentIndex: currentPageIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
            )
          : null,
    );
  }
}
