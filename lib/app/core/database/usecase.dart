//* how to store data

// final prefs = await SharedPrefsService.getInstance();
// final user = UserModel(
//   id: '123',
//   name: 'John Doe',
//   email: 'john@example.com',
//   // ... other fields
// );
// await prefs.saveUser(user);


//* how to access data 
// final prefs = await SharedPrefsService.getInstance();
// final user = prefs.getUser();
// if (user != null) {
//   print(user.name); // Access user data
// }



//* login token 
// final prefs = await SharedPrefsService.getInstance();
// await prefs.setLoggedIn(true); // Set logged in
// bool isLoggedIn = prefs.isLoggedIn(); // Check login status