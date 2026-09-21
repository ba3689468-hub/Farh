import 'package:flutter/material.dart';
import 'shared/colors.dart';
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
      title: 'فرح - احجز قاعتك',
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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const _CustomerLogin()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 120, color: kAccent),
            SizedBox(height: 20),
            Text('فرح',
                style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('احجز قاعة أحلامك',
                style: TextStyle(fontSize: 18, color: kAccent)),
          ],
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

// ================= Global Customer State =================
class CustomerSession {
  static Map<String, dynamic>? current;
}

// ================= شاشة تسجيل دخول الزبون =================
class _CustomerLogin extends StatefulWidget {
  const _CustomerLogin();
  @override
  State<_CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<_CustomerLogin> {
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    if (_phone.text.isEmpty || _pass.text.isEmpty) {
      _snack('الرجاء إدخال الرقم وكلمة المرور');
      return;
    }
    setState(() => loading = true);
    final all = await _service.getCollection('customers');
    setState(() => loading = false);
    try {
      final c = all.firstWhere((e) => e['phone'] == _phone.text.trim());
      if (c['password'] != _pass.text) {
        _snack('كلمة المرور غير صحيحة', red: true);
        return;
      }
      CustomerSession.current = c;
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const _CustomerHome()));
    } catch (_) {
      _snack('لا يوجد حساب بهذا الرقم', red: true);
    }
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
              const Icon(Icons.celebration, size: 80, color: kPrimary),
              const SizedBox(height: 20),
              const Text('تسجيل دخول الزبون',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: loading ? null : _login,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('دخول',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const _CustomerRegister())),
                child: const Text('ليس لديك حساب؟ سجّل الآن',
                    style: TextStyle(color: kAccentDark)),
              ),
              TextButton(
                onPressed: () {
                  CustomerSession.current = null;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const _CustomerHome()));
                },
                child: const Text('تصفح بدون تسجيل',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= شاشة تسجيل الزبون =================
class _CustomerRegister extends StatefulWidget {
  const _CustomerRegister();
  @override
  State<_CustomerRegister> createState() => _CustomerRegisterState();
}

class _CustomerRegisterState extends State<_CustomerRegister> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  Future<void> _register() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _pass.text.isEmpty) {
      _snack('الرجاء ملء جميع الحقول');
      return;
    }
    setState(() => loading = true);
    final all = await _service.getCollection('customers');
    final exists = all.any((e) => e['phone'] == _phone.text.trim());
    if (exists) {
      setState(() => loading = false);
      _snack('هذا الرقم مسجّل مسبقاً', red: true);
      return;
    }
    final ok = await _service.addToCollection('customers', {
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
      _snack('فشل التسجيل', red: true);
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
          title: const Text('تسجيل جديد'),
          backgroundColor: kPrimary,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('فلترة النتائج',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('أقصى سعر',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: maxPrice,
                min: 500,
                max: 10000,
                divisions: 19,
                activeColor: kAccent,
                label: '${maxPrice.toInt()} د.ل',
                onChanged: (v) {
                  setSt(() => maxPrice = v);
                  setState(() {});
                },
              ),
              Text('حتى ${maxPrice.toInt()} د.ل',
                  style: const TextStyle(color: kAccentDark)),
              const SizedBox(height: 20),
              const Text('الحد الأدنى للسعة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: minCapacity.toDouble(),
                min: 0,
                max: 500,
                divisions: 10,
                activeColor: kAccent,
                label: '$minCapacity',
                onChanged: (v) {
                  setSt(() => minCapacity = v.round());
                  setState(() {});
                },
              ),
              Text('من $minCapacity شخص أو أكثر',
                  style: const TextStyle(color: kAccentDark)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تطبيق',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('فرح'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const _CustomerProfile())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث باسم القاعة أو المدينة...',
                prefixIcon: const Icon(Icons.search, color: kPrimary),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        })
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemBuilder: (_, i) {
                final c = cities[i];
                final sel = c == city;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    selectedColor: kPrimary,
                    backgroundColor: kSoftPink,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : kAccentDark,
                        fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => city = c),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 80, color: Colors.grey),
                            SizedBox(height: 10),
                            Text('لا توجد نتائج مطابقة'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) =>
                            _HallCard(hall: _filtered[i], onRefresh: _load),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => _HallDetails(hall: hall, onRefresh: onRefresh)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                hall.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: kSoftPink,
                  child: const Icon(Icons.image, size: 60, color: kPrimary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hall.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: kAccentDark),
                      const SizedBox(width: 4),
                      Text(hall.city,
                          style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.people, size: 16, color: kAccentDark),
                      const SizedBox(width: 4),
                      Text('${hall.capacity} شخص'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${hall.price.toStringAsFixed(0)} د.ل / الليلة',
                      style: const TextStyle(
                          fontSize: 18,
                          color: kAccentDark,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
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
      appBar: AppBar(
        title: Text(hall.name),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              hall.image,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: kSoftPink,
                child: const Icon(Icons.image, size: 80, color: kPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hall.name,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: kPrimary),
                      const SizedBox(width: 6),
                      Text(hall.city, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 20),
                      const Icon(Icons.people, color: kPrimary),
                      const SizedBox(width: 6),
                      Text('${hall.capacity} شخص',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('الوصف',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      hall.description.isEmpty
                          ? 'لا يوجد وصف متاح'
                          : hall.description,
                      style: const TextStyle(fontSize: 16, height: 1.6)),
                  const SizedBox(height: 20),
                  const Text('الخدمات المتوفرة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(
                          label: Text('تزيين القاعة'),
                          backgroundColor: kSoftPink),
                      Chip(
                          label: Text('ضيافة كاملة'),
                          backgroundColor: kSoftPink),
                      Chip(
                          label: Text('تصوير احترافي'),
                          backgroundColor: kSoftPink),
                      Chip(
                          label: Text('موقف سيارات'),
                          backgroundColor: kSoftPink),
                      Chip(
                          label: Text('دي جي وموسيقى'),
                          backgroundColor: kSoftPink),
                      Chip(
                          label: Text('تكييف مركزي'),
                          backgroundColor: kSoftPink),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('السعر لليلة الواحدة',
                                style: TextStyle(color: Colors.grey)),
                            Text('${hall.price.toStringAsFixed(0)} د.ل',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kAccentDark)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.calendar_month,
                            color: Colors.white),
                        label: const Text('احجز الآن',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _BookingScreen(hall: hall)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إكمال البيانات')),
      );
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
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بيانات الحجز',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person, color: kPrimary),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone, color: kPrimary),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'تاريخ الحجز',
                    prefixIcon: Icon(Icons.calendar_month, color: kPrimary),
                    border: OutlineInputBorder()),
                child: Text(date == null
                    ? 'اختر التاريخ'
                    : '${date!.year}/${date!.month}/${date!.day}'),
              ),
            ),
            const SizedBox(height: 20),
            Text('عدد الضيوف: $guests',
                style: const TextStyle(fontSize: 16)),
            Slider(
              value: guests.toDouble(),
              min: 50,
              max: 500,
              divisions: 10,
              activeColor: kAccent,
              inactiveColor: kSoftPink,
              label: '$guests',
              onChanged: (v) => setState(() => guests = v.round()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSoftPink,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAccent, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${widget.hall.price.toStringAsFixed(0)} د.ل',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kAccentDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text('الانتقال للدفع',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: _next,
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل بيانات البطاقة كاملة')),
      );
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
      'date': '${widget.date.year}/${widget.date.month}/${widget.date.day}',
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
          backgroundColor: kPrimary,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 8)
                ],
              ),
              child: Column(
                children: [
                  _row('القاعة', widget.hall.name),
                  _row('التاريخ',
                      '${widget.date.year}/${widget.date.month}/${widget.date.day}'),
                  _row('الضيوف', '${widget.guests}'),
                  const Divider(),
                  _row('الإجمالي',
                      '${widget.hall.price.toStringAsFixed(0)} د.ل',
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('اختر طريقة الدفع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _tile('بطاقة مصرفية', Icons.credit_card),
            _tile('سداد', Icons.account_balance),
            _tile('موبي كاش', Icons.phone_android),
            _tile('الدفع عند الوصول', Icons.money),
            if (method == 'بطاقة مصرفية') ...[
              const SizedBox(height: 20),
              TextField(
                controller: _card,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                    labelText: 'رقم البطاقة',
                    prefixIcon: Icon(Icons.credit_card, color: kPrimary),
                    border: OutlineInputBorder(),
                    counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardName,
                decoration: const InputDecoration(
                    labelText: 'اسم حامل البطاقة',
                    prefixIcon: Icon(Icons.person, color: kPrimary),
                    border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: processing ? null : _pay,
                child: processing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'تأكيد (${widget.hall.price.toStringAsFixed(0)} د.ل)',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(color: Colors.grey)),
            Text(v,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    color: bold ? kAccentDark : Colors.black)),
          ],
        ),
      );

  Widget _tile(String t, IconData i) {
    final s = method == t;
    return Card(
      elevation: s ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: s ? kAccent : Colors.grey.shade300, width: s ? 2 : 1),
      ),
      child: ListTile(
        leading: Icon(i, color: s ? kAccentDark : Colors.grey),
        title: Text(t,
            style: TextStyle(
                fontWeight: s ? FontWeight.bold : FontWeight.normal)),
        trailing: s ? const Icon(Icons.check_circle, color: kAccentDark) : null,
        onTap: () => setState(() => method = t),
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
              const Icon(Icons.check_circle, size: 120, color: Colors.green),
              const SizedBox(height: 20),
              const Text('تم إرسال طلب الحجز!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('سيتم التواصل معك بعد مراجعة الطلب من قبل صاحب القاعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const _CustomerHome()),
                    (_) => false,
                  ),
                  child: const Text('العودة للرئيسية',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= الملف الشخصي للزبون =================
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
      loading = false;
    });
  }

  Color _c(String? s) {
    if (s == 'مؤكد') return Colors.green;
    if (s == 'مرفوض') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final c = CustomerSession.current;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: kAccent,
              child: Text(
                (c?['name'] ?? '؟').toString().substring(0, 1),
                style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(c?['name'] ?? 'زائر',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(c?['phone'] ?? 'غير مسجل',
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('حجوزاتي',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_myBookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('لا توجد حجوزات بعد',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ..._myBookings.map((b) => Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _c(b['status']).withOpacity(0.15),
                      child: Icon(Icons.event, color: _c(b['status'])),
                    ),
                    title: Text(b['hallName'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${b['date']} • ${b['guests']} ضيف'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _c(b['status']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(b['status'] ?? '',
                          style: TextStyle(
                              color: _c(b['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                )),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(color: Colors.red)),
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
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
