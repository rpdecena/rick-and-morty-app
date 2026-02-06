import 'package:rick_and_morty_app/domain/models/character.dart';
import 'package:rick_and_morty_app/domain/repositories/character_repository.dart';

class GetCharactersUseCase {
  final CharacterRepository repository;

  GetCharactersUseCase({required this.repository});

  Future<CharacterResponse> call({int page = 1}) {
    return repository.getCharacters(page: page);
  }
}

class GetCharacterByIdUseCase {
  final CharacterRepository repository;

  GetCharacterByIdUseCase({required this.repository});

  Future<Character> call(int id) {
    return repository.getCharacterById(id);
  }
}

class GetMultipleCharactersUseCase {
  final CharacterRepository repository;

  GetMultipleCharactersUseCase({required this.repository});

  Future<List<Character>> call(List<int> ids) {
    return repository.getMultipleCharacters(ids);
  }
}
