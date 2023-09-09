//Packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Provider
import '../providers/authentication_provider.dart';
import '../providers/user_page_provider.dart';

//Widget
import '../widgets/top_bar.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/custom_list_view_tile.dart';
import '../widgets/rounded_button.dart';

//Models
import '../models/chat_user.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UsersPageState();
  }
}

class _UsersPageState extends State<UsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late UserPageProvider _pageProvider;
  final TextEditingController _searchFieldTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.sizeOf(context).height;
    _deviceWidth = MediaQuery.sizeOf(context).width;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserPageProvider>(
            create: (_) => UserPageProvider(_auth))
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<UserPageProvider>();
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.02),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              'Users',
              primaryAction: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
                onPressed: () {
                  _auth.logOut();
                },
              ),
            ),
            CustomTextField(
              controller: _searchFieldTextEditingController,
              hintText: "search...",
              icon: Icons.search,
              obsecureText: false,
              onEditingComplete: (_value) {
                _pageProvider.getUsers(name: _value);
                FocusScope.of(context).unfocus();
              },
            ),
            _userList(),
            _creatChatButton(),
          ],
        ),
      );
    });
  }

  Widget _userList() {
    List<ChatUser>? _users = _pageProvider.users;
    return Expanded(child: () {
      if (_users != null) {
        if (_users.length != 0) {
          return ListView.builder(
            itemCount: _users.length,
            itemBuilder: (BuildContext _context, int _index) {
              return CustomListViewTile(
                height: _deviceHeight * 0.10,
                title: _users[_index].name,
                subtitle: "Last Active: ${_users[_index].lastActive}",
                imagePath: _users[_index].imageURL,
                isActive: _users[_index].wasRecentlyActive(),
                isSelected: _pageProvider.selectedUsers.contains(
                  _users[_index],
                ),
                onTap: () {
                  _pageProvider.updateSelectedUser(
                    _users[_index],
                  );
                },
              );
            },
          );
        } else {
          return Center(
            child: Text(
              "No User Found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      } else {
        return Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    }());
  }

  Widget _creatChatButton() {
    return Visibility(
      visible: _pageProvider.selectedUsers.length == 1,
      child: RoundedButton(
        name: _pageProvider.selectedUsers.length == 1
            ? "Chat With ${_pageProvider.selectedUsers.first.name}"
            : "Create Group Chat",
        height: _deviceHeight * 0.08,
        width: _deviceWidth * 0.08,
        onPressed: () {
          _pageProvider.createChat();
        },
      ),
    );
  }
}
