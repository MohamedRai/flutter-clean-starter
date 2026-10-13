// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Clean Starter';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement…';

  @override
  String get emptyGeneric => 'Rien à afficher pour le moment.';

  @override
  String get failureServer =>
      'Un problème est survenu de notre côté. Veuillez réessayer plus tard.';

  @override
  String get failureNetwork =>
      'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';

  @override
  String get failureCache => 'Aucune donnée enregistrée n\'est disponible.';

  @override
  String get failureUnauthorized =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get failureForbidden =>
      'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get failureNotFound =>
      'Nous n\'avons pas trouvé ce que vous cherchiez.';

  @override
  String get failureBadRequest =>
      'La requête n\'a pas pu être traitée. Vérifiez votre saisie.';

  @override
  String get failureRateLimit =>
      'Trop de requêtes. Patientez un instant puis réessayez.';

  @override
  String get failureValidation => 'Veuillez vérifier les champs signalés.';

  @override
  String get failureUnknown =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get navPosts => 'Articles';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue de l\'appareil';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountSignedIn =>
      'Vous êtes connecté (session de démonstration).';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signInTitle => 'Connexion';

  @override
  String get signInMessage =>
      'Cette page illustre la garde d\'authentification du routeur. Connectez-vous pour ouvrir la page Compte.';

  @override
  String get signInButton => 'Se connecter (démo)';

  @override
  String get notFoundTitle => 'Page introuvable';

  @override
  String get notFoundMessage => 'La page demandée n\'existe pas.';

  @override
  String get goHome => 'Accueil';

  @override
  String get postsTitle => 'Articles';

  @override
  String get postsEmpty => 'Aucun article pour le moment.';

  @override
  String get postDetailTitle => 'Article';

  @override
  String postAuthor(int userId) {
    return 'Par l\'utilisateur n° $userId';
  }
}
