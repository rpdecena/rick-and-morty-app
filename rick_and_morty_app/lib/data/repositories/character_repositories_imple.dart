import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/character.dart';
import '../models/character_model.dart';

class CharacterRepositoryImpl {
  final http.Client client;
  CharacterRepositoryImpl({required this.client});

  Future<List<Character>> getCharacters() async {
    final response = await client
        .get(Uri.parse('https://rickandmortyapi.com/api/character'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => CharacterModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }
}
