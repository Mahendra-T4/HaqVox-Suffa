class EditProfileApiParams {
  final String uFirstName;
  final String uLastName;
  final String uEmail;
  final String uMobile;
  final String uAlternateNumber;
  final String uDOB;
  final String uGender;
  final String uStep;
  final String? rKey;

  EditProfileApiParams({
    required this.uFirstName,
    required this.uLastName,
    required this.uEmail,
    required this.uMobile,
    required this.uAlternateNumber,
    required this.uDOB,
    required this.uGender,
    required this.uStep,
    this.rKey,
  });

  Map<String, String> toJson() {
    return {
      'uFirstName': uFirstName.trim(),
      'uLastName': uLastName.trim(),
      'uEmail': uEmail.trim(),
      'uMobile': uMobile.trim(),
      'uAlternateNumber': uAlternateNumber.trim(),
      'uDOB': uDOB.trim(),
      'uGender': uGender.trim(),
      'uStep': uStep.toString().trim(),
      if (rKey != null) 'rKey': rKey!.trim(),
    };
  }
}
