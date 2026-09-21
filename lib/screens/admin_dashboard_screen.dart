import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

const Color kPrimary = Color(0xFF1A237E);
const Color kAccent = Color(0xFFF48FB1);
const Color kAccentDark = Color(0xFFC2185B);
const Color kSoftPink = Color(0xFFFCE4EC);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kAccent,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.home_work), text: 'القاعات'),
            Tab(icon: Icon(Icons.book_online), text: 'الحجوزات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HallsTab(service: _service),
          _BookingsTab(service: _service),
        ],
      ),
    );
  }
}

// ================= تبويب القاعات =================
class _HallsTab extends StatefulWidget {
  final FirebaseService service;
  const _HallsTab({required this.service});
  @override
  State<_HallsTab> createState() => _HallsTabState();
}

class _HallsTabState extends State<_HallsTab> {
  List<Map<String, dynamic>> _halls = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.service.getHalls();
    setState(() {
      _halls = data;
      _loading = false;
    });
  }

  void _openForm({Map<String, dynamic>? hall}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HallFormSheet(
        service: widget.service,
        hall: hall,
        onSaved: _load,
      ),
    );
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذه القاعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.service.deleteHall(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة قاعة',
            style: TextStyle(color: Colors.white)),
        onPressed: () => _openForm(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _halls.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('لا توجد قاعات بعد'),
                      SizedBox(height: 8),
                      Text('اضغط على زر الإضافة',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _halls.length,
                  itemBuilder: (_, i) {
                    final hall = _halls[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            hall['image'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: kSoftPink,
                              child: const Icon(Icons.home_work, color: kPrimary),
                            ),
                          ),
                        ),
                        title: Text(hall['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${hall['city']} • ${hall['price']} د.ل • ${hall['capacity']} شخص'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: kPrimary),
                              onPressed: () => _openForm(hall: hall),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(hall['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ================= نموذج إضافة/تعديل قاعة =================
class _HallFormSheet extends StatefulWidget {
  final FirebaseService service;
  final Map<String, dynamic>? hall;
  final VoidCallback onSaved;

  const _HallFormSheet({
    required this.service,
    this.hall,
    required this.onSaved,
  });

  @override
  State<_HallFormSheet> createState() => _HallFormSheetState();
}

class _HallFormSheetState extends State<_HallFormSheet> {
  late TextEditingController _name,
      _city,
      _price,
      _capacity,
      _image,
      _description;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.hall ?? {};
    _name = TextEditingController(text: h['name'] ?? '');
    _city = TextEditingController(text: h['city'] ?? '');
    _price = TextEditingController(text: h['price']?.toString() ?? '');
    _capacity = TextEditingController(text: h['capacity']?.toString() ?? '');
    _image = TextEditingController(text: h['image'] ?? '');
    _description = TextEditingController(text: h['description'] ?? '');
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _city.text.isEmpty || _price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء الحقول الأساسية')),
      );
      return;
    }
    setState(() => _saving = true);
    final data = {
      'name': _name.text,
      'city': _city.text,
      'price': double.tryParse(_price.text) ?? 0,
      'capacity': int.tryParse(_capacity.text) ?? 0,
      'image': _image.text,
      'description': _description.text,
    };

    bool ok;
    if (widget.hall == null) {
      ok = await widget.service.addHall(data);
    } else {
      ok = await widget.service.updateHall(widget.hall!['id'], data);
    }

    setState(() => _saving = false);

    if (ok) {
      widget.onSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحفظ بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل الحفظ، تحقق من الاتصال'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hall == null ? 'إضافة قاعة جديدة' : 'تعديل القاعة',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _field('اسم القاعة', _name, Icons.home_work),
            _field('المدينة', _city, Icons.location_city),
            _field('السعر (د.ل)', _price, Icons.attach_money,
                keyboard: TextInputType.number),
            _field('السعة (شخص)', _capacity, Icons.people,
                keyboard: TextInputType.number),
            _field('رابط الصورة', _image, Icons.image),
            _field('الوصف', _description, Icons.description, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, IconData icon,
      {TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent, width: 2)),
        ),
      ),
    );
  }
}

// ================= تبويب الحجوزات =================
class _BookingsTab extends StatefulWidget {
  final FirebaseService service;
  const _BookingsTab({required this.service});
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await widget.service.getBookings();
    setState(() {
      _bookings = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(Map<String, dynamic> booking, String status) async {
    final data = Map<String, dynamic>.from(booking);
    data.remove('id');
    data['status'] = status;
    await widget.service.updateBooking(booking['id'], data);
    _load();
  }

  Future<void> _delete(String id) async {
    await widget.service.deleteBooking(id);
    _load();
  }

  Color _statusColor(String? s) {
    if (s == 'مؤكد') return Colors.green;
    if (s == 'مرفوض') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('لا توجد حجوزات بعد'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _bookings.length,
                itemBuilder: (_, i) {
                  final b = _bookings[i];
                  final status = b['status'] ?? 'قيد المراجعة';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(b['customerName'] ?? 'بدون اسم',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(status,
                                    style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const Divider(),
                          _row('📞 الهاتف', b['customerPhone'] ?? '-'),
                          _row('🏛️ القاعة', b['hallName'] ?? '-'),
                          _row('📅 التاريخ', b['date'] ?? '-'),
                          _row('👥 الضيوف', b['guests']?.toString() ?? '-'),
                          _row('💰 المبلغ', '${b['total'] ?? 0} د.ل'),
                          _row('💳 الدفع', b['paymentMethod'] ?? '-'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green, size: 18),
                                  label: const Text('تأكيد',
                                      style: TextStyle(color: Colors.green)),
                                  onPressed: () =>
                                      _updateStatus(b, 'مؤكد'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red, size: 18),
                                  label: const Text('رفض',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () =>
                                      _updateStatus(b, 'مرفوض'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.grey),
                                onPressed: () => _delete(b['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
