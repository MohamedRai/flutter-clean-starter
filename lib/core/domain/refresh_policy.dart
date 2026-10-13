/// Controls how a refresh treats data that is already cached.
///
/// | Policy            | UI during refresh   | Cache during refresh   |
/// |-------------------|---------------------|------------------------|
/// | [silentOverwrite] | Shows stale data    | Overwritten atomically |
/// | [full]            | Shows loading state | Cleared before fetch   |
enum RefreshPolicy {
  /// Fetch fresh data and overwrite the cache in one pass.
  ///
  /// The UI keeps showing stale data while the request is in flight.
  /// **Prefer this for pull-to-refresh** — it never leaves the cache empty.
  silentOverwrite,

  /// Clear the cache first, then fetch.
  ///
  /// Use only when stale data must not be shown at all (e.g. after a
  /// destructive bulk mutation). If the fetch fails the cache stays empty.
  full,
}
