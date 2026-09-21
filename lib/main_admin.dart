import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const AdminApp());
}

final _service = FirebaseService();

// 🔐 رمز دخول المدير - غيّره من هنا
const String ADMIN_PIN = '1234';

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

// ================= شاشة دخول المدير =================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pin = TextEditingController();
  bool _obscure = true;
  bool _showHint = false;

  void _login() {
    if (_pin.text == ADMIN_PIN) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرمز غير صحيح'),
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
                    const Text('أدخل رمز PIN للمتابعة',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _pin,
                      obscureText: _obscure,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '••••',
                        counterText: '',
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
                    const SizedBox(height: 16),
                    // إظهار الرمز للمساعدة
                    TextButton.icon(
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: Text(_showHint
                          ? 'الرمز الافتراضي: $ADMIN_PIN'
                          : 'نسيت الرمز؟'),
                      onPressed: () =>
                          setState(() => _showHint = !_showHint),
                    ),
                    const SizedBox(height: 16),
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

// ================= لوحة التحكم الرئيسية =================
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
  List<Map<String, dynamic>> _customers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final halls = await _service.getHalls();
    final bookings = await _service.getBookings();
    final clients = await _service.getCollection('clients');
    final customers = await _service.getCollection('customers');
    setState(() {
      _halls = halls;
      _bookings = bookings;
      _clients = clients;
      _customers = customers;
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
            Tab(icon: Icon(Icons.dashboard), text: 'الإحصائيات'),
            Tab(icon: Icon(Icons.home_work), text: 'القاعات'),
            Tab(icon: Icon(Icons.book_online), text: 'الحجوزات'),
            Tab(icon: Icon(Icons.people), text: 'المستخدمون'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _StatsTab(
                    halls: _halls,
                    bookings: _bookings,
                    clients: _clients,
                    customers: _customers),
                _AdminHallsTab(halls: _halls, onRefresh: _load),
                _AdminBookingsTab(
                    bookings: _bookings, onRefresh: _load),
                _AdminUsersTab(
                  clients: _clients,
                  customers: _customers,
                  onRefresh: _load,
                ),
              ],
            ),
    );
  }
}

// ================= تبويب الإحصائيات =================
class _StatsTab extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final List<Map<String, dynamic>> bookings;
  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> customers;

  const _StatsTab({
    required this.halls,
    required this.bookings,
    required this.clients,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    // حساب الإحصائيات
    double totalRevenue = 0;
    double confirmedRevenue = 0;
    int pending = 0;
    int confirmed = 0;
    int rejected = 0;

    for (final b in bookings) {
      final t = (b['total'] is num)
          ? (b['total'] as num).toDouble()
          : double.tryParse('${b['total']}') ?? 0;
      totalRevenue += t;
      final s = b['status'] ?? 'قيد المراجعة';
      if (s == 'مؤكد') {
        confirmed++;
        confirmedRevenue += t;
      } else if (s == 'مرفوض') {
        rejected++;
      } else {
        pending++;
      }
    }

    // المدن
    final cityCount = <String, int>{};
    for (final h in halls) {
      final c = h['city'] ?? 'غير محدد';
      cityCount[c] = (cityCount[c] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نظرة عامة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // الإحصائيات الرئيسية
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'القاعات',
                  '${halls.length}',
                  Icons.home_work,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'الحجوزات',
                  '${bookings.length}',
                  Icons.book_online,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'أصحاب القاعات',
                  '${clients.length}',
                  Icons.store,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'الزبائن',
                  '${customers.length}',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('الإيرادات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _revenueCard(
            'إجمالي الإيرادات المتوقعة',
            totalRevenue,
            Icons.trending_up,
            kPrimary,
          ),
          const SizedBox(height: 8),
          _revenueCard(
            'الإيرادات المؤكدة',
            confirmedRevenue,
            Icons.check_circle,
            Colors.green,
          ),

          const SizedBox(height: 24),
          const Text('حالة الحجوزات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _statusCard('قيد المراجعة', pending, Colors.orange),
          const SizedBox(height: 8),
          _statusCard('مؤكدة', confirmed, Colors.green),
          const SizedBox(height: 8),
          _statusCard('مرفوضة', rejected, Colors.red),

          const SizedBox(height: 24),
          const Text('توزيع القاعات حسب المدينة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (cityCount.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Text('لا توجد قاعات',
                        style: TextStyle(color: Colors.grey))),
              ),
            )
          else
            ...cityCount.entries.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.location_city, color: kPrimary),
                    title: Text(e.key,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kSoftPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${e.value}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kPrimary)),
                    ),
                  ),
                )),

          const SizedBox(height: 24),
          const Text('آخر 5 حجوزات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (bookings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: Text('لا توجد حجوزات',
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
                    trailing: Text(
                        '${b['total'] ?? 0} د.ل',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kAccentDark)),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
              decoration:
                  BoxDecoration(color: c, shape: BoxShape.circle),
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

// ================= تبويب القاعات =================
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

// ================= تبويب الحجوزات =================
class _AdminBookingsTab extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onRefresh;

  const _AdminBookingsTab(
      {required this.bookings, required this.onRefresh});

  @override
  State<_AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<_AdminBookingsTab> {
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
        // فلاتر
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
                                    color:
                                        _c(status).withOpacity(0.15),
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
                                        style: TextStyle(
                                            color: Colors.green)),
                                    onPressed: () =>
                                        _update(b, 'مؤكد'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red, size: 18),
                                    label: const Text('رفض',
                                        style: TextStyle(
                                            color: Colors.red)),
                                    onPressed: () =>
                                        _update(b, 'مرفوض'),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.grey),
                                  onPressed: () async {
                                    await _service
                                        .deleteBooking(b['id']);
                                    widget.onRefresh();
                                  },
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

// ================= تبويب المستخدمين =================
class _AdminUsersTab extends StatefulWidget {
  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> customers;
  final VoidCallback onRefresh;

  const _AdminUsersTab({
    required this.clients,
    required this.customers,
    required this.onRefresh,
  });

  @override
  State<_AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<_AdminUsersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tab,
            indicatorColor: kPrimary,
            labelColor: kPrimary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'أصحاب القاعات (${widget.clients.length})'),
              Tab(text: 'الزبائن (${widget.customers.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _usersList(widget.clients, 'client'),
              _usersList(widget.customers, 'customer'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _usersList(List<Map<String, dynamic>> users, String type) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                type == 'client'
                    ? Icons.store_outlined
                    : Icons.people_outline,
                size: 80,
                color: Colors.grey),
            const SizedBox(height: 10),
            Text(type == 'client'
                ? 'لا يوجد أصحاب قاعات'
                : 'لا يوجد زبائن'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: kSoftPink,
              child: Text(
                (u['name'] ?? '?').toString().substring(0, 1),
                style: const TextStyle(
                    color: kPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(u['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(u['phone'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: Text('حذف حساب ${u['name']}؟'),
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
                  if (type == 'client') {
                    await _service.deleteClient(u['id']);
                  } else {
                    await _service.deleteCollectionItem(
                        'customers', u['id']);
                  }
                  widget.onRefresh();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
