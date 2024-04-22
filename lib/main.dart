import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:blissful_backdrop/about.dart';
import 'package:blissful_backdrop/check_update.dart';
import 'package:blissful_backdrop/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart' as window_manager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initilize the analytics
  await Aptabase.init(
      "A-SH-9850745473", const InitOptions(host: "http://13.201.134.252:8000"));

  runApp(const MyApp());

  doWhenWindowReady(() {
    window_manager.appWindow.alignment = Alignment.center;
    window_manager.appWindow.maximize();
    window_manager.appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const fluent_ui.FluentApp(
      themeMode: ThemeMode.dark,
      title: 'Blissful Backdrop',
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedPanelIndex = 0;
  PackageInfo? packageInfo;

  List<fluent_ui.NavigationPaneItem> items = [
    fluent_ui.PaneItem(
      icon: const Icon(fluent_ui.FluentIcons.home),
      title: const Text('Home'),
      body: const Home(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    checkForAppUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    return fluent_ui.NavigationView(
      appBar: fluent_ui.NavigationAppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CachedNetworkImage(
                imageUrl:
                    "https://github.com/hvg2416/blissful_backdrop/raw/master/windows/runner/resources/app_icon.ico",
                height: 24,
                width: 24,
              ),
            ),
            const Text(
              'Blissful Backdrop',
              style: TextStyle(fontSize: 16),
            ),
            Expanded(child: window_manager.MoveWindow()),
            window_manager.MinimizeWindowButton(animate: true),
            window_manager.RestoreWindowButton(animate: true),
            window_manager.CloseWindowButton(
              animate: true,
              onPressed: () {
                Aptabase.instance.trackEvent('app_closed');
                window_manager.appWindow.close();
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      pane: fluent_ui.NavigationPane(
        selected: selectedPanelIndex,
        onChanged: (index) {
          setState(() {
            selectedPanelIndex = index;
          });
        },
        displayMode: fluent_ui.PaneDisplayMode.compact,
        items: items,
        footerItems: [
          fluent_ui.PaneItemAction(
              icon: const Icon(fluent_ui.FluentIcons.info),
              title: const Text('About'),
              onTap: () async {
                if (packageInfo == null) {
                  PackageInfo pckgInfo = await PackageInfo.fromPlatform();
                  setState(() {
                    packageInfo = pckgInfo;
                  });
                }
                showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => AboutApp(
                          appVersion: packageInfo!.version,
                        ),
                    barrierDismissible: true);
              }),
          // fluent_ui.PaneItem(
          //   icon: const Icon(fluent_ui.FluentIcons.settings),
          //   title: const Text('Settings'),
          //   body: Center(
          //     child: fluent_ui.ToggleSwitch(
          //       checked: false,
          //       onChanged: (value) {
          //         log(value.toString());
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
