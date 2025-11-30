import 'package:flutter/material.dart';
import 'package:project/User/homeU.dart';
import 'package:project/owner/homeO.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tellus extends StatefulWidget {
  @override
  _Tellus createState() => _Tellus();
}

class _Tellus extends State<Tellus> {
  String _selectedRole = '';

  @override
  void initState() {
    super.initState();
    _checkSavedRole(); // Check if user has already selected a role
  }

  Future<void> _checkSavedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRole = prefs.getString('userRole');
    if (savedRole != null && savedRole.isNotEmpty) {
      // Navigate directly based on saved role
      if (savedRole == 'seller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
        );
      } else if (savedRole == 'buyer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePageU()),
        );
      }
    }
  }

  Future<void> _saveRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role); // Save role locally
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    "Tell Us About Yourself",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),

              // Middle section (buttons)
              Column(
                children: [
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'seller';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      side: BorderSide(color: Colors.black, width: 2),
                      backgroundColor: _selectedRole == 'seller'
                          ? Color.fromARGB(255, 72, 113, 247)
                          : Colors.transparent,
                    ),
                    child: Text(
                      "Seller",
                      style: TextStyle(
                        fontSize: _selectedRole == 'seller' ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedRole == 'seller'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = 'buyer';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      side: BorderSide(color: Colors.black, width: 2),
                      backgroundColor: _selectedRole == 'buyer'
                          ? Colors.blue
                          : Colors.transparent,
                    ),
                    child: Text(
                      "Buyer",
                      style: TextStyle(
                        fontSize: _selectedRole == 'buyer' ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedRole == 'buyer'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom section (Continue button)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: OutlinedButton(
                  onPressed: () async {
                    if (_selectedRole.isEmpty)
                      return; // do nothing if no selection
                    await _saveRole(_selectedRole); // Save selected role
                    if (_selectedRole == "seller") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePageU()),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
