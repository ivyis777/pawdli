import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawlli/data/model/radiostreammodel.dart';

class StreamRepository {
  Future<StreamModel> fetchStream(int slotId) async {
    final response = await http.post(
      Uri.parse('https://app.pawdli.com/user/check_stream_url'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"slot_id": slotId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["stream_url"] != null) {
      return StreamModel.fromJson(data);
    } else {
      throw data["message"] ?? "Stream URL not found";
    }
  }
}
