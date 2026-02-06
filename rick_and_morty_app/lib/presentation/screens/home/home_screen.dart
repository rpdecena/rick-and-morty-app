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
    'All', 'Human', 'Alien', 'Humanoid', 'Poopybutthole',
    'Mythological Creature', 'Robot', 'Cronenberg'
  ];

  String selectedStatus = 'All';
  String selectedSpecies = 'All';

  @override
  void initState() {
    super.initState();
    // REMOVED: Scroll listener for infinite scrolling
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
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          )
        ],
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
      // CHANGED: Use Column to stack List and Pagination Bar
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CharacterCubit, CharacterState>(
              builder: (context, state) {
                // Handle initial loading
                if (state is CharacterLoading && state.isFirstFetch) {
                  return const Center(child: CircularProgressIndicator());
                }

                List characters = [];
                
                // Logic updated for Pagination (replacing list, not appending)
                if (state is CharacterLoading) {
                  // If using the updated Cubit from previous step, use currentList
                  // fallback to empty if your state hasn't been updated yet
                  try {
                    characters = state.currentList; 
                  } catch (_) {
                    // Fallback if you haven't updated State class variable name
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

                // Opacity creates a subtle "loading" effect on the list while fetching next page
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
          // ADDED: Pagination Controls
          _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      color: Colors.grey[200], // distinct background
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
             // We can't access page easily in loading state without casting 
             // or storing it in the cubit differently, so we assume buttons disabled
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: (currentPage <= 1 || isLoading)
                    ? null
                    : () {
                        context.read<CharacterCubit>().previousPage();
                        // Optional: Scroll to top when changing page
                        if (_scrollController.hasClients) {
                           _scrollController.jumpTo(0);
                        }
                      },
                child: const Text("Previous"),
              ),
              if (isLoading)
                const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                )
              else
                Text(
                  "Page $currentPage",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ElevatedButton(
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