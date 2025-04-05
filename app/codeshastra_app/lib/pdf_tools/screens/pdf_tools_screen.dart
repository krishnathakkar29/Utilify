import 'package:codeshastra_app/pdf_tools/widgets/merge_section.dart';
import 'package:codeshastra_app/pdf_tools/widgets/rotate_section.dart';
import 'package:codeshastra_app/pdf_tools/widgets/split_section.dart';
import 'package:flutter/material.dart';
// import 'package:pdf_tools_app/widgets/merge_section.dart';
// import 'package:pdf_tools_app/widgets/split_section.dart';
// import 'package:pdf_tools_app/widgets/rotate_section.dart';

class PdfToolsScreen extends StatefulWidget {
  const PdfToolsScreen({super.key});

  @override
  State<PdfToolsScreen> createState() => _PdfToolsScreenState();
}

class _PdfToolsScreenState extends State<PdfToolsScreen> {
  @override
  Widget build(BuildContext context) {
    // backgroundColor:
    // Theme.of(context).primaryColorDark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: const Text('PDF Power Tools'),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(icon: Icon(Icons.merge_type), text: 'Merge'),
              Tab(icon: Icon(Icons.splitscreen), text: 'Split'),
              Tab(icon: Icon(Icons.rotate_90_degrees_ccw), text: 'Rotate'),
            ],
          ),
        ),

        body: const TabBarView(
          children: [MergeSection(), SplitSection(), RotateSection()],
        ),
      ),
    );
  }
}
