import 'package:flutter_spaces/flutter_spaces.dart';
import 'package:static_shock/static_shock.dart';

Future<void> main(List<String> arguments) async {
  // Configure the static website generator.
  final staticShock = StaticShock()
    ..pick(DirectoryPicker.parse("images"))
    ..plugin(const MarkdownPlugin())
    ..plugin(const JinjaPlugin())
    ..plugin(const PrettyUrlsPlugin())
    ..plugin(const SassPlugin())
    // Load data for the next scheduled Flutter space.
    ..loadData(const FlutterSpacesCalendarLoader());

  // Generate the static website.
  await staticShock.generateSite();
}
