class Register {
String fName;
String lName;
String email;
String mobile;
String? alternateMobile;
String dob;
String gender; // Should be String, not int
String password;
String uTerms; // Should be String, not int

  Register({
    required this.fName,
    required this.lName,
    required this.email,
    required this.mobile,
    this.alternateMobile,
    required this.dob,
    required this.gender,
    required this.password,
    required this.uTerms,
  });
}
