import 'package:flutter/material.dart';
import 'package:my_desktop_app/features/view/home/convert_page.dart';
import 'package:my_desktop_app/features/view/home/history_page.dart';
import 'package:my_desktop_app/features/view/home/merge_page.dart';
import 'package:my_desktop_app/features/view/home/settings_page.dart';
import 'package:my_desktop_app/features/view/home/split_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    ConvertPage(),
    MergeDetails(),
    SplitDetails(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Converter v1.0'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar
       Container(
  width: 260,
  padding: const EdgeInsets.symmetric(vertical: 16),
  color: Theme.of(context).colorScheme.secondary.withOpacity(0.06),
  child: Column(
    children: [
      _SidebarItem(
        icon: Icons.picture_as_pdf,
        label: 'Convert',
        selected: selectedIndex == 0,
        onTap: () => setState(() => selectedIndex = 0),
      ),
        _SidebarItem(
        icon: Icons.picture_as_pdf,
        label: 'Merge',
        selected: selectedIndex == 1,
        onTap: () => setState(() => selectedIndex = 1),
      ),
        _SidebarItem(
        icon: Icons.picture_as_pdf,
        label: 'Split',
        selected: selectedIndex == 2,
        onTap: () => setState(() => selectedIndex = 2),
      ),
      _SidebarItem(
        icon: Icons.history,
        label: 'History',
        selected: selectedIndex == 3,
        onTap: () => setState(() => selectedIndex = 3),
      ),
      _SidebarItem(
        icon: Icons.settings,
        label: 'Settings',
        selected: selectedIndex == 4,
        onTap: () => setState(() => selectedIndex = 4),
      ),
      

      const Spacer(),

      _SidebarItem(
        icon: Icons.help_outline,
        label: 'Help',
        selected: false,
        onTap: () {
        showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Help & Instructions'),
    content: SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _HelpSection(
            title: 'How to Convert Files',
            items: [
              'Choose a conversion type (PDF → Word, PDF → TXT, etc.)',
              'Select a file from your computer',
              'Click the Convert button to start conversion',
            ],
          ),

          SizedBox(height: 16),

          _HelpSection(
            title: 'Conversion History',
            items: [
              'All converted files will appear in the History tab',
              'You can reopen converted files from History',
              'Future updates will allow re-converting with one click',
            ],
          ),

          SizedBox(height: 16),

          _HelpSection(
            title: 'Themes & Settings',
            items: [
              'Switch between Light, Dark, and System themes',
              'Settings are applied instantly',
              'More customization options coming soon',
            ],
          ),

          SizedBox(height: 16),

        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);

        },
      ),
    ],
  ),
),


          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: pages[selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _HelpSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HelpSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
