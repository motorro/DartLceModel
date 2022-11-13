import 'package:flutter/material.dart';

import '../data/Repository.dart';

class ContentState extends StatelessWidget {
  final List<Repository> _repositories;

  const ContentState({super.key, required List<Repository> repositories}) : _repositories = repositories;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _repositories.length,
        itemBuilder: (context, i) {
          final repo = _repositories[i];
          return Card(
              child: ListTile(
                  title: Text(repo.name),
                  subtitle: Text(repo.language)
              )
          );
        });
  }
}
