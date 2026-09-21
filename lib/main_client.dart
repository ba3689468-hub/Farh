import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'shared/ui_kit.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const ClientApp());
}

final _service = FirebaseService();

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
      showAppSnack(context, 'الرجاء إدخال الرقم وكلمة المرور', error: true);
      return;
    }
    setState(() => loading = true);
    final all = await _service.getCollection('clients');
    setState(() => loading = false);

    Map<String, dynamic>? c;
    try {
      c = all.firstWhere((e) => e['phone'] == _phone.text.trim());
    } catch (_) {
      c = null;
    }

    if (c == null) {
      showAppSnack(context, 'لا يوجد حساب بهذا الرقم', error: true);
      return;
    }
    if (c['password'] != _pass.text) {
      showAppSnack(context, 'كلمة المرور غير صحيحة', error: true);
      return;
    }

    ClientSession.current = c;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            ClientDashboardScreen(client: c!),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
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
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: kSoftPink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.storefront,
                    size: 55, color: kPrimary),
              ),
              const SizedBox(height: 24),
              const Text('أهلاً بك', style: AppText.display),
              const SizedBox(height: 6),
              const Text('سجّل دخولك لإدارة قاعاتك',
                  style: AppText.caption),
              const SizedBox(height: 36),
              AppTextField(
                label: 'رقم الهاتف',
                icon: Icons.phone_outlined,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                controller: _pass,
                obscure: obscure,
                suffix: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'تسجيل الدخول',
                icon: Icons.login,
                loading: loading,
                onPressed: _login,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ليس لديك حساب؟ ',
                      style: AppText.caption),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClientRegisterScreen()),
                    ),
                    child: const Text('سجّل الآن',
                        style: TextStyle(
                            color: kAccentDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= التسجيل =================
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
      showAppSnack(context, 'الرجاء ملء جميع الحقول', error: true);
      return;
    }
    if (_pass.text != _confirm.text) {
      showAppSnack(context, 'كلمتا المرور غير متطابقتين', error: true);
      return;
    }
    setState(() => loading = true);
    final all = await _service.getCollection('clients');
    final exists = all.any((e) => e['phone'] == _phone.text.trim());
    if (exists) {
      setState(() => loading = false);
      showAppSnack(context, 'هذا الرقم مسجّل مسبقاً', error: true);
      return;
    }
    final ok = await _service.addToCollection('clients', {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'password': _pass.text,
      'createdAt': DateTime.now().toIso8601String(),
    });
    setState(() => loading = false);
    if (!mounted) return;
    if (ok) {
      showAppSnack(context, 'تم التسجيل بنجاح', success: true);
      Navigator.pop(context);
    } else {
      showAppSnack(context, 'فشل التسجيل', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب جديد'),
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('سجّل قاعتك', style: AppText.h1),
            const SizedBox(height: 8),
            const Text('انضم إلينا وابدأ باستقبال الحجوزات',
                style: AppText.caption),
            const SizedBox(height: 32),
            AppTextField(
              label: 'الاسم الكامل',
              icon: Icons.person_outline,
              controller: _name,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'كلمة المرور',
              icon: Icons.lock_outline,
              controller: _pass,
              obscure: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'تأكيد كلمة المرور',
              icon: Icons.lock_outline,
              controller: _confirm,
              obscure: true,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'إنشاء الحساب',
              icon: Icons.person_add_alt,
              loading: loading,
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= لوحة التحكم =================
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
      _bookings =
          allBookings.where((b) => b['clientId'] == cid).toList();
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
          children: [
            Text('أهلاً، ${widget.client['name']}',
                style: AppText.h3),
            const Text('إدارة قاعاتك', style: AppText.caption),
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
                backgroundColor: kSoftPink,
                foregroundColor: kPrimary,
              ),
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ClientProfileScreen(client: widget.client),
                ),
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
              fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'الرئيسية'),
            Tab(text: 'قاعاتي'),
            Tab(text: 'الحجوزات'),
          ],
        ),
      ),
      body: loading
          ? const AppLoader(text: 'جاري التحميل...')
          : TabBarView(
              controller: _tab,
              children: [
                _ClientHomeTab(
                  halls: _halls,
                  bookings: _bookings,
                  clientName: widget.client['name'] ?? '',
                  onRefresh: _load,
                ),
                _ClientHallsTab(
                  halls: _halls,
                  clientId: widget.client['id'],
                  onRefresh: _load,
                ),
                _ClientBookingsTab(
                  bookings: _bookings,
                  onRefresh: _load,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        elevation: 6,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة قاعة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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

// ================= الصفحة الرئيسية =================
class _ClientHomeTab extends StatelessWidget {
  final List<Map<String, dynamic>> halls;
  final List<Map<String, dynamic>> bookings;
  final String clientName;
  final VoidCallback onRefresh;

  const _ClientHomeTab({
    required this.halls,
    required this.bookings,
    required this.clientName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    double total = 0, confirmed = 0;
    int pending = 0, confirmedCount = 0, rejected = 0;

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
                        Text('مرحباً $clientName',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        const Text('إليك ملخص أدائك',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13)),
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
                              const Icon(Icons.trending_up,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('${confirmed.toStringAsFixed(0)} د.ل',
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
                    child: const Icon(Icons.storefront,
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
                  child: _statCard('قاعاتي', '${halls.length}',
                      Icons.home_work, kPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard('الحجوزات', '${bookings.length}',
                      Icons.book_online, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard('قيد المراجعة', '$pending',
                      Icons.pending_actions, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard('مؤكدة', '$confirmedCount',
                      Icons.check_circle, Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Text('الإيرادات', style: AppText.h3),
            const SizedBox(height: 14),
            _revenueCard('إجمالي الإيرادات المتوقعة', total,
                Icons.trending_up, kPrimary),
            const SizedBox(height: 10),
            _revenueCard('الإيرادات المؤكدة', confirmed,
                Icons.verified, Colors.green),

            const SizedBox(height: 28),
            const Text('حالة الحجوزات', style: AppText.h3),
            const SizedBox(height: 14),
            _statusCard('قيد المراجعة', pending, Colors.orange),
            const SizedBox(height: 8),
            _statusCard('مؤكدة', confirmedCount, Colors.green),
            const SizedBox(height: 8),
            _statusCard('مرفوضة', rejected, Colors.red),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('آخر الحجوزات', style: AppText.h3),
                if (bookings.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: const Text('عرض الكل',
                        style: TextStyle(color: kPrimary)),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (bookings.isEmpty)
              const EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'لا توجد حجوزات بعد',
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
                              color: kSoftPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.event,
                                color: kPrimary, size: 22),
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
                          Text('${b['total'] ?? 0}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: kAccentDark,
                                  fontSize: 15)),
                          const SizedBox(width: 2),
                          const Text('د.ل',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 80),
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
                  color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
      return const EmptyState(
        icon: Icons.home_work_outlined,
        title: 'لا توجد قاعات بعد',
        subtitle: 'أضف قاعتك الأولى من الزر بالأسفل',
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
                      child:
                          const Icon(Icons.home_work, color: kPrimary),
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
                      Row(
                        children: [
                          Text('${h['price']}',
                              style: const TextStyle(
                                  color: kAccentDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14)),
                          const Text(' د.ل',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: kSoftPink,
                        foregroundColor: kPrimary,
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        builder: (_) => HallForm(
                          clientId: clientId,
                          hall: h,
                          onSaved: onRefresh,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
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
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= نموذج القاعة =================
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
  late TextEditingController _name, _price, _capacity, _image, _desc;
  bool saving = false;

  final List<String> _cities = [
    'طرابلس', 'بنغازي', 'مصراتة', 'الزاوية', 'سبها', 'البيضاء', 'طبرق', 'سرت',
  ];
  String _selectedCity = 'طرابلس';

  @override
  void initState() {
    super.initState();
    final h = widget.hall ?? {};
    _name = TextEditingController(text: h['name'] ?? '');
    _price = TextEditingController(text: h['price']?.toString() ?? '');
    _capacity =
        TextEditingController(text: h['capacity']?.toString() ?? '');
    _image = TextEditingController(text: h['image'] ?? '');
    _desc = TextEditingController(text: h['description'] ?? '');
    if (h['city'] != null && _cities.contains(h['city'])) {
      _selectedCity = h['city'];
    }
  }

  Future<void> _save() async {
    if (_name.text.isEmpty ||
        _price.text.isEmpty ||
        _capacity.text.isEmpty) {
      showAppSnack(context, 'الرجاء ملء الحقول الأساسية', error: true);
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
      showAppSnack(
          context,
          widget.hall == null
              ? 'تم إضافة القاعة بنجاح'
              : 'تم تحديث القاعة',
          success: true);
    } else {
      showAppSnack(context, 'فشل الحفظ، حاول مرة أخرى', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            Text(
              widget.hall == null ? 'إضافة قاعة جديدة' : 'تعديل القاعة',
              style: AppText.h2,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'اسم القاعة',
              icon: Icons.home_work_outlined,
              controller: _name,
            ),
            const SizedBox(height: 16),
            // المدينة
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'المدينة',
                  prefixIcon:
                      Icon(Icons.location_city_outlined, color: kPrimary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _cities
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCity = v!),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'السعر (د.ل)',
              icon: Icons.attach_money,
              controller: _price,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'السعة (شخص)',
              icon: Icons.people_outline,
              controller: _capacity,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'رابط الصورة',
              icon: Icons.image_outlined,
              controller: _image,
              hint: 'https://...',
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'الوصف',
              icon: Icons.description_outlined,
              controller: _desc,
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: widget.hall == null ? 'إضافة القاعة' : 'حفظ التعديلات',
              icon: Icons.check,
              loading: saving,
              onPressed: _save,
            ),
            const SizedBox(height: 20),
          ],
        ),
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
                              color:
                                  sel ? Colors.white : Colors.black87,
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
                  subtitle: 'ستظهر الحجوزات الجديدة هنا',
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
                            const SizedBox(height: 10),
                            _infoRow(
                                Icons.calendar_today_outlined,
                                'التاريخ',
                                b['date'] ?? '-'),
                            const SizedBox(height: 10),
                            _infoRow(Icons.people_outline, 'الضيوف',
                                '${b['guests']} ضيف'),
                            const SizedBox(height: 10),
                            _infoRow(Icons.payments_outlined, 'المبلغ',
                                '${b['total']} د.ل'),
                            const SizedBox(height: 10),
                            _infoRow(Icons.credit_card_outlined, 'الدفع',
                                b['paymentMethod'] ?? '-'),
                            if ((b['notes'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _infoRow(Icons.notes_outlined, 'ملاحظات',
                                  b['notes']),
                            ],
                            const SizedBox(height: 16),
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
                                const SizedBox(width: 10),
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
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 10),
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

// ================= الملف الشخصي =================
class ClientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  const ClientProfileScreen({super.key, required this.client});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
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
      showAppSnack(context, 'لا تترك حقولاً فارغة', error: true);
      return;
    }
    setState(() => saving = true);

    final all = await _service.getCollection('clients');
    final duplicate = all.any((c) =>
        c['phone'] == _phone.text.trim() &&
        c['id'] != widget.client['id']);

    if (duplicate) {
      setState(() => saving = false);
      showAppSnack(context, 'الرقم مستخدم من قبل حساب آخر', error: true);
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
      showAppSnack(context, 'تم حفظ التعديلات', success: true);
    } else {
      showAppSnack(context, 'فشل الحفظ', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFF3949AB)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Center(
                child: Text(
                  (widget.client['name'] ?? '?')
                      .toString()
                      .substring(0, 1),
                  style: const TextStyle(
                      fontSize: 44,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 30),
            AppTextField(
              label: 'الاسم الكامل',
              icon: Icons.person_outline,
              controller: _name,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'كلمة المرور',
              icon: Icons.lock_outline,
              controller: _pass,
              obscure: obscure,
              suffix: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: 'حفظ التعديلات',
              icon: Icons.save_outlined,
              loading: saving,
              onPressed: _save,
            ),
            const SizedBox(height: 16),
            OutlineButton(
              text: 'تسجيل الخروج',
              icon: Icons.logout,
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
          ],
        ),
      ),
    );
  }
}
