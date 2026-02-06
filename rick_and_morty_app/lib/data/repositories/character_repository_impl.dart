import 'package:rick_and_morty_app/models/character.dart';
import 'package:rick_and_morty_app/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/data/datasources/character_remote_datasource.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource remoteDataSource;

  CharacterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CharacterResponse> getCharacters({int page = 1}) async {
    return await remoteDataSource.getCharacters(page: page);
  }

  @override
  Future<Character> getCharacterById(int id) async {
    return await remoteDataSource.getCharacterById(id);
  }

  @override
  Future<List<Character>> getMultipleCharacters(List<int> ids) async {
    return await remoteDataSource.getMultipleCharacters(ids);
  }
}
