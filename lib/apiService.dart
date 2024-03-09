import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/patients';

 // Future<http.Response> registerUser(String email, String password) async {
   // final response = await http.post(
     // '$baseUrl/login' as Uri,
      //body: {'email': email, 'password': password},
    //);
    //return response;


  Future<http.Response> loginUser(String email, String password) async {

    final response = await http.post('$baseUrl/login' as Uri,
      body: {'email': email, 'password': password},
    );
    return response;
  }
}
