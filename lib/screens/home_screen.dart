import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<dynamic>> fetchDisneyCharacters() async {
    final response =
        await http.get(Uri.parse('https://api.disneyapi.dev/character'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load Disney characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disney Characters"),
      ),
      body: FutureBuilder(
        future: fetchDisneyCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final List<dynamic> characters = snapshot.data!;
            return ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];

                final controller = ExpandedTileController();

                final name = character['name'] ?? 'Unknown';
                final imageUrl = character['imageUrl'];
                final description = character['shortDescription'] ??
                    (character['films']?.isNotEmpty == true
                        ? 'Featured in: ${character['films'][0]}'
                        : 'No description available.');

                return ExpandedTile(
                    controller: controller,
                    title: Text(name),
                    leading: imageUrl != null
                        ? Image.network(character['imageUrl'],
                            width: 50, height: 50)
                        : const Icon(Icons.image_not_supported),
                    content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${character['id']}'),
                          if (character['films'] != null &&
                              (character['films'] as List).isNotEmpty)
                            Text(
                                'Appears in: ${(character['films'] as List).join(', ')}'),
                          Text(description),
                        ]));
              },
            );
          } else {
            return const Center(child: Text('No characters found. :[ '));
          }
        },
      ),
    );
  }
}
