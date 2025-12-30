import 'package:flutter/material.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Khách hàng', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.black), onPressed: () {}),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: TabBarSection(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 1, // Tạm thời để 1 khách hàng mẫu như hình
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person_outline, color: Colors.green),
            ),
            title: Text('Khách lẻ', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('0999988888'),
            trailing: Icon(Icons.monetization_on_outlined, color: Colors.green),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF3B66FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo khách hàng', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// Widget thanh chuyển đổi Khách hàng / Nhóm khách hàng
class TabBarSection extends StatelessWidget {
  const TabBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildTabItem("Khách hàng", true),
          _buildTabItem("Nhóm khách hàng", false),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isActive)
            Container(height: 2, color: Colors.green, width: double.infinity),
        ],
      ),
    );
  }
}