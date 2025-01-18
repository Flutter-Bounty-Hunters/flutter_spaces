import 'package:captivate/captivate.dart';
import 'package:intl/intl.dart';
import 'package:static_shock/static_shock.dart';

class EpisodeLoader implements DataLoader {
  EpisodeLoader({
    required this.captivateUsername,
    required this.captivateApiToken,
    required this.showId,
  });

  final _client = CaptivateClient();
  final String captivateUsername;
  final String captivateApiToken;
  final String showId;

  @override
  Future<Map<String, Object>> loadData(StaticShockPipelineContext context) async {
    context.log.info("Loading podcast episodes...");

    context.log.detail("Authenticating with Captivate...");
    final userPayload = await _client.authenticate(
      username: captivateUsername,
      apiToken: captivateApiToken,
    );
    final authToken = userPayload!.user.token;
    context.log.detail("Done authenticating with Captivate");

    context.log.detail("Requesting all episodes from Captivate...");
    final response = await _client.getEpisodes(authToken, showId);
    if (response == null) {
      context.log.warn("Failed to load episodes for show: $showId");
      return {
        "episodes": [],
      };
    }
    context.log.detail("Loaded ${response.episodes.length} episodes.");

    context.log.info("Done loading episodes from Captivate.");

    return {
      // Ordered from most recent to least recent.
      "loadedEpisodes": [
        for (final episode in response.episodes) //
          {
            "id": episode.id,
            "title": episode.title,
            "date": episode.formattedPublishedDate,
          }
      ],
    };
  }
}

extension on Episode {
  static final captivateDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  static final presentationDateFormat = DateFormat("MMMM dd, yyyy");

  String get formattedPublishedDate {
    if (publishedDate == null) {
      return "Now Available";
    }

    final dateTime = captivateDateFormat.parse(publishedDate!);
    return presentationDateFormat.format(dateTime);
  }
}
