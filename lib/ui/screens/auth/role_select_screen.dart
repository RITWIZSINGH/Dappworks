// lib/ui/screens/auth/role_select_screen.dart
import 'package:flutter/material.dart';
import 'authenticate_screen.dart';
import '../../../data/models/user_type.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _go(BuildContext context, UserType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthenticateScreen(userType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // const Spacer(),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or Icon
                  // Container(
                  //   width: 80,
                  //   height: 80,
                  //   margin: const EdgeInsets.only(bottom: 32),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xff1c3c5b).withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: const Icon(
                  //     Icons.work_outline,
                  //     size: 40,
                  //     color: Color(0xff1c3c5b),
                  //   ),
                  // ),
                  const Text(
                    'FreelanceForge',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Geist",
                      color: Color(0xff1c3c5b),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose how you want to use the app.\nThis demo works completely offline using local storage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Geist",
                      color: const Color(0xff1c3c5b).withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Client Button
                  _RoleCard(
                    icon: Icons.business_center_outlined,
                    title: 'Client',
                    description: 'Post projects and hire freelancers',
                    onTap: () => _go(context, UserType.client),
                  ),
                  const SizedBox(height: 16),
                  // Freelancer Button
                  _RoleCard(
                    icon: Icons.person_outline,
                    title: 'Freelancer',
                    description: 'Browse projects and get hired',
                    onTap: () => _go(context, UserType.freelancer),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xff1c3c5b).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xff1c3c5b).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xff1c3c5b), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Geist",
                      color: Color(0xff1c3c5b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Geist",
                      color: const Color(0xff1c3c5b).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xff1c3c5b).withOpacity(0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
