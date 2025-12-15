import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostViewScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostViewScreen({super.key, required this.post});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  final TextEditingController _commentController = TextEditingController();

  // Mock Comments Data
  final List<Map<String, dynamic>> _comments = [
    {
      "author": "Sarah M.",
      "text":
          "Hey, can you mention what you're ensuring to make it work so well together?",
      "time": "22h ago",
      "likes": 3,
      "replies": [
        {
          "author": "Sarah M.",
          "text": "Wow! A sleep training success!",
          "time": "2h ago",
          "likes": 4,
        },
      ],
    },
    {
      "author": "Jessica K.",
      "text":
          "This is exactly what I needed to hear today. Thanks for sharing!",
      "time": "5h ago",
      "likes": 12,
      "replies": [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Post Detail",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2623),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF1E2623),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            // Reduced bottom padding slightly to compact vertical space
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // Reduced from 10
                // --- Post Image (Updated with Border & Radius) ---
                Container(
                  height:
                      MediaQuery.of(context).size.height *
                      0.25, // Responsive height for compactness
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    // Increased radius for smoother look
                    borderRadius: BorderRadius.circular(24),
                    // Added subtle border
                    border: Border.all(
                      color: const Color(0xFFF0F0F0),
                      width: 1.5,
                    ),
                    image: DecorationImage(
                      image: AssetImage(
                        widget.post['image'] ?? 'assets/images/family.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Post Title ---
                Text(
                  widget.post['title'] ?? "Post Title",
                  style: GoogleFonts.poppins(
                    fontSize: 20, // Slightly more compact font size
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2623),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 10
                // --- Author Row ---
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: const AssetImage(
                        'assets/images/men.png',
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.post['author'] ?? "Unknown",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E2623),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduced from 12 to compact
                // --- Description ---
                Text(
                  "Sleep training success! is specifically waiting testimony it comes intending to liberate and change sleep training in near our deni meet san bewimaled monthly sleep training in ston wais even some time.",
                  style: GoogleFonts.poppins(
                    fontSize: 13, // Reduced font size
                    color: const Color(0xFF5A5A5A),
                    height: 1.3, // Reduced line height
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 24
                // --- Comments Section Header ---
                Text(
                  "Comments",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2623),
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 16
                // --- Comments List ---
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildCommentThread(_comments[index]);
                  },
                ),
              ],
            ),
          ),

          // --- Bottom Floating Button ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.0), Colors.white],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Open comment input modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DAE96), // Muted green
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Add Comment",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a main comment and its replies (Threaded View)
  Widget _buildCommentThread(Map<String, dynamic> comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Comment
        _buildSingleComment(comment, isReply: false),

        // Replies (if any)
        if (comment['replies'] != null &&
            (comment['replies'] as List).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 40),
            child: _buildSingleComment(comment['replies'][0], isReply: true),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleComment(
    Map<String, dynamic> data, {
    required bool isReply,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: isReply ? 16 : 20,
          backgroundImage: const AssetImage('assets/images/men.png'),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(width: 12),

        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    data['author'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E2623),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                data['text'],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF1E2623),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),

              // Metadata Row (Time, Reply, Likes)
              Row(
                children: [
                  Text(
                    data['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Reply",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E2623),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${data['likes']}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReplyConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Removed as per request because UI line handling is sufficient
    // final paint = Paint()
    //   ..color = const Color(0xFFE0E0E0)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 2;

    // // Adjusted Curve for tighter vertical spacing
    // final path2 = Path();
    // path2.moveTo(20, -20); // Start higher to catch the line
    // path2.lineTo(20, 15); // Go down

    // // Curve right
    // path2.arcToPoint(
    //   const Offset(35, 30),
    //   radius: const Radius.circular(15),
    //   clockwise: false,
    // );

    // canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
