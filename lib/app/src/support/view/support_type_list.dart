import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/support/bloc/ticket_bloc.dart';

class AllSupportList extends StatefulWidget {
  const AllSupportList({super.key});
  static const String routeName = '/all-support-list';

  @override
  State<AllSupportList> createState() => _AllSupportListState();
}

class _AllSupportListState extends State<AllSupportList> {
  late TicketBloc _ticketBloc;
  @override
  void initState() {
    _ticketBloc = TicketBloc();
    _ticketBloc.add(TicketSubjectListFetchingEvent());
    super.initState();
  }

  List<IconData> iconList = [
    Icons.help_outline_rounded,
    Icons.payment_rounded,
    Icons.computer_rounded,
  ];

  List<String> description = [
    'General questions about our services and policies',
    'Questions about payments, subscriptions, or refunds',
    'Help with app features, bugs, or technical issues',
  ];

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
          appBar: customAppBar1(title: 'Customer Support', context: context),
          body: BlocBuilder(
            bloc: _ticketBloc,
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (TicketGlobalLoadingState):
                  return Center(child: CircularProgressIndicator.adaptive());
                case const (TicketSubjectListFetchingLoadedSuccessState):
                  final blocSnapshot =
                      (state as TicketSubjectListFetchingLoadedSuccessState)
                          .ticketsSubjectEntity;
                  return ListView.builder(
                    itemCount: blocSnapshot.record?.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: _buildSupportTypeCard(
                          context: context,
                          icon: iconList[index],
                          title:
                              blocSnapshot.record![index].subjectName
                                  .toString(),
                          description: description[index],
                          onTap: () {
                            // GoRouter.of(context)
                            //     .pushNamed(CustomerChatSupport.routeName);
                          },
                        ),
                      );
                    },
                  );
                case const (TicketSubjectListFailedErrorState):
                  final error =
                      (state as TicketSubjectListFailedErrorState).error;
                  return Center(child: Text(error));
                default:
                  return Center(child: Text('State not found'));
              }
            },
          ),
        );
      },
    );
  }

  // Container(
  Widget _buildSupportTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: primaryColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
