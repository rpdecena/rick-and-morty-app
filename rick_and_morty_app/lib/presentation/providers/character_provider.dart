import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/domain/models/character.dart';
import 'package:rick_and_morty_app/domain/usecases/character_usecases.dart';

class CharacterProvider extends ChangeNotifier {
  final GetCharactersUseCase getCharactersUseCase;
  final GetCharacterByIdUseCase getCharacterByIdUseCase;
  final GetMultipleCharactersUseCase getMultipleCharactersUseCase;

  CharacterResponse? _characterResponse;
  String? _error;
  bool _isLoading = false;
  int _currentPage = 1;

  CharacterResponse? get characterResponse => _characterResponse;
  String? get error => _error;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;

  CharacterProvider({
    required this.getCharactersUseCase,
    required this.getCharacterByIdUseCase,
    required this.getMultipleCharactersUseCase,
  });

  Future<void> fetchCharacters({int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      _characterResponse = await getCharactersUseCase(page: page);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _characterResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (_characterResponse != null &&
        _currentPage < _characterResponse!.info.pages) {
      await fetchCharacters(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 1) {
      await fetchCharacters(page: _currentPage - 1);
    }
  }

  Future<void> retry() async {
    await fetchCharacters(page: _currentPage);
  }
}
