// import 'package:ai_farmer_app/Constants/app_colors.dart';
// import 'package:ai_farmer_app/utility/sizedbox_util.dart';
import 'package:codeshastra_app/Constants/app_colors.dart';
import 'package:codeshastra_app/utility/sizedbox_util.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.greenn,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction and Overview
              Text(
                'Introduction & Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greenn,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'This app helps you with crop yield prediction, crop disease detection, crop prediction',
              ),
              Divider(color: AppColors.grey, thickness: 0.6),
              vSize(20),
              Text(
                'Feature Descriptions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greenn,
                ),
              ),
              ExpansionTile(
                title: Text('Crop Yield Prediction'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Enter details like area size, district, crop type, and season to predict the crop yield.',
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('Crop Disease Detection'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Upload an image of your crop to detect potential diseases.',
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.grey, thickness: 0.6),

              // Add more features similarly...
              vSize(100),
            ],
          ),
        ),
      ),
    );
  }
}
