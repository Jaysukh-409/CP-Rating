import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> ratingOfUser(String user) async {
  String url = "https://codeforces.com/api/user.rating?handle=$user";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var list = json.decode(response.body);
    int sz = list['result'].length;
    int newRating = 0;
    if (sz == 0) {
      newRating = 0;
    } else {
      newRating = list['result'][sz - 1]['newRating'];
    }
    return newRating;
  } else {
    // throw Exception('Failed to load Data');
    return -1;
  }
}
