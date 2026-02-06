import 'package:http/http.dart' as http;
import 'package:rick_and_morty_app/data/datasources/character_remote_datasource.dart';
import 'package:rick_and_morty_app/data/repositories/character_repository_impl.dart';
import 'package:rick_and_morty_app/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/domain/usecases/character_usecases.dart';
import 'package:rick_and_morty_app/presentation/providers/character_provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  late CharacterProvider _characterProvider;

  void setup() {
    // Data Sources
    final httpClient = http.Client();
    final characterRemoteDataSource = CharacterRemoteDataSourceImpl(
      httpClient: httpClient,
    );

    // Repositories
    final CharacterRepository characterRepository =
        CharacterRepositoryImpl(
          remoteDataSource: characterRemoteDataSource,
        );

    // Use Cases
    final GetCharactersUseCase getCharactersUseCase =
        GetCharactersUseCase(repository: characterRepository);
    final GetCharacterByIdUseCase getCharacterByIdUseCase =
        GetCharacterByIdUseCase(repository: characterRepository);
    final GetMultipleCharactersUseCase getMultipleCharactersUseCase =
        GetMultipleCharactersUseCase(repository: characterRepository);

    // Providers
    _characterProvider = CharacterProvider(
      getCharactersUseCase: getCharactersUseCase,
      getCharacterByIdUseCase: getCharacterByIdUseCase,
      getMultipleCharactersUseCase: getMultipleCharactersUseCase,
    );
  }

  CharacterProvider get characterProvider => _characterProvider;
}
