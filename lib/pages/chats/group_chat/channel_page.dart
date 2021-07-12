import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:microsoft_teams_clone/config/constants.dart';
import 'package:microsoft_teams_clone/pages/meetings/create_meetings_page.dart';
import 'package:microsoft_teams_clone/routes/routes.dart';
import 'package:microsoft_teams_clone/pages/chats/thread_page.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../chat_info_page.dart';
import 'channel_info_page.dart';

/*
This page renders the UI and integrates the BusinessLogic
for the Chat thread page for Channels or Group Chats
 in a channel of the Chat functionality
powered by Stream Chat SDK.
*/


class ChannelPageArgs {
  final Channel? channel;
  final Message? initialMessage;

  const ChannelPageArgs({
    this.channel,
    this.initialMessage,
  });
}

class ChannelPage extends StatefulWidget {
  final int? initialScrollIndex;
  final double? initialAlignment;
  final bool highlightInitialMessage;

  const ChannelPage({
    Key? key,
    this.initialScrollIndex,
    this.initialAlignment,
    this.highlightInitialMessage = false,
  }) : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  Message? _quotedMessage;
  FocusNode? _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    super.dispose();
  }

  void _reply(Message message) {
    setState(() => _quotedMessage = message);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _focusNode!.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var channel = StreamChannel.of(context).channel;
    var code = channel.id.toString().substring(0, 6);
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.whiteSnow,
      appBar: ChannelHeader(
        leading: StreamBackButton(),
        showTypingIndicator: true,
        onImageTap: () async {
          var channel = StreamChannel.of(context).channel;
          if (channel.memberCount == 2 && channel.isDistinct) {
            final currentUser = StreamChat.of(context).user;
            final otherUser = channel.state!.members.firstWhereOrNull(
              (element) => element.user!.id != currentUser!.id,
            );
            if (otherUser != null) {
              final pop = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreamChannel(
                    child: ChatInfoPage(
                      messageTheme: StreamChatTheme.of(context).ownMessageTheme,
                      user: otherUser.user,
                    ),
                    channel: channel,
                  ),
                ),
              );

              if (pop == true) {
                Navigator.pop(context);
              }
            }
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamChannel(
                  child: ChannelInfoPage(
                    messageTheme: StreamChatTheme.of(context).ownMessageTheme,
                  ),
                  channel: channel,
                ),
              ),
            );
          }
        },
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                MessageListView(
                  /*
                  Renders the chat messages for the channel obtained from the
                  stream chat servers for the current client
                  * */
                  initialScrollIndex: widget.initialScrollIndex,
                  initialAlignment: widget.initialAlignment,
                  highlightInitialMessage: widget.highlightInitialMessage,
                  onMessageSwiped: _reply,
                  onReplyTap: _reply,
                  threadBuilder: (_, parentMessage) {
                    return ThreadPage(
                      parent: parentMessage,
                    );
                  },
                  onShowMessage: (m, c) async {
                    final client = StreamChat.of(context).client;
                    final message = m;
                    final channel = client.channel(
                      c.type,
                      id: c.id,
                    );
                    if (channel.state == null) {
                      await channel.watch();
                    }
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.CHANNEL_PAGE,
                      arguments: ChannelPageArgs(
                        channel: channel,
                        initialMessage: message,
                      ),
                    );
                  },
                  pinPermissions: ['owner', 'admin', 'member'],
                  // Sets the permissions only to privileged members
                ),
                Positioned(
                  //sets the video icon for the call functionality
                  top: size.height * 0.75,
                  left: 8,
                  child: IconButton(
                    onPressed: () {
                      CreateMeetingsPage.joinMeet(code);
                    },
                    icon: FaIcon(FontAwesomeIcons.video, color: appPurpleColor),
                    iconSize: 25,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: StreamChatTheme.of(context)
                        .colorTheme
                        .whiteSnow
                        .withOpacity(.9),
                    child: TypingIndicator(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      style: StreamChatTheme.of(context)
                          .textTheme
                          .footnote
                          .copyWith(color: appLightColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          MessageInput(
            // Widget to input messages from the user
            focusNode: _focusNode,
            quotedMessage: _quotedMessage,
            onQuotedMessageCleared: () {
              setState(() => _quotedMessage = null);
              _focusNode!.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
