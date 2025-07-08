import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'EditRecipeScreen.dart'; // Make sure this path matches the actual location of EditRecipeScreen
import '../service/ResepService.dart'; // Update the path if your ResepService is located elsewhere
import '../model/recipe.dart'; // Make sure this path matches the actual location of your Recipe class




class FoodPhotoCard extends StatelessWidget {
  final Map<String, dynamic> foodPhoto;
  final Recipe recipe;
  final VoidCallback onDeleteSuccess;

  const FoodPhotoCard({
    super.key,
    required this.foodPhoto,
    required this.recipe,
    required this.onDeleteSuccess,
  });

  void _handleMenuAction(BuildContext context, String value) async {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditRecipeScreen(recipe: recipe),
        ),
      );
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Yakin ingin menghapus resep ini?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
          ],
        ),
      );

      if (confirm == true) {
        final response = await ResepService.deleteResep(recipe.id);
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Resep berhasil dihapus')),
          );
          onDeleteSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Gagal menghapus resep')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                foodPhoto['image_url'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Resep')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              foodPhoto['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
