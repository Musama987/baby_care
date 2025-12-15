import 'package:baby_care/screens/navbar/community/widgets/create_post.dart';
import 'package:baby_care/screens/navbar/community/widgets/post_view.dart';
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Mock Data for Community Posts
  final List<Map<String, dynamic>> _posts = [
    {
      "title": "Best Stroller for City Living?",
      "author": "Sarah M.",
      "likes": 8,
      "image": "assets/images/family.png", // Using existing asset
    },
    {
      "title": "Sleep Training Success!",
      "author": "Emily R.",
      "likes": 12,
      "image": "assets/images/growthh.png", // Using existing asset
    },
    {
      "title": "Healthy snacks for toddlers",
      "author": "Jessica K.",
      "likes": 24,
      "image": "assets/images/men.png", // Using existing asset
    },
    {
      "title": "Postpartum recovery tips",
      "author": "Dr. Smith",
      "likes": 156,
      "image": "assets/images/family.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),

      // Floating Action Button (Bottom Right)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Post Screen without the Bottom Nav Bar
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: const CreatePostScreen(),
            withNavBar: false, // Hides the navbar
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              const SizedBox(height: 10),
              Text(
                "Community",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
              const SizedBox(height: 20),

              // --- Grid of Posts ---
              Expanded(
                child: GridView.builder(
                  itemCount: _posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 Columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7, // Makes cards taller
                  ),
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return _buildPostCard(post);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: PostViewScreen(post: post),
          withNavBar:
              true, // User requested persistent, keeping navbar visible is often preferred unless full screen modal
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  post['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      post['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E2623),
                        height: 1.2,
                      ),
                    ),

                    // Author and Likes Row
                    Row(
                      children: [
                        // Small Avatar
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: const AssetImage(
                            'assets/images/men.png',
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Author Name
                        Expanded(
                          child: Text(
                            post['author'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                        // Like Icon & Count
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${post['likes']}",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
