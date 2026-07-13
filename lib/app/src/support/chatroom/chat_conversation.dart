import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/shared_prefs_config.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/src/support/bloc/ticket_bloc.dart';

class CustomerSupportChat extends StatefulWidget {
  final String ticketKey;
  final String ticketTitle;

  const CustomerSupportChat({
    super.key,
    required this.ticketKey,
    required this.ticketTitle,
  });

  @override
  State<CustomerSupportChat> createState() => _CustomerSupportChatState();
}

class _CustomerSupportChatState extends State<CustomerSupportChat> {
  late final TicketBloc _ticketBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAttaching = false;
  // dynamic uKey;

  @override
  void initState() {
    super.initState();
    _ticketBloc = TicketBloc();
    _ticketBloc.add(
      LoadUserChatConversationMessageEvent(ticketKey: widget.ticketKey),
    );
    // initUKey();
  }

  @override
  void dispose() {
    _ticketBloc.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Future<void> initUKey() async {
  //   StorageConfig config = StorageConfig();
  //   final userKey = await config.getUserData(key: DBKeys.userKey);
  //   if (mounted) {
  //     setState(() {
  //       uKey = userKey;
  //     });
  //   }
  // }

  void _refreshMessages() {
    _ticketBloc.add(
      LoadUserChatConversationMessageEvent(ticketKey: widget.ticketKey),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _ticketBloc.add(
        SendTicketChatToServerEvent(
          ticketKey: widget.ticketKey,
          ticketMsg: _messageController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar1(title: widget.ticketTitle, context: context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chat Messages
          BlocConsumer(
            bloc: _ticketBloc,
            listener: (context, state) {
              if (state is SendTicketChatToSupportSuccessState) {
                _messageController.clear();
                // Refresh messages immediately after successful send
                _refreshMessages();
                // Scroll to bottom after refresh
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
              if (state is SendTicketChatToSupportFailedErrorState) {
                CustomSnackBar.show(context: context, message: state.error);
              }
            },
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (TicketGlobalLoadingState):
                  return const Center(child: CircularProgressIndicator());
                case const (LoadUserChatMessagesLoadedSuccessState):
                  final successState =
                      (state as LoadUserChatMessagesLoadedSuccessState)
                          .chatConversationEntity;
                  return successState.record?.first.ticketMessage != null
                      ? Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: successState.record?.length,
                          itemBuilder: (context, index) {
                            return Align(
                              alignment:
                                  HiveService.getUserId() ==
                                          successState.record?[index].ticketUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: 16,
                                  left:
                                      HiveService.getUserId() ==
                                              successState
                                                  .record![index]
                                                  .ticketUser
                                          ? 50
                                          : 0,
                                  right:
                                      HiveService.getUserId() ==
                                              successState
                                                  .record![index]
                                                  .ticketUser
                                          ? 0
                                          : 50,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      HiveService.getUserId() ==
                                              successState
                                                  .record![index]
                                                  .ticketUser
                                          ? primaryColor
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ).copyWith(
                                    bottomLeft:
                                        HiveService.getUserId() ==
                                                successState
                                                    .record![index]
                                                    .ticketUser
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                    bottomRight:
                                        HiveService.getUserId() ==
                                                successState
                                                    .record![index]
                                                    .ticketUser
                                            ? Radius.zero
                                            : const Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      successState.record![index].ticketMessage
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        color:
                                            HiveService.getUserId() ==
                                                    successState
                                                        .record![index]
                                                        .ticketUser
                                                ? Colors.white
                                                : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      successState.record![index].ticketDate
                                          .toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color:
                                            HiveService.getUserId() ==
                                                    successState
                                                        .record![index]
                                                        .ticketUser
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : const Center(child: Text('No messages yet'));
                default:
                  return const Center(child: Text('No messages yet'));
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attachment Preview
            if (_isAttaching)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(Icons.attachment, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Demo Attachment',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _isAttaching = false),
                    ),
                  ],
                ),
              ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: primaryColor),
                    onPressed: () {
                      setState(() => _isAttaching = !_isAttaching);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<TicketBloc, TicketState>(
                    bloc: _ticketBloc,
                    builder: (context, state) {
                      return state is TicketGlobalLoadingState
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : IconButton(
                            icon: Icon(Icons.send, color: primaryColor),
                            onPressed: _sendMessage,
                          );
                    },
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

class DemoMessage {
  final String message;
  final bool isUser;
  final String time;

  DemoMessage({
    required this.message,
    required this.isUser,
    required this.time,
  });
}
