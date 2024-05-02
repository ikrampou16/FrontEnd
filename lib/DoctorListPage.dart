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
          if (doctor['image'] != null)
            _buildDoctorAvatar(doctor['image']),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorName(doctor),
                SizedBox(height: 8),
                Text(
                  '${doctor['speciality']}',
                  style: TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                ),
                SizedBox(height: 8),
                _buildDoctorLocation(doctor['address']),
                SizedBox(height: 8),
                _buildDoctorEmail(doctor['email']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(imageUrl),
    );
  }

  Widget _buildDoctorName(Map<String, dynamic> doctor) {
    return Text(
      'Dr.${doctor['first_name']} ${doctor['last_name']}',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
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
