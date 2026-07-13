import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/screens.dart';
import 'package:haqvox/app/src/subscription/view/subscription_plan_view.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

abstract class SubscriptionBuilder extends State<SubscriptionPlanView> {
  int selectedPlanIndex = 0; // Default to most popular plan
  late final Razorpay razorpay;
  // dynamic amount;

  openCheckout(amount) {
    final parsed = double.tryParse(amount.toString()) ?? 0.0;

    if (parsed <= 0) {
      CustomSnackBar.show(
        context: context,
        message: 'Please provide a valid amount greater than zero.',
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );

      return;
    }

    final intAmount = (parsed * 100).round(); // Convert to paise

    var options = {
      'key': Environment.razorPayTestKey,
      'amount': intAmount,
      'name': 'HaqVox',
      'description': 'Payment for Premium Account',
      'prefill': {'contact': '9251421785', 'email': 'haqvox786@gmail.com'},
    };

    try {
      razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  void processPayment(amount) {
    final parsed = double.tryParse(amount.toString());
    if (parsed == null || parsed <= 0) {
      CustomSnackBar.show(
        context: context,
        message: 'Please enter a valid amount greater than zero.',
        type: SnackBarType.error,
        duration: const Duration(seconds: 3),
      );

      return;
    }

    openCheckout(parsed);
  }

  paymentSuccessHandler(PaymentSuccessResponse response) {
    CustomSnackBar.show(
      context: context,
      message: 'Payment ID: ${response.paymentId}',
      type: SnackBarType.success,
      duration: const Duration(seconds: 3),
    );
  }

  paymentErrorHandler(PaymentFailureResponse response) {
    CustomSnackBar.show(
      context: context,
      message: 'Payment Failed due to error code ${response.code}',
      type: SnackBarType.error,
      duration: const Duration(seconds: 3),
    );
  }

  paymentExternalWalletHandler(ExternalWalletResponse response) {
    CustomSnackBar.show(
      context: context,
      message: 'Wallet Name: ${response.walletName}',
      type: SnackBarType.warning,
    );
  }

  Widget buildSubscriptionCard({
    required int index,
    required String price,
    required String duration,
    required List<String> features,
    required bool isPopular,
    required void Function()? onTap,
  }) {
    final isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          ' $duration',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? primaryColor
                              : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primaryColor : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            if (isPopular) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Most Popular',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
