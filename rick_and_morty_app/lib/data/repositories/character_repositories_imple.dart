// data/repositories/character_repositories_imple.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/character.dart';
import '../models/character_model.dart';

class CharacterRepositoryImpl {
  final http.Client client;
  CharacterRepositoryImpl({required this.client});

  Future<List<Character>> getCharacters({
    int page = 1,
    String name = '',
    String status = '',
    String species = '',
  }) async {
    // Build query parameters
    final Map<String, String> queryParams = {
      'page': page.toString(),
    };
    if (name.isNotEmpty) queryParams['name'] = name;
    if (status.isNotEmpty && status != 'All') queryParams['status'] = status;
    if (species.isNotEmpty && species != 'All') queryParams['species'] = species;

    final uri = Uri.https('rickandmortyapi.com', '/api/character/', queryParams);

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => CharacterModel.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // API returns 404 if filter finds no matches
      return []; 
    } else {
      throw Exception('Failed to load characters');
    }
  }
}