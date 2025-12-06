// lib/router.dart
import 'package:dappworks/ui/screens/auth/role_select_screen.dart';
import 'package:flutter/material.dart';

import 'ui/screens/projects/my_projects_screen.dart';
import 'ui/screens/bidders/view_bidders_screen.dart';
import 'ui/screens/bids/my_bids_screen.dart';
import 'ui/screens/gigs/my_jobs_screen.dart';
import 'ui/screens/chat/chat_screen.dart';
import 'ui/screens/chat/recent_conversations_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case '/':
      // Entry point: choose Freelancer or Client
      return MaterialPageRoute(builder: (_) => const RoleSelectScreen());

    case '/my-projects':
      return MaterialPageRoute(builder: (_) => const MyProjectsScreen());

    case '/view-bidders':
      final id = s.arguments as int;
      return MaterialPageRoute(builder: (_) => ViewBiddersScreen(jobId: id));

    case '/my-bids':
      return MaterialPageRoute(builder: (_) => const MyBidsScreen());

    case '/my-jobs':
      return MaterialPageRoute(builder: (_) => const MyJobsScreen());

    case '/messages':
      return MaterialPageRoute(
        builder: (_) => const RecentConversationsScreen(),
      );

    case '/chats':
      // ChatScreen now requires jobId and otherUserName
      final args = s.arguments as Map<String, dynamic>?;
      if (args == null) {
        // Fallback if no arguments provided
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(
            jobId: 0,
            otherUserName: 'User',
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => ChatScreen(
          jobId: args['jobId'] as int? ?? 0,
          otherUserName: args['otherUserName'] as String? ?? 'User',
        ),
      );

    case '/authenticate':
      // In the new flow AuthenticateScreen is created with a UserType argument,
      // so the named route is not used. We just fall back to role selection.
      return MaterialPageRoute(builder: (_) => const RoleSelectScreen());

    default:
      // Any unknown route -> role selection
      return MaterialPageRoute(builder: (_) => const RoleSelectScreen());
  }
}