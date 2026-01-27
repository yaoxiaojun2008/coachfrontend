import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../providers.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/responsive_layout.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showProfileMenu = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final session = ref.watch(sessionProvider);

    return ResponsiveLayout(
      currentRoute: '/',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                         if (session != null) {
                           setState(() => _showProfileMenu = !_showProfileMenu);
                         } else {
                           context.push('/auth');
                         }
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: (user.avatar.isNotEmpty && user.avatar.startsWith('http')) 
                            ? NetworkImage(user.avatar) 
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: (user.avatar.isEmpty || !user.avatar.startsWith('http'))
                            ? const Icon(Icons.person, color: Colors.grey)
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primary, width: 2),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user.name}!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.level,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '12',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Profile Dropdown (Simple overlay implementation)
          if (_showProfileMenu && session != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                         if(user.email != null) Text(user.email!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                       ]
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () {
                       ref.read(authServiceProvider).signOut();
                       setState(() => _showProfileMenu = false);
                    },
                  )
                ],
              ),
            ),

          const SizedBox(height: 16),

          // For You Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('For You', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/recommended-feed'),
                  child: const Text('Explore more'),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => context.push('/recommended-content'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/cards/article-background.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,4))],
                    ),
                    child: Stack(
                      children: [
                         Positioned(
                           top: 12, left: 12,
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                             decoration: BoxDecoration(
                               color: Colors.black.withOpacity(0.6),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: const Row(
                               children: [
                                 Icon(Icons.description, color: Colors.white, size: 16),
                                 SizedBox(width: 4),
                                 Text('ARTICLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                               ],
                             ),
                           ),
                         ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Exploring news and blogs today',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('8 min read • Vocabulary', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _StatCard(title: 'Daily Goal', icon: Icons.track_changes, value: '85%', subValue: '+5%', subColor: const Color(0xFF0BDA5E), progress: 0.85)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'New Words', icon: Icons.menu_book, value: '24', subValue: '/ 30', subColor: AppTheme.primary, progress: 0.7)),
              ],
            ),
          ),

           const SizedBox(height: 24),

          // Main Tutors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Main Tutors', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _TutorCard(
                  title: 'Writing Coach',
                  description: 'Improve grammar and style with real-time AI feedback.',
                  icon: Icons.edit_note,
                  bgImage: 'assets/images/tutors/writing-coach-bg.jpg',
                  onStart: () => context.push('/writing-coach'),
                  onHistory: () => context.push('/writing-history'),
                  buttonText: 'Start Writing',
                ),
                const SizedBox(height: 16),
                _TutorCard(
                  title: 'Reading Coach',
                  description: 'Practice comprehension with smart interactive quizzes.',
                  icon: Icons.auto_stories,
                  bgImage: 'assets/images/tutors/reading-coach-bg.jpg',
                  onStart: () => context.push('/reading-coach'),
                  onHistory: () => context.push('/history'),
                  buttonText: 'Take Quiz',
                ),
                const SizedBox(height: 16),
                // Live AI Tutor Card
                 Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                       BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.forum, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Live AI Tutor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text(
                                'Speak with your AI anytime.',
                                style: TextStyle(color: Colors.blue.shade100, fontSize: 12),
                              )
                            ],
                          ),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.graphic_eq, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Start Conversation', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String subValue;
  final Color subColor;
  final double progress;

  const _StatCard({required this.title, required this.icon, required this.value, required this.subValue, required this.subColor, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Icon(icon, size: 16, color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(subValue, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: AppTheme.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String bgImage;
  final VoidCallback onStart;
  final VoidCallback onHistory;
  final String buttonText;

  const _TutorCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.bgImage,
    required this.onStart,
    required this.onHistory,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   children: [
                     Icon(icon, color: AppTheme.primary),
                     const SizedBox(width: 8),
                     Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   ],
                 ),
                 const SizedBox(height: 4),
                 Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                 const SizedBox(height: 12),
                 Row(
                   children: [
                     ElevatedButton(
                       onPressed: onStart,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppTheme.primary,
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                         minimumSize: const Size(0, 36),
                       ),
                       child: Text(buttonText),
                     ),
                     const SizedBox(width: 8),
                     Container(
                       width: 36, height: 36,
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: IconButton(
                         icon: const Icon(Icons.history, size: 20, color: Colors.grey),
                         onPressed: onHistory,
                         padding: EdgeInsets.zero,
                       ),
                     )
                   ],
                 ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(bgImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
