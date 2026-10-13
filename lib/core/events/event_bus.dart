import 'dart:async';

import 'package:flutter_clean_starter/core/utils/app_logger.dart';

/// Base class for events sent through the [EventBus].
abstract class BusEvent {
  /// Creates an event.
  const BusEvent();
}

/// A synchronous, typed, app-wide broadcast channel.
///
/// Lets features react to each other **without importing each other** —
/// e.g. a `SignedOut` event that every feature listens to. Define events in
/// `core/` (or in a shared domain contract) so both sides depend on core
/// only.
///
/// ```dart
/// bus.on<SignedOut>().listen((_) => cubit.reset());
/// bus.emit(const SignedOut());
/// ```
class EventBus {
  /// Creates the bus. With [debug] every emitted event is logged.
  EventBus({this.debug = false});

  /// Whether to log emitted events.
  final bool debug;

  final _controller = StreamController<BusEvent>.broadcast(sync: true);

  /// Whether [dispose] has been called.
  bool get isDisposed => _controller.isClosed;

  /// Sends [event] to every listener. Ignored after [dispose].
  void emit(BusEvent event) {
    if (isDisposed) return;
    if (debug) AppLogger.debug('EventBus: ${event.runtimeType}');
    _controller.add(event);
  }

  /// All events.
  Stream<BusEvent> get stream => _controller.stream;

  /// Only events of type [T].
  Stream<T> on<T extends BusEvent>() => _controller.stream.whereType<T>();

  /// Closes the bus.
  Future<void> dispose() => _controller.close();
}

extension on Stream<BusEvent> {
  Stream<T> whereType<T>() => where((e) => e is T).cast<T>();
}
