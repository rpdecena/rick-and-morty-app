import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/data/repositories/character_repositories_imple.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart';
import 'package:rick_and_morty_app/data/models/character_model.dart';

// 1. States
abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  CharacterLoaded(this.characters);
}

class CharacterError extends CharacterState {
  final String message;
  CharacterError(this.message);
}

class CharacterCubit extends Cubit<CharacterState> {
  final CharacterRepositoryImpl repository;

  CharacterCubit(this.repository) : super(CharacterInitial());

  void getCharacters() async {
    try {
      emit(CharacterLoading());
      final characters = await repository.getCharacters();
      emit(CharacterLoaded(characters));
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }
}
