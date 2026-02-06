import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/presentation/screens/home/cubits/character_cubit.dart';
import 'package:rick_and_morty_app/presentation/widgets/character_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Note: ScrollController is no longer needed for pagination logic,
  // but kept if you want to scroll to top on page change.
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> statusOptions = ['All', 'Alive', 'Dead', 'unknown'];
  final List<String> speciesOptions = [
    'All',
    'Human',
    'Alien',
    'Humanoid',
    'Poopybutthole',
    'Mythological Creature',
    'Robot',
    'Cronenberg'
  ];

  String selectedStatus = 'All';
  String selectedSpecies = 'All';

  @override
  void initState() {
    super.initState();
  }

  void _performSearch() {
    context.read<CharacterCubit>().loadCharacters(
          name: _searchController.text,
          status: selectedStatus == 'All' ? '' : selectedStatus,
          species: selectedSpecies == 'All' ? '' : selectedSpecies,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Modern Search Bar in Title
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  border: InputBorder.none,
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey.shade700, size: 20),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade700),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                style: const TextStyle(color: Colors.black87),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
              );
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                _buildDropdown(
                  value: selectedStatus,
                  items: statusOptions,
                  label: "Status",
                  onChanged: (val) {
                    setState(() => selectedStatus = val!);
                    _performSearch();
                  },
                ),
                const SizedBox(width: 10),
                _buildDropdown(
                  value: selectedSpecies,
                  items: speciesOptions,
                  label: "Species",
                  onChanged: (val) {
                    setState(() => selectedSpecies = val!);
                    _performSearch();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CharacterCubit, CharacterState>(
              builder: (context, state) {
                if (state is CharacterLoading && state.isFirstFetch) {
                  return const Center(child: CircularProgressIndicator());
                }

                List characters = [];

                if (state is CharacterLoading) {
                  try {
                    characters = state.currentList;
                  } catch (_) {
                    characters = (state as dynamic).oldCharacters ?? [];
                  }
                } else if (state is CharacterLoaded) {
                  characters = state.characters;
                } else if (state is CharacterError) {
                  return Center(child: Text(state.message));
                }

                if (characters.isEmpty) {
                  return const Center(child: Text('No characters found.'));
                }

                return Opacity(
                  opacity: state is CharacterLoading ? 0.5 : 1.0,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final char = characters[index];
                      return CharacterListItem(character: char);
                    },
                  ),
                );
              },
            ),
          ),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: BlocBuilder<CharacterCubit, CharacterState>(
        builder: (context, state) {
          int currentPage = 1;
          bool isLastPage = false;
          bool isLoading = false;

          if (state is CharacterLoaded) {
            currentPage = state.currentPage;
            isLastPage = state.hasReachedMax;
          } else if (state is CharacterLoading) {
            isLoading = true;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PREVIOUS BUTTON
              SizedBox(
                width: 120, // Fixed width ensures symmetry
                child: ElevatedButton(
                  onPressed: (currentPage <= 1 || isLoading)
                      ? null
                      : () {
                          context.read<CharacterCubit>().previousPage();
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }
                        },
                  child: const Text("Previous"),
                ),
              ),
              
              if (isLoading)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text(
                  "Page $currentPage",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),

              // NEXT BUTTON
              SizedBox(
                width: 120, // Same width as Previous
                child: ElevatedButton(
                  onPressed: (isLastPage || isLoading)
                      ? null
                      : () {
                          context.read<CharacterCubit>().nextPage();
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }
                        },
                  child: const Text("Next"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}