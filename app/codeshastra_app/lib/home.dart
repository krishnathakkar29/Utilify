import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EFE1),
      // backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
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
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.question_mark, size: 20),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          size: 20,
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

              // Feature cards grid
              Expanded(
                child: Column(
                  children: [
                    // First row of feature cards
                    Row(
                      children: [
                        // Scan card
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.document_scanner_outlined,
                            title: 'Scan',
                            description:
                                'Documents, ID card,\nMeasure, Count, Passport...',
                            color: const Color(0xFFEFEACC),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Edit card
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.crop_outlined,
                            title: 'Edit',
                            description:
                                'Sign, Add text, Add images,\nMarkup, Hide, Recognize...',
                            color: const Color(0xFFFFE38E),
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
                            icon: Icons.file_copy_outlined,
                            title: 'Convert',
                            description: 'pdf, jpg, doc, txt,\nxls, ppt',
                            color: const Color(0xFFD0E8B5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Ask AI card
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.extension_outlined,
                            title: 'Ask AI',
                            description:
                                'Summarize, Finish writing,\nMake shorter, Simplify...',
                            color: const Color(0xFFFFD699),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFBF49),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.mic, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent documents
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DocumentThumbnail(
                          label: 'Strategy-Pitch-\nFinal.xls',
                          color: const Color(0xFFEFEACC),
                          icon: Icons.document_scanner_outlined,
                        ),
                        DocumentThumbnail(
                          label: 'user-\njourney-01.jpg',
                          color: const Color(0xFFEFEACC),
                          icon: Icons.image_outlined,
                        ),
                        DocumentThumbnail(
                          label: 'Invoice-\noct-2024.doc',
                          color: const Color(0xFFD0E8B5),
                          icon: Icons.file_copy_outlined,
                        ),
                        DocumentThumbnail(
                          label: '',
                          color: const Color(0xFFFFD699),
                          icon: Icons.crop_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 30), // Offset to center the FABs
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.black,
            child: const Icon(Icons.layers, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.black54,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {},
            heroTag: 'addButton',
            backgroundColor: const Color(0xFFE5E2F1),
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

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentThumbnail extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const DocumentThumbnail({
    Key? key,
    required this.label,
    required this.color,
    required this.icon,
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
          child: Center(child: Icon(icon, size: 30)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}
