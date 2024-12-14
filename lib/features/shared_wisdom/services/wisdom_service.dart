import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wisdom_post.dart';
import '../models/conversation_detail.dart';

class WisdomService {
  static const String baseUrl = 'https://tech0-advance2-webapp4-ayecbfc4b4akgmc7.koreasouth-01.azurewebsites.net/';

  Future<List<WisdomPost>> getPublicConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public-conversations'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);

        print('Received data: $data'); // デバッグ用

        return data.map((json) {
          try {
            return WisdomPost.fromJson(json);
          } catch (e) {
            print('Error parsing post: $e'); // デバッグ用
            print('Problematic json: $json'); // デバッグ用
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to load public conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPublicConversations: $e'); // デバッグ用
      rethrow;
    }
  }

  Future<bool> toggleLike(int conversationId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/likes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'conversation_id': conversationId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in toggleLike: $e');
      return false;
    }
  }

  Future<ConversationDetail> getConversationDetail(int conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/detail'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        print('Received conversation detail: $data'); // デバッグ用

        try {
          return ConversationDetail.fromJson(data);
        } catch (e) {
          print('Error parsing conversation detail: $e'); // デバッグ用
          print('Problematic json: $data'); // デバッグ用
          rethrow;
        }
      } else {
        throw Exception('Failed to load conversation detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getConversationDetail: $e'); // デバッグ用
      rethrow;
    }
  }
}