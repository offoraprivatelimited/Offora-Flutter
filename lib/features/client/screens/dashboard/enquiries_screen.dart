import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  final darkBlue = const Color(0xFF1F477D);
  final brightGold = const Color(0xFFF0B84D);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.question_answer_outlined,
                    size: 64, color: darkBlue.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Enquiries - Coming Soon',
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We are working on real-time customer enquiries. This feature will appear here soon.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Enquiry {
  final String id;
  final String customerName;
  final String offerTitle;
  final String message;
  final DateTime timestamp;
  bool isRead;

  _Enquiry({
    required this.id,
    required this.customerName,
    required this.offerTitle,
    required this.message,
    required this.timestamp,
    // ignore: unused_element_parameter
    this.isRead = false,
  });
}

// ignore: unused_element
class _EnquiryCard extends StatelessWidget {
  final _Enquiry enquiry;
  final Color darkBlue;
  final Color brightGold;
  final VoidCallback onTap;

  const _EnquiryCard({
    required this.enquiry,
    required this.darkBlue,
    required this.brightGold,
    required this.onTap,
  });

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(dt);
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            enquiry.isRead ? Colors.white : brightGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enquiry.isRead
              ? Colors.grey.shade200
              : brightGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          if (!enquiry.isRead)
            BoxShadow(
              color: brightGold.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: darkBlue.withValues(alpha: 0.1),
                child: Text(
                  enquiry.customerName[0].toUpperCase(),
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            enquiry.customerName,
                            style: TextStyle(
                              color: darkBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!enquiry.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: brightGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enquiry.offerTitle,
                      style: TextStyle(
                        color: brightGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      enquiry.message,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(enquiry.timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnquiryDetailSheet extends StatefulWidget {
  final _Enquiry enquiry;
  final Color darkBlue;
  final Color brightGold;

  const _EnquiryDetailSheet({
    required this.enquiry,
    required this.darkBlue,
    required this.brightGold,
  });

  @override
  State<_EnquiryDetailSheet> createState() => _EnquiryDetailSheetState();
}

class _EnquiryDetailSheetState extends State<_EnquiryDetailSheet> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    if (_replyController.text.trim().isEmpty) return;

    // Note: Reply functionality to be implemented with Firebase messaging
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply sent successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              widget.darkBlue.withValues(alpha: 0.1),
                          child: Text(
                            widget.enquiry.customerName[0].toUpperCase(),
                            style: TextStyle(
                              color: widget.darkBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.enquiry.customerName,
                                style: TextStyle(
                                  color: widget.darkBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a')
                                    .format(widget.enquiry.timestamp),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.brightGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.brightGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer,
                                  color: widget.brightGold, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.enquiry.offerTitle,
                                  style: TextStyle(
                                    color: widget.darkBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Message',
                      style: TextStyle(
                        color: widget.darkBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.enquiry.message,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Reply',
                      style: TextStyle(
                        color: widget.darkBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _replyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type your reply here...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: widget.darkBlue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _sendReply,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Send Reply',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.brightGold,
                          foregroundColor: widget.darkBlue,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
