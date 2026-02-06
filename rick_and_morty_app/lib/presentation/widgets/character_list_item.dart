import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/domain/entities/character.dart'
    as domain_char;
import 'package:rick_and_morty_app/domain/models/character.dart' as full_char;
import 'package:rick_and_morty_app/core/navigation/routes.dart';

class CharacterListItem extends StatelessWidget {
  final dynamic character;

  const CharacterListItem({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.characterDetail,
          arguments: character,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.lightGreenAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Character Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                (character is full_char.Character)
                    ? (character as full_char.Character).image
                    : (character as domain_char.Character).image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade700,
                    child: const Icon(Icons.error, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Character Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (character is full_char.Character)
                        ? (character as full_char.Character).name
                        : (character as domain_char.Character).name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor((character
                                  is full_char.Character)
                              ? (character as full_char.Character).status
                              : (character as domain_char.Character).status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (character is full_char.Character)
                              ? (character as full_char.Character).status
                              : (character as domain_char.Character).status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (character is full_char.Character)
                              ? (character as full_char.Character).species
                              : (character as domain_char.Character).species,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green.shade600;
      case 'dead':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
