import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'CreateProfilePage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Profile details variables
  String name = '';
  String phone = '+919021600896'; // The phone number to search for
  String state = '';
  String district = '';
  String taluka = '';
  String village = '';
  String pinCode = '';
  String maritalStatus = '';
  String annualIncome = '';
  String education = '';
  String age = '';

  final DatabaseReference _profileRef = FirebaseDatabase.instance.ref().child('userProfiles');

  @override
  void initState() {
    super.initState();
    // Fetch profile data from Firebase Realtime Database
    _fetchProfileData();
  }

  // Fetch profile data based on the phone number
  void _fetchProfileData() async {
    try {
      // Query the database to find the profile with the matching phone number
      DatabaseEvent event = await _profileRef.orderByChild('phone').equalTo(phone).once();

      if (event.snapshot.exists) {
        // Profile found, update the UI with the fetched data
        var profileData = event.snapshot.value as Map<dynamic, dynamic>;
        var profile = profileData.values.first;

        setState(() {
          name = profile['name'];
          state = profile['state'];
          district = profile['district'];
          taluka = profile['taluka'];
          village = profile['village'];
          pinCode = profile['pinCode'];
          maritalStatus = profile['maritalStatus'];
          annualIncome = profile['annualIncome'];
          education = profile['education'];
          age = profile['age'];
        });
      } else {
        // No profile found with the given phone number
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile not found!')));
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching profile data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [
          // Edit button in AppBar
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Action to edit the profile (e.g., navigate to an edit page)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProfilePage(
                    name: name,
                    phone: phone,
                    state: state,
                    district: district,
                    taluka: taluka,
                    village: village,
                    pinCode: pinCode,
                    maritalStatus: maritalStatus,
                    annualIncome: annualIncome,
                    education: education,
                    age: age,
                  ),
                ),
              ).then((updatedProfile) {
                // If the profile is updated, update the state
                if (updatedProfile != null) {
                  setState(() {
                    name = updatedProfile['name'];
                    phone = updatedProfile['phone'];
                    state = updatedProfile['state'];
                    district = updatedProfile['district'];
                    taluka = updatedProfile['taluka'];
                    village = updatedProfile['village'];
                    pinCode = updatedProfile['pinCode'];
                    maritalStatus = updatedProfile['maritalStatus'];
                    annualIncome = updatedProfile['annualIncome'];
                    education = updatedProfile['education'];
                    age = updatedProfile['age'];
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/517/517542.png'), // Replace with your image URL or Asset
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Loading...',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Location Info Section
              Text(
                'Location Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
              SizedBox(height: 8),
              Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('State:', state.isNotEmpty ? state : 'Loading...'),
                      _buildInfoRow('District:', district.isNotEmpty ? district : 'Loading...'),
                      _buildInfoRow('Taluka / Tehsil:', taluka.isNotEmpty ? taluka : 'Loading...'),
                      _buildInfoRow('Village:', village.isNotEmpty ? village : 'Loading...'),
                      _buildInfoRow('PIN Code:', pinCode.isNotEmpty ? pinCode : 'Loading...'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Personal Info Section
              Text(
                'Personal Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
              SizedBox(height: 8),
              Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Marital Status:', maritalStatus.isNotEmpty ? maritalStatus : 'Loading...'),
                      _buildInfoRow('Annual Income:', annualIncome.isNotEmpty ? annualIncome : 'Loading...'),
                      _buildInfoRow('Highest Education:', education.isNotEmpty ? education : 'Loading...'),
                      _buildInfoRow('Age:', age.isNotEmpty ? age : 'Loading...'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build each info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
