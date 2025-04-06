import 'package:codeshastra_app/audio_converter/audio_converter.dart';
import 'package:codeshastra_app/barcode_generator.dart';
import 'package:codeshastra_app/coding_assistant.dart';
import 'package:codeshastra_app/color_palette.dart';
import 'package:codeshastra_app/community_page.dart';
import 'package:codeshastra_app/excel_to_csv/screens.dart/excet_to_csv.dart';
import 'package:codeshastra_app/home.dart';
import 'package:codeshastra_app/image_converter/screens/image_converter_screen.dart';
import 'package:codeshastra_app/image_to_pdf.dart';
import 'package:codeshastra_app/notes_taking/notes_module.dart';
import 'package:codeshastra_app/notes_taking/providers/notes_provider.dart';
import 'package:codeshastra_app/password_screen.dart';
import 'package:codeshastra_app/pdf_maker/main_page.dart';
import 'package:codeshastra_app/pdf_makerr/main_page.dart';
import 'package:codeshastra_app/pdf_qna.dart';
import 'package:codeshastra_app/pdf_tools/screens/pdf_tools_screen.dart';
import 'package:codeshastra_app/productivity_tools/countdown_screen.dart';
import 'package:codeshastra_app/productivity_tools/currency_converter_screen.dart';
import 'package:codeshastra_app/productivity_tools/pomodoro_timer_sheet.dart';
import 'package:codeshastra_app/productivity_tools/stopwatch_screen.dart';
import 'package:codeshastra_app/productivity_tools/timer_screen.dart';
import 'package:codeshastra_app/productivity_tools/timesheet_screen.dart';
import 'package:codeshastra_app/productivity_tools/unit_converter_screen.dart';
import 'package:codeshastra_app/productivity_tools/world_clock.dart';
import 'package:codeshastra_app/profile/profile_screen.dart';
import 'package:codeshastra_app/qr_code.dart';
import 'package:codeshastra_app/random_number_screen.dart';
import 'package:codeshastra_app/razorpay.dart';
import 'package:codeshastra_app/text_summarization.dart';
import 'package:codeshastra_app/tts.dart';
import 'package:codeshastra_app/uiud_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:codeshastra_app/notes_taking/services/shared_preferences_helper.dart';
import 'package:codeshastra_app/notes_taking/services/notes_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // Replace with direct SharedPreferences initialization
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  runApp(
    // Wrap the entire app with the provider
    ChangeNotifierProvider(
      create:
          (context) => NotesProvider(), // Create an instance of your provider
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
}
// void main() {
//   runApp(
//     // Use Provider for state management
//     ChangeNotifierProvider(
//       create: (context) => PasswordProvider(ApiService()),
//       child: const MyApp(),
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFF2EFE1),
        primaryColorDark: Color.fromARGB(255, 48, 47, 47),
        fontFamily: 'SF Pro Display',
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(), // MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
