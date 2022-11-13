import 'dart:async';

import 'package:dartlcemodel/dartlcemodel_cache.dart';
import 'package:dartlcemodel/dartlcemodel_lce.dart';
import 'package:dartlcemodel/dartlcemodel_model.dart';
import 'package:dartlcemodel/dartlcemodel_utils.dart';
import 'package:example/data/Repository.dart';
import 'package:example/lceWidget.dart';
import 'package:example/service/repositoryNetService.dart';
import 'package:example/view/colors.dart';
import 'package:example/view/content.dart';
import 'package:example/view/error.dart';
import 'package:example/view/loading.dart';
import 'package:flutter/material.dart';

/// Globally available service-set that is somehow available to required application parts
/// If anything wants to invalidate data it uses the cache to propagate changes
/// See app-bar refresh action for example
late ServiceSet<List<Repository>, String> serviceSet;
Logger logger = const Logger.print();

void main() {
  // Creates a set of services
  // - memory cache for data
  // - a service to get data from server. `isolated()` runs networking and parsing in [Isolate]
  serviceSet = ServiceSet(
      CacheService<List<Repository>, String>.withSyncDelegate(MemoryCacheDelegate.map()),
      RepositoryNetService()//.isolated()
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Welcome to DartLceModel',
      home: HomePage(),
    );
  }
}

/// Lists repositories for GitHub user
/// - Press Search to search for input
/// - Press Refresh to externally invalidate cache
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _search = 'motorro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
              children: [
                const Text('Welcome to DartLceModel'),
                const SizedBox(width: 30),
                Search(
                  onRequest: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                  text: _search,
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await serviceSet.cache.invalidateAll();
                  },
                  child: const Icon(
                    Icons.refresh,
                    size: 26.0,
                  )
                )
              ]
          )
      ),
      body: Center(child: UserRepositories(user: _search)),
    );
  }
}

/// Handles [LceUseCase] to load user repositories for requested [user]
class UserRepositories extends LceWidget<List<Repository>> {
  final String user;

  const UserRepositories({Key? key, required this.user}): super(key: key);

  @override
  LceUseCase<List<Repository>> factory() => LceModel.cacheThenNet(user, serviceSet, logger: logger);

  @override
  Widget processState(LceState<List<Repository>> lceState, Future<void> Function() refresh) => lceState.when(
      loading: (_) => const LoadingState(),
      content: (state) => ContentState(repositories: state.data),
      error: (state) => ErrorState(error: state.error, onRetry: () async { await refresh(); })
  );

  @override
  bool resubscribe(covariant UserRepositories newWidget, covariant UserRepositories oldWidget) => newWidget.user != oldWidget.user;
}

/// Search string
class Search extends StatelessWidget {
  final void Function(String string) onRequest;
  final TextEditingController editingController;

  Search({Key? key, required this.onRequest, String? text})
      : editingController = TextEditingController(text: text),
        super(key: key);

  @override
  Widget build(BuildContext context) => Row(
      children: [
        SizedBox(width: 250, height: 40, child: TextField(
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.left,
            maxLines: 1,
            controller: editingController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                hintText: "Search",
                filled: true,
                fillColor: colorWhite,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                )
            )
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            final text = editingController.value.text.trim();
            if (text.isNotEmpty) {
              onRequest(text);
            }
          },
          child: const Icon(
            Icons.search,
            size: 26.0,
          ),
        )
      ]
  );
}



