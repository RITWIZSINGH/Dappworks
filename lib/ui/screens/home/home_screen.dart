// lib/ui/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_type.dart';
import '../../../data/models/job.dart';
import '../../../state/app_state.dart';
import '../bidders/view_bidders_screen.dart';
import '../chat/chat_screen.dart';
import '../job/job_detail_screen.dart';
import '../../widgets/create_job_sheet.dart';

class UserDashboardScreen extends StatefulWidget {
  final UserType userType;
  const UserDashboardScreen({super.key, required this.userType});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isClient = widget.userType == UserType.client;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isClient ? 'Client Dashboard' : 'Freelancer Dashboard',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Geist",
            color: Color(0xff1c3c5b),
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xff1c3c5b),
            ),
            onPressed: () {
              // Profile action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: isClient
            ? [_buildClientHome(), _buildProjectsView(), _buildMessagesView()]
            : [
                _buildFreelancerHome(),
                _buildBrowseView(),
                _buildMessagesView(),
              ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xff1c3c5b).withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff1c3c5b),
          unselectedItemColor: const Color(0xff1c3c5b).withOpacity(0.4),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: "Geist",
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontFamily: "Geist",
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: isClient
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_outline),
                    activeIcon: Icon(Icons.work),
                    label: 'Projects',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    activeIcon: Icon(Icons.message),
                    label: 'Messages',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'Browse',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    activeIcon: Icon(Icons.message),
                    label: 'Messages',
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildClientHome() {
    final app = context.watch<AppState>();
    final myJobs = app.jobs.where((j) => j.owner == app.account).toList();
    final activeJobs = myJobs.where((j) => j.listed && !j.paidOut).length;
    final totalSpent = myJobs.fold<double>(
      0.0,
      (sum, j) => sum + (j.paidOut ? double.tryParse(j.prizeEth) ?? 0 : 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatCard('Active Projects', '$activeJobs', Icons.work_outline),
          const SizedBox(height: 16),
          _buildStatCard(
            'Total Spent',
            '${totalSpent.toStringAsFixed(2)} ETH',
            Icons.currency_exchange,
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: "Geist",
              color: Color(0xff1c3c5b),
            ),
          ),
          const SizedBox(height: 16),
          if (myJobs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No projects yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Geist",
                    color: const Color(0xff1c3c5b).withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            ...myJobs
                .take(5)
                .map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJobCard(
                      job,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewBiddersScreen(jobId: job.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFreelancerHome() {
    final app = context.watch<AppState>();
    final myBids = app.jobs
        .where((j) => j.bidders.contains(app.account.toLowerCase()))
        .toList();
    final activeGigs = myBids
        .where((j) => j.freelancer == app.account && !j.paidOut)
        .length;
    final totalEarned = app.jobs.fold<double>(
      0.0,
      (sum, j) =>
          sum +
          (j.freelancer == app.account && j.paidOut
              ? double.tryParse(j.prizeEth) ?? 0
              : 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatCard('Active Gigs', '$activeGigs', Icons.work_outline),
          const SizedBox(height: 16),
          _buildStatCard(
            'Total Earned',
            '${totalEarned.toStringAsFixed(2)} ETH',
            Icons.currency_exchange_outlined,
          ),
          const SizedBox(height: 32),
          const Text(
            'My Bids',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: "Geist",
              color: Color(0xff1c3c5b),
            ),
          ),
          const SizedBox(height: 16),
          if (myBids.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No bids yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Geist",
                    color: const Color(0xff1c3c5b).withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            ...myBids
                .take(5)
                .map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJobCard(
                      job,
                      showAccepted: job.freelancer == app.account,
                      onTap: () {
                        if (job.freelancer == app.account) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                jobId: job.id,
                                otherUserName: 'Client',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProjectsView() {
    final app = context.watch<AppState>();
    final myJobs = app.jobs.where((j) => j.owner == app.account).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CreateJobSheet(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Post New Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1c3c5b),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: myJobs.isEmpty
              ? Center(
                  child: Text(
                    'No projects yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Geist",
                      color: const Color(0xff1c3c5b).withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: myJobs.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJobCard(
                      myJobs[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ViewBiddersScreen(jobId: myJobs[i].id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBrowseView() {
    final app = context.watch<AppState>();
    final availableJobs = app.jobs
        .where(
          (j) =>
              j.listed &&
              j.freelancer == '0x0000000000000000000000000000000000000000',
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff1c3c5b).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xff1c3c5b).withOpacity(0.15),
                width: 1,
              ),
            ),
            child: TextField(
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Geist",
                color: Color(0xff1c3c5b),
              ),
              decoration: InputDecoration(
                hintText: 'Search projects...',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: "Geist",
                  color: const Color(0xff1c3c5b).withOpacity(0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xff1c3c5b).withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: availableJobs.isEmpty
              ? Center(
                  child: Text(
                    'No projects available',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Geist",
                      color: const Color(0xff1c3c5b).withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: availableJobs.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildJobCard(
                      availableJobs[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                JobDetailScreen(job: availableJobs[i]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMessagesView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildMessageCard(
          'John Doe',
          'Hey, how\'s the project going?',
          '2h ago',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ChatScreen(jobId: 1, otherUserName: 'John Doe'),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMessageCard(
          'Sarah Smith',
          'Thanks for the update!',
          '5h ago',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ChatScreen(jobId: 2, otherUserName: 'Sarah Smith'),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMessageCard(
          'Mike Johnson',
          'Can we schedule a call?',
          '1d ago',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ChatScreen(jobId: 3, otherUserName: 'Mike Johnson'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1c3c5b).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xff1c3c5b).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff1c3c5b).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff1c3c5b), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Geist",
                  color: const Color(0xff1c3c5b).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Geist",
                  color: Color(0xff1c3c5b),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    Job job, {
    VoidCallback? onTap,
    bool showAccepted = false,
  }) {
    String status = 'Open';
    if (job.paidOut) {
      status = 'Completed';
    } else if (job.freelancer != '0x0000000000000000000000000000000000000000') {
      status = 'In Progress';
    } else if (job.bidders.isNotEmpty) {
      status = '${job.bidders.length} Bids';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xff1c3c5b).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.jobTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Geist",
                      color: Color(0xff1c3c5b),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: showAccepted
                        ? Colors.green.withOpacity(0.15)
                        : const Color(0xff1c3c5b).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    showAccepted ? 'Accepted' : status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Geist",
                      color: showAccepted
                          ? Colors.green.shade700
                          : const Color(0xff1c3c5b),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.currency_exchange_outlined,
                  size: 16,
                  color: const Color(0xff1c3c5b).withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${job.prizeEth} ETH',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Geist",
                    color: const Color(0xff1c3c5b).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    String name,
    String message,
    String time,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xff1c3c5b).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xff1c3c5b).withOpacity(0.1),
              child: Text(
                name[0],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "Geist",
                  color: Color(0xff1c3c5b),
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Geist",
                          color: Color(0xff1c3c5b),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Geist",
                          color: const Color(0xff1c3c5b).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Geist",
                      color: const Color(0xff1c3c5b).withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
