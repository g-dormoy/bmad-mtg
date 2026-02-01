import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mtg/gen/assets.gen.dart';
import 'package:mtg/start.dart';

Future<void> main() async {
  await dotenv.load(fileName: Assets.env.envStaging);

  await start();
}
