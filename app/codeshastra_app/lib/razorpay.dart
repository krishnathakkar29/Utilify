import 'package:codeshastra_app/nextpageafterpayment.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isPaymentComplete = false;
  late Razorpay _razorpay;
  final double amount = 200.0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _openRazorpay() async {
    if (!await checkInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No Internet Connection. Please check your network settings.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert amount to paise/cents (smallest currency unit)
    final amountInPaise = (amount * 100).toInt();

    var options = {
      'key': 'rzp_test_YghCO1so2pwPnx',
      'amount': amountInPaise,
      'name': 'My Company Name',
      'description': 'Buying Premium Membership',
      'prefill': {
        'contact': '9876543210', // Optional: Pre-fill customer phone
        'email': 'customer@example.com', // Optional: Pre-fill customer email
      },
      'theme': {'color': '#008000'},
      'retry': {'enabled': true, 'max_count': 3},
      'send_sms_hash': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: ${e.toString()}');
      showPaymentPopupMessage(
        context,
        false,
        'Failed to open payment gateway: ${e.toString()}',
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      isPaymentComplete = true;
    });

    print("Payment Success: ${response.paymentId}");

    // Here you would typically verify the payment with your backend
    // verifyPaymentWithBackend(response.paymentId);

    showPaymentPopupMessage(
      context,
      true,
      'Payment Successful!\nPayment ID: ${response.paymentId}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Nextpageafterpayment()),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error Code: ${response.code}");
    print("Payment Error Message: ${response.message}");

    String errorMessage = "Payment Failed";

    // Provide more specific error messages based on common error codes
    if (response.code == 2) {
      errorMessage = "Network error occurred. Please check your connection.";
    } else if (response.code == 1) {
      errorMessage = "Payment cancelled by user or payment failed.";
    }

    showPaymentPopupMessage(context, false, errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
    showPaymentPopupMessage(
      context,
      true,
      'You have chosen to pay via: ${response.walletName}',
    );
  }

  void showPaymentPopupMessage(
    BuildContext ctx,
    bool isPaymentSuccess,
    String message,
  ) {
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isPaymentSuccess ? Icons.check_circle : Icons.error,
                color: isPaymentSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                isPaymentSuccess ? 'Payment Successful' : 'Payment Failed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Divider(color: Colors.grey),
                SizedBox(height: 10),
                Text(message, style: TextStyle(fontSize: 16)),
                if (isPaymentSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Thank you for your purchase!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate further if payment was successful
                if (isPaymentComplete) {
                  // You could navigate to order confirmation page
                  // Navigator.pushReplacement(...);
                }
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Premium Membership'),
                                Text('₹$amount'),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '₹$amount',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
            ),
            Container(
              color: Colors.green,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹$amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _openRazorpay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'PAY NOW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class CheckoutScreen extends StatefulWidget {
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   bool isPaymentComplete = false;
//   late Razorpay _razorpay;
//   TextEditingController paymentField = TextEditingController();

//   // Future<bool> checkInternet() async {
//   //   var connectivityResult = await Connectivity().checkConnectivity();
//   //   return connectivityResult != ConnectivityResult.none;
//   // }

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   @override
//   void dispose() {
//     _razorpay.clear(); // Clean up resources
//     paymentField.dispose();
//     super.dispose(); // super.dispose() should be last
//   }

//   // 'key': 'rzp_test_GcZZFDPP0jHtC4',
//   void _openRazorpay() async {
//     // if (!await checkInternet()) {
//     //   // Inform the user about the lack of internet connectivity
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(
//     //       content: Text(
//     //         "No Internet Connection. Please check your network settings.",
//     //       ),
//     //     ),
//     //   );
//     //   return;
//     // }

//     var options = {
//       'key': 'rzp_test_YghCO1so2pwPnx',
//       'amount': 200 * 100,
//       'order_id': 'order_ABC123xyz', // Backend-generated order ID
//       'name': 'My Company Name',
//       'description': 'Buying Premium Membership',
//       'theme': {'color': '#008000'},
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print('Error: ${e.toString()}');
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     setState(() {
//       isPaymentComplete = true;
//     });
//     showPaymentPopupMessage(context, true, 'Payment Successful!');
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     print("Payment Error Code: ${response.code}");
//     print("Payment Error Message: ${response.message}");
//     showPaymentPopupMessage(
//       context,
//       false,
//       "Payment Failed: ${response.message}",
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print('You have chosen to pay via: ${response.walletName}');
//   }

//   void showPaymentPopupMessage(
//     BuildContext ctx,
//     bool isPaymentSuccess,
//     String message,
//   ) {
//     showDialog<void>(
//       context: ctx,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(
//                 isPaymentSuccess ? Icons.done : Icons.clear,
//                 color: isPaymentSuccess ? Colors.green : Colors.red,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 isPaymentSuccess ? 'Payment Successful' : 'Payment Failed',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Divider(color: Colors.grey),
//                 SizedBox(height: 5),
//                 Text(message),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Cart')),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: Text(
//                   'Cart items here..',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//             Container(
//               color: Colors.green,
//               width: double.infinity,
//               padding: EdgeInsets.all(10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Total amount: ₹200',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: _openRazorpay,
//                     child: Text(
//                       'CHECKOUT',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.green,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
