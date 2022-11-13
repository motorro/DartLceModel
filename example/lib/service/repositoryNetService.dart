
import 'dart:convert';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:http/http.dart' as http;

import '../data/Repository.dart';

/// Runs network requests to retrieve data
class RepositoryNetService implements NetService<List<Repository>, String> {
  /// Provides validator with data TTL of 30 seconds
  final _validatorFactory = EntityValidatorFactory.lifespan(30000);

  @override
  Future<Entity<List<Repository>>> get(String params) async {
    final dataURL = Uri.parse('https://api.github.com/users/$params/repos');
    http.Response response = await http.get(dataURL, headers: {'Accept' : 'application/vnd.github+json'});
    final List<Repository> data = jsonDecode(response.body)
        .where((item) => null != item)
        .map<Repository>((source) => Repository.fromJson(source))
        .toList(growable: false);
    return Entity.create(data, _validatorFactory.create());
  }
}
