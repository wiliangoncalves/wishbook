import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart' show SecureStorage;
import 'package:app/screens/login.dart' show LoginState;
import 'package:app/profileclasses/profiledata.dart' show ProfileClass;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:logger/logger.dart';

Future getProfile() async {
  final token = await SecureStorage.readData('token');
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/profile/'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
    });

  final responseJson = jsonDecode(response.body);

  if(responseJson['status'] == 200){
    await SecureStorage.saveData('firstname', responseJson['firstname']);
    await SecureStorage.saveData('lastname', responseJson['lastname']);
    await SecureStorage.saveData('email', responseJson['email']);
    await SecureStorage.saveData('avatar', responseJson['avatar']);
  }
}

class ProfileState extends StatefulWidget {
  const ProfileState({super.key});

  @override
  State createState () => Profile();
}

class Profile extends State<ProfileState> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController avatarController = TextEditingController();
  var logger = Logger();

  XFile? _selectedImage;

  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> uploadImage() async {
    if (_selectedImage != null) {
      File file = File(_selectedImage!.path);

      var url = Uri.parse('https://api.imgbb.com/1/upload');
      var request = http.MultipartRequest('POST', url);
      request.fields['key'] = '${dotenv.env['IMGBB_API_KEY']}';
      request.files.add(await http.MultipartFile.fromPath('image', file.path,
          contentType: MediaType('image', 'jpeg')));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseString = await response.stream.transform(utf8.decoder).join();
        var responseData = json.decode(responseString);

        final token = await SecureStorage.readData('token');

        final responseAvatar = await http.put(
          Uri.parse('${dotenv.env['API_URL']}/profile/?new_avatar=${responseData['data']['url']}'),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8'
          });

        final responseAvatarJson = jsonDecode(responseAvatar.body);

        if(responseAvatarJson['status'] == 200){
          setState(() {
            profile.setAvatar = avatarController.text;
          });
        }
      } else {
        logger.w('Image error upload. statusCode: ${response.statusCode}');
      }
    } else {
      logger.w('None image selected!');
    }
  }

  @override
  void initState() {
    super.initState();
    SecureStorage.readData('firstname').then((value) {
      setState(() {
        profile.setName=value ?? '';
      });
    });

    SecureStorage.readData('lastname').then((value) {
      setState(() {
        profile.setLastname=value ?? '';
      });
    });

    SecureStorage.readData('email').then((value){
      setState(() {
        profile.setEmail=value ?? '';
      });
    });
    
    SecureStorage.readData('avatar').then((value) {
      setState(() {
        profile.setAvatar=value ?? '';
      });
    });
  }

  ProfileClass profile = ProfileClass();

  Future logOut() async {
    await SecureStorage.deleteData('token');

    if(context.mounted){
        Navigator
      .of(context)
        .pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginState()
        )
       );
      }
  }

  Future confirmSignOut() async {
    final localizations = AppLocalizations.of(context);
    if(localizations == null) {
      return;
    }

    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Icon(
          Icons.warning_amber_outlined,
          color: Colors.orange,
          size: 50.0
        ),
        content: Text(
          '${localizations.sureToSignOut}?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop();
            signOut();
          }, child: Center(
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20)
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  localizations.yes,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white)
                ),
              ),
            ),
          ))
        ],
      );
    });
  }

  void signOut() async {
    await SecureStorage.deleteAllData();
    gotoLogin();
  }

  void gotoLogin() {
    if (context.mounted)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const LoginState()));
      }
  }

  void deleteAccount() async {
    final token = await SecureStorage.readData('token');

    final response = await http.delete(Uri.parse('${dotenv.env['API_URL']}/profile/'), headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});

    final responseJson = jsonDecode(response.body);

    if(responseJson['status'] == 200) {
      await SecureStorage.deleteAllData();
      gotoLogin();
    }
  }

  Future confirmDelete() async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return; // Retorna antecipadamente se localizations for nulo
    }
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Icon(
          Icons.warning_amber_sharp,
          color: Colors.red,
          size: 50.0
        ),
        content: Text(
          '${localizations.sureToDelete}?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
        actions: [
          TextButton(onPressed: () => {
            Navigator.of(context).pop(),
            deleteAccount(),
          }, child: Center(
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20)
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(localizations.yes, 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)
                ),
              ),
            ),
          ))
        ],
      );
    });
  }

  void save() async {
    final token = await SecureStorage.readData('token');

    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}/profile/?new_firstname=${firstnameController.text}&new_lastname=${lastnameController.text}&new_avatar=${avatarController.text}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8'
      });

    final responseJson = jsonDecode(response.body);

    if(responseJson['status'] == 200){
      setState(() {
        profile.setName = firstnameController.text;
        profile.setLastname = lastnameController.text;
        profile.setAvatar = avatarController.text;
      });
    }
    uploadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
          margin: const EdgeInsets.only(top: 10, left: 30),
          child:
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  child: Text(AppLocalizations.of(context)!.profile, style: const TextStyle(fontSize: 20),)),
                Container(
                  margin: const EdgeInsets.only(left: 0, bottom: 0),
                  child:
                    Row(
                      children: [
                        SingleChildScrollView(
                          child:
                            InkWell(
                              onTap: selectImage,
                              child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(70), // Defina o raio desejado
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    height: 90,
                                    scale: 5,
                                  ),
                                )
                              : FutureBuilder(
                                  future: Future.delayed(const Duration(seconds: 1)), // Adiciona um atraso de 1 segundo
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      // Após o atraso, carrega a imagem da rede
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(70),
                                        child: Image.network(
                                          profile.getAvatar == '' ?
                                          'https://i.ibb.co/MPGG9nn/avatar.jpg' : profile.getAvatar,
                                          height: 90,
                                          scale: 5,
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 15.0),
                                  child: Text(profile.getFirstname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8.0, left: 15.0),
                                  child: Text(profile.getLastname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                ),
                              ],
                            ),
                          )),
                      ]),
                ),
                const Divider(color: Colors.black),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child: TextFormField(
                        controller: firstnameController..text=profile.getFirstname,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.firstname,
                        ),
                      ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child:  TextFormField(
                        controller: lastnameController..text=profile.getLastname,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.lastname,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child:  TextFormField(
                        controller: emailController..text=profile.getEmail,
                        decoration: const InputDecoration(
                          enabled: false, 
                          labelText: 'E-mail',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(onPressed: confirmSignOut, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange) ,child: Text(AppLocalizations.of(context)!.signOut)),
                      ElevatedButton(onPressed: save, child: Text(AppLocalizations.of(context)!.save)),
                    ],
                  ),
                ),
               
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: confirmDelete, style: TextButton.styleFrom(foregroundColor: Colors.red), child: Text(AppLocalizations.of(context)!.deleteAccount),)
                    ],
                  ),
                ),
              ]),
          ),
    ]));
  }
}
