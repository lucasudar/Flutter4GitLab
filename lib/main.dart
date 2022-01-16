import 'package:F4Lab/providers/package_info.dart';
import 'package:F4Lab/providers/theme.dart';
import 'package:F4Lab/providers/user.dart';
import 'package:F4Lab/ui/config/config_page.dart';
import 'package:F4Lab/ui/home_page.dart';
import 'package:F4Lab/util/exception_capture.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    FlutterError.onError = MyApp.errorHandler;
  }

  static void errorHandler(FlutterErrorDetails details,
      {bool forceReport = false}) {
    sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );
  }

  List<SingleChildWidget> _buildProviders(BuildContext context) {
    return [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => PackageInfoProvider()),
    ];
  }

  Map<String, WidgetBuilder> _buildRoutes() => {
        '/': (_) => HomePage(),
        '/config': (_) => ConfigPage(),
      };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: _buildProviders(context),
        child: Consumer<ThemeProvider>(builder: (context, theme, _) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'GitLab',
              initialRoute: '/',
              theme: theme.currentTheme,
              routes: _buildRoutes());
        }));
  }
}
