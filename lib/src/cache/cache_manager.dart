/// Closes and deletes cache
/// May be used to close or delete all scoped cache at once e.g. for current user
abstract class CacheManager {
  /// Closes cache
  void close();

  /// Closes cache and deletes data
  void delete();
}