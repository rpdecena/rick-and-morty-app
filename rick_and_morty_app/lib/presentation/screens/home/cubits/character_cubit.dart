import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/data/repositories/character_repositories_imple.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';

// --- States ---
abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {
  final List<Character> currentList; 
  final bool isFirstFetch;

  CharacterLoading(this.currentList, {this.isFirstFetch = false});
}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  final int currentPage; // Added to track UI display
  final bool hasReachedMax;

  CharacterLoaded(this.characters, {required this.currentPage, this.hasReachedMax = false});
}

class CharacterError extends CharacterState {
  final String message;
  CharacterError(this.message);
}

// --- Cubit ---
class CharacterCubit extends Cubit<CharacterState> {
  final CharacterRepositoryImpl repository;

  CharacterCubit(this.repository) : super(CharacterInitial());

  int page = 1;
  String currentName = '';
  String currentStatus = '';
  String currentSpecies = '';
  bool isFetching = false; 

  // --- Search / Filter Reset ---
  void loadCharacters({
    String? name,
    String? status,
    String? species,
  }) {
    if (isFetching) return;
    
    page = 1;
    currentName = name ?? currentName;
    currentStatus = status ?? currentStatus;
    currentSpecies = species ?? currentSpecies;
    
    _fetchCharacters(isFirstFetch: true);
  }

  // --- Pagination Controls ---
  void nextPage() {
    if (isFetching) return;
    if (state is CharacterLoaded && (state as CharacterLoaded).hasReachedMax) return;
    
    page++;
    _fetchCharacters(isFirstFetch: false);
  }

  void previousPage() {
    if (isFetching || page <= 1) return;
    
    page--;
    _fetchCharacters(isFirstFetch: false);
  }

  void _fetchCharacters({required bool isFirstFetch}) async {
    try {
      isFetching = true;
      List<Character> currentList = [];
      
      // Keep displaying current list while loading next page to avoid white flash
      if (state is CharacterLoaded) {
        currentList = (state as CharacterLoaded).characters;
      }

      emit(CharacterLoading(currentList, isFirstFetch: isFirstFetch));

      final newCharacters = await repository.getCharacters(
        page: page,
        name: currentName,
        status: currentStatus,
        species: currentSpecies,
      );

      isFetching = false;

      // Logic Change: We REPLACE the list, not append.
      // We assume API returns < 20 items if it's the last page.
      emit(CharacterLoaded(
        newCharacters, 
        currentPage: page,
        hasReachedMax: newCharacters.length < 20 
      ));
    } catch (e) {
      isFetching = false;
      emit(CharacterError(e.toString()));
    }
  }
}