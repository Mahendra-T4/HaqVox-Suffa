import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/global/bloc/global_bloc.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/subscription/view/subcription_builder.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionPlanView extends StatefulWidget {
  const SubscriptionPlanView({super.key});
  static const String routeName = '/subscription-plans';

  @override
  State<SubscriptionPlanView> createState() => _SubscriptionPlanViewState();
}

class _SubscriptionPlanViewState extends SubscriptionBuilder {
  late GlobalBloc _globalBloc;
  dynamic amount;

  @override
  void initState() {
    _globalBloc = GlobalBloc();
    _globalBloc.add(SubscriptionPlanFetchingEvent());
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, paymentSuccessHandler);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, paymentErrorHandler);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, paymentExternalWalletHandler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: InternetConnectionService().connectionStream,
      initialData: true, // Assume connected initially
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const OfflineDownloads();
        }

        // Handle disconnected state
        if (snapshot.data == false) {
          return const OfflineDownloads();
        }

        // Handle loading state
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: customAppBar1(title: 'Choose Your Plan', context: context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the perfect plan for you',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get unlimited access to all features',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                BlocConsumer(
                  bloc: _globalBloc,
                  listener: (context, state) {
                    if (state is GlobalSubscriptionPlanLoadedSuccessState) {
                      if (state.subscriptionsPlanEntity.status == 1) {
                        amount =
                            state
                                .subscriptionsPlanEntity
                                .record![0]
                                .subscriptionPrice;
                      }
                    }
                  },
                  builder: (context, state) {
                    switch (state.runtimeType) {
                      case const (GlobalLoadingState):
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      case const (GlobalSubscriptionPlanLoadedSuccessState):
                        final successState =
                            (state as GlobalSubscriptionPlanLoadedSuccessState)
                                .subscriptionsPlanEntity;
                        return successState.status == 1
                            ? Column(
                              children: [
                                SizedBox(
                                  height: 500,
                                  child: ListView.builder(
                                    itemCount: successState.record?.length,
                                    itemBuilder:
                                        (
                                          context,
                                          index,
                                        ) => buildSubscriptionCard(
                                          onTap: () {
                                            setState(() {
                                              selectedPlanIndex = index;
                                            });
                                            amount =
                                                successState
                                                    .record![index]
                                                    .subscriptionPrice;
                                          },
                                          index: index,
                                          price:
                                              successState
                                                  .record![index]
                                                  .subscriptionPrice
                                                  .toString(),
                                          duration:
                                              successState
                                                  .record![index]
                                                  .subscriptionFor
                                                  .toString(),
                                          features: [
                                            'Access all content for ${successState.record![index].subscriptionFor.toString()}',
                                            'Unlimited downloads',
                                            'Standard quality',
                                            'Ad-Free experience',
                                          ],
                                          isPopular: false,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      processPayment(amount);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Continue with Selected Plan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Center(
                              child: Text(successState.message.toString()),
                            );
                      case const (GlobalNotificationFetchingFailedErrorState):
                        final error =
                            (state as GlobalNotificationFetchingFailedErrorState)
                                .error;
                        return Center(child: Text(error));
                      default:
                        return Center(child: Text('State not found'));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
