# RxLceModel

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
