import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/hive_boxes.dart';
import 'data/models/dtc_model.dart';
import 'data/models/trip_session_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Hive initialisation ──────────────────────────────────────────────────
  await Hive.initFlutter();

  // Register generated adapters (run: flutter pub run build_runner build)
  Hive.registerAdapter(TripSessionModelAdapter());
  Hive.registerAdapter(DtcModelAdapter());

  // Open boxes before app starts
  await Hive.openBox<TripSessionModel>(HiveBoxes.tripSession);
  await Hive.openBox<DtcModel>(HiveBoxes.dtcHistory);
  await Hive.openBox(HiveBoxes.appSettings);

  runApp(
    // ProviderScope is the root of the Riverpod DI tree
    const ProviderScope(
      child: ReadCarApp(),
    ),
  );
}
