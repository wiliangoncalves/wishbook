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

  XFile? _selectedImage;

  Future<void> selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _selectedImage = image;
      });

    setState(() {
      _selectedImage = image;
    });

    if (image != null) {
      String imagePath = image.path;
      // Agora você pode usar o caminho da imagem conforme necessário
      print('Caminho da imagem: $imagePath');
      // Aqui você pode fazer o upload da imagem para o servidor ou realizar outras ações com a imagem selecionada
      // O caminho da imagem selecionada pode ser acessado através de "image.path"
    }
  }

  Future<void> uploadImage(String imagePath) async {
    final token = await SecureStorage.readData('token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}/profile/?new_firstname=${firstnameController.text}&new_lastname=${lastnameController.text}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8'
      });

    final responseJson = jsonDecode(response.body);

    if(responseJson['status'] == 200){
      setState(() {
        profile.setName = firstnameController.text;
        profile.setLastname = lastnameController.text;
      });
    }
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('${dotenv.env['API_URL']}/profile/'));

      // Set the field name for the image
      request.fields['imageField'] = 'image';

      // Create a file from the image path
      var imageFile = File(imagePath);

      // Add the image file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send the request and get the response
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
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

  void signOut() async {
    await SecureStorage.deleteAllData();
    if(context.mounted){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginState()));
    }
  }

  void save() async {
    final token = await SecureStorage.readData('token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}/profile/?new_firstname=${firstnameController.text}&new_lastname=${lastnameController.text}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8'
      });

    final responseJson = jsonDecode(response.body);

    if(responseJson['status'] == 200){
      setState(() {
        profile.setName = firstnameController.text;
        profile.setLastname = lastnameController.text;
      });
    }
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
                  margin: const EdgeInsets.only(left: 20, bottom: 15),
                  child:
                    Row(
                      children: [
                        SizedBox(
                          child:
                          Column(
                            children: [
                              ElevatedButton(onPressed: selectImage, child: Text('Aperte')),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Column(
                                  children: [
                                    if (_selectedImage != null)
                                      Image.file(
                                        File(_selectedImage!.path),
                                        width: 200,
                                        height: 200,
                                      ),
                                  ],
                                ))
                            ],
                          )
                          // InkWell(
                          //   onTap: selectImage,
                          //   child: 
                          //     ClipRRect(
                          //       borderRadius: BorderRadius.circular(50.0),
                          //       child: Column(
                          //         children: [
                          //           if (_selectedImage != null)
                          //             Image.file(
                          //               File(_selectedImage!.path),
                          //               width: 200,
                          //               height: 200,
                          //             ),
                          //         ],
                          //       )
                          //       // child: Image.asset('images/waco.jpg', scale: 6)
                          // )),
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
                          disabledBorder: UnderlineInputBorder(),
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
                      ElevatedButton(onPressed: signOut, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange) ,child: Text(AppLocalizations.of(context)!.signOut)),
                      ElevatedButton(onPressed: save, child: Text(AppLocalizations.of(context)!.save)),
                    ],
                  ),
                ),
               
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: logOut, style: TextButton.styleFrom(foregroundColor: Colors.red), child: Text(AppLocalizations.of(context)!.deleteAccount),)
                    ],
                  ),
                ),
              ]),
          ),
    ]));
  }
}
