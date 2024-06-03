import 'package:flutter/material.dart';

class DoctorListPage extends StatelessWidget {
  final List doctors;

  DoctorListPage({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: _buildAppBar(),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return _buildDoctorCard(doctor);
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.teal[50],
        title: Text(
          'List of Doctors',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF199A8E), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorName(doctor),
                SizedBox(height: 8),
                _buildDoctorSpeciality(doctor['speciality'] ?? 'No speciality'),
                SizedBox(height: 8),
                _buildDoctorLocation(doctor['address'] ?? 'No address provided'),
                SizedBox(height: 8),
                _buildDoctorEmail(doctor['email'] ?? 'No email provided'),
              ],
            ),
          ),
          SizedBox(width: 15),
          _buildDoctorAvatar(doctor['image'] as String?),
        ],
      ),
    );
  }

  Widget _buildDoctorAvatar(String? imageUrl) {
    return Container(
      alignment: Alignment.centerRight,
      width: 80, // Adjust width as needed
      height: 110, // Adjust height as needed
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : AssetImage('assets/imm.png') as ImageProvider,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10), // Optional: rounded corners
        border: Border.all(color: Color(0xFF199A8E), width: 2), // Optional: border color and width
      ),
    );
  }

  Widget _buildDoctorName(Map<String, dynamic> doctor) {
    return Text(
      'Dr. ${doctor['first_name'] ?? 'First Name'} ${doctor['last_name'] ?? 'Last Name'}',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildDoctorSpeciality(String speciality) {
    return Row(
      children: [
        Icon(
          Icons.medical_services_outlined,
          size: 25,
          color: Color(0xFF199A8E),
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            speciality,
            style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorLocation(String address) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 25,
          color: Color(0xFF199A8E),
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            address,
            style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorEmail(String email) {
    return Row(
      children: [
        Icon(
          Icons.email_outlined,
          size: 25,
          color: Color(0xFF199A8E),
        ),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            email,
            style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
