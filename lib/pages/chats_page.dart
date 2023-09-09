import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Provider
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Widget
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tile.dart';

//Service
import '../services/navigation.service.dart';

//Pages
import '../pages/chat_page.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatsPageProvider _pageProvider;
  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.sizeOf(context).height;
    _deviceWidth = MediaQuery.sizeOf(context).width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext _context) {
      _pageProvider = _context.watch<ChatsPageProvider>();
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _auth.logOut();
                  },
                ),
              ),
              _chatList(),
            ]),
      );
    });
  }

  Widget _chatList() {
    List<Chat>? chats = _pageProvider.chats;
    print(chats);
    return Expanded(
      child: (() {
        if (chats != null) {
          if (chats.length != 0) {
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _chatTile(chats[index]);
              },
            );
          } else {
            return Center(
              child: Text(
                "No Chats Found!",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recipients = _chat.recipients();
    bool isActive = _recipients.any((_d) => _d.wasRecentlyActive());
    String _subTitleText = "";
    if (_chat.message.isNotEmpty) {
      _subTitleText = _chat.message.first.type != MessageType.Text
          ? "Media Attahment"
          : _chat.message.first.content;
    }

    return CustomListViewTileWithActivity(
      height: _deviceHeight * 0.01,
      title: _chat.title(),
      subtitle: _subTitleText,
      imagePath: _chat.imageURL(),
      isActive: isActive,
      isActivity: _chat.activity,
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: _chat),
        );
      },
    );
  }
}
