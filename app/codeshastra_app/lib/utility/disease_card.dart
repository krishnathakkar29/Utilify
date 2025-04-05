// import 'package:ai_farmer_app/Constants/app_colors.dart';
import 'package:codeshastra_app/Constants/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:local/Models/eatery.dart';

class DiseaseCard extends StatefulWidget {
  final String? image;
  // final EateryModel response;
  DiseaseCard({
    super.key,
    this.image,
    // required this.response,
  });

  @override
  State<DiseaseCard> createState() => _DiseaseCardState();
}

class _DiseaseCardState extends State<DiseaseCard> {
  bool tapped = false;
  // @override
  // void initState() {
  //   // print("/////////////////////${widget.response}");
  //   // TODO: implement initState
  //   print(widget.response.highlightImages.toString());
  //   print(widget.response.toString());
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    // String imageUrl = widget.response.highlightImages != null &&
    //         widget.response.highlightImages!.isNotEmpty
    //     ? widget.response.highlightImages![0]
    //     : "https://via.placeholder.com/150";

    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 4.0,
          right: 4.0,
          left: 4,
          bottom: 4,
        ),
        child: SizedBox(
          height: w * 0.7,
          width: w * 0.9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              image: DecorationImage(
                // image: AssetImage(widget.response["pictures"][0]),
                image: AssetImage("assets/images/leaf.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: w * 0.845,
                        // height: h * 0.115,
                        margin: const EdgeInsets.only(
                          // bottom: 0,
                          left: 12,
                          right: 8,
                        ),
                        // padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // widget.response.name,
                                    "Plant Disease Detection",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "popR",
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: w * 0.7,
                                    child: Text(
                                      // widget.response.location,
                                      "Analyze crop health with a simple photo upload.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "popR",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.greenn,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
