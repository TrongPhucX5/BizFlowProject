import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'message_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool showUnreadOnly = false;

  final List<MessageModel> messages = [
    MessageModel(
      id: "1",
      sender: "Hỗ trợ BizFlow",
      content: "Chúng tôi đã tiếp nhận yêu cầu của bạn.",
      time: DateTime.now(),
      category: "Support",
      unreadCount: 1,
    ),
    MessageModel(
      id: "2",
      sender: "Đơn hàng #1023",
      content: "Đơn hàng mới vừa được tạo.",
      time: DateTime.now().subtract(const Duration(hours: 2)),
      category: "Orders",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = showUnreadOnly
        ? messages.where((m) => !m.isRead).toList()
        : messages;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hộp thư", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildCategoryBar(),
          _buildFilterBar(),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xffF2F2F2)),
              itemBuilder: (context, index) {
                final msg = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.notifications, color: Colors.green),
                  ),
                  title: Text(
                    msg.sender,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    msg.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: msg.unreadCount > 0
                      ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      msg.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageDetailScreen(message: msg),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff446CF6),
        child: const Icon(Icons.edit),
        onPressed: () {},
      ),
    );
  }

  Widget _buildCategoryBar() {
    final items = [
      Icons.support_agent,
      Icons.smart_toy,
      Icons.notifications,
      Icons.receipt_long,
      Icons.account_balance_wallet,
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(items[index], color: Colors.green),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: const Text(
                        "1",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 6),
              const Text("Mục", style: TextStyle(fontSize: 12))
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text("Tất cả"),
            selected: !showUnreadOnly,
            onSelected: (_) => setState(() => showUnreadOnly = false),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Chưa đọc"),
            selected: showUnreadOnly,
            onSelected: (_) => setState(() => showUnreadOnly = true),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.done_all),
            label: const Text("Đọc tất cả"),
          )
        ],
      ),
    );
  }
}
