import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:microsoft_teams_clone/config/constants.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';

class JoinMeetingsPage extends StatefulWidget {
  @override
  _JoinMeetingsPageState createState() => _JoinMeetingsPageState();
}

class _JoinMeetingsPageState extends State<JoinMeetingsPage> {
  String code = "";
  createCode() {
    setState(() {
      code = Uuid().v1().substring(0, 6);
    });
  }

  joinMeet() async {
    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false
      };
      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      }
      var options = JitsiMeetingOptions(room: code)
        ..userDisplayName = "Karan"
        ..audioMuted = false
        ..videoMuted = true
        ..featureFlags.addAll(featureFlags);

      await JitsiMeet.joinMeeting(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "Create an Instant Meeting",
              style: TextStyle(
                color: StreamChatTheme.of(context).colorTheme.black,
                fontSize: 16.0,
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Code:",
                style: TextStyle(
                  color: StreamChatTheme.of(context).colorTheme.black,
                  fontSize: 16.0,
                ),
              ),
              Text(
                code,
                style: TextStyle(
                  color: StreamChatTheme.of(context).colorTheme.black,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () => createCode(),
            child: Container(
              color: appAccentIconColor,
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: Center(
                child: Text(
                  "Create Code",
                  style: TextStyle(
                    color: StreamChatTheme.of(context).colorTheme.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () => joinMeet(),
            child: Container(
              color: appAccentIconColor,
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: Center(
                child: Text(
                  "Join Meeting",
                  style: TextStyle(
                    color: StreamChatTheme.of(context).colorTheme.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          // Add Join Meeting
        ],
      ),
    );
  }
}
