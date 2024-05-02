import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'api_urls.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final int? patientId;

  HistoryPage({this.patientId});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _fetchTestsFuture = Future.value([]);
  late Future<List<Map<String, dynamic>>> _fetchDkaHistoryFuture = Future.value([]);
  final TextEditingController dateController = TextEditingController();
  final TextEditingController acetoneController = TextEditingController();
  String _selectedHistoryType = 'Test';
  bool _showAddDkaForm = false;
  String? dkaOrderValue;
  int? idFolder;

  @override
  void initState() {
    super.initState();
    fetchMedicalFolderId(widget.patientId).then((id) {
      setState(() {
        idFolder = id;
        _fetchTestsFuture = fetchTests();
        _fetchDkaHistoryFuture = fetchDkaHistory(idFolder);
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<int?> fetchMedicalFolderId(int? patientId) async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.medicalFolderUrl(patientId!)));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('JSON Data: $jsonData');
        final information = jsonData['information'];
        if (information != null && information['id_folder'] != null) {
          final idFolder = information['id_folder'];
          print('idFolder after extracting it: $idFolder');
          return idFolder;
        } else {
          throw Exception('Failed to fetch medical folder: id_folder not found');
        }
      } else {
        throw Exception('Failed to fetch medical folder: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching medical folder: $error');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDkaHistory(int? idFolder) async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.dkaHistoryUrl(idFolder)));
      print('DKA History Response Status Code: ${response.statusCode}');
      print('DKA History Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> dkaHistoryData = jsonDecode(response.body);
        return dkaHistoryData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch DKA history');
      }
    } catch (error) {
      print('Error fetching DKA history: $error');
      return [];
    }
  }

  Future<void> deleteTest(int? testId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.3:3000/api/deleteTest/$testId'),
      );

      if (response.statusCode == 200) {
        print('Test deleted successfully');

        // Print additional information to verify the deletion
        print('Deleted Test ID: $testId');

        // Fetch tests again after deletion
        setState(() {
          _fetchTestsFuture = fetchTests();
        });
      } else {
        print('Failed to delete test: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error deleting test: $error');
    }
  }

  Future<void> deleteDkaHistory(int dkaHistoryId, int? idFolder) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.3:3000/api/deleteDH/$dkaHistoryId'),
      );

      if (response.statusCode == 200) {
        print('DKA history deleted successfully');

        // Ensure idFolder is not null before using it
        if (idFolder != null) {
          setState(() {
            _fetchDkaHistoryFuture = fetchDkaHistory(idFolder);
          });
        } else {
          print('idFolder is null');
        }
      } else {
        print('Failed to delete DKA history: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error deleting DKA history: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTests() async {
    try {
      final response = await http.get(Uri.parse(ApiUrls.testsUrl(widget.patientId)));
      if (response.statusCode == 200) {
        final List<dynamic> testData = jsonDecode(response.body);

        // Map each test data to a Map containing test details including test ID
        final List<Map<String, dynamic>> tests = testData.map((test) {
          return {
            'id_test': test['id_test'],
            'state': test['state'],
            'acetoneqt': test['acetoneqt'],
            'date': test['date'],
            'id_patient': test['id_patient'],
            'ref_device': test['ref_device'],
          };
        }).toList();

        return tests;
      } else {
        throw Exception('Failed to fetch tests');
      }
    } catch (error) {
      print('Error fetching tests: $error');
      return [];
    }
  }

  Future<int?> createMedicalFolder(int? patientId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiUrls.medicalFolderUrlPrefix}${widget.patientId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final idFolder = jsonData['id_folder'];
        return idFolder;
      } else {
        print('Failed to create medical folder: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error creating medical folder: $error');
      return null;
    }
  }

  Future<void> registerDkaHistory() async {
    try {
      int? medicalFolderId = await fetchMedicalFolderId(widget.patientId);

      if (medicalFolderId == null) {
        medicalFolderId = await createMedicalFolder(widget.patientId);
      }

      if (medicalFolderId != null) {
        final response = await http.post(
          Uri.parse(ApiUrls.createDkaHistoryUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'order': dkaOrderValue,
            'acetoneqt': acetoneController.text,
            'date': dateController.text,
            'id_folder': medicalFolderId,
          }),
        );

        if (response.statusCode == 201) {
          setState(() {
            _showAddDkaForm = false;
            _fetchDkaHistoryFuture = fetchDkaHistory(medicalFolderId);
          });
          // Clear text fields after successful registration
          acetoneController.clear();
          dateController.clear();
        } else {
          print('Failed to create DKA history: ${response.statusCode}');
        }
      } else {
        print('Failed to fetch or create medical folder ID');
      }

      // Print the value of medicalFolderId after fetching or creating the medical folder
      print('medicalFolderId after fetching or creating medical folder: $medicalFolderId');
    } catch (error) {
      print('Error registering DKA history: $error');
    }
  }
  Widget _buildAddDkaForm() {
    return Container(
      color:Colors.teal[50],
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'DKA Order',
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              prefixIcon: Icon(
                Icons.history,
                color: Color(0xFF199A8E),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF199A8E),
                ),
              ),
            ),
            value: dkaOrderValue,
            onChanged: (String? newValue) {
              setState(() {
                dkaOrderValue = newValue!;
              });
            },
            items: [
              'First Time',
              'Second Time',
              'Third Time',
              'Fourth Time',
              'Fifth Time',
              'Sixth Time',
              'Seventh Time',
              'Eighth Time',
              'Ninth Time',
              'Tenth Time',
              'More than Ten Times',
            ].map((String order) {
              return DropdownMenuItem<String>(
                value: order,
                child: Text(order),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: acetoneController,
            decoration: InputDecoration(
              labelText: 'Ketone Level In ppm',
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              prefixIcon: Icon(
                Icons.history,
                color: Color(0xFF199A8E),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF199A8E),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: dateController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.date_range_outlined, color: Color(0xFF199A8E)),
              labelText: 'Date',
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF199A8E),
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: Icon(Icons.calendar_today, color: Color(0xFF199A8E)),
              ),
            ),
            readOnly: true,
            onTap: () {
              _selectDate(context);
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              registerDkaHistory();
              setState(() {
                _showAddDkaForm = false;
                _fetchDkaHistoryFuture = fetchDkaHistory(idFolder);
              });
            },
            child: Text('Register',style: TextStyle(fontFamily: 'Poppins',color: Colors.black, fontWeight: FontWeight.bold, fontSize:15
            ),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[50],
        title: Text(
          'History',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedHistoryType = 'Test';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Colors.white,
                  ),
                  child: Text('Test History',
                    style: TextStyle(
                        color:Colors.black,fontFamily: 'Poppins'
                    ),),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedHistoryType = 'DKA';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Color(0xFFB0EFE9),
                  ),
                  child: Text('DKA History', style: TextStyle(
                    color:Colors.black,fontFamily: 'Poppins'
                  ),),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedHistoryType == 'Test'
                ? FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final historyData = snapshot.data!;
                  if (historyData.isEmpty) {
                    return Center(child: Text('No Test history available'));
                  }
                  return ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final item = historyData[index];
                      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['date']));
                      final formattedTime = DateFormat('HH:mm:ss').format(DateTime.parse(item['date']));
                      return Dismissible(
                        key: Key('$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          final testId = item['id_test'];
                          deleteTest(testId);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal:20 ,vertical: 10),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFF199A8E),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: $formattedDate',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Time: $formattedTime',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'State: ${item['state']}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Ketone Level: ${item['acetoneqt']} ppm',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
                : _showAddDkaForm
                ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildAddDkaForm(),
                ],
              ),
            )
                : FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchDkaHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final historyData = snapshot.data!;
                  if (historyData.isEmpty) {
                    return Center(child: Text('No DKA history available'));
                  }
                  return ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final item = historyData[index];
                      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['date']));
                      final formattedTime = DateFormat('HH:mm:ss').format(DateTime.parse(item['date']));
                      return Dismissible(
                        key: Key('$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          deleteDkaHistory(item['id'], idFolder);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal:20 ,vertical: 20),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFF199A8E),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order: ${item['order']}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Date: $formattedDate',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),

                              SizedBox(height: 10),
                              Text(
                                'Ketone Level: ${item['acetoneqt']} ppm',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedHistoryType == 'DKA'
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _showAddDkaForm = !_showAddDkaForm;
          });
        },
        child: Icon(_showAddDkaForm ? Icons.close : Icons.add),
      )
          : null,
    );
  }
}
