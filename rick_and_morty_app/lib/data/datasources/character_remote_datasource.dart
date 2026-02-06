import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rick_and_morty_app/domain/models/character.dart';

abstract class CharacterRemoteDataSource {
  Future<CharacterResponse> getCharacters({int page = 1});
  Future<Character> getCharacterById(int id);
  Future<List<Character>> getMultipleCharacters(List<int> ids);
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  final http.Client httpClient;

  CharacterRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<CharacterResponse> getCharacters({int page = 1}) async {
    try {
      final response = await httpClient
          .get(
            Uri.parse('$baseUrl/character?page=$page'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return CharacterResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Page not found');
      } else {
        throw Exception('Failed to load characters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }

  @override
  Future<Character> getCharacterById(int id) async {
    try {
      final response = await httpClient
          .get(
            Uri.parse('$baseUrl/character/$id'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Character.fromJson(jsonData);
      } else {
        throw Exception('Failed to load character: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching character: $e');
    }
  }

  @override
  Future<List<Character>> getMultipleCharacters(List<int> ids) async {
    try {
      final idString = ids.join(',');
      final response = await httpClient
          .get(
            Uri.parse('$baseUrl/character/$idString'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          return jsonData
              .map((e) => Character.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          return [Character.fromJson(jsonData as Map<String, dynamic>)];
        }
      } else {
        throw Exception('Failed to load characters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }
}
