//Packages
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Services
import '../services/media_service.dart';
import '../services/database_services.dart';
import '../services/cloud_storage_service.dart';
import '../services/navigation.service.dart';

//Widget
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_image.dart';

//Provider
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  PlatformFile? profileImage;

  String? email;
  String? name;
  String? password;

  late AuthenticationProvider auth;
  late DatabaseService db;
  late CloudStorageService storage;
  late NavigationService navigation;

  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthenticationProvider>(context);
    db = GetIt.instance.get<DatabaseService>();
    storage = GetIt.instance.get<CloudStorageService>();
    navigation = GetIt.instance.get<NavigationService>();

    _deviceHeight = MediaQuery.sizeOf(context).height;
    _deviceWidth = MediaQuery.sizeOf(context).width;

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImageField(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerForm(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              _registerButton(),
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
            ]),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaSevice>().pickImageFromLibrary().then(
          (file) {
            setState(
              () {
                profileImage = file;
              },
            );
          },
        );
      },
      child: () {
        if (profileImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            image: profileImage!,
            size: _deviceHeight * 0.15,
          );
        } else {
          return RoundedImageNetwork(
            key: UniqueKey(),
            imagePath: "https://www.pngwing.com/en/free-png-buqqo",
            size: _deviceHeight * 0.15,
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextFormField(
                  onSaved: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  regEx: r".{8,}",
                  hintText: "Name",
                  obsecureText: false),
              CustomTextFormField(
                  onSaved: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  regEx: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-z]{2,}\$',
                  hintText: "Email",
                  obsecureText: false),
              CustomTextFormField(
                  onSaved: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  regEx: r".{8,}",
                  hintText: "Password",
                  obsecureText: true),
            ]),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.065,
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() && profileImage != null) {
          _registerFormKey.currentState!.save();
          String? uid =
              await auth.registerUsingEmailAndPassword(email!, password!);
          String? imageURL =
              await storage.saveUserImageToStorage(uid!, profileImage!);
          await db.createUser(uid, email!, name!, imageURL!);
          await auth.logOut();
          await auth.registerUsingEmailAndPassword(email!, password!);
        }
      },
    );
  }
}

class RoundedImageFile extends StatelessWidget {
  final PlatformFile image;
  final double size;

  RoundedImageFile({
    required Key key,
    required this.image,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(image.path!),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(size),
        ),
        color: Colors.black,
      ),
    );
  }
}
