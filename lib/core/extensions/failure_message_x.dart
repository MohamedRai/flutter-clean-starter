import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/l10n/gen/app_localizations.dart';

/// Maps a [Failure] to a localized, user-facing message.
///
/// This is the only place where failures become text. Usage:
/// `failure.localizedMessage(context.l10n)`.
extension FailureMessageX on Failure {
  /// A user-facing message for this failure in the language of [l10n].
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    ServerFailure() => l10n.failureServer,
    NetworkFailure() => l10n.failureNetwork,
    CacheFailure() => l10n.failureCache,
    UnauthorizedFailure() => l10n.failureUnauthorized,
    ForbiddenFailure() => l10n.failureForbidden,
    NotFoundFailure() => l10n.failureNotFound,
    BadRequestFailure() => l10n.failureBadRequest,
    RateLimitFailure() => l10n.failureRateLimit,
    // Validation messages come from the validator / server and are already
    // meant for the user.
    ValidationFailure(:final message)
        when message != null && message.isNotEmpty =>
      message,
    ValidationFailure() || ValidationFailures() => l10n.failureValidation,
    UnknownFailure() => l10n.failureUnknown,
  };
}
