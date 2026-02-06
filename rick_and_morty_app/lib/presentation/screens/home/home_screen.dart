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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Hardcoded Choices
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
    // Setup Pagination Listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<CharacterCubit>().loadMore();
      }
    });
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
                            // Rebuild to hide clear icon
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Optional: open a filters modal in the future
            },
          )
        ],
        // Filters in Bottom Slot
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
      body: BlocBuilder<CharacterCubit, CharacterState>(
        builder: (context, state) {
          if (state is CharacterLoading && state.isFirstFetch) {
            return const Center(child: CircularProgressIndicator());
          }

          List characters = [];
          bool isLoadingMore = false;

          if (state is CharacterLoading) {
            characters = state.oldCharacters;
            isLoadingMore = true;
          } else if (state is CharacterLoaded) {
            characters = state.characters;
          } else if (state is CharacterError) {
            return Center(child: Text(state.message));
          }

          if (characters.isEmpty) {
            return const Center(child: Text('No characters found.'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: characters.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < characters.length) {
                final char = characters[index];
                return CharacterListItem(character: char);
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
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
