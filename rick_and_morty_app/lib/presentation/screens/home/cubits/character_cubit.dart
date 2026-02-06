// presentation/screens/home/cubits/character_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/data/repositories/character_repositories_imple.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';

// --- States ---
abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {
  final List<Character> oldCharacters; // Keep old data while loading next page
  final bool isFirstFetch;

  CharacterLoading(this.oldCharacters, {this.isFirstFetch = false});
}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  final bool hasReachedMax; // To stop pagination

  CharacterLoaded(this.characters, {this.hasReachedMax = false});
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

  // Triggered by Search Button or Filter Change
  void loadCharacters({
    String? name,
    String? status,
    String? species,
  }) {
    if (isFetching) return;
    
    // Reset for new search
    page = 1;
    currentName = name ?? currentName;
    currentStatus = status ?? currentStatus;
    currentSpecies = species ?? currentSpecies;
    
    _fetchCharacters(isFirstFetch: true);
  }

  // Triggered by ScrollController
  void loadMore() {
    if (state is CharacterLoaded && (state as CharacterLoaded).hasReachedMax) return;
    if (isFetching) return;

    _fetchCharacters(isFirstFetch: false);
  }

  void _fetchCharacters({required bool isFirstFetch}) async {
    try {
      isFetching = true;
      List<Character> oldCharacters = [];
      
      if (state is CharacterLoaded) {
        oldCharacters = (state as CharacterLoaded).characters;
      }

      if (isFirstFetch) {
        emit(CharacterLoading([], isFirstFetch: true));
      } else {
        // Show loading indicator at bottom while keeping list
        emit(CharacterLoading(oldCharacters, isFirstFetch: false));
      }

      final newCharacters = await repository.getCharacters(
        page: page,
        name: currentName,
        status: currentStatus,
        species: currentSpecies,
      );

      isFetching = false;
      page++;

      final totalCharacters = isFirstFetch 
          ? newCharacters 
          : [...oldCharacters, ...newCharacters];

      emit(CharacterLoaded(
        totalCharacters, 
        hasReachedMax: newCharacters.isEmpty // If return empty, we are done
      ));
    } catch (e) {
      isFetching = false;
      emit(CharacterError(e.toString()));
    }
  }
}