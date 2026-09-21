import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرح - لوحة المدير',
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
      home: const AdminLoginScreen(),
    );
  }
}

final _service = FirebaseService();

// ================= شاشة تسجيل دخول المدير =================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pass = TextEditingController();
  bool _obscure = true;

  // 🔐 غيّر كلمة السر من هنا
  static const String ADMIN_PASSWORD = 'admin2024';

  void _login() {
    if (_pass.text == ADMIN_PASSWORD) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        size: 80, color: kPrimary),
                    const SizedBox(height: 20),
                    const Text('لوحة تحكم المدير',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('أدخل كلمة المرور للمتابعة',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _pass,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon:
                            const Icon(Icons.lock, color: kPrimary),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: kAccent, width: 2)),
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
                        onPressed: _login,
                        child: const Text('دخول',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= لوحة تحكم المدير =================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _halls = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _clients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final halls = await _service.getHalls();
    final bookings = await _service.getBookings();
    final clients = await _service.getClients();
    setState(() {
      _halls = halls;
      _bookings = bookings;
      _clients = clients;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminLoginScreen()),
              (_) => false,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: kAccent,
          labelColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.home_work), text: 'القاعات'),
            Tab(icon: Icon(Icons.book_online), text: 'الحجوزات'),
            Tab(icon: Icon(Icons.people), text: 'أصحاب القاعات'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _AdminHallsTab(halls: _halls, onRefresh: _load),
                _AdminBookingsTab(
                    bookings: _bookings, onRefresh: _load),
                _AdminClientsTab(clients: _clients, onRefresh: _load),
              ],
            ),
    );
  }
}

// ================= تبويب القاعات (المدير) =================
class _AdminHallsTab extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final VoidCallback onRefresh;

  const _AdminHallsTab({required this.halls, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (halls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text('لا توجد قاعات'),
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
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text('حذف هذه القاعة نهائياً؟'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
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
          ),
        );
      },
    );
  }
}

// ================= تبويب الحجوزات (المدير) =================
class _AdminBookingsTab extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onRefresh;

  const _AdminBookingsTab(
      {required this.bookings, required this.onRefresh});

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
            Text('لا توجد حجوزات'),
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
                        color: _c(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
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
                _r('📞', b['customerPhone'] ?? '-'),
                _r('🏛️', b['hallName'] ?? '-'),
                _r('📅', b['date'] ?? '-'),
                _r('👥', b['guests']?.toString() ?? '-'),
                _r('💰', '${b['total'] ?? 0} د.ل'),
                _r('💳', b['paymentMethod'] ?? '-'),
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
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () async {
                        await _service.deleteBooking(b['id']);
                        onRefresh();
                      },
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

// ================= تبويب أصحاب القاعات (المدير) =================
class _AdminClientsTab extends StatelessWidget {
  final List<Map<String, dynamic>> clients;
  final VoidCallback onRefresh;

  const _AdminClientsTab(
      {required this.clients, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text('لا يوجد أصحاب قاعات مسجلون'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: clients.length,
      itemBuilder: (_, i) {
        final c = clients[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: kSoftPink,
              child: Text(
                (c['name'] ?? '?').toString().substring(0, 1),
                style: const TextStyle(
                    color: kPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(c['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c['phone'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف صاحب القاعة'),
                    content: const Text(
                        'سيتم حذف الحساب. القاعات المرتبطة لن تُحذف تلقائياً.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _service.deleteClient(c['id']);
                  onRefresh();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
