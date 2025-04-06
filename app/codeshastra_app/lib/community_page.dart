import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Post {
  final String userName;
  final String content;
  final String? link;
  final DateTime timestamp;

  Post({
    required this.userName,
    required this.content,
    this.link,
    required this.timestamp,
  });
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final List<Post> _posts = [];

  // App theme colors
  static const Color primaryColor = Color(0xFF6B4EFF);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF2D2D2D);

  void _addPost() {
    if (_postController.text.isNotEmpty) {
      setState(() {
        _posts.insert(
          0,
          Post(
            userName: 'User', // Hardcoded for now
            content: _postController.text,
            link: _linkController.text.isEmpty ? null : _linkController.text,
            timestamp: DateTime.now(),
          ),
        );
      });
      _postController.clear();
      _linkController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    // Add default post
    _posts.add(
      Post(
        userName: 'Admin',
        content:
            'Welcome to our community! 👋\nShare your projects, ideas, and collaborate with others. Feel free to post your GitHub links and discuss your work.',
        link: 'https://github.com/example/project',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryColorDark,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report a Bug',
          style: TextStyle(color: theme.primaryColor),
        ),
        backgroundColor: theme.primaryColorDark,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _posts.isEmpty
                    ? Center(
                      child: Text(
                        'No posts yet. Be the first to share!',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        post.userName[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          post.timestamp.toString().split(
                                            '.',
                                          )[0],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(post.content),
                                if (post.link != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: InkWell(
                                      onTap: () async {
                                        final url = Uri.parse(
                                          'https://example.com',
                                        ); // your URL here

                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          // You can also show a Snackbar or alert here
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text(
                                        post.link!,
                                        style: TextStyle(
                                          color: primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    hintText: 'Share something with the community...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.primaryColor,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    hintText: 'Add a link (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
