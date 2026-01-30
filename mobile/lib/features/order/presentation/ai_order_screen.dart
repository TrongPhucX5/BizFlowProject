import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/data/repositories/ai_repository.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:intl/intl.dart';

class AiOrderScreen extends StatefulWidget {
  const AiOrderScreen({super.key});

  @override
  State<AiOrderScreen> createState() => _AiOrderScreenState();
}

class _AiOrderScreenState extends State<AiOrderScreen> {
  final AiRepository _aiRepository = AiRepository();
  final AuthRepository _authRepository = AuthRepository();
  
  final TextEditingController _inputController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _selectedCustomer;
  
  bool _isAnalyzing = false;
  bool _isListening = false;
  String _botReply = "Chào bạn! Tôi là trợ lý BizFlow AI. Bạn muốn lên đơn hàng gì cho hôm nay?";
  List<Map<String, dynamic>> _draftItems = [];
  double _totalAmount = 0;
  String? _lastOrderNum;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final data = await _authRepository.getCustomers();
      setState(() => _customers = data);
    } catch (e) {
      debugPrint("Lỗi tải khách hàng: $e");
    }
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
        if (!status.isGranted) return;
      }

      bool available = await _speech.initialize(
        onError: (val) => debugPrint('Error: $val'),
        onStatus: (val) => debugPrint('Status: $val'),
      );
      
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _inputController.text = val.recognizedWords;
              if (val.finalResult) {
                _isListening = false;
                _analyzeText();
              }
            });
          },
          localeId: 'vi_VN',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _analyzeText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _lastOrderNum = null;
    });

    try {
      final result = await _aiRepository.chatWithAI(text);
      
      final String reply = result['reply'] ?? "Tôi không rõ ý bạn lắm.";
      final bool isOrder = result['is_order'] ?? false;
      final Map<String, dynamic>? data = result['data'];
      
      List<Map<String, dynamic>> items = [];
      double total = 0;
      Map<String, dynamic>? matchedCustomer;

      if (isOrder && data != null) {
        final aiCustomerName = data['customerName']?.toString().toLowerCase();
        if (aiCustomerName != null) {
          matchedCustomer = _customers.firstWhere(
            (c) => c['fullName'].toString().toLowerCase().contains(aiCustomerName),
            orElse: () => _customers.isNotEmpty ? _customers.first : {},
          );
        }

        final List aiItems = data['items'] ?? [];
        items = List<Map<String, dynamic>>.from(aiItems);
        
        for (var item in items) {
          total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
        }
      }

      setState(() {
        _botReply = reply;
        _draftItems = items;
        _totalAmount = total;
        if (matchedCustomer != null && matchedCustomer.isNotEmpty) _selectedCustomer = matchedCustomer;
        
        final orderMatch = RegExp(r'ORD-\d+-\d+').firstMatch(reply);
        if (orderMatch != null) {
          _lastOrderNum = orderMatch.group(0);
        }
      });

      _inputController.clear();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString().replaceAll("Exception: ", "")}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Trợ lý AI BizFlow", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_lastOrderNum != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_circle, color: Colors.green),
                label: const Text("Xong", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBotMessage(),
                if (_draftItems.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildOrderPreview(currencyFormat),
                ],
              ],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBotMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Text(
                  _botReply,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.4),
                ),
              ),
              const SizedBox(height: 4),
              const Text("Vừa xong", style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderPreview(NumberFormat currencyFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                const Text("Chi tiết đơn đã lên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (_lastOrderNum != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text("ĐÃ LƯU", style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _draftItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 50),
            itemBuilder: (context, index) {
              final item = _draftItems[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Text("${index + 1}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
                title: Text(item['productName'] ?? 'Sản phẩm', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text("Số lượng: ${item['quantity'] ?? 0}"),
                trailing: Text("${currencyFormat.format((item['price'] ?? 0) * (item['quantity'] ?? 0))} đ", style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG TIỀN:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text("${currencyFormat.format(_totalAmount)} đ", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          if (_lastOrderNum != null)
             Padding(
               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
               child: Text(
                 "Mã đơn hàng: $_lastOrderNum",
                 style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
               ),
             )
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _listen,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red.withOpacity(0.1) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none_rounded,
                color: _isListening ? Colors.red : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: "Nhập hoặc nói yêu cầu...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      ),
                      onSubmitted: (_) => _analyzeText(),
                    ),
                  ),
                  if (_isAnalyzing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF6366F1)),
                      onPressed: _analyzeText,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
