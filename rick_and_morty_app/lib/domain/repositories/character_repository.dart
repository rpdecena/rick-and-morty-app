import 'package:rick_and_morty_app/models/character.dart';

abstract class CharacterRepository {
  Future<CharacterResponse> getCharacters({int page = 1});
  Future<Character> getCharacterById(int id);
  Future<List<Character>> getMultipleCharacters(List<int> ids);
}
