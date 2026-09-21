import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'shared/ui_kit.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const AdminApp());
}

final _service = FirebaseService();

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

// ================= شاشة الدخول =================
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
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const AdminDashboardScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    } else {
      showAppSnack(context, 'الرمز غير صحيح', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimary, Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings,
                        size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  const Text('لوحة تحكم المدير',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('أدخل رمز PIN للمتابعة',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _pin,
                          obscureText: _obscure,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          style: const TextStyle(
                              fontSize: 32,
                              letterSpacing: 12,
                              fontWeight: FontWeight.w900,
                              color: kPrimary),
                          decoration: InputDecoration(
                            hintText: '••••',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade300,
                                letterSpacing: 12,
                                fontSize: 32),
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: kBackground,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: kPrimary, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: Icon(
                              _showHint
                                  ? Icons.info
                                  : Icons.help_outline,
                              size: 16),
                          label: Text(_showHint
                              ? 'الرمز: $ADMIN_PIN'
                              : 'نسيت الرمز؟'),
                          onPressed: () =>
                              setState(() => _showHint = !_showHint),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          text: 'دخول',
                          icon: Icons.login,
                          onPressed: _login,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= لوحة التحكم =================
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('لوحة المدير', style: AppText.h2),
            Text('إدارة كاملة للتطبيق', style: AppText.caption),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimary,
              ),
              icon: const Icon(Icons.refresh),
              onPressed: _load,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
              ),
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen()),
                (_) => false,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: kPrimary,
          indicatorWeight: 3,
          labelColor: kPrimary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 12),
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'الإحصائيات'),
            Tab(icon: Icon(Icons.home_work_outlined, size: 20), text: 'القاعات'),
            Tab(icon: Icon(Icons.book_online_outlined, size: 20), text: 'الحجوزات'),
            Tab(icon: Icon(Icons.people_outline, size: 20), text: 'المستخدمون'),
          ],
        ),
      ),
      body: loading
          ? const AppLoader(text: 'جاري التحميل...')
          : TabBarView(
              controller: _tab,
              children: [
                _StatsTab(
                  halls: _halls,
                  bookings: _bookings,
                  clients: _clients,
                  customers: _customers,
                  onRefresh: _load,
                ),
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
  final VoidCallback onRefresh;

  const _StatsTab({
    required this.halls,
    required this.bookings,
    required this.clients,
    required this.customers,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    double totalRevenue = 0, confirmedRevenue = 0;
    int pending = 0, confirmed = 0, rejected = 0;

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

    final cityCount = <String, int>{};
    for (final h in halls) {
      final c = h['city'] ?? 'غير محدد';
      cityCount[c] = (cityCount[c] ?? 0) + 1;
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: kPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترحيب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('لوحة الإحصائيات',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('${bookings.length} حجز • ${halls.length} قاعة',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.attach_money,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                  '${totalRevenue.toStringAsFixed(0)} د.ل',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.trending_up,
                        color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('نظرة عامة', style: AppText.h3),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _statCard('القاعات', '${halls.length}',
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
                  child: _statCard('أصحاب القاعات', '${clients.length}',
                      Icons.storefront, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard('الزبائن', '${customers.length}',
                      Icons.people, Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Text('الإيرادات', style: AppText.h3),
            const SizedBox(height: 14),
            _revenueCard('إجمالي الإيرادات المتوقعة', totalRevenue,
                Icons.trending_up, kPrimary),
            const SizedBox(height: 10),
            _revenueCard('الإيرادات المؤكدة', confirmedRevenue,
                Icons.verified, Colors.green),

            const SizedBox(height: 28),
            const Text('حالة الحجوزات', style: AppText.h3),
            const SizedBox(height: 14),
            _statusCard('قيد المراجعة', pending, Colors.orange),
            const SizedBox(height: 8),
            _statusCard('مؤكدة', confirmed, Colors.green),
            const SizedBox(height: 8),
            _statusCard('مرفوضة', rejected, Colors.red),

            const SizedBox(height: 28),
            const Text('توزيع القاعات حسب المدينة', style: AppText.h3),
            const SizedBox(height: 14),

            if (cityCount.isEmpty)
              const AppCard(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('لا توجد قاعات',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...cityCount.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kSoftPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_city,
                                color: kPrimary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(e.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: kSoftPink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${e.value} قاعة',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: kAccentDark,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('آخر الحجوزات', style: AppText.h3),
                Text('${bookings.length}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 14),

            if (bookings.isEmpty)
              const EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'لا توجد حجوزات',
                subtitle: 'ستظهر الحجوزات هنا عند وصولها',
              )
            else
              ...bookings.reversed.take(5).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kPrimary, Color(0xFF3949AB)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                (b['customerName'] ?? '?')
                                    .toString()
                                    .substring(0, 1),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['customerName'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                    '${b['hallName'] ?? '-'} • ${b['date'] ?? '-'}',
                                    style: AppText.caption),
                              ],
                            ),
                          ),
                          StatusBadge(
                              status: b['status'] ?? 'قيد المراجعة'),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color c) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, color: c)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _revenueCard(String title, double value, IconData icon, Color c) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: c, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Text('${value.toStringAsFixed(0)} د.ل',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: c)),
        ],
      ),
    );
  }

  Widget _statusCard(String title, int count, Color c) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: c, fontSize: 14)),
          ),
        ],
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
      return const EmptyState(
        icon: Icons.home_work_outlined,
        title: 'لا توجد قاعات',
        subtitle: 'لم يقم أصحاب القاعات بإضافة قاعات بعد',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: halls.length,
      itemBuilder: (_, i) {
        final h = halls[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    h['image'] ?? '',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: kSoftPink,
                      child: const Icon(Icons.home_work, color: kPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h['name'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(h['city'] ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${h['price']} د.ل • ${h['capacity']} شخص',
                          style: const TextStyle(
                              color: kAccentDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    final confirm = await showAppDialog(
                      context,
                      title: 'حذف القاعة',
                      message: 'هل تريد حذف "${h['name']}" نهائياً؟',
                      yesText: 'حذف',
                      yesColor: Colors.red,
                      icon: Icons.delete_outline,
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

  Future<void> _update(Map<String, dynamic> b, String status) async {
    final data = Map<String, dynamic>.from(b);
    data.remove('id');
    data['status'] = status;
    await _service.updateBooking(b['id'], data);
    widget.onRefresh();
    if (mounted) {
      showAppSnack(
          context,
          status == 'مؤكد' ? 'تم تأكيد الحجز' : 'تم رفض الحجز',
          success: status == 'مؤكد',
          error: status == 'مرفوض');
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showAppDialog(
      context,
      title: 'حذف الحجز',
      message: 'هل تريد حذف هذا الحجز نهائياً؟',
      yesText: 'حذف',
      yesColor: Colors.red,
      icon: Icons.delete_outline,
    );
    if (confirm == true) {
      await _service.deleteBooking(id);
      widget.onRefresh();
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['الكل', 'قيد المراجعة', 'مؤكد', 'مرفوض']
                .map((f) {
              final sel = filter == f;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? const LinearGradient(
                            colors: [kPrimary, Color(0xFF3949AB)])
                        : null,
                    color: sel ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: sel
                        ? null
                        : Border.all(color: Colors.grey.shade200),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => filter = f),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        child: Text(f,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'لا توجد حجوزات',
                  subtitle: 'ستظهر الحجوزات هنا عند وصولها',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final b = filtered[i];
                    final status = b['status'] ?? 'قيد المراجعة';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        kPrimary,
                                        Color(0xFF3949AB)
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (b['customerName'] ?? '?')
                                          .toString()
                                          .substring(0, 1),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(b['customerName'] ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text(b['customerPhone'] ?? '',
                                          style: AppText.caption),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: status),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1),
                            ),
                            _infoRow(Icons.home_work_outlined, 'القاعة',
                                b['hallName'] ?? '-'),
                            const SizedBox(height: 8),
                            _infoRow(Icons.calendar_today_outlined,
                                'التاريخ', b['date'] ?? '-'),
                            const SizedBox(height: 8),
                            _infoRow(Icons.people_outline, 'الضيوف',
                                '${b['guests']}'),
                            const SizedBox(height: 8),
                            _infoRow(Icons.payments_outlined, 'المبلغ',
                                '${b['total']} د.ل'),
                            const SizedBox(height: 8),
                            _infoRow(Icons.credit_card_outlined, 'الدفع',
                                b['paymentMethod'] ?? '-'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.check,
                                        color: Colors.white, size: 18),
                                    label: const Text('تأكيد',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                    onPressed: status == 'مؤكد'
                                        ? null
                                        : () => _update(b, 'مؤكد'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 18),
                                    label: const Text('رفض',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                    onPressed: status == 'مرفوض'
                                        ? null
                                        : () => _update(b, 'مرفوض'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.1),
                                    foregroundColor: Colors.grey.shade700,
                                  ),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  onPressed: () => _delete(b['id']),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const Spacer(),
        Flexible(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              textAlign: TextAlign.left),
        ),
      ],
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
            indicatorWeight: 3,
            labelColor: kPrimary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 13),
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
              _usersList(widget.clients, 'client',
                  Icons.storefront_outlined, 'لا يوجد أصحاب قاعات'),
              _usersList(widget.customers, 'customer',
                  Icons.people_outline, 'لا يوجد زبائن'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _usersList(List<Map<String, dynamic>> users, String type,
      IconData icon, String emptyTitle) {
    if (users.isEmpty) {
      return EmptyState(
        icon: icon,
        title: emptyTitle,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: type == 'client'
                          ? [Colors.orange, Colors.deepOrange]
                          : [kPrimary, const Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      (u['name'] ?? '?').toString().substring(0, 1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u['name'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(u['phone'] ?? '',
                              style: AppText.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: type == 'client'
                        ? Colors.orange.withOpacity(0.12)
                        : kPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    type == 'client' ? 'صاحب قاعة' : 'زبون',
                    style: TextStyle(
                        color: type == 'client'
                            ? Colors.deepOrange
                            : kPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    final confirm = await showAppDialog(
                      context,
                      title: 'حذف المستخدم',
                      message: 'حذف حساب "${u['name']}"؟',
                      yesText: 'حذف',
                      yesColor: Colors.red,
                      icon: Icons.delete_outline,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
