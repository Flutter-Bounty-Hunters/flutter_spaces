import 'dart:convert';
import 'dart:io';

import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:static_shock/static_shock.dart';

class FlutterSpacesCalendarLoader implements DataLoader {
  const FlutterSpacesCalendarLoader();

  @override
  Future<Map<String, Object>> loadData(StaticShockPipelineContext context) async {
    context.log.info("Loading Google Calendar data for next Flutter Space...");
    final nextEvent = await fetchNextEvent();
    if (nextEvent == null) {
      context.log.warn("Didn't find any future Flutter Spaces!");
      return {};
    }

    final dateTime = nextEvent.start?.dateTime;
    if (dateTime == null) {
      context.log.warn("Found the next Flutter Space calendar entry, but it doesn't have a date/time!");
      return {};
    }

    context.log.detail("Found the next Flutter Space calendar event: $dateTime");

    return {
      "calendar": {
        "next": {
          "title": nextEvent.summary,
          "description": nextEvent.description,
          "timestamp": dateTime.millisecondsSinceEpoch,
        },
      },
    };
  }
}

Future<calendar.Event?> fetchNextEvent() async {
  final credentials = ServiceAccountCredentials.fromJson(_loadGoogleApiKey());

  final scopes = [calendar.CalendarApi.calendarReadonlyScope];
  final client = await clientViaServiceAccount(credentials, scopes);
  final calendarApi = calendar.CalendarApi(client);

  final calendarId = 'e82a4193b085a9f0902259c2f620491b52a952e11d194f193834e31fdad157cb@group.calendar.google.com';
  final now = DateTime.now().toUtc();

  try {
    final events = await calendarApi.events.list(
      calendarId,
      maxResults: 1,
      timeMin: now,
      singleEvents: true,
      orderBy: 'startTime',
    );

    if (events.items == null || events.items!.isEmpty) {
      return null;
    }

    return events.items!.first;
  } catch (exception) {
    print("Failed to get next event: $exception");
    rethrow;
  } finally {
    client.close();
  }
}

Map<String, dynamic> _loadGoogleApiKey() {
  late final String? keyText;

  // Try loading key from local file first, then try loading from environment
  // variable if no local value is available.
  final calendarKeyFile = File("google-calendar/flutter-spaces-447701-fa2acfad3cbb.json");
  if (calendarKeyFile.existsSync()) {
    keyText = calendarKeyFile.readAsStringSync();
  } else {
    keyText = Platform.environment['GOOGLE_CALENDAR_API_KEY'];
    if (keyText == null || keyText.trim().isEmpty) {
      throw Exception("Missing Google Calendar API Key!");
    }
  }

  return jsonDecode(keyText);
}
