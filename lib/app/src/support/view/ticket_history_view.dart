import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/support/bloc/ticket_bloc.dart';
import 'package:haqvox/app/src/support/chatroom/chat_conversation.dart';

class TicketHistoryView extends StatefulWidget {
  const TicketHistoryView({super.key});
  static const String routeName = '/ticket-history-view';

  @override
  State<TicketHistoryView> createState() => _TicketHistoryViewState();
}

class _TicketHistoryViewState extends State<TicketHistoryView> {
  late TicketBloc _ticketBloc;
  @override
  void initState() {
    _ticketBloc = TicketBloc();
    _ticketBloc.add(TicketHistoryFetchingEvent());
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
          appBar: customAppBar1(title: 'Support History', context: context),
          body: BlocBuilder(
            bloc: _ticketBloc,
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (TicketGlobalLoadingState):
                  return Center(child: CircularProgressIndicator.adaptive());

                case const (TicketHistoryLoadedSuccessState):
                  final blocSnapshot =
                      (state as TicketHistoryLoadedSuccessState)
                          .ticketsHistoryEntity;
                  return blocSnapshot.record != null
                      ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: blocSnapshot.record!.length,
                        itemBuilder: (context, index) {
                          return _buildTicketCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CustomerSupportChat(
                                        ticketKey:
                                            blocSnapshot
                                                .record![index]
                                                .ticketKey
                                                .toString(),
                                        ticketTitle:
                                            blocSnapshot
                                                .record![index]
                                                .ticketTitle
                                                .toString(),
                                      ),
                                ),
                              );
                            },
                            context,
                            title:
                                blocSnapshot.record![index].ticketTitle
                                    .toString(),
                            message:
                                blocSnapshot.record![index].ticketSubjectName
                                    .toString(),
                            date:
                                blocSnapshot.record![index].ticketDate
                                    .toString(),
                            // isResolved: isResolved,
                          );
                        },
                      )
                      : Center(child: Text(blocSnapshot.message.toString()));

                case const (TicketHistoryFailedErrorState):
                  final error = (state as TicketHistoryFailedErrorState).error;
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

  Widget _buildTicketCard(
    BuildContext context, {
    required String title,
    required String message,
    required String date,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDateRow(date),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Unused status badge builder - kept for potential future use
  // Widget _buildStatusBadge(bool isResolved) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: isResolved ? Colors.green.shade50 : Colors.orange.shade50,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Text(
  //       isResolved ? 'Resolved' : 'Pending',
  //       style: GoogleFonts.poppins(
  //         fontSize: 12,
  //         color: isResolved ? Colors.green.shade700 : Colors.orange.shade700,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDateRow(String date) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 16, color: primaryColor),
        const SizedBox(width: 6),
        Text(
          date,
          style: GoogleFonts.poppins(fontSize: 12, color: primaryColor),
        ),
        const Spacer(),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ],
    );
  }
}
