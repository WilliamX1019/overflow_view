import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverflowView Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
      ),
      home: const ExpandableOverflowDemo(),
    );
  }
}

class ExpandableOverflowDemo extends StatefulWidget {
  const ExpandableOverflowDemo({super.key});

  @override
  State<ExpandableOverflowDemo> createState() => _ExpandableOverflowDemoState();
}

class _ExpandableOverflowDemoState extends State<ExpandableOverflowDemo> {
  // Toggle state to control expand/collapse
  bool _isExpanded = false;

  // Generate a list of sample data (e.g., user skills or tags)
  final List<String> _tags = [
    'Flutter AAAA',
    'Dart BBBBBBBBBBBBC',
    'Mobile Development',
    'iOS',
    'Android',
    'UI/UX Design',
    'Web Development',
    'React',
    'TypeScript',
    'JavaScript',
    'Node.js',
    'Python',
    'Machine Learning',
    'Firebase',
    'Cloud Computing',
    'Cloud Computing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OverflowView Demo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoCard(),
              const SizedBox(height: 40),
              const Text(
                'Resize the usage description or add more items\nto see the overflow in action.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.code,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Technical proficiency',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: Colors.red,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topLeft,
                  child: OverflowView.wrap(
                    // If collapsed, limit to 2 lines (maxRun: 2).
                    // If expanded, allow unlimited lines (maxRun: null).
                    maxRun: _isExpanded ? null : 3,
                    visibleFitRun: 3,
                    maxItemPerRun: null, // No limit per run
                    spacing: 8, // Horizontal spacing
                    runSpacing: 8, // Vertical spacing

                    // The widget to show when there is not enough space.
                    // Effectively the "More" button in constrained state.
                    overflowWidget: _buildOverflowButton(),

                    // The widget to show when the list is expanded but could be collapsed.
                    // Effectively the "Less" button.
                    unconstrainedOverflowWidget: _buildCollapseButton(),

                    children: _tags.map((tag) => _buildTagChip(tag)).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.transparent),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget shown when overflow occurs (Collapsed State)
  Widget _buildOverflowButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors
              .yellow, //Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View all',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }

  // Widget appended to the end of the list (Expanded State)
  Widget _buildCollapseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.yellow, // Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Show less',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 16,
              color: Colors.black87,
            )
          ],
        ),
      ),
    );
  }
}
