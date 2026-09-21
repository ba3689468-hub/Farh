import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const ClientApp());
}

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرح - لأصحاب القاعات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimary,
        scaffoldBackgroundColor: kBackground,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          secondary: kAccent,
        ),
      ),
      home: const ClientLoginScreen(),
    );
  }
}

final _service = FirebaseService();

// ================= شاشة تسجيل الدخول =================
class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});
  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    if (_phone.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الرقم وكلمة المرور')),
      );
      return;
    }
    setState(() => loading = true);
    final client = await _service.findClientByPhone(_phone.text.trim());
    setState(() => loading = false);

    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد حساب بهذا الرقم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (client['password'] != _pass.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDashboardScreen(
          clientId: client['id'],
          clientName: client['name'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.home_work, size: 80, color: kPrimary),
              const SizedBox(height: 20),
              const Text('دخول صاحب القاعة',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: const Icon(Icons.phone, color: kPrimary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock, color: kPrimary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: loading ? null : _login,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('دخول',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ClientRegisterScreen()),
                ),
                child: const Text('ليس لديك حساب؟ سجّل الآن',
                    style: TextStyle(color: kAccentDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= شاشة التسجيل =================
class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});
  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  Future<void> _register() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }
    setState(() => loading = true);

    final existing = await _service.findClientByPhone(_phone.text.trim());
    if (existing != null) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا الرقم مسجّل مسبقاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ok = await _service.addClient({
      'name': _name.text,
      'phone': _phone.text.trim(),
      'password': _pass.text,
    });
    setState(() => loading = false);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التسجيل بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل التسجيل'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل صاحب قاعة'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person, color: kPrimary),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone, color: kPrimary),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock, color: kPrimary),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: loading ? null : _register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تسجيل',
                        style: TextStyle(
                            fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= لوحة تحكم صاحب القاعة =================
class ClientDashboardScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  const ClientDashboardScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _halls = [];
  List<Map<String, dynamic>> _bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final allHalls = await _service.getHalls();
    final allBookings = await _service.getBookings();
    setState(() {
      _halls = allHalls.where((h) => h['clientId'] == widget.clientId).toList();
      _bookings = allBookings
          .where((b) => b['clientId'] == widget.clientId)
          .toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${widget.clientName}'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const ClientLoginScreen()),
              (_) => false,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: kAccent,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.home_work), text: 'قاعاتي'),
            Tab(icon: Icon(Icons.book_online), text: 'الحجوزات'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _HallsTab(
                  halls: _halls,
                  clientId: widget.clientId,
                  onRefresh: _load,
                ),
                _BookingsTab(bookings: _bookings, onRefresh: _load),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة قاعة',
            style: TextStyle(color: Colors.white)),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _HallForm(
            clientId: widget.clientId,
            onSaved: _load,
          ),
        ),
      ),
    );
  }
}

// ================= تبويب القاعات =================
class _HallsTab extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final String clientId;
  final VoidCallback onRefresh;

  const _HallsTab({
    required this.halls,
    required this.clientId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (halls.isEmpty) {
      return const Center(
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
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: halls.length,
      itemBuilder: (_, i) {
        final h = halls[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                h['image'] ?? '',
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
            title: Text(h['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text('${h['city']} • ${h['price']} د.ل • ${h['capacity']} شخص'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: kPrimary),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => _HallForm(
                      clientId: clientId,
                      hall: h,
                      onSaved: onRefresh,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content:
                            const Text('هل تريد حذف هذه القاعة؟'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('إلغاء')),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('حذف',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _service.deleteHall(h['id']);
                      onRefresh();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= نموذج إضافة/تعديل قاعة =================
class _HallForm extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic>? hall;
  final VoidCallback onSaved;

  const _HallForm({
    required this.clientId,
    this.hall,
    required this.onSaved,
  });

  @override
  State<_HallForm> createState() => _HallFormState();
}

class _HallFormState extends State<_HallForm> {
  late TextEditingController _name, _city, _price, _capacity, _image, _desc;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.hall ?? {};
    _name = TextEditingController(text: h['name'] ?? '');
    _city = TextEditingController(text: h['city'] ?? '');
    _price = TextEditingController(text: h['price']?.toString() ?? '');
    _capacity = TextEditingController(text: h['capacity']?.toString() ?? '');
    _image = TextEditingController(text: h['image'] ?? '');
    _desc = TextEditingController(text: h['description'] ?? '');
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _city.text.isEmpty || _price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء الحقول الأساسية')),
      );
      return;
    }
    setState(() => saving = true);
    final data = {
      'name': _name.text,
      'city': _city.text,
      'price': double.tryParse(_price.text) ?? 0,
      'capacity': int.tryParse(_capacity.text) ?? 0,
      'image': _image.text,
      'description': _desc.text,
      'clientId': widget.clientId,
    };

    bool ok;
    if (widget.hall == null) {
      ok = await _service.addHall(data);
    } else {
      ok = await _service.updateHall(widget.hall!['id'], data);
    }
    setState(() => saving = false);

    if (ok) {
      widget.onSaved();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحفظ'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل الحفظ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hall == null ? 'إضافة قاعة' : 'تعديل القاعة',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _f('اسم القاعة', _name, Icons.home_work),
            _f('المدينة', _city, Icons.location_city),
            _f('السعر (د.ل)', _price, Icons.attach_money,
                keyboard: TextInputType.number),
            _f('السعة (شخص)', _capacity, Icons.people,
                keyboard: TextInputType.number),
            _f('رابط الصورة', _image, Icons.image),
            _f('الوصف', _desc, Icons.description, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                onPressed: saving ? null : _save,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ',
                        style: TextStyle(
                            fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(String label, TextEditingController c, IconData icon,
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
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ================= تبويب الحجوزات =================
class _BookingsTab extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onRefresh;

  const _BookingsTab({required this.bookings, required this.onRefresh});

  Color _statusColor(String? s) {
    if (s == 'مؤكد') return Colors.green;
    if (s == 'مرفوض') return Colors.red;
    return Colors.orange;
  }

  Future<void> _update(Map<String, dynamic> b, String status) async {
    final data = Map<String, dynamic>.from(b);
    data.remove('id');
    data['status'] = status;
    await _service.updateBooking(b['id'], data);
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text('لا توجد حجوزات بعد'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (_, i) {
        final b = bookings[i];
        final status = b['status'] ?? 'قيد المراجعة';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(b['customerName'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                _r('📞', b['customerPhone'] ?? '-'),
                _r('🏛️', b['hallName'] ?? '-'),
                _r('📅', b['date'] ?? '-'),
                _r('👥', b['guests']?.toString() ?? '-'),
                _r('💰', '${b['total'] ?? 0} د.ل'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.check,
                            color: Colors.green, size: 18),
                        label: const Text('تأكيد',
                            style: TextStyle(color: Colors.green)),
                        onPressed: () => _update(b, 'مؤكد'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 18),
                        label: const Text('رفض',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () => _update(b, 'مرفوض'),
                      ),
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

  Widget _r(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
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
