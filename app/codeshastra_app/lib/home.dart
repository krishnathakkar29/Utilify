// import 'dart:ffi';

// import 'dart:nativewrappers/_internal/vm/lib/async_patch.dart';

import 'package:codeshastra_app/audio_converter/audio_converter.dart';
import 'package:codeshastra_app/barcode_generator.dart';
import 'package:codeshastra_app/coding_assistant.dart';
import 'package:codeshastra_app/color_palette.dart';
import 'package:codeshastra_app/community_page.dart';
import 'package:codeshastra_app/excel_to_csv/screens.dart/excet_to_csv.dart';
import 'package:codeshastra_app/image_converter/screens/image_converter_screen.dart';
import 'package:codeshastra_app/image_to_pdf.dart';
import 'package:codeshastra_app/models/block_data.dart';
import 'package:codeshastra_app/notes_taking/notes_module.dart';
import 'package:codeshastra_app/notification.dart';
import 'package:codeshastra_app/password_screen.dart';
import 'package:codeshastra_app/pdf_qna.dart';
import 'package:codeshastra_app/pdf_tools/screens/pdf_tools_screen.dart';
import 'package:codeshastra_app/productivity_tools/currency_converter_screen.dart';
import 'package:codeshastra_app/productivity_tools/pomodoro_timer_sheet.dart';
import 'package:codeshastra_app/productivity_tools/stopwatch_screen.dart';
import 'package:codeshastra_app/productivity_tools/timer_screen.dart';
import 'package:codeshastra_app/productivity_tools/timesheet_screen.dart';
import 'package:codeshastra_app/productivity_tools/unit_converter_screen.dart';
import 'package:codeshastra_app/productivity_tools/world_clock.dart';
import 'package:codeshastra_app/profile/help_center.dart';
import 'package:codeshastra_app/profile/profile_screen.dart';
import 'package:codeshastra_app/qr_code.dart';
import 'package:codeshastra_app/random_number_screen.dart';
import 'package:codeshastra_app/text_summarization.dart';
import 'package:codeshastra_app/tts.dart';
import 'package:codeshastra_app/uiud_screen.dart';
import 'package:codeshastra_app/utility/sizedbox_util.dart';
import 'package:codeshastra_app/video_converter/video_converter.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Colors for the dark purple theme
  static const Color primaryPurple = Color(0xFF56288a); // Your requested purple
  static const Color darkBackground = Color.fromARGB(
    255,
    48,
    47,
    47,
  ); // Dark background
  static const Color cardPurple = Color(0xFFEFEACC); // Lighter purple
  static const Color cardTeal = Color(0xFFFFE38E); // Teal accent
  static const Color cardPink = Color(0xFFD0E8B5); // Pink accent
  static const Color cardBlue = Color(0xFFFFD699); // Blue accent
  static const Color accentYellow = Color(0xFFF2EFE1);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void showScanOptionsBottomSheet(
    BuildContext context,
    List data,
    int maincolor,
    String name,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ScanOptionsBottomSheet(
            data: data,
            maincolor: maincolor,
            name: name,
          ),
    );
  }

  // final List<BlockData> convert = [
  final convert = [
    {
      'title': 'Make Pdf',
      'subtitle': 'Make pdf from uploading images',
      'icon': Icons.picture_as_pdf,
      'color': 0xFFEFEACC,
      'keyword': 'pdf',
    },
    {
      'title': 'Image Conversions',
      'subtitle': 'Convert images',
      'icon': Icons.image,
      'color': 0xFFEFEACC,
      'keyword': 'image',
    },
    {
      'title': 'Merge Pdf',
      'subtitle': 'Scan multiple documents',
      'icon': Icons.merge,
      'color': 0xFFEFEACC,
      'keyword': 'convert',
    },
    {
      'title': 'Split Pdf',
      'subtitle': 'Scan ID cards',
      'icon': Icons.splitscreen,
      'color': 0xFFEFEACC,
      'keyword': 'convert',
    },
    {
      'title': 'Rotate Pdf',
      'subtitle': 'Scan ID cards',
      'icon': Icons.rotate_90_degrees_ccw_rounded,
      'color': 0xFFEFEACC,
      'keyword': 'convert',
    },
    {
      'title': 'Excel to Csv',
      'subtitle': 'Convert excel into csv',
      'icon': Icons.swap_horiz_outlined,
      'color': 0xFFEFEACC,
      'keyword': 'excel',
    },
    {
      'title': 'Csv to Excel',
      'subtitle': 'Convert csv into excel',
      'icon': Icons.swap_horiz_outlined,
      'color': 0xFFEFEACC,
      'keyword': 'excel',
    },
  ];

  final scan = [
    {
      'title': 'QrCode Generator',
      'subtitle': 'Create and Scan qrcode',
      'icon': Icons.qr_code,
      'color': 0xFFFFF3C2,
      'keyword': 'qr',
    },
    {
      'title': 'Barcode Generator',
      'subtitle': 'Create and Scan barcode',
      'icon': Icons.qr_code,
      'color': 0xFFFFF3C2,
      'keyword': 'bar',
    },
    {
      'title': 'Password Generator',
      'subtitle': 'Create strong passwords',
      'icon': Icons.password,
      'color': 0xFFFFF3C2,
      'keyword': 'password',
    },
    {
      'title': 'Random Number Generator',
      'subtitle': 'Generate random numbers',
      'icon': Icons.numbers,
      'color': 0xFFFFF3C2,
      'keyword': 'number',
    },
    {
      'title': 'UUID Generator',
      'subtitle': 'Generate UUID',
      'icon': Icons.numbers_rounded,
      'color': 0xFFFFF3C2,
      'keyword': 'uuid',
    },
    // {
    //   'title': 'ID card',
    //   'subtitle': 'Scan ID cards',
    //   'icon': Icons.credit_card_outlined,
    //   'color': 0xFFFFECB3,
    // },
    // {
    //   'title': 'ID card',
    //   'subtitle': 'Scan ID cards',
    //   'icon': Icons.credit_card_outlined,
    //   'color': 0xFFFFE082,
    // },
  ];

  final pt = [
    {
      'title': 'Timer',
      'subtitle': 'Keep a Timer',
      'icon': Icons.timer,
      'color': 0xFFE6F4D8,
      'keyword': 'timer',
    },
    {
      'title': 'Pomodoro',
      'subtitle': 'Keep a focus timer',
      'icon': Icons.timelapse_rounded,
      'color': 0xFFE6F4D8,
      'keyword': 'pomo',
    },
    {
      'title': 'Stopwatch',
      'subtitle': 'Start a stop watch',
      'icon': Icons.pause_circle_outline,
      'color': 0xFFE6F4D8,
      'keyword': 'stopwatch',
    },
    {
      'title': 'TimeSheet',
      'subtitle': 'Keep track of your timesheet',
      'icon': Icons.format_align_center_sharp,
      'color': 0xFFE6F4D8,
      'keyword': 'timesheet',
    },
    {
      'title': 'Unit Converter',
      'subtitle': 'Be accurate with measurements',
      'icon': Icons.square_foot,
      'color': 0xFFE6F4D8,
      'keyword': 'unit',
    },
    {
      'title': 'Notes Taking',
      'subtitle': 'Take notes',
      'icon': Icons.note_add,
      'color': 0xFFE6F4D8,
      'keyword': 'note',
    },
    {
      'title': 'World Clock',
      'subtitle': 'Keep track of timezones',
      'icon': Icons.access_time_filled_rounded,
      'color': 0xFFE6F4D8,
      'keyword': 'wclock',
    },
    // {
    //   'title': 'ID card',
    //   'subtitle': 'Scan ID cards',
    //   'icon': Icons.credit_card_outlined,
    //   'color': 0xFFC8E6C9,
    // },
    // {
    //   'title': 'ID card',
    //   'subtitle': 'Scan ID cards',
    //   'icon': Icons.credit_card_outlined,
    //   'color': 0xFFB2D8A4,
    // },
  ];

  final ai_tools = [
    {
      'title': 'PDF QnA',
      'subtitle': 'Process your pdf and ask questions',
      'icon': Icons.picture_as_pdf,
      'color': 0xFFFFF0D1,
      'keyword': 'pdfqna',
    },
    {
      'title': 'Text to Speech',
      'subtitle': 'Generate speech from input text',
      'icon': Icons.speaker_notes,
      'color': 0xFFFFF0D1,
      'keyword': 'tts',
    },
    {
      'title': 'Text Summarization',
      'subtitle': 'Give summary for big texts',
      'icon': Icons.summarize,
      'color': 0xFFFFF0D1,
      'keyword': 'summarize',
    },
    // {
    //   'title': 'ID card',
    //   'subtitle': 'Scan ID cards',
    //   'icon': Icons.credit_card_outlined,
    //   'color': 0xFFFFE0B2,
    // },
    // {
    //   'title': 'ID card',
    //   'subtitle': 'Scan ID cards',
    //   'icon': Icons.credit_card_outlined,
    //   'color': 0xFFFFCBA4,
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top bar with question mark and notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text('Help'),
                                content: const Text(
                                  'This is the help dialog.',
                                  style: TextStyle(color: Colors.black),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpCenterScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.question_mark,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationPage(),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '4',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: HomeScreen.accentYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: HomeScreen.darkBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                vSize(24),

                // Feature cards grid
                Row(
                  children: [
                    // Scan card
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.file_copy_outlined,
                        // icon: Icons.document_scanner_outlined,
                        title: 'Convert',
                        description:
                            'Transform files and images effortlessly. ',
                        // title: 'Scan',
                        // description:
                        //     'Documents, ID card,\nMeasure, Count, Passport...',
                        color: HomeScreen.cardPurple,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(
                            context,
                            convert,
                            1,
                            'Convert',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Edit card
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.document_scanner_outlined,
                        // icon: Icons.crop_outlined,
                        title: 'Scan and Check',
                        description:
                            'Generate and verify QR codes/barcodes & passwords.',
                        color: HomeScreen.cardTeal,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(context, scan, 2, 'Scan');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Second row of feature cards
                Row(
                  children: [
                    // Convert card
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.task_alt,
                        title: 'Productivity Tools',
                        description:
                            'Stay organized with notes, timers, and more.',
                        color: HomeScreen.cardPink,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(
                            context,
                            pt,
                            3,
                            'Productivity Tools',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Ask AI card
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.extension_outlined,
                        title: 'AI Tools',
                        description:
                            'Smart assistance for summarizing and editing text.',
                        color: HomeScreen.cardBlue,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(
                            context,
                            ai_tools,
                            4,
                            'AI Tools',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search bar
                const SizedBox(height: 24),

                // Recent documents
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ColorPalette(),
                          ),
                        );
                      },
                      child: DocumentThumbnail(
                        label: 'Colour\nPalette',
                        color: HomeScreen.cardPurple,
                        icon: Icons.palette,
                        textColor: Colors.white,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoConverterScreen(),
                          ),
                        );
                      },
                      child: DocumentThumbnail(
                        label: 'Video\nConverter',
                        color: HomeScreen.cardPink,
                        icon: Icons.video_collection,
                        textColor: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioConverterScreen(),
                          ),
                        );
                      },
                      child: DocumentThumbnail(
                        label: 'Audio\nConverter',
                        color: HomeScreen.cardBlue,
                        icon: Icons.library_music,
                        textColor: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CurrencyConverterScreen(),
                          ),
                        );
                      },
                      child: DocumentThumbnail(
                        label: 'Currency\nConverter',
                        color: HomeScreen.cardTeal,
                        icon: Icons.monetization_on_outlined,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                vSize(110),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const SizedBox(width: 30), // Offset to center the FABs
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            backgroundColor: Colors.white60,
            heroTag: 'profile',
            child: const Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommunityPage()),
              );
            },
            heroTag: 'addButton',
            backgroundColor: HomeScreen.accentYellow,
            child: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(width: 160),

          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
            backgroundColor: HomeScreen.accentYellow,
            heroTag: 'layers',
            child: const Icon(Icons.forum, color: Colors.black),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.iconBackgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 175,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: HomeScreen.darkBackground),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentThumbnail extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final Color textColor;

  const DocumentThumbnail({
    Key? key,
    required this.label,
    required this.color,
    required this.icon,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(icon, size: 30, color: HomeScreen.darkBackground),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: textColor),
        ),
      ],
    );
  }
}

class ScanOptionsBottomSheet extends StatelessWidget {
  final List data;
  final int maincolor;
  final String name;

  const ScanOptionsBottomSheet({
    required this.data,
    required this.maincolor,
    required this.name,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color:
            maincolor == 1
                ? const Color(0xFFF2EFE1)
                : maincolor == 2
                ? const Color(0xFFFFE38E)
                : maincolor == 3
                ? const Color(0xFFD0E8B5)
                : maincolor == 4
                ? const Color(0xFFFFD699)
                : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Sheet header with title and close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                // Scan icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        maincolor == 1
                            ? const Color(0xFFEFEACC)
                            : maincolor == 2
                            ? const Color(0xFFFFE38E)
                            : maincolor == 3
                            ? const Color(0xFFD0E8B5)
                            : maincolor == 4
                            ? const Color(0xFFFFD699)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.document_scanner_outlined, size: 20),
                ),
                const SizedBox(width: 12),
                // Title
                Text(
                  name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid of options
          Expanded(
            child: GridView.builder(
              itemCount: data.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = data[index];
                // Inside ScanOptionsBottomSheet class, replace the GestureDetector's onTap:
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet first
                    Future.delayed(Duration(milliseconds: 100), () {
                      // Add a small delay before navigation
                      if (item['keyword'] == 'convert') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfToolsScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'qr') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeGenerator(),
                          ),
                        );
                      } else if (item['keyword'] == 'bar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarcodeGenerator(),
                          ),
                        );
                      } else if (item['keyword'] == 'pdf') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageToPdfScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'excel') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExceltoCsv()),
                        );
                      } else if (item['keyword'] == 'number') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RandomNumberScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'uuid') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UuidGeneratorScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'password') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'timer') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimerScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'pomo') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PomodoroTimerScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'curr') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CurrencyConverterScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'unit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnitConverterScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'stopwatch') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StopwatchScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'timesheet') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimesheetScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'wclock') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorldClockScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'iamge') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageConverterScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'pdfqna') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfChatScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'tts') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TextToSpeechScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'summarize') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TextSummarizationScreen(),
                          ),
                        );
                      } else if (item['keyword'] == 'note') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesModule(),
                          ),
                        );
                      }
                    });
                  },
                  child: ScanOption(
                    title: item['title'],
                    subtitle: item['subtitle'],
                    icon: item['icon'],
                    color: item['color'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ScanOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int color;

  const ScanOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// class FeatureCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final String description;
//   final Color color;
//   final VoidCallback onTap;

//   const FeatureCard({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.description,
//     required this.color,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 24),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               description,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.black.withOpacity(0.7),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
