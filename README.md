# DartLceModel

A reactive data loading for Dart platform to load data and report an
operation state (`Loading`/`Content`/`Error`).

**WORK IN PROGRESS**. Refer to [Android library docs](https://github.com/motorro/RxLceModel) to get an overview

## Features
- Widely used design with `Loading`/`Content`/`Error` states
- Uses cache as a 'source of truth' with [CacheThenNetLceModel](#cachethennetlcemodel).
- Checks data is valid (up-to-date or whatever).
- Falls back to invalid cache data if failed to refresh which allows offline application use.
- Supports data _refresh_ or _update_ to implement reload or server data update operations.
- Cache may be _invalidated_ separately from loading to allow lazy data updates and complex data linking.
- Extendable architecture on every level.
- Thoroughly tested.

## Example
The project contains an example app that:
- loads a list of GitHub user repositories, caching resulting data
- externally invalidates cache that makes active listeners to reload data

## Table of Contents

<!-- toc -->

- [Setting up the dependency](#setting-up-the-dependency)
- [LceState](#lcestate)
- [LceModel](#lcemodel)
- [CacheThenNetLceModel](#cachethennetlcemodel)
- [Getting and caching data](#getting-and-caching-data)
- [Choosing EntityValidator](#choosing-entityvalidator)
- [Displaying 'invalid' data and cache fall-back](#displaying-invalid-data-and-cache-fall-back)
- [Cache invalidation and data updates](#cache-invalidation-and-data-updates)
- [On-demand cache refetch](#on-demand-cache-refetch)
- [Cache service implementation](#cache-service-implementation)
- [A complete example of model setup in a widget](#a-complete-example-of-model-setup-in-a-widget)
- [Getting data-only stream and stream transformations](#getting-data-only-stream-and-stream-transformations)
- [State transformations](#state-transformations)

<!-- tocstop -->

## Setting up the dependency [![pub package](https://img.shields.io/pub/v/dartlcemodel.svg)](https://pub.dev/packages/dartlcemodel):

```shell
$ dart pub add dartlcemodel
```

## LceState
A modern approach to architecting the reactive application suggests packing the combined state of the application into a
flow of immutable state-objects. Each of them should contain the whole set of data required to process, transform,
and display according to the business requirement. The most commonly used information besides the data itself is a state
of data-loading pipeline.

![LceState class diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/lce_state.puml)

Each `LceState<DATA, PARAMS>` subclass represents a data-loading phase and contains the following data:
*  `DATA? data` - Loaded data
*  `bool dataIsValid` - The validity of data at the time of emission. May be used by caching services to indicate
   the need of data refresh. More about it in [CacheThenNetLceModel](#cachethennetlcemodel) section.

States being emitted are:
* `Loading` - data is being loaded or updated. May contain some data. The exact state is defined by `type` property:
```dart
/// Loading type
enum LoadingType {
  /// Just loads. May be initial load operation
  loading,
  /// Loading more items for paginated view
  loadingMore,
  /// Refreshing content
  refreshing,
  /// Updating data on server
  updating
}
```
* `Content` - data is loaded.
* `Error` - some error  while loading or updating data. May also contain some data.
* `Terminated` - a special state to indicate that resource identified by `params` is not available anymore. 

## LceModel
`LceState<DATA, PARAMS>` in this library is being produced by the simple use-case [interface](lib/src/model/lceUseCase.dart):
```dart
/// Base LCE use-case with [state] and [refresh]
/// [DATA] Data type of data being loaded
abstract class LceUseCase<DATA extends Object> {
    /// Model state. Subscription starts data load for the first subscriber.
    /// Whenever last subscriber cancels, the model unsubscribes internal components for data updates
    Stream<LceState<DATA>> get state;

    /// Requests a refresh of data.
    /// Data will be updated asynchronously
    Future<void> refresh();
}
```
The use-case contains the following properties:
*   `state` - the `Stream` that emits `LceState`
*   `refresh` - the `Future` to perform data refresh
  
The direct extension of the use-case is the [LceModel](lib/src/model/lceModel.dart) that binds the expected data with 
the data identifying `PARAMS`:
```dart
/// A model interface to load data and transmit it to subscribers along with loading operation state
/// The model is bound with [params] that identify the data
/// [DATA] Data type of data being loaded
/// [PARAMS] Params type that identify data being loaded
abstract class LceModel<DATA extends Object, PARAMS extends Object> implements LceUseCase<DATA> {

  /// Params that identify data being loaded
  PARAMS get params;
}
```

As you may see, parameters for model is a property - thus making the model immutable itself. This approach makes
things a bit easier in many cases like:
*   When you share your model and it's emission
*   You don't need to supply a Stream for `PARAMS` which complicates design a lot
    If you need dynamic params - just flat-map your params by creating a new model for each parameter value like this:

```dart
Stream<string> params = Stream.fromIterable(['peach', 'banana', 'apple']);
Stream<LceState<FruitData>> state = params.asyncExpand((params) => createModel(params).state);
```

## CacheThenNetLceModel
As you may guess from its name this kind of model tries to get cached data first and then loads data from network if
nothing is found or the cached data is stalled. Here is the sequence diagram of data loading using this type of model:

![CacheThenNet loading sequence](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/loading.puml)

The model creates a data stream for given `PARAMS` in a [cache-service](lib/src/model/service/cacheService.dart)
and transmits it to subscriber. If cache does not contain any data or data is not valid (more on validation later) the
model subscribes a [net-service](lib/src/model/service/netService.dart) to download data from network and saves it 
to the cache for a later use.

It is worth noting that `cache` and `net` here is just a common use-case of data-sources: locally stored  data (`cache`)
and some data that is maybe not that easy to get (`net`). You may easily adopt data sources of your choice to that
approach. Say you have a resource-consuming computation result which may be cached and consumed later. The computation
itself than becomes a `net-service` while the result is being stashed to a `cache-service` of
your choice for later reuse.

To create new `CacheThenNet` model call a factory function:
```dart
final useCase = LceModel.cacheThenNet(
    'params', // params that identify the data being loaded 
    serviceSet, // A set of cache + net services (see below)
    startWith: const LceState.loading(null, false), // Optional initial state to emit at subscription
    logger: logger // Optional logger to get what's going on inside the use-case
);
``` 

## Getting and caching data
As already mentioned above caching model uses two services to get data from network and to store it locally.

*   [NetService](lib/src/model/service/netService.dart) - loads data from network.
*   [CacheService](lib/src/model/service/cacheService.dart) - saves data locally.

Caching data always brings up a problem of cache updates and invalidation. Be it a caching policy of your backend team
or some internal logic of your application the data validity evaluation may be easily implemented:

![Entity and validation](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/entity.puml)

The `NetService` retrieved data and packages it to [Entity](lib/src/cache/entity/entity.dart)
wrapper - effectively the data itself and some `EntityValidator` to provide information when data expires.
Validator is a simple interface with only three essential methods:
*   `bool isValid()` - being used by loading pipeline to determine if data is still valid
*   `string serialize()` - being called by `CacheService` to save data validation parameters along with data
*   `EntityValidator createSnapshot()` - creates a 'snapshot' of `isVAlid()` value at the moment of creation (more
    about it later).

The resulting `Entity` is then saved using `CacheService` preserving the data itself and the way to tell when data
expires.

To convert `Any` data to `Entity` within your services use the following function:
```dart
EntityValidator createValidator() {
    // Create a validator
}

val data = "Some data";
val entity = data.toEntity(createValidator());
``` 

## Choosing EntityValidator
There are some validators [available](lib/src/cache/entity) already:
*   `Simple` - just a data-class that is initialized with boolean validity status.
*   `Never` - never valid.
*   `Always` - always valid.
*   `Lifespan` - A validator that is initialized with Time-To-Live value and becomes invalid after it
    expires.

While the first three of above-listed validators are easy to use and intuitive the last one needs to be explained.
`Lifespan` when created gets a reference to a system clock and evaluates its validity against it every time it is being
asked of it. Thus `Lifespan` is not an immutable and is an object with a self-changing internal state. A valid `Entity`
with `Lifespan` validator that just seats in memory will expire eventually and become non-valid. That may be a desired
behavior however in most cases the most useful way to deal with validity is to take a snapshot of data state at the time
data is being emitted from the `CacheService`. To be able to do this both `EntityValidator` and `Entity` wrappers both
have `createSnapshot()` methods that fix the validation status at the time of function is called.

To create a `LifeSpan` validator, there is a helper-factory that takes a single parameter of TTL in a constructor:
```dart
// Creates validators that are valid for 5 seconds
final validatorFactory = EntityValidatorFactory.lifespan(5000);
``` 

The `LifespanValidatorFactory` is an implementation of [EntityValidatorFactory](lib/src/cache/entity/entityValidatorFactory.dart)
that you may implement in case you need your own custom validator.

## Displaying 'invalid' data and cache fall-back
Having a cache of required data, besides eliminating extra network calls, gives us the ability to fall back to cached data
in case network is not available and to keep working. This is an easy way to create an offline-capable mobile app when
complex state synchronization between the app and server is not required. With 'cache-then-net' model you get the cache
fall-back already implemented. Here is what you get when network connection is not available:

![Cache fallback](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/cache_fallback_on_error.puml)

When there is no cached data available you just get `null` for `data` property in emitted `LceState.Error`.

## Cache invalidation and data updates
A common task in complex applications may be the need to refresh some data in a part of application whenever something
happens in another part. Reloading a list of messages in a chat application when push arrives may be a simple example.
There are different ways of doing this - event-buses, Stream-subjects, you name it.
With reactive cache-service the library provides, such an invalidation is made in a simple and clean way:

![Cache invalidation](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/cache_invalidation.puml)

If the push-message brings a payload that is enough to display data change you could simply save the new data to cash
with `save` method or delete it with `delete` method of [CacheService](lib/src/model/service/cacheService.dart) interface:

The sample application demonstrates cache invalidation with a click or `Refresh` button. Here is how the invalidation is
implemented:
```dart
/// Globally available service-set
late ServiceSet<List<Repository>, String> serviceSet;

void main() {
  // Creates a set of services
  // - memory cache for data
  // - a service to get data from server. `isolated()` runs networking and parsing in [Isolate]
  serviceSet = ServiceSet(
      CacheService<List<Repository>, String>.withSyncDelegate(MemoryCacheDelegate.map()),
      RepositoryNetService().isolated()
  );

  runApp(const MyApp());
}

// Later in widget
final refresh = GestureDetector(
  onTap: () async {
    await serviceSet.cache.invalidateAll();
  },
  child: const Icon(
    Icons.refresh,
    size: 26.0,
  )
);
``` 
## On-demand cache refetch
Consider a cache service with complex internal structure that is updated by some internal logic.
For example a database that saves entities and something that updates records directly.
In case of Room you may observe a query and get updates if something changes underneath. But sometimes
you have a complex entity with relations that are not so easy to fetch as they need conditional processing
in synchronous way.
In this case you may write an SQL delegate for sync-delegate service (see below) to implement reactive cache.
When you get/put the whole entity the solution works. But as soon as you start to update entity parts
you need some way to notify subscribers of data change.

![Cache refetch](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/cache_refetch.puml)

[CacheService](lib/src/model/service/cacheService.dart)
has two methods that when called makes it to refetch data and update its active clients:
- `Future<void> refetch(P params): Completable` - makes cache service to refetch data for `params` and update corresponding clients
- `Future<void> refetchAll()` - makes cache service to refetch data for all subscribers

## Cache service implementation
While you can implement any cache-service you like the library comes with simple [AsyncDelegateCacheService](lib/src/cache/asyncCacheDelegate.dart)
and [SyncDelegateCacheService](lib/src/cache/syncCacheDelegate.dart) which use the following async/sync delegates for data IO:

![Cache delegate](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/motorro/DartLceModel/master/readme_files/cache_delegate.puml)

The interface is self-explanatory and does all the IO for `CacheService` in sync/async way. 

There is a simple in-memory cache service available so far. Disk cache port is a **work in progress**. 
To create an in-memory cache, use the following:
```dart
final cache = CacheService<SomeData, String>.withSyncDelegate(MemoryCacheDelegate.map());
```

## A complete example of model setup in a widget
Here is a complete setup of `LceModel` in a widget :
```dart
class LceWidget<D extends Object> extends StatefulWidget {
  final String params;

  const LceWidget({Key? key, required this.params}) : super(key: key);

  @override
  State<LceWidget<D>> createState() => _LceWidgetState();
}

class _LceWidgetState<D extends Object> extends State<LceWidget<D>> {
  LceUseCase<D>? _useCase;
  StreamSubscription<LceState<D>>? _subscription;
  late LceState<D> _lceState;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(LceWidget<D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if we need to load another data
    if (widget.params != oldWidget.params) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _unsubscribe();
  }

  _subscribe() {
    // Initial state to display
    _lceState = const LceState.loading(null, false);
    _useCase = LceModel.cacheThenNet(
        widget.params, // params that identify the data being loaded 
        serviceSet // A set of cache + net services - defined globally or provided with DI
    );
    _subscription = _useCase!.state.listen((newLceState) {
      setState(() { _lceState = newLceState; });
    });
  }

  _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _useCase = null;
  }

  Future<void> _refresh() async {
    return _useCase?.refresh() ?? Future.value();
  }

  @override
  Widget build(BuildContext context)  => lceState.when(
      loading: (_) => const LoadingState(), // Widget for loading
      content: (state) => ContentState(repositories: state.data), // Widget for content
      error: (state) => ErrorState(error: state.error, onRetry: () async { await _refresh(); }) // Error widget
  );
}
```

## Getting data-only stream and stream transformations
You may transform the `state` property `Stream` to strip state information and to get only the data. The library
ships with some functions already implemented like:
* `dataWithErrors` - emits data emitting stream error on any error
* `dataWithEmptyErrors` - emits data and emits an error only if there is no data in original emission
  (`LceError` with `null` for `data` property)
* `dataNoErrors` - emits data and ignores errors
* `validData` - emits data only if it is valid

More information and the complete list of extensions may be found in generated documentation or the [source code](lib/src/model/utils.dart) and tests.

## State transformations
Sometimes you need to mix several LCE streams from different sources or transform a data. For that there are several 
extensions [available](lib/src/lce/utils.dart) to map and combine them. For example:
* `map` - maps state data to another type with a mapper
* `mapEmptyDataItem` - replaces the empty data with the default item
* `combine` - combines one state with another and presenting the 'average' value of both