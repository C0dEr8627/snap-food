import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Path URL strategy is a web-only concern. Android/iOS use the same
  // Flutter app/router without depending on browser URL APIs.
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  runApp(const ProviderScope(child: SnapFoodApp()));
}
