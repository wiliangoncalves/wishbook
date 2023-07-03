
class ProfileClass {
  String _firstname = '';
  String _lastname = '';
  String _email = '';
 
  String get getFirstname {
    return _firstname;
  }
 
  set setName(String name) {
    _firstname = name;
  }

  String get getLastname {
    return _lastname;
  }

  set setLastname(String lastname) {
    _lastname = lastname;
  }

  String get getEmail {
    return _email;
  }

  set setEmail(String email) {
    _email = email;
  }
}