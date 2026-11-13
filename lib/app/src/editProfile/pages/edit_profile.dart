// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haqvox/app/assets/assets.dart';
import 'package:haqvox/app/config/environment.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/database/key.dart';
import 'package:haqvox/app/core/database/user/hive_db.dart';
import 'package:haqvox/app/core/widgets/appbar.dart';
import 'package:haqvox/app/core/widgets/custom_snackbar.dart';
import 'package:haqvox/app/services/connectivity.dart';
import 'package:haqvox/app/src/auth/models/gender_entity.dart';
import 'package:haqvox/app/src/auth/view/widget/date_picker.dart';
import 'package:haqvox/app/src/auth/view/widget/textfields.dart';
import 'package:haqvox/app/src/editProfile/bloc/profile_bloc.dart';
import 'package:haqvox/app/src/myspace/view/offline_download.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, this.image}) : super(key: key);
  static const String routeName = '/edit_profile';
  final String? image;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? rKEY;
  late ProfileBloc _profileBloc;
  File? pickedImg;
  String? userImage;
  Timer? timer;
  // bool _acceptedTerms = false;
  String termsValue = '2'; // Default value is '2' for not accepted

  void loadUser() async {
    setState(() {
      profileImg = HiveService.userImage();
      fNameController.text = HiveService.getFName() ?? '';
      lNameController.text = HiveService.getLName() ?? '';
      emailController.text = HiveService.getUserEmail() ?? '';
      mobileController.text = HiveService.getMobile() ?? '';
      alternateMobileController.text =
          (HiveService.getAlternateMobile() == null ||
                  HiveService.getAlternateMobile() == 'N/A')
              ? ''
              : HiveService.getAlternateMobile()!;
      dobPickerController.text = HiveService.getDOB() ?? '';
    });
  }

  // storeImg() async {
  //   StorageConfig config = StorageConfig();
  //   if (_selectedImage != null) {
  //     await config.saveUserData(
  //       key: DBKeys.localImgKey,
  //       value: _selectedImage!.path,
  //     );
  //   }
  // }

  TextEditingController fNameController = TextEditingController();

  TextEditingController lNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController mobileController = TextEditingController();

  TextEditingController dobPickerController = TextEditingController();

  TextEditingController asswordController = TextEditingController();

  TextEditingController alternateMobileController = TextEditingController();

  TextEditingController dobController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isVisible = false;

  bool psw = false;

  bool confirmPsw = false;

  String? gender;

  String? rKey;

  bool _isLoading = false;

  String? profileImg;
  final ImagePicker _picker = ImagePicker();
  initUser() async {
    // StorageConfig config = StorageConfig();

    // final dob = await config.getUserData(key: DBKeys.uDOB);
    final imagePath = await HiveService.getUserLocalImage();

    setState(() {
      if (imagePath != null) {
        profileImg = imagePath.toString();
      }
      dobPickerController.text = HiveService.getDOB()!;
    });
  }

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    _profileBloc.add(FetchUserProfileDetailsEvent());
    timer = Timer.periodic(const Duration(microseconds: 100), (timer) {
      if (mounted) initUser();
    });
    initUser();
    // loadUser();
    genderList();
  }

  GenderEntity genderEntity = GenderEntity();
  String? pickedGender; // Changed from dynamic to String? to ensure type safety
  bool _isLoadingGenders = false;
  String? _genderError;

  Future<void> genderList() async {
    if (_isLoadingGenders) return;

    setState(() {
      _isLoadingGenders = true;
      _genderError = null;
    });

    try {
      final url = Uri.parse(Environment.baseUrl);

      final response = await http.post(url, body: {'activity': 'gender-list'});

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          genderEntity = GenderEntity.fromJson(jsonResponse);
          _isLoadingGenders = false;
          log('GenderList Message : ${genderEntity.message}');
        });
      } else {
        setState(() {
          _genderError = 'Failed to load gender list';
          _isLoadingGenders = false;
        });
        log('Failed to Load GenderList : ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _genderError = 'Error loading gender list';
        _isLoadingGenders = false;
      });
      log('GenderList Fetching Error : $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
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
          appBar: customAppBar1(title: 'Edit Profile', context: context),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding * 2.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.05),
                        profileImage(context),
                        SizedBox(height: size.height * 0.02),
                        CustomTextField(
                          controller: fNameController,

                          // onChanged: (value) {
                          //   setState(() {
                          //     fName = value;
                          //   });
                          // },
                          hintText: 'First Name',
                          icon: Icons.person,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your First Name';
                            }
                            return null;
                          },
                          // obscureText: false,
                        ),
                        SizedBox(height: size.height * 0.02),
                        CustomTextField(
                          controller: lNameController,

                          // onChanged: (value) {
                          //   setState(() {
                          //     lName = value;
                          //   });
                          // },
                          hintText: 'Last Name',
                          icon: Icons.person,
                          keyboardType: TextInputType.emailAddress,

                          // obscureText: false,
                        ),
                        SizedBox(height: size.height * 0.025),
                        CustomTextField(
                          controller: emailController,

                          // onChanged: (value) {
                          //   setState(() {
                          //     email = value;
                          //   });
                          // },
                          hintText: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          // obscureText: false,
                        ),
                        SizedBox(height: size.height * 0.025),
                        CustomTextField(
                          controller: mobileController,

                          // onChanged: (value) {
                          //   setState(() {
                          //     mobile = value;
                          //   });
                          // },
                          hintText: 'Mobile Number',
                          icon: Icons.phone,
                          maxLength: 10,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter mobile number';
                            }
                            return null;
                          },
                          // obscureText: false,
                        ),
                        SizedBox(height: size.height * 0.025),
                        CustomTextField(
                          controller: alternateMobileController,

                          // onChanged: (value) {
                          //   setState(() {
                          //     alternateMobile = value;
                          //   });
                          // },
                          hintText: 'Alternate Number',
                          icon: Icons.phone,
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null; // Make alternate number optional
                            }
                            // Validate if number is provided
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10 digit number';
                            }
                            // Check if alternate number is same as primary number
                            if (value == mobileController.text) {
                              return 'Alternate number should be different';
                            }
                            return null;
                          },
                          // obscureText: false,
                        ),
                        SizedBox(height: size.height * 0.025),
                        DatePickerField(controller: dobPickerController),
                        SizedBox(height: size.height * 0.025),
                        _buildGenderPicker(),
                        SizedBox(height: size.height * 0.025),
                      ],
                    ),
                  ),
                ),
              ),
              submitButton(context),
              SizedBox(height: fixPadding * 9.0),
            ],
          ),
        );
      },
    );
  }

  profileImage(context) {
    return Container(
      height: 200.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withValues(alpha:0.3),
                    width: 2,
                  ),
                ),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image:
                          pickedImg != null
                              ? FileImage(pickedImg!) as ImageProvider
                              : profileImg != null && profileImg!.isNotEmpty
                              ? (profileImg!.startsWith('http')
                                  ? NetworkImage(profileImg!)
                                  : FileImage(File(profileImg!)))
                              : AssetImage(Assets.defaultAvatar)
                                  as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha:0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (pickedImg != null)
            BlocConsumer(
              bloc: _profileBloc,
              listener: (context, state) {
                if (state is UserProfileUpdateFailedErrorState) {
                  CustomSnackBar.show(
                    context: context,
                    message: state.error,
                    type: SnackBarType.error,
                  );
                }
                // if (state is UserProfileImageUpdateSuccessState) {
                //   storeImg();
                // }
              },
              builder: (context, state) {
                if (state is ProfileLoadingState) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  );
                }

                return Container(
                  // margin: const EdgeInsets.only(top: 16),
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // StorageConfig config = StorageConfig();
                      if (pickedImg != null) {
                        HiveService.setter(
                          key: DBKeys.profileImgKey,
                          value: pickedImg,
                        );
                        _profileBloc.add(
                          UpdateUserProfileImageEvent(
                            file: pickedImg,
                            context: context,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: primaryColor.withValues(alpha:0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Upload Photo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile(ImageSource source) async {
    try {
      final imgFile = await _picker.pickImage(source: source);
      if (imgFile != null) {
        pickedImg = File(imgFile.path);
        setState(() {});
      } else {
        CustomSnackBar.show(
          context: context,
          message: 'failed to pick image',
          type: SnackBarType.error,
        );
      }

      // _profileBloc.add(
      //   UpdateUserProfileImageEvent(file: permanentFile, context: context),
      // );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Error picking image: $e',
          type: SnackBarType.error,
        );
        log('Error picking image: $e');
      }
    }
  }

  // Unused permission methods - commented out for future use
  // Future<bool> _requestImagePermission(ImageSource source) async {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     if (source == ImageSource.camera) {
  //       var status = await Permission.camera.request();
  //       return status.isGranted;
  //     } else {
  //       var status = await Permission.photos.request();
  //       if (status.isGranted) return true;
  //       // Fallback for Android older versions
  //       status = await Permission.storage.request();
  //       return status.isGranted;
  //     }
  //   }
  //   return true;
  // }

  // Future<bool> _requestStoragePermission() {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     return Permission.storage.request().then((status) {
  //       if (status.isGranted) {
  //         return Future.value(true);
  //       } else if (status.isDenied || status.isPermanentlyDenied) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Storage permission is required')),
  //         );
  //         return Future.value(false);
  //       }
  //       return Future.value(false);
  //     });
  //   } else {
  //     return Future.value(
  //       true,
  //     ); // Assume permission granted for other platforms
  //   }
  // }

  // changeProfilePick(context) async {
  //   StorageConfig config = StorageConfig();

  // }

  Widget _buildGenderError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(height: 4),
          Text(_genderError!, style: const TextStyle(color: Colors.red)),
          TextButton.icon(
            onPressed: genderList,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  submitButton(context) {
    return BlocBuilder(
      bloc: _profileBloc,
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: fixPadding * 5.0,
            vertical: fixPadding,
          ),
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final selectedGender =
                  (pickedGender ?? genderEntity.record!.first.genderID)
                      .toString();
              _profileBloc.add(
                EditUserProfileDetailsEvent(
                  fName: fNameController.text,
                  lName: lNameController.text,
                  email: emailController.text,
                  mobile: mobileController.text,
                  alternateMobile: alternateMobileController.text,
                  dob: dobPickerController.text,
                  gender: selectedGender,
                  uStep: '1',
                  context: context,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text('Update Profile', style: white18SemiBoldTextStyle),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileImage() {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha:0.3),
                width: 2,
              ),
            ),
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ClipOval(
                      child:
                          pickedImg != null
                              ? Image.file(
                                pickedImg!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.person, size: 60),
                                frameBuilder: (
                                  _,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (frame == null) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return child;
                                },
                              )
                              : profileImg != null
                              ? Image.network(
                                profileImg.toString(),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.person, size: 60),
                              )
                              : const Icon(Icons.person, size: 60),
                    ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Gender', style: grey14RegularTextStyle),
        ),
        SizedBox(
          height: 50,
          child:
              _isLoadingGenders
                  ? const Center(child: CircularProgressIndicator())
                  : _genderError != null
                  ? _buildGenderError()
                  : genderEntity.record == null
                  ? const Center(
                    child: Text(
                      'Unable to load genders',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: genderEntity.record?.length ?? 0,
                    itemBuilder: (context, index) {
                      // Set Male as default selection when list is loaded
                      if (pickedGender == null &&
                          genderEntity.record![index].genderName == 'Male') {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            pickedGender =
                                genderEntity.record![index].genderID
                                    ?.toString();
                            gender = genderEntity.record![index].genderName;
                          });
                        });
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                pickedGender =
                                    genderEntity.record![index].genderID
                                        ?.toString();
                                gender = genderEntity.record![index].genderName;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    pickedGender ==
                                            genderEntity.record![index].genderID
                                                ?.toString()
                                        ? primaryColor.withValues(alpha:0.15)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      pickedGender ==
                                              genderEntity
                                                  .record![index]
                                                  .genderID
                                                  ?.toString()
                                          ? primaryColor
                                          : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  genderEntity.record![index].genderName
                                      .toString(),
                                  style: TextStyle(
                                    color:
                                        pickedGender ==
                                                genderEntity
                                                    .record![index]
                                                    .genderID
                                                    ?.toString()
                                            ? primaryColor
                                            : Colors.grey.shade600,
                                    fontSize: 15,
                                    fontWeight:
                                        pickedGender ==
                                                genderEntity
                                                    .record![index]
                                                    .genderID
                                                    ?.toString()
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
