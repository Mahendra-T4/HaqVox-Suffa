import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/myspace/view/myspace.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:haqvox/app/src/support/bloc/ticket_bloc.dart';
import 'package:haqvox/app/src/support/models/generate_ticket_params.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class SuffaSupport extends StatefulWidget {
  const SuffaSupport({super.key});
  static const String routeName = '/support-list';

  @override
  State<SuffaSupport> createState() => _SuffaSupportState();
}

class _SuffaSupportState extends State<SuffaSupport> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String? _ticketSubjectID;
  File? _attachedFile;
  // bool _isLoading = false;
  late TicketBloc _ticketBloc;

  // final List<String> _categories = [
  //   'Technical Support',
  //   'Billing Issue',
  //   'General Inquiry',
  // ];

  @override
  void initState() {
    super.initState();
    _ticketBloc = TicketBloc();
    _ticketBloc.add(TicketSubjectListFetchingEvent());
  }

  @override
  void dispose() {
    // _ticketBloc.close();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void generateTicket() {
    if (_formKey.currentState!.validate()) {
      if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Fill Required Fields')),
        );
      } else {
        _ticketBloc.add(
          GenerateTicketEvent(
            context: context,
            generateTicketParams: GenerateTicketParams(
              ticketTitle: _titleController.text,
              ticketMsg: _messageController.text,
              ticketSubjectID: _ticketSubjectID.toString(),
            ),
            file: _attachedFile,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _attachedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _attachedFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Error capturing image: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     // Implement form submission
  //     print('Category: $_ticketSubjectID');
  //     print('Title: ${_titleController.text}');
  //     print('Message: ${_messageController.text}');
  //     print('File: ${_attachedFile?.path}');
  //   }
  // }

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
          appBar: customAppBar1(
            title: 'Submit Support Ticket',
            context: context,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How can we help you?',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please fill out the form below and we\'ll get back to you shortly',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Dropdown
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: subjectList(),
                    ),
                    const SizedBox(height: 16), // Title Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Describe your issue...',
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe your issue';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // File Attachment Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              _attachedFile != null
                                  ? _attachedFile!.path.split('/').last
                                  : 'Add Attachment',
                              style: GoogleFonts.poppins(
                                color:
                                    _attachedFile != null
                                        ? Colors.black87
                                        : Colors.grey[600],
                              ),
                            ),
                            trailing:
                                _attachedFile != null
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _attachedFile = null;
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          if (_attachedFile == null) ...[
                            const Divider(height: 1),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickFile,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Choose File',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey[300],
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickImage,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Take Photo',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    submitTicketButton(),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget submitTicketButton() {
    return BlocConsumer(
      bloc: _ticketBloc,
      listener: (context, state) {
        if (state is GenerateTicketFailedErrorState) {
          return CustomSnackBar.show(
            context: context,
            message: state.error,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is TicketGlobalLoadingState) {
          return Center(child: CircularProgressIndicator.adaptive());
        }

        return SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: generateTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Submit Ticket',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget subjectList() {
    return BlocConsumer(
      bloc: _ticketBloc,
      listener: (context, state) {
        if (state is TicketSubjectListFailedErrorState) {
          CustomSnackBar.show(
            context: context,
            message: state.error,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        if (state is TicketGlobalLoadingState) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (state is TicketSubjectListFetchingLoadedSuccessState) {
          return DropdownButtonFormField<String>(
            value: _ticketSubjectID,
            decoration: const InputDecoration(
              hintText: 'Select Category',
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
            ),
            items:
                state.ticketsSubjectEntity.record?.map((subject) {
                  return DropdownMenuItem(
                    value: subject.subjectID.toString(),
                    child: Text(subject.subjectName.toString()),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _ticketSubjectID = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          );
        } else {
          return const Center(child: Text('State not found'));
        }
      },
    );
  }
}
