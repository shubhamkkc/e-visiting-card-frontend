import 'package:flutter/material.dart';
import '../widgets/section_title.dart';
import '../services/api_client.dart';

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({super.key});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final _api = ApiClient();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _feedbacks = [];

  int selectedRating = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.fetchFeedbacks(); // optionally: fetchFeedbacks(slug: ...)
      // Normalize for UI
      final mapped = list.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final createdAt = (m['createdAt'] ?? m['date'] ?? '').toString();
        return {
          'name': (m['name'] ?? '').toString(),
          'rating': (m['rating'] as num?)?.toInt() ?? 0,
          'comment': (m['comment'] ?? '').toString(),
          'date': _formatDate(createdAt),
        };
      }).toList();
      setState(() {
        _feedbacks = mapped;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String s) {
    try {
      final dt = DateTime.tryParse(s);
      if (dt == null) return s.isEmpty ? '' : s;
      final d = dt.toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return s;
    }
  }

  Future<void> _submit() async {
    if (selectedRating == 0 ||
        nameController.text.trim().isEmpty ||
        commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a rating.')),
      );
      return;
    }
    try {
      // Send to API
      await _api.sendFeedback(
        name: nameController.text.trim(),
        rating: selectedRating,
        comment: commentController.text.trim(),
      );
      // Clear inputs
      setState(() {
        selectedRating = 0;
        nameController.clear();
        commentController.clear();
      });
      // Refresh list
      await _loadFeedbacks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send feedback: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Feedbacks'),
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Failed to load: $_error', style: const TextStyle(color: Colors.red)),
            )
          else if (_feedbacks.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('No feedback yet. Be the first!'),
            )
          else
            ..._feedbacks.map((fb) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFFDEDE3), width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            fb['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Spacer(),
                          Text(
                            fb['date'],
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (fb['rating'] as int) ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(fb['comment'], style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                )),

          const SizedBox(height: 12),

          // Submit form
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDE3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Give Feedback',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                // Star rating
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        i < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 28,
                      ),
                      onPressed: () => setState(() => selectedRating = i + 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                if (selectedRating == 0)
                  const Padding(
                    padding: EdgeInsets.only(left: 2, bottom: 8),
                    child: Text('Select a Rating', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                const SizedBox(height: 8),
                // Name field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Full Name',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Feedback field
                TextField(
                  controller: commentController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _submit,
                    child: const Text('Give Feedback'),
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
