import 'package:flutter/material.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/projects/my_projects_screen.dart';
import 'ui/screens/bidders/view_bidders_screen.dart';
import 'ui/screens/bids/my_bids_screen.dart';
import 'ui/screens/gigs/my_jobs_screen.dart';
import 'ui/screens/chat/chats_screen.dart';
import 'ui/screens/chat/recent_conversations_screen.dart';
import 'ui/screens/auth/authenticate_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case '/my-projects':
      return MaterialPageRoute(builder: (_) => const MyProjectsScreen());
    case '/view-bidders':
      final id = s.arguments as int;
      return MaterialPageRoute(builder: (_) => ViewBiddersScreen());//jobId: id(pass as an arg in viewBiddersScreen)
    case '/my-bids':
      return MaterialPageRoute(builder: (_) => const MyBidsScreen());
    case '/my-jobs':
      return MaterialPageRoute(builder: (_) => const MyJobsScreen());
    case '/messages':
      return MaterialPageRoute(builder: (_) => const RecentConversationsScreen());
    case '/chats':
      final uid = s.arguments as String? ?? '';
      return MaterialPageRoute(builder: (_) => ChatsScreen());//otherUid: uid (pass as an arg in ChatsScreen)
    case '/authenticate':
      return MaterialPageRoute(builder: (_) => const AuthenticateScreen());
    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
