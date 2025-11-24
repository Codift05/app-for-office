import 'package:flutter/material.dart';

/// Development Screen - untuk testing semua screen tanpa login
/// Gunakan ini untuk development frontend saja
class DevNavigationScreen extends StatelessWidget {
  const DevNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ Development Navigation'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.black87),
                    SizedBox(height: 8),
                    Text(
                      'DEVELOPMENT MODE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Screen ini untuk testing frontend tanpa login.\nJangan gunakan di production!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Auth Screens
            _buildSection('Authentication Screens', Icons.login, Colors.blue, [
              _buildNavButton(context, 'Login Screen', '/login', Icons.login),
              _buildNavButton(
                context,
                'Sign Up Screen',
                '/signup',
                Icons.person_add,
              ),
            ]),

            const SizedBox(height: 16),

            // Employee Screens
            _buildSection('Employee Screens', Icons.badge, Colors.green, [
              _buildNavButton(
                context,
                'Employee Home',
                '/home_employee',
                Icons.home,
              ),
              _buildNavButton(
                context,
                'Create Report',
                '/create_report',
                Icons.add_circle,
              ),
              _buildNavButton(
                context,
                'All Reports',
                '/all_reports',
                Icons.list,
              ),
              _buildNavButton(
                context,
                'Create Request',
                '/create_request',
                Icons.request_page,
              ),
            ]),

            const SizedBox(height: 16),

            // Cleaner Screens
            _buildSection(
              'Cleaner Screens',
              Icons.cleaning_services,
              Colors.orange,
              [
                _buildNavButton(
                  context,
                  'Cleaner Home',
                  '/home_cleaner',
                  Icons.home,
                ),
                _buildNavButton(
                  context,
                  'My Tasks',
                  '/cleaner/my_tasks',
                  Icons.task,
                ),
                _buildNavButton(
                  context,
                  'Pending Reports',
                  '/cleaner/pending_reports',
                  Icons.pending,
                ),
                _buildNavButton(
                  context,
                  'Available Requests',
                  '/cleaner/available_requests',
                  Icons.work,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Admin Screens
            _buildSection(
              'Admin Screens',
              Icons.admin_panel_settings,
              Colors.red,
              [
                _buildNavButton(
                  context,
                  'Admin Dashboard',
                  '/home_admin',
                  Icons.dashboard,
                ),
                _buildNavButton(
                  context,
                  'Analytics',
                  '/analytics',
                  Icons.analytics,
                ),
                _buildNavButton(
                  context,
                  'Reports Management',
                  '/admin/reports_management',
                  Icons.assessment,
                ),
                _buildNavButton(
                  context,
                  'Requests Management',
                  '/admin/requests_management',
                  Icons.manage_search,
                ),
                _buildNavButton(
                  context,
                  'Cleaner Management',
                  '/admin/cleaner_management',
                  Icons.people,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Shared Screens
            _buildSection('Shared Screens', Icons.settings, Colors.purple, [
              _buildNavButton(context, 'Profile', '/profile', Icons.person),
              _buildNavButton(context, 'Settings', '/settings', Icons.settings),
              _buildNavButton(
                context,
                'Edit Profile',
                '/edit_profile',
                Icons.edit,
              ),
              _buildNavButton(
                context,
                'Change Password',
                '/change_password',
                Icons.lock,
              ),
              _buildNavButton(
                context,
                'Notifications',
                '/notifications',
                Icons.notifications,
              ),
            ]),

            const SizedBox(height: 16),

            // Inventory Screens
            _buildSection('Inventory Screens', Icons.inventory, Colors.teal, [
              _buildNavButton(
                context,
                'Inventory List',
                '/inventory',
                Icons.list_alt,
              ),
              _buildNavButton(
                context,
                'Inventory Dashboard',
                '/inventory/list',
                Icons.dashboard_customize,
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> buttons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: buttons),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String title,
    String route,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(
        route,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        try {
          Navigator.pushNamed(context, route);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      },
    );
  }
}
