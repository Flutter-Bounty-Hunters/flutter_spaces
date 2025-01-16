import 'dart:io';

import 'package:flutter_spaces/flutter_spaces.dart';
import 'package:static_shock/static_shock.dart';

Future<void> main(List<String> arguments) async {
  // Load Captivate credentials.
  final podcastShowId = "3743ba71-859c-4164-99ff-999b525ccf48";
  final (captivateUsername, captivateApiKey) = _loadCaptivateCredentials();

  // Configure the static website generator.
  final staticShock = StaticShock()
    ..pick(DirectoryPicker.parse("images"))
    ..plugin(const MarkdownPlugin())
    ..plugin(const JinjaPlugin())
    ..plugin(const PrettyUrlsPlugin())
    ..plugin(const SassPlugin())
    // Load data for the next scheduled Flutter space.
    ..loadData(const FlutterSpacesCalendarLoader())
    // Load all episodes.
    ..loadData(EpisodeLoader(
      captivateUsername: captivateUsername,
      captivateApiToken: captivateApiKey,
      showId: podcastShowId,
    ));

  // Generate the static website.
  await staticShock.generateSite();
}

(String username, String apiToken) _loadCaptivateCredentials() {
  // REQUIRED: Environment variable called "captivate_username"
  final captivateUsername = Platform.environment["captivate_username"];

  // REQUIRED: Environment variable called "captivate_token"
  final captivateApiToken = Platform.environment["captivate_token"];

  if (captivateUsername == null) {
    print("Missing environment variable for Captivate username.");
    exit(-1);
  }

  if (captivateApiToken == null) {
    print("Missing environment variable for Captivate API token.");
    exit(-1);
  }

  return (captivateUsername, captivateApiToken);
}
