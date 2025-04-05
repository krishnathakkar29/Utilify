import 'dart:ffi';

import 'package:codeshastra_app/color_palette.dart';
import 'package:codeshastra_app/models/block_data.dart';
import 'package:codeshastra_app/utility/sizedbox_util.dart';
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
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ScanOptionsBottomSheet(data: data, maincolor: maincolor),
    );
  }

  // final List<BlockData> convert = [
  final convert = [
    {
      'title': 'Documents',
      'subtitle': 'Scan multiple documents',
      'icon': Icons.copy_outlined,
      'color': 0xFFEFEACC,
    },
    {
      'title': 'ID card',
      'subtitle': 'Scan ID cards',
      'icon': Icons.credit_card_outlined,
      'color': 0xFFEFEACC,
    },
  ];

  final scan = [
    {
      'title': 'Documents',
      'subtitle': 'Scan multiple documents',
      'icon': Icons.copy_outlined,
      'color': 0xFFFFF3C2,
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
      'title': 'Documents',
      'subtitle': 'Scan multiple documents',
      'icon': Icons.copy_outlined,
      'color': 0xFFE6F4D8,
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
      'title': 'Documents',
      'subtitle': 'Scan multiple documents',
      'icon': Icons.copy_outlined,
      'color': 0xFFFFF0D1,
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
                    Container(
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
                    Stack(
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
                                '5',
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
                  ],
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
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
                        description: 'pdf, jpg, doc, txt,\nxls, ppt',
                        // title: 'Scan',
                        // description:
                        //     'Documents, ID card,\nMeasure, Count, Passport...',
                        color: HomeScreen.cardPurple,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(context, convert, 1);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Edit card
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.document_scanner_outlined,
                        // icon: Icons.crop_outlined,
                        title: 'Scan',
                        description: 'Qr code/ barcode generator',
                        color: HomeScreen.cardTeal,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(context, scan, 2);
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
                        description: 'notes taking,timer,world clock...',
                        color: HomeScreen.cardPink,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(context, pt, 3);
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
                            'Summarize, Finish writing,\nMake shorter, Simplify...',
                        color: HomeScreen.cardBlue,
                        iconBackgroundColor: Colors.white,
                        onTap: () {
                          showScanOptionsBottomSheet(context, ai_tools, 4);
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
                    DocumentThumbnail(
                      label: 'user-\njourney-01.jpg',
                      color: HomeScreen.cardTeal,
                      icon: Icons.image_outlined,
                      textColor: Colors.white,
                    ),
                    DocumentThumbnail(
                      label: 'Invoice-\noct-2024.doc',
                      color: HomeScreen.cardPink,
                      icon: Icons.file_copy_outlined,
                      textColor: Colors.white,
                    ),
                    DocumentThumbnail(
                      label: 'Invoice-\noct-2024.doc',
                      color: HomeScreen.cardBlue,
                      icon: Icons.crop_outlined,
                      textColor: Colors.white,
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
          const SizedBox(width: 30), // Offset to center the FABs
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: HomeScreen.accentYellow,
            heroTag: 'layers',
            child: const Icon(Icons.layers, color: Colors.black),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.white60,
            heroTag: 'profile',
            child: const Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {},
            heroTag: 'addButton',
            backgroundColor: HomeScreen.accentYellow,
            child: const Icon(Icons.add, color: Colors.black),
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

  const ScanOptionsBottomSheet({
    required this.data,
    required this.maincolor,
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
                const Text(
                  'Scan',
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
                return ScanOption(
                  title: item['title'],
                  subtitle: item['subtitle'],
                  icon: item['icon'],
                  color: item['color'],
                  // maincolor:item['maincolor']
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
