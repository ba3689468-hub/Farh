import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'shared/ui_kit.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const CustomerApp());
}

final _service = FirebaseService();

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرح',
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
      home: const _Splash(),
    );
  }
}

// ================= Splash =================
class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const _CustomerLogin(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration,
                    size: 80, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text('فرح',
                  style: TextStyle(
                      fontSize: 56,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4)),
              const SizedBox(height: 12),
              const Text('احجز قاعة أحلامك',
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= نموذج القاعة =================
class Hall {
  final String id, name, city, image, description, clientId;
  final double price;
  final int capacity;

  Hall({
    required this.id,
    required this.name,
    required this.city,
    required this.price,
    required this.capacity,
    required this.image,
    required this.description,
    required this.clientId,
  });

  factory Hall.fromMap(Map<String, dynamic> m) => Hall(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        city: m['city'] ?? '',
        price: (m['price'] is num) ? (m['price'] as num).toDouble() : 0,
        capacity: (m['capacity'] is int)
            ? m['capacity']
            : int.tryParse('${m['capacity']}') ?? 0,
        image: m['image'] ?? '',
        description: m['description'] ?? '',
        clientId: m['clientId'] ?? '',
      );
}

class CustomerSession {
  static Map<String, dynamic>? current;
}

// ================= شاشة الدخول =================
class _CustomerLogin extends StatefulWidget {
  const _CustomerLogin();
  @override
  State<_CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<_CustomerLogin> {
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
    final all = await _service.getCollection('customers');
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

    CustomerSession.current = c;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const _CustomerHome(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
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
                child: const Icon(Icons.celebration,
                    size: 55, color: kPrimary),
              ),
              const SizedBox(height: 24),
              const Text('أهلاً بك', style: AppText.display),
              const SizedBox(height: 6),
              const Text('سجّل دخولك لحجز قاعتك',
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
                    obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                          builder: (_) => const _CustomerRegister()),
                    ),
                    child: const Text('سجّل الآن',
                        style: TextStyle(
                            color: kAccentDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  CustomerSession.current = null;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _CustomerHome()),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore_outlined,
                        color: Colors.grey, size: 18),
                    SizedBox(width: 8),
                    Text('تصفح كزائر',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= التسجيل =================
class _CustomerRegister extends StatefulWidget {
  const _CustomerRegister();
  @override
  State<_CustomerRegister> createState() => _CustomerRegisterState();
}

class _CustomerRegisterState extends State<_CustomerRegister> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool loading = false;
  bool obscure = true;

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
    final all = await _service.getCollection('customers');
    final exists = all.any((e) => e['phone'] == _phone.text.trim());
    if (exists) {
      setState(() => loading = false);
      showAppSnack(context, 'هذا الرقم مسجّل مسبقاً', error: true);
      return;
    }
    final ok = await _service.addToCollection('customers', {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'password': _pass.text,
      'createdAt': DateTime.now().toIso8601String(),
    });
    setState(() => loading = false);
    if (!mounted) return;
    if (ok) {
      showAppSnack(context, 'تم التسجيل بنجاح، يمكنك الدخول الآن',
          success: true);
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
            const Text('أنشئ حسابك',
                style: AppText.h1),
            const SizedBox(height: 8),
            const Text('سجّل بياناتك للحجز بسهولة', style: AppText.caption),
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

// ================= الشاشة الرئيسية =================
class _CustomerHome extends StatefulWidget {
  const _CustomerHome();
  @override
  State<_CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<_CustomerHome> {
  final _search = TextEditingController();
  String city = 'الكل';
  double maxPrice = 10000;
  int minCapacity = 0;
  List<Hall> halls = [];
  bool loading = true;

  final cities = ['الكل', 'طرابلس', 'بنغازي', 'مصراتة', 'الزاوية', 'سبها'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await _service.getHalls();
    setState(() {
      halls = data.map((e) => Hall.fromMap(e)).toList();
      loading = false;
    });
  }

  List<Hall> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return halls.where((h) {
      if (city != 'الكل' && h.city != city) return false;
      if (h.price > maxPrice) return false;
      if (h.capacity < minCapacity) return false;
      if (q.isNotEmpty &&
          !h.name.toLowerCase().contains(q) &&
          !h.city.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('فلترة النتائج', style: AppText.h2),
              const SizedBox(height: 24),
              const Text('أقصى سعر', style: AppText.h3),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: maxPrice,
                      min: 500,
                      max: 10000,
                      divisions: 19,
                      activeColor: kPrimary,
                      label: '${maxPrice.toInt()} د.ل',
                      onChanged: (v) {
                        setSt(() => maxPrice = v);
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSoftPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${maxPrice.toInt()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: kAccentDark)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('الحد الأدنى للسعة', style: AppText.h3),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: minCapacity.toDouble(),
                      min: 0,
                      max: 500,
                      divisions: 10,
                      activeColor: kPrimary,
                      label: '$minCapacity',
                      onChanged: (v) {
                        setSt(() => minCapacity = v.round());
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kSoftPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$minCapacity',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: kAccentDark)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'تطبيق الفلاتر',
                icon: Icons.check,
                height: 50,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    setSt(() {
                      maxPrice = 10000;
                      minCapacity = 0;
                    });
                    setState(() {});
                  },
                  child: const Text('إعادة ضبط',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = CustomerSession.current;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user != null ? 'أهلاً، ${user['name']}' : 'مرحباً بك',
                style: AppText.h3),
            Text('اكتشف أجمل قاعات ليبيا', style: AppText.caption),
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
              icon: const Icon(Icons.tune),
              onPressed: _openFilters,
            ),
          ),
          const SizedBox(width: 4),
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
                    builder: (_) => const _CustomerProfile()),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم القاعة أو المدينة...',
                  hintStyle: AppText.caption,
                  prefixIcon:
                      const Icon(Icons.search, color: kPrimary, size: 22),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          })
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ),
          ),

          // فلاتر المدن
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cities.length,
              itemBuilder: (_, i) {
                final c = cities[i];
                final sel = c == city;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      gradient: sel
                          ? const LinearGradient(
                              colors: [kPrimary, Color(0xFF3949AB)],
                            )
                          : null,
                      color: sel ? null : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: sel
                          ? null
                          : Border.all(color: Colors.grey.shade200),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => setState(() => city = c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          child: Text(
                            c,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // قائمة القاعات
          Expanded(
            child: loading
                ? const AppLoader(text: 'جاري تحميل القاعات...')
                : _filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'لا توجد قاعات مطابقة',
                        subtitle: _search.text.isNotEmpty
                            ? 'جرّب كلمات بحث أخرى'
                            : 'لم نجد قاعات في هذه المدينة',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: kPrimary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _HallCard(
                            hall: _filtered[i],
                            onRefresh: _load,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ================= كرت القاعة =================
class _HallCard extends StatelessWidget {
  final Hall hall;
  final VoidCallback onRefresh;
  const _HallCard({required this.hall, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _HallDetails(hall: hall, onRefresh: onRefresh),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'hall_${hall.id}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      hall.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: kSoftPink,
                        child: const Icon(Icons.image, size: 60, color: kPrimary),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('4.8',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hall.name, style: AppText.h3),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoChip(Icons.location_on_outlined, hall.city),
                      const SizedBox(width: 12),
                      _infoChip(Icons.people_outline, '${hall.capacity} شخص'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${hall.price.toStringAsFixed(0)}',
                              style: AppText.price),
                          const SizedBox(width: 4),
                          const Text('د.ل',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: kSoftPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Text('التفاصيل',
                                style: TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward,
                                color: kPrimary, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text, style: AppText.caption),
      ],
    );
  }
}

// ================= تفاصيل القاعة =================
class _HallDetails extends StatelessWidget {
  final Hall hall;
  final VoidCallback onRefresh;
  const _HallDetails({required this.hall, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'hall_${hall.id}',
                child: Image.network(
                  hall.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: kSoftPink,
                    child: const Icon(Icons.image,
                        size: 80, color: kPrimary),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hall.name, style: AppText.display),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSoftPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: kPrimary),
                            const SizedBox(width: 4),
                            Text(hall.city,
                                style: const TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSoftPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people,
                                size: 16, color: kPrimary),
                            const SizedBox(width: 4),
                            Text('${hall.capacity} شخص',
                                style: const TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('عن القاعة', style: AppText.h2),
                  const SizedBox(height: 10),
                  Text(
                    hall.description.isEmpty
                        ? 'قاعة رائعة بجميع الخدمات المتكاملة لإحياء حفل زفاف لا يُنسى'
                        : hall.description,
                    style: AppText.body.copyWith(height: 1.7),
                  ),
                  const SizedBox(height: 28),
                  const Text('الخدمات المتوفرة', style: AppText.h2),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      'تزيين القاعة',
                      'ضيافة كاملة',
                      'تصوير احترافي',
                      'موقف سيارات',
                      'دي جي وموسيقى',
                      'تكييف مركزي',
                    ].map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: kPrimary, size: 16),
                            const SizedBox(width: 6),
                            Text(s,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('السعر لليلة', style: AppText.caption),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${hall.price.toStringAsFixed(0)}',
                          style: AppText.price),
                      const SizedBox(width: 4),
                      const Text('د.ل',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: PrimaryButton(
                  text: 'احجز الآن',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _BookingScreen(hall: hall)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= شاشة الحجز =================
class _BookingScreen extends StatefulWidget {
  final Hall hall;
  const _BookingScreen({required this.hall});
  @override
  State<_BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<_BookingScreen> {
  DateTime? date;
  int guests = 100;
  late TextEditingController _name;
  late TextEditingController _phone;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = CustomerSession.current;
    _name = TextEditingController(text: c?['name'] ?? '');
    _phone = TextEditingController(text: c?['phone'] ?? '');
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => date = d);
  }

  void _next() {
    if (date == null || _name.text.isEmpty || _phone.text.isEmpty) {
      showAppSnack(context, 'الرجاء إكمال البيانات', error: true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PaymentScreen(
          hall: widget.hall,
          date: date!,
          guests: guests,
          name: _name.text,
          phone: _phone.text,
          notes: _notes.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز ${widget.hall.name}'),
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بياناتك', style: AppText.h2),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            const Text('تفاصيل الحجز', style: AppText.h2),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: date != null
                        ? kPrimary
                        : Colors.grey.shade200,
                    width: date != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: kPrimary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('تاريخ الحجز',
                              style: AppText.caption),
                          const SizedBox(height: 4),
                          Text(
                            date == null
                                ? 'اختر التاريخ'
                                : '${date!.year}/${date!.month}/${date!.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: date != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عدد الضيوف', style: AppText.h3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: kSoftPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$guests',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: kAccentDark,
                          fontSize: 16)),
                ),
              ],
            ),
            Slider(
              value: guests.toDouble(),
              min: 50,
              max: 500,
              divisions: 9,
              activeColor: kPrimary,
              inactiveColor: kSoftPink,
              label: '$guests',
              onChanged: (v) => setState(() => guests = v.round()),
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'ملاحظات (اختياري)',
              icon: Icons.notes_outlined,
              controller: _notes,
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kSoftPink, Color(0xFFF8BBD0)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الإجمالي',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      SizedBox(height: 4),
                      Text('سعر الليلة الواحدة',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${widget.hall.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: kAccentDark)),
                      const SizedBox(width: 4),
                      const Text('د.ل',
                          style: TextStyle(
                              fontSize: 15,
                              color: kAccentDark,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: 'متابعة للدفع',
              icon: Icons.payment_outlined,
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= شاشة الدفع =================
class _PaymentScreen extends StatefulWidget {
  final Hall hall;
  final DateTime date;
  final int guests;
  final String name, phone, notes;

  const _PaymentScreen({
    required this.hall,
    required this.date,
    required this.guests,
    required this.name,
    required this.phone,
    required this.notes,
  });

  @override
  State<_PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<_PaymentScreen> {
  String method = 'الدفع عند الوصول';
  bool processing = false;
  final _card = TextEditingController();
  final _cardName = TextEditingController();

  Future<void> _pay() async {
    if (method == 'بطاقة مصرفية' &&
        (_card.text.length < 16 || _cardName.text.isEmpty)) {
      showAppSnack(context, 'أدخل بيانات البطاقة كاملة', error: true);
      return;
    }
    setState(() => processing = true);
    final booking = {
      'customerName': widget.name,
      'customerPhone': widget.phone,
      'customerId': CustomerSession.current?['id'] ?? '',
      'hallId': widget.hall.id,
      'hallName': widget.hall.name,
      'clientId': widget.hall.clientId,
      'date':
          '${widget.date.year}/${widget.date.month}/${widget.date.day}',
      'guests': widget.guests,
      'total': widget.hall.price,
      'paymentMethod': method,
      'notes': widget.notes,
      'status': 'قيد المراجعة',
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _service.addToCollection('bookings', booking);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _Success(hall: widget.hall, date: widget.date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ملخص
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _row('القاعة', widget.hall.name),
                  const SizedBox(height: 12),
                  _row('التاريخ',
                      '${widget.date.year}/${widget.date.month}/${widget.date.day}'),
                  const SizedBox(height: 12),
                  _row('الضيوف', '${widget.guests} ضيف'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('${widget.hall.price.toStringAsFixed(0)} د.ل',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: kAccentDark)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('طريقة الدفع', style: AppText.h2),
            const SizedBox(height: 14),
            _tile('الدفع عند الوصول', Icons.payments_outlined,
                'الأكثر شيوعاً'),
            _tile('بطاقة مصرفية', Icons.credit_card, 'آمن 100%'),
            _tile('سداد', Icons.account_balance, 'تحويل مصرفي'),
            _tile('موبي كاش', Icons.phone_android, 'محفظة إلكترونية'),
            if (method == 'بطاقة مصرفية') ...[
              const SizedBox(height: 24),
              AppTextField(
                label: 'رقم البطاقة',
                icon: Icons.credit_card_outlined,
                controller: _card,
                keyboardType: TextInputType.number,
                hint: '0000 0000 0000 0000',
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'اسم حامل البطاقة',
                icon: Icons.person_outline,
                controller: _cardName,
              ),
            ],
            const SizedBox(height: 28),
            PrimaryButton(
              text:
                  'تأكيد الدفع • ${widget.hall.price.toStringAsFixed(0)} د.ل',
              icon: Icons.lock_outline,
              loading: processing,
              onPressed: _pay,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('دفع آمن ومشفّر',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: AppText.caption),
        Text(v,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }

  Widget _tile(String t, IconData i, String subtitle) {
    final s = method == t;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: s ? kPrimary : Colors.grey.shade200,
            width: s ? 2 : 1,
          ),
          boxShadow: s
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => method = t),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: s ? kSoftPink : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(i,
                        color: s ? kPrimary : Colors.grey, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: s ? kPrimary : Colors.black87,
                            )),
                        Text(subtitle,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s ? kPrimary : Colors.transparent,
                      border: Border.all(
                        color: s ? kPrimary : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: s
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 14)
                        : null,
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

// ================= شاشة النجاح =================
class _Success extends StatelessWidget {
  final Hall hall;
  final DateTime date;
  const _Success({required this.hall, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 90, color: Colors.green),
              ),
              const SizedBox(height: 32),
              const Text('تم إرسال الحجز!', style: AppText.display),
              const SizedBox(height: 12),
              const Text(
                'سيتواصل معك صاحب القاعة قريباً لتأكيد الحجز',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              const SizedBox(height: 40),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _row('القاعة', hall.name),
                    const SizedBox(height: 10),
                    _row('المدينة', hall.city),
                    const SizedBox(height: 10),
                    _row('التاريخ',
                        '${date.year}/${date.month}/${date.day}'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'العودة للرئيسية',
                icon: Icons.home_outlined,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const _CustomerHome()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: AppText.caption),
        Text(v,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }
}

// ================= الملف الشخصي =================
class _CustomerProfile extends StatefulWidget {
  const _CustomerProfile();
  @override
  State<_CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<_CustomerProfile> {
  List<Map<String, dynamic>> _myBookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final all = await _service.getCollection('bookings');
    final phone = CustomerSession.current?['phone'];
    setState(() {
      _myBookings =
          all.where((b) => b['customerPhone'] == phone).toList();
      _myBookings = _myBookings.reversed.toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = CustomerSession.current;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h3,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: kPrimary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // رأس
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, Color(0xFF3949AB)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (c?['name'] ?? '؟').toString().substring(0, 1),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(c?['name'] ?? 'زائر', style: AppText.h2),
                  const SizedBox(height: 4),
                  Text(c?['phone'] ?? 'غير مسجل',
                      style: AppText.caption),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Text('حجوزاتي', style: AppText.h2),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: kSoftPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_myBookings.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: kAccentDark,
                          fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: AppLoader(),
              )
            else if (_myBookings.isEmpty)
              const EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'لا توجد حجوزات بعد',
                subtitle: 'ابدأ بحجز قاعتك الأولى من الصفحة الرئيسية',
              )
            else
              ..._myBookings.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: kSoftPink,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.event,
                                    color: kPrimary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(b['hallName'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 13,
                                            color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(b['date'] ?? '',
                                            style: AppText.caption),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.people_outline,
                                            size: 13,
                                            color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${b['guests']}',
                                            style: AppText.caption),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                  status: b['status'] ?? 'قيد المراجعة'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 20),
            if (c != null)
              OutlineButton(
                text: 'تسجيل الخروج',
                icon: Icons.logout,
                onPressed: () {
                  CustomerSession.current = null;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _CustomerLogin()),
                    (_) => false,
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
