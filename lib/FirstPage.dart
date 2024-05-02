import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_urls.dart';
import 'dart:convert';
import 'DoctorListPage.dart';
import 'PatientProfilePage.dart';
import 'HistoryPage.dart';
import 'MapPage.dart';
import 'QuizPage.dart';
import 'KetoPage.dart';
import 'CachHelper.dart';
import 'loginScreen.dart';

class FirstPage extends StatefulWidget {
  final String firstName;
  final int? patientId;

  FirstPage({required this.firstName, this.patientId});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _cacheData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _cacheData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', widget.firstName);
    await prefs.setInt('patientId', widget.patientId ?? 0);
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF199A8E)),
              ),
            ),
            TextButton(
              onPressed: () async {
                bool loggedOut = await CachHelper.removdata(key: 'token');
                if (loggedOut) {
                  // Replace all routes in the stack with the login screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => loginScreen()),
                        (route) => false,
                  );
                }
              },
              child: Text(
                'Logout',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.teal[50],
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildHomePage(),
            _buildMapPage(),
            _buildHistoryPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF199A8E),
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            decoration: BoxDecoration(
              color: Color(0xFF199A8E),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  left: MediaQuery.of(context).size.width * 0.8,
                  child: GestureDetector(
                    onTap: () async {
                      await _showLogoutConfirmationDialog();
                    },
                    child: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.patientId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientProfilePage(patientId: widget.patientId!),
                          ),
                        );
                      } else {
                        print('Patient ID is null');
                      }
                    },
                    child: Icon(
                      Icons.perm_identity_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 45),
                    Text(
                      'Hi, ${widget.firstName} !',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'We hope you are feeling good today!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/logomob.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: MediaQuery.of(context).size.height * 0.16,
            decoration: BoxDecoration(
              color: Color(0xFF80CBC4),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(horizontal: 25),
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/persone.jpg',
                    width: 90,
                    height: 90,
                  ),
                ),
                SizedBox(width: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore our list \n of doctors !',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final response = await http.get(Uri.parse(ApiUrls.doctorsUrl));

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);

                          if (data['status'] == true) {
                            final List doctors = data['doctors'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorListPage(doctors: doctors),
                              ),
                            );
                          } else {
                            print('Failed to fetch doctors: ${data['message']}');
                          }
                        } else {
                          print('Failed to fetch doctors: ${response.statusCode}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(90, 35),
                      ),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF199A8E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: MediaQuery.of(context).size.height * 0.19,
            decoration: BoxDecoration(
              color: Color(0xFF80CBC4),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(horizontal: 25),
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/newquizz.jpg',
                    width: 90,
                    height: 90,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Looking for a \ngood time?\ncheck our Quizz!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(90, 30),
                      ),
                      child: Text(
                        'Get Start',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF199A8E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: MediaQuery.of(context).size.height * 0.17,
            decoration: BoxDecoration(
              color: Color(0xFF80CBC4),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(horizontal: 25),
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/logomob.png',
                    width:87,
                    height: 87,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About your\nKetoSmart device!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => KetoPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 35),
                      ),
                      child: Text('Check',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF199A8E),
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMapPage() {
    return MyMapPage();
  }

  Widget _buildHistoryPage() {
    return HistoryPage(patientId: widget.patientId);
  }
}
