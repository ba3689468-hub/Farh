import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const ClientApp());
}

final _service = FirebaseService();

// ================= Global Session =================
class ClientSession {
  static Map<String, dynamic>? current;
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

// ================= شاشة الدخول =================
class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});
  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;
  bool obscure = true;

  Future<void> _login() async {
    if (_phone.text.isEmpty || _pass.text.isEmpty) {
      _snack('الرجاء إدخال الرقم وكلمة المرور');
      return;
    }
    setState(() => loading = true);
    final all = await _service.getCollection('clients');
    setState(() => loading = false);

    Map<String, dynamic>? client;
    try {
      client = all.firstWhere((c) => c['phone'] == _phone.text.trim());
    } catch (_) {
      client = null;
    }

    if (client == null) {
      _snack('لا يوجد حساب بهذا الرقم', red: true);
      return;
    }
    if (client['password'] != _pass.text) {
      _snack('كلمة المرور غير صحيحة', red: true);
      return;
    }

    ClientSession.current = client;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => ClientDashboardScreen(client: client!)),
    );
  }

  void _snack(String m, {bool red = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: red ? Colors.red : null,
    ));
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
              const SizedBox(height: 8),
              const Text('أدر قاعاتك وحجوزاتك بسهولة',
                  style: TextStyle(color: Colors.grey)),
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
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock, color: kPrimary),
                  suffixIcon: IconButton(
                    icon: Icon(obscure
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
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
  final _confirm = TextEditingController();
  bool loading = false;

  Future<void> _register() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _pass.text.isEmpty) {
      _snack('الرجاء ملء جميع الحقول', red: true);
      return;
    }
    if (_pass.text != _confirm.text) {
      _snack('كلمتا المرور غير متطابقتين', red: true);
      return;
    }
    if (_pass.text.length < 4) {
      _snack('كلمة المرور قصيرة جداً', red: true);
      return;
    }
    setState(() => loading = true);
    final all = await _service.getCollection('clients');
    final exists = all.any((e) => e['phone'] == _phone.text.trim());
    if (exists) {
      setState(() => loading = false);
      _snack('هذا الرقم مسجّل مسبقاً', red: true);
      return;
    }
    final ok = await _service.addToCollection('clients', {
      'name': _name.text,
      'phone': _phone.text.trim(),
      'password': _pass.text,
      'createdAt': DateTime.now().toIso8601String(),
    });
    setState(() => loading = false);
    if (!mounted) return;
    if (ok) {
      _snack('تم التسجيل بنجاح');
      Navigator.pop(context);
    } else {
      _snack('فشل التسجيل، حاول مرة أخرى', red: true);
    }
  }

  void _snack(String m, {bool red = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: red ? Colors.red : Colors.green,
    ));
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
            const SizedBox(height: 16),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline, color: kPrimary),
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
                        style: TextStyle(fontSize: 18, color: Colors.white)),
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
  final Map<String, dynamic> client;
  const ClientDashboardScreen({super.key, required this.client});
  @override
  State<ClientDashboardScreen> createState() =>
      _ClientDashboardScreenState();
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
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final allHalls = await _service.getHalls();
    final allBookings = await _service.getBookings();
    final cid = widget.client['id'];
    setState(() {
      _halls = allHalls.where((h) => h['clientId'] == cid).toList();
      _bookings = allBookings.where((b) => b['clientId'] == cid).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${widget.client['name']}'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientProfileScreen(client: widget.client),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: kAccent,
          labelColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'الرئيسية'),
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
                _ClientHomeTab(
                    halls: _halls,
                    bookings: _bookings,
                    clientName: widget.client['name'] ?? ''),
                _ClientHallsTab(
                  halls: _halls,
                  clientId: widget.client['id'],
                  onRefresh: _load,
                ),
                _ClientBookingsTab(
                    bookings: _bookings, onRefresh: _load),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => HallForm(
            clientId: widget.client['id'],
            onSaved: _load,
          ),
        ),
      ),
    );
  }
}

// ================= التبويب الرئيسي =================
class _ClientHomeTab extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final List<Map<String, dynamic>> bookings;
  final String clientName;

  const _ClientHomeTab({
    required this.halls,
    required this.bookings,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    double total = 0;
    double confirmed = 0;
    int pending = 0;
    int confirmedCount = 0;
    int rejected = 0;

    for (final b in bookings) {
      final t = (b['total'] is num)
          ? (b['total'] as num).toDouble()
          : double.tryParse('${b['total']}') ?? 0;
      total += t;
      final s = b['status'] ?? 'قيد المراجعة';
      if (s == 'مؤكد') {
        confirmed += t;
        confirmedCount++;
      } else if (s == 'مرفوض') {
        rejected++;
      } else {
        pending++;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ترحيب
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مرحباً $clientName',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('إليك ملخص أدائك اليوم',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // البطاقات
          Row(
            children: [
              Expanded(
                child: _statCard('قاعاتي', '${halls.length}',
                    Icons.home_work, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('الحجوزات', '${bookings.length}',
                    Icons.book_online, Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard('قيد المراجعة', '$pending',
                    Icons.pending, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('مؤكدة', '$confirmedCount',
                    Icons.check_circle, Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('الإيرادات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _revenueCard('إجمالي الإيرادات المتوقعة', total, Icons.trending_up,
              kPrimary),
          const SizedBox(height: 8),
          _revenueCard('الإيرادات المؤكدة', confirmed, Icons.check_circle,
              Colors.green),

          const SizedBox(height: 24),
          const Text('حالة الحجوزات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _statusCard('قيد المراجعة', pending, Colors.orange),
          const SizedBox(height: 8),
          _statusCard('مؤكدة', confirmedCount, Colors.green),
          const SizedBox(height: 8),
          _statusCard('مرفوضة', rejected, Colors.red),

          const SizedBox(height: 24),
          const Text('آخر 5 حجوزات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (bookings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Text('لا توجد حجوزات بعد',
                        style: TextStyle(color: Colors.grey))),
              ),
            )
          else
            ...bookings.reversed.take(5).map((b) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: kSoftPink,
                      child: Icon(Icons.event, color: kPrimary),
                    ),
                    title: Text(b['customerName'] ?? '-',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${b['hallName'] ?? '-'} • ${b['date'] ?? '-'}'),
                    trailing: Text('${b['total'] ?? 0} د.ل',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kAccentDark)),
                  ),
                )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color c) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c, size: 30),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: c)),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _revenueCard(String title, double value, IconData icon, Color c) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.withOpacity(0.15),
          child: Icon(icon, color: c),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text('${value.toStringAsFixed(0)} د.ل',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: c)),
      ),
    );
  }

  Widget _statusCard(String title, int count, Color c) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Text('$count',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: c)),
          ],
        ),
      ),
    );
  }
}

// ================= تبويب قاعاتي =================
class _ClientHallsTab extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final String clientId;
  final VoidCallback onRefresh;

  const _ClientHallsTab({
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
            SizedBox(height: 12),
            Text('لا توجد قاعات بعد'),
            SizedBox(height: 8),
            Text('اضغط على زر الإضافة بالأسفل',
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
            subtitle: Text(
                '${h['city']} • ${h['price']} د.ل • ${h['capacity']} شخص'),
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
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24)),
                    ),
                    builder: (_) => HallForm(
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
class HallForm extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic>? hall;
  final VoidCallback onSaved;

  const HallForm({
    super.key,
    required this.clientId,
    this.hall,
    required this.onSaved,
  });

  @override
  State<HallForm> createState() => _HallFormState();
}

class _HallFormState extends State<HallForm> {
  late TextEditingController _name, _city, _price, _capacity, _image, _desc;
  bool saving = false;

  final List<String> _cities = [
    'طرابلس',
    'بنغازي',
    'مصراتة',
    'الزاوية',
    'سبها',
    'البيضاء',
    'طبرق',
    'سرت',
  ];
  String _selectedCity = 'طرابلس';

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
    if (h['city'] != null && _cities.contains(h['city'])) {
      _selectedCity = h['city'];
    }
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _price.text.isEmpty || _capacity.text.isEmpty) {
      _snack('الرجاء ملء الحقول الأساسية', red: true);
      return;
    }
    setState(() => saving = true);
    final data = {
      'name': _name.text.trim(),
      'city': _selectedCity,
      'price': double.tryParse(_price.text) ?? 0,
      'capacity': int.tryParse(_capacity.text) ?? 0,
      'image': _image.text.trim(),
      'description': _desc.text.trim(),
      'clientId': widget.clientId,
    };

    bool ok;
    if (widget.hall == null) {
      ok = await _service.addHall(data);
    } else {
      ok = await _service.updateHall(widget.hall!['id'], data);
    }
    setState(() => saving = false);

    if (!mounted) return;
    if (ok) {
      widget.onSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.hall == null
              ? 'تم إضافة القاعة بنجاح'
              : 'تم تحديث القاعة'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _snack('فشل الحفظ', red: true);
    }
  }

  void _snack(String m, {bool red = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: red ? Colors.red : Colors.green,
    ));
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
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.hall == null ? 'إضافة قاعة جديدة' : 'تعديل القاعة',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _f('اسم القاعة *', _name, Icons.home_work),
            const SizedBox(height: 12),
            // اختيار المدينة
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: InputDecoration(
                labelText: 'المدينة *',
                prefixIcon: const Icon(Icons.location_city, color: kPrimary),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCity = v!),
            ),
            const SizedBox(height: 12),
            _f('السعر (د.ل) *', _price, Icons.attach_money,
                keyboard: TextInputType.number),
            const SizedBox(height: 12),
            _f('السعة (شخص) *', _capacity, Icons.people,
                keyboard: TextInputType.number),
            const SizedBox(height: 12),
            _f('رابط الصورة', _image, Icons.image),
            const SizedBox(height: 12),
            _f('الوصف', _desc, Icons.description, maxLines: 3),
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
                onPressed: saving ? null : _save,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.hall == null ? 'إضافة' : 'حفظ التعديلات',
                        style: const TextStyle(
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
    return TextField(
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
    );
  }
}

// ================= تبويب الحجوزات =================
class _ClientBookingsTab extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onRefresh;

  const _ClientBookingsTab(
      {required this.bookings, required this.onRefresh});

  @override
  State<_ClientBookingsTab> createState() => _ClientBookingsTabState();
}

class _ClientBookingsTabState extends State<_ClientBookingsTab> {
  String filter = 'الكل';

  Color _c(String? s) {
    if (s == 'مؤكد') return Colors.green;
    if (s == 'مرفوض') return Colors.red;
    return Colors.orange;
  }

  Future<void> _update(Map<String, dynamic> b, String status) async {
    final data = Map<String, dynamic>.from(b);
    data.remove('id');
    data['status'] = status;
    await _service.updateBooking(b['id'], data);
    widget.onRefresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'مؤكد'
              ? 'تم تأكيد الحجز'
              : 'تم رفض الحجز'),
          backgroundColor:
              status == 'مؤكد' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'الكل'
        ? widget.bookings
        : widget.bookings
            .where((b) => (b['status'] ?? 'قيد المراجعة') == filter)
            .toList();

    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['الكل', 'قيد المراجعة', 'مؤكد', 'مرفوض']
                .map((f) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: filter == f,
                        selectedColor: kPrimary,
                        backgroundColor: kSoftPink,
                        labelStyle: TextStyle(
                            color: filter == f
                                ? Colors.white
                                : kAccentDark,
                            fontWeight: FontWeight.bold),
                        onSelected: (_) => setState(() => filter = f),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('لا توجد حجوزات'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final b = filtered[i];
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
                                  child: Text(b['customerName'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _c(status).withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(status,
                                      style: TextStyle(
                                          color: _c(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                            const Divider(),
                            _r('📞 الهاتف', b['customerPhone'] ?? '-'),
                            _r('🏛️ القاعة', b['hallName'] ?? '-'),
                            _r('📅 التاريخ', b['date'] ?? '-'),
                            _r('👥 الضيوف', b['guests']?.toString() ?? '-'),
                            _r('💰 المبلغ', '${b['total'] ?? 0} د.ل'),
                            _r('💳 الدفع', b['paymentMethod'] ?? '-'),
                            if ((b['notes'] ?? '').toString().isNotEmpty)
                              _r('📝 ملاحظات', b['notes']),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    icon: const Icon(Icons.check,
                                        color: Colors.white, size: 18),
                                    label: const Text('تأكيد',
                                        style: TextStyle(
                                            color: Colors.white)),
                                    onPressed: status == 'مؤكد'
                                        ? null
                                        : () => _update(b, 'مؤكد'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 18),
                                    label: const Text('رفض',
                                        style: TextStyle(
                                            color: Colors.white)),
                                    onPressed: status == 'مرفوض'
                                        ? null
                                        : () => _update(b, 'مرفوض'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _r(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ================= الملف الشخصي لصاحب القاعة =================
class ClientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  const ClientProfileScreen({super.key, required this.client});

  @override
  State<ClientProfileScreen> createState() => ClientProfileScreenState();
}

class ClientProfileScreenState extends State<ClientProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool saving = false;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    _name.text = widget.client['name'] ?? '';
    _phone.text = widget.client['phone'] ?? '';
    _pass.text = widget.client['password'] ?? '';
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _pass.text.isEmpty) {
      _snack('لا تترك حقولاً فارغة', red: true);
      return;
    }
    setState(() => saving = true);

    // تحقق من عدم تكرار الرقم
    final all = await _service.getCollection('clients');
    final duplicate = all.any((c) =>
        c['phone'] == _phone.text.trim() && c['id'] != widget.client['id']);

    if (duplicate) {
      setState(() => saving = false);
      _snack('الرقم مستخدم من قبل حساب آخر', red: true);
      return;
    }

    final ok = await _service.updateClient(widget.client['id'], {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'password': _pass.text,
      'createdAt': widget.client['createdAt'] ?? '',
    });
    setState(() => saving = false);

    if (!mounted) return;
    if (ok) {
      ClientSession.current = {
        ...widget.client,
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'password': _pass.text,
      };
      _snack('تم حفظ التعديلات');
    } else {
      _snack('فشل الحفظ', red: true);
    }
  }

  void _snack(String m, {bool red = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: red ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: kAccent,
              child: Text(
                (widget.client['name'] ?? '?').toString().substring(0, 1),
                style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
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
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock, color: kPrimary),
              suffixIcon: IconButton(
                icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              onPressed: saving ? null : _save,
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ التعديلات',
                      style:
                          TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('تسجيل الخروج',
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                ClientSession.current = null;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ClientLoginScreen()),
                  (_) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
