import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class RecommendedFeedScreen extends StatelessWidget {
  const RecommendedFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter chips mock
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _Chip(label: 'All', isActive: true),
                  const SizedBox(width: 8),
                  _Chip(label: 'Grammar'),
                  const SizedBox(width: 8),
                  _Chip(label: 'Business'),
                  const SizedBox(width: 8),
                  _Chip(label: 'Daily Life'),
                ],
              ),
            ),
            
            // AI Pick content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                         Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)), child: const Text('AI PICK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                         const SizedBox(width: 8),
                         const Text('Based on your session yesterday', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Mastering Professional Greetings & Sign-offs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('In your last session, we noticed you were unsure about when to use "Kind Regards" vs "Best Wishes".', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Resume Lesson'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            
            // Recommended Section Header
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Recommended for You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                       Text('Curated daily to reach your C1 goal', style: TextStyle(fontSize: 12, color: Colors.grey)),
                     ],
                   ),
                 ],
               ),
            ),
            
            const SizedBox(height: 16),
            
            // Content Card Mock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => context.push('/recommended-content'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               children: [
                                 const Icon(Icons.description, size: 12, color: AppTheme.primary),
                                 const SizedBox(width: 4),
                                 Text('5 MIN READ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                               ],
                             ),
                             const SizedBox(height: 8),
                             const Text('We recommend today...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                             const Text('Top 3 news and blogs.', style: TextStyle(color: Colors.grey)),
                             const SizedBox(height: 16),
                             ElevatedButton(
                               onPressed: () => context.push('/recommended-content'),
                               style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, minimumSize: const Size(0, 32)),
                               child: const Text('Read Now'),
                             )
                           ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80, height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC2rSeFf5Ov4YwH0lLv6vItmeUHyFCC5g1pioMCd3XcQudZ2Mqvd8fPocBkSB3ATI2Xp59h7hAPHucpfOaHIfXCa8QZiCWAkJjEEyoGILS7CARwq044LI0r4nV3rn1FXAtkrFD7KQ1FeGI9BFYmSShMR8gb9fHpTfheLlfmkVBFeZyQhqyChHnDi7sSa8T4Fj6GwpoXqtrYG0UQBulpih7rGKOzzTKiOr0RLsuB5iSv8wYYPcUjPOIB7zXx1Mv4U3Eys9ZhDzpEzqAs'), fit: BoxFit.cover),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  
  const _Chip({required this.label, this.isActive = false});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
    );
  }
}
