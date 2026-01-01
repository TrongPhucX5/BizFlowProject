import 'package:flutter/material.dart';

class AddHourlyPriceScreen extends StatefulWidget {
  const AddHourlyPriceScreen({super.key});

  @override
  State<AddHourlyPriceScreen> createState() => _AddHourlyPriceScreenState();
}

class _AddHourlyPriceScreenState extends State<AddHourlyPriceScreen> {
  final Color kPrimaryGreen = const Color(0xff289ca7);

  final List<PriceGroup> _priceGroups = [
    PriceGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      selectedDays: [],
      timeSlots: [
        TimeSlot(startTime: "00:00", endTime: "23:59", price: 0),
      ],
    )
  ];

  // --- LOGIC CHỌN NGÀY ---
  void _showDaySelectionModal(PriceGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DaySelectionModal(
        initialSelection: group.selectedDays,
        onApply: (selectedDays) {
          setState(() {
            group.selectedDays = selectedDays;
          });
        },
      ),
    );
  }

  // --- LOGIC CHỌN GIỜ ---
  Future<void> _selectTime(TimeSlot slot, bool isStartTime) async {
    final currentTimeString = isStartTime ? slot.startTime : slot.endTime;
    final parts = currentTimeString.split(":");
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: kPrimaryGreen),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          slot.startTime = formattedTime;
        } else {
          slot.endTime = formattedTime;
        }
      });
    }
  }

  // --- LOGIC NHẬP GIÁ (Dialog) ---
  Future<void> _editPrice(TimeSlot slot) async {
    TextEditingController controller = TextEditingController(text: slot.price.toInt().toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nhập giá bán"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: "đ"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              setState(() {
                slot.price = double.tryParse(controller.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _addNewPriceGroup() {
    setState(() {
      _priceGroups.add(PriceGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        selectedDays: [],
        timeSlots: [TimeSlot(startTime: "00:00", endTime: "23:59", price: 0)],
      ));
    });
  }

  void _removePriceGroup(int index) {
    setState(() {
      _priceGroups.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thêm bảng giá theo khung giờ",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  ..._priceGroups.asMap().entries.map((entry) {
                    return _buildPriceGroupItem(entry.value, entry.key);
                  }),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _addNewPriceGroup,
                        icon: const Icon(Icons.add),
                        label: const Text("Thêm giá theo ngày khác"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2F80ED),
                          side: const BorderSide(color: Color(0xFF2F80ED)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black38),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text("Huỷ bảng giá", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Trả data về màn trước
                      Navigator.pop(context, _priceGroups);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceGroupItem(PriceGroup group, int index) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Theo thứ", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              if (_priceGroups.length > 1)
                InkWell(
                  onTap: () => _removePriceGroup(index),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                )
            ],
          ),
          GestureDetector(
            onTap: () => _showDaySelectionModal(group),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.selectedDays.isEmpty ? "Chọn ngày áp dụng" : group.selectedDays.join(", "),
                      style: TextStyle(
                          fontSize: 16, color: group.selectedDays.isEmpty ? Colors.black87 : Colors.black),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(flex: 2, child: _buildTableHeader("TỪ GIỜ *")),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildTableHeader("ĐẾN GIỜ *")),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: _buildTableHeader("GIÁ BÁN", alignRight: true)),
            ],
          ),
          const Divider(),
          ...group.timeSlots.asMap().entries.map((slotEntry) {
            int slotIdx = slotEntry.key;
            TimeSlot slot = slotEntry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _buildInputBox(
                          slot.startTime, () => _selectTime(slot, true),
                          icon: Icons.access_time)),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 2,
                      child: _buildInputBox(
                          slot.endTime, () => _selectTime(slot, false),
                          icon: Icons.access_time)),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 3,
                      child: _buildInputBox(
                          slot.price.toInt().toString(), () => _editPrice(slot),
                          alignRight: true)),
                  if (group.timeSlots.length > 1)
                    InkWell(
                      onTap: () {
                        setState(() => group.timeSlots.removeAt(slotIdx));
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                    )
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              setState(() {
                group.timeSlots.add(TimeSlot(startTime: "00:00", endTime: "23:59", price: 0));
              });
            },
            child: Row(
              children: const [
                Icon(Icons.add_circle_outline, color: Color(0xFF2F80ED), size: 20),
                SizedBox(width: 8),
                Text("Thêm khung giờ",
                    style: TextStyle(color: Color(0xFF2F80ED), fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {bool alignRight = false}) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  Widget _buildInputBox(String value, VoidCallback onTap, {IconData? icon, bool alignRight = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
          children: [
            if (alignRight) ...[
              Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15))),
            ] else ...[
              Text(value, style: const TextStyle(fontSize: 15)),
              if (icon != null) Icon(icon, size: 16, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }
}

// === Widget Modal Chọn Ngày ===
class _DaySelectionModal extends StatefulWidget {
  final List<String> initialSelection;
  final Function(List<String>) onApply;

  const _DaySelectionModal({required this.initialSelection, required this.onApply});

  @override
  State<_DaySelectionModal> createState() => _DaySelectionModalState();
}

class _DaySelectionModalState extends State<_DaySelectionModal> {
  final List<String> _daysOfWeek = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"];
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text("Ngày áp dụng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _daysOfWeek.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final day = _daysOfWeek[index];
                final isChecked = _selected.contains(day);
                return CheckboxListTile(
                  title: Text(day, style: const TextStyle(fontSize: 16)),
                  value: isChecked,
                  activeColor: Colors.green,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  onChanged: (bool? val) {
                    setState(() {
                      if (val == true) {
                        _selected.add(day);
                      } else {
                        _selected.remove(day);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_selected);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff289ca7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text("Áp dụng", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// === MODELS ===
class PriceGroup {
  String id;
  List<String> selectedDays;
  List<TimeSlot> timeSlots;
  PriceGroup({required this.id, required this.selectedDays, required this.timeSlots});
}

class TimeSlot {
  String startTime;
  String endTime;
  double price;
  TimeSlot({required this.startTime, required this.endTime, required this.price});
}