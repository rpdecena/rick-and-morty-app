import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/presentation/screens/home/cubits/character_cubit.dart';
import 'package:rick_and_morty_app/presentation/widgets/character_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rick & Morty Characters')),
      body: BlocBuilder<CharacterCubit, CharacterState>(
        builder: (context, state) {
          if (state is CharacterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CharacterLoaded) {
            return ListView.builder(
              itemCount: state.characters.length,
              itemBuilder: (context, index) {
                final char = state.characters[index];
                return CharacterListItem(character: char);
              },
            );
          } else if (state is CharacterError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Press the button to load'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CharacterCubit>().getCharacters(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
