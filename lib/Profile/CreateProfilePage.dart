import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CreateProfilePage extends StatefulWidget {
  final String name;
  final String phone;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String pinCode;
  final String maritalStatus;
  final String annualIncome;
  final String education;
  final String age;

  CreateProfilePage({
    required this.name,
    required this.phone,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.pinCode,
    required this.maritalStatus,
    required this.annualIncome,
    required this.education,
    required this.age,
  });

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _annualIncomeController = TextEditingController();

  String _state = 'Maharashtra';
  String _district = 'Nagpur';
  String _taluka = 'Umred';
  String _village = 'Umred (Rural)';
  String _maritalStatus = 'Single';
  String _education = 'High School';

  final List<String> states = ['Maharashtra', 'Gujarat', 'Karnataka'];
  final List<String> districts = ['Nagpur', 'Pune', 'Mumbai'];
  final List<String> talukas = ['Umred', 'Nagpur City', 'Saoner'];
  final List<String> maritalStatuses = ['Single', 'Married', 'Divorced'];
  final List<String> educationLevels = ['High School', 'Graduation', 'Post Graduation'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _phoneController.text = widget.phone;
    _pinCodeController.text = widget.pinCode;
    _ageController.text = widget.age;
    _annualIncomeController.text = widget.annualIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create / Update Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);  // Navigates back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              SizedBox(height: 5),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Full Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              // PIN Code
              TextField(
                controller: _pinCodeController,
                decoration: InputDecoration(
                  labelText: 'PIN Code',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Age
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Annual Income
              TextField(
                controller: _annualIncomeController,
                decoration: InputDecoration(
                  labelText: 'Annual Income',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // State Dropdown
              DropdownButtonFormField<String>(
                value: _state,
                onChanged: (String? newValue) {
                  setState(() {
                    _state = newValue!;
                  });
                },
                items: states.map((String state) {
                  return DropdownMenuItem<String>(value: state, child: Text(state));
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              // District Dropdown
              DropdownButtonFormField<String>(
                value: _district,
                onChanged: (String? newValue) {
                  setState(() {
                    _district = newValue!;
                  });
                },
                items: districts.map((String district) {
                  return DropdownMenuItem<String>(value: district, child: Text(district));
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              // Taluka Dropdown
              DropdownButtonFormField<String>(
                value: _taluka,
                onChanged: (String? newValue) {
                  setState(() {
                    _taluka = newValue!;
                  });
                },
                items: talukas.map((String taluka) {
                  return DropdownMenuItem<String>(value: taluka, child: Text(taluka));
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Taluka',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              // Marital Status Dropdown
              DropdownButtonFormField<String>(
                value: _maritalStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    _maritalStatus = newValue!;
                  });
                },
                items: maritalStatuses.map((String status) {
                  return DropdownMenuItem<String>(value: status, child: Text(status));
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Marital Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              // Education Dropdown
              DropdownButtonFormField<String>(
                value: _education,
                onChanged: (String? newValue) {
                  setState(() {
                    _education = newValue!;
                  });
                },
                items: educationLevels.map((String educationLevel) {
                  return DropdownMenuItem<String>(value: educationLevel, child: Text(educationLevel));
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Education Level',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty ||
                      _phoneController.text.isEmpty ||
                      _pinCodeController.text.isEmpty ||
                      _ageController.text.isEmpty ||
                      _annualIncomeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all the fields.')),
                    );
                  } else {
                    // Prepare the user data to display
                    Map<String, String> userProfileData = {
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'state': _state,
                      'district': _district,
                      'taluka': _taluka,
                      'village': _village,
                      'pinCode': _pinCodeController.text,
                      'maritalStatus': _maritalStatus,
                      'annualIncome': _annualIncomeController.text,
                      'education': _education,
                      'age': _ageController.text,
                    };

                    // Get a reference to the Firebase Realtime Database
                    DatabaseReference ref = FirebaseDatabase.instance.reference().child('userProfiles');

                    // Push new user data to Firebase
                    await ref.push().set(userProfileData).then((_) {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile Saved Successfully!')),
                      );

                      // Optionally navigate back with the updated data
                      Navigator.pop(context, userProfileData);
                    }).catchError((error) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save profile: $error')),
                      );
                    });
                  }
                },
                child: Text('Save Profile', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  backgroundColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
