import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'screens/admin_login_screen.dart';

// ============ ألوان التطبيق ============
const Color kPrimary = Color(0xFF1A237E);
const Color kAccent = Color(0xFFF48FB1);
const Color kAccentDark = Color(0xFFC2185B);
const Color kBackground = Color(0xFFF5F7FA);
const Color kSoftPink = Color(0xFFFCE4EC);

void main() {
  runApp(const FarahApp());
}

class FarahApp extends StatelessWidget {
  const FarahApp({super.key});

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
      home: const SplashScreen(),
    );
  }
}

// ================= شاشة البداية =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
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
            Text('لحجز قاعات الأفراح في ليبيا',
                style: TextStyle(fontSize: 18, color: kAccent)),
          ],
        ),
      ),
    );
  }
}

// ================= تسجيل الدخول =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  void _login() {
    if (_phone.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف وكلمة المرور')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.celebration, size: 80, color: kPrimary),
              const SizedBox(height: 20),
              const Text('تسجيل الدخول',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: const Icon(Icons.phone, color: kPrimary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kAccent, width: 2)),
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
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kAccent, width: 2)),
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
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('إنشاء حساب جديد',
                    style: TextStyle(color: kAccentDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= التسجيل =================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
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
                onPressed: _register,
                child: const Text('تسجيل',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= نموذج القاعة =================
class Hall {
  final String id;
  final String name;
  final String city;
  final double price;
  final int capacity;
  final String image;
  final String description;

  Hall({
    required this.id,
    required this.name,
    required this.city,
    required this.price,
    required this.capacity,
    required this.image,
    required this.description,
  });

  factory Hall.fromMap(Map<String, dynamic> m) {
    return Hall(
      id: m['id'] ?? '',
      name: m['name'] ?? '',
      city: m['city'] ?? '',
      price: (m['price'] is num) ? (m['price'] as num).toDouble() : 0,
      capacity: (m['capacity'] is int) ? m['capacity'] : int.tryParse('${m['capacity']}') ?? 0,
      image: m['image'] ?? '',
      description: m['description'] ?? '',
    );
  }
}

// ================= الشاشة الرئيسية =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = 'الكل';
  final List<String> cities = ['الكل', 'طرابلس', 'بنغازي', 'مصراتة', 'الزاوية'];
  final _service = FirebaseService();
  List<Hall> halls = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadHalls();
  }

  Future<void> _loadHalls() async {
    setState(() => loading = true);
    final data = await _service.getHalls();
    setState(() {
      halls = data.map((e) => Hall.fromMap(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCity == 'الكل'
        ? halls
        : halls.where((h) => h.city == selectedCity).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('فرح - القاعات'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHalls,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              itemBuilder: (_, i) {
                final c = cities[i];
                final sel = c == selectedCity;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    selectedColor: kPrimary,
                    backgroundColor: kSoftPink,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : kAccentDark,
                        fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => selectedCity = c),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('لا توجد قاعات متاحة'),
                            SizedBox(height: 8),
                            Text('أضف قاعات من لوحة تحكم المدير',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => HallCard(hall: filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

// ================= كرت القاعة =================
class HallCard extends StatelessWidget {
  final Hall hall;
  const HallCard({super.key, required this.hall});

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
          MaterialPageRoute(builder: (_) => HallDetailsScreen(hall: hall)),
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
class HallDetailsScreen extends StatelessWidget {
  final Hall hall;
  const HallDetailsScreen({super.key, required this.hall});

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
                  Text(hall.description,
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
                              builder: (_) => BookingScreen(hall: hall)),
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
class BookingScreen extends StatefulWidget {
  final Hall hall;
  const BookingScreen({super.key, required this.hall});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  int guests = 100;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => selectedDate = d);
  }

  void _continue() {
    if (selectedDate == null || _name.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إكمال البيانات المطلوبة')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          hall: widget.hall,
          date: selectedDate!,
          guests: guests,
          customerName: _name.text,
          customerPhone: _phone.text,
          total: widget.hall.price,
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                child: Text(selectedDate == null
                    ? 'اختر التاريخ'
                    : '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}'),
              ),
            ),
            const SizedBox(height: 20),
            Text('عدد الضيوف: $guests',
                style: const TextStyle(fontSize: 16)),
            Slider(
              value: guests.toDouble(),
              min: 50,
              max: widget.hall.capacity > 50
                  ? widget.hall.capacity.toDouble()
                  : 500,
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
                  labelText: 'ملاحظات إضافية (اختياري)',
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
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= شاشة الدفع الإلكتروني =================
class PaymentScreen extends StatefulWidget {
  final Hall hall;
  final DateTime date;
  final int guests;
  final String customerName;
  final String customerPhone;
  final double total;

  const PaymentScreen({
    super.key,
    required this.hall,
    required this.date,
    required this.guests,
    required this.customerName,
    required this.customerPhone,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String method = 'بطاقة مصرفية';
  final _cardNumber = TextEditingController();
  final _cardName = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool processing = false;
  final _service = FirebaseService();

  Future<void> _pay() async {
    if (method == 'بطاقة مصرفية') {
      if (_cardNumber.text.length < 16 ||
          _cardName.text.isEmpty ||
          _expiry.text.isEmpty ||
          _cvv.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال بيانات البطاقة كاملة')),
        );
        return;
      }
    }

    setState(() => processing = true);

    // حفظ الحجز في Firebase
    final booking = {
      'customerName': widget.customerName,
      'customerPhone': widget.customerPhone,
      'hallName': widget.hall.name,
      'hallId': widget.hall.id,
      'date': '${widget.date.year}/${widget.date.month}/${widget.date.day}',
      'guests': widget.guests,
      'total': widget.total,
      'paymentMethod': method,
      'status': 'قيد المراجعة',
    };

    await _service.addBooking(booking);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => processing = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          hall: widget.hall,
          date: widget.date,
          guests: widget.guests,
          total: widget.total,
          method: method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع الإلكتروني'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
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
                  _row('المدينة', widget.hall.city),
                  _row(
                      'التاريخ',
                      '${widget.date.year}/${widget.date.month}/${widget.date.day}'),
                  _row('عدد الضيوف', '${widget.guests}'),
                  const Divider(),
                  _row('المبلغ الإجمالي',
                      '${widget.total.toStringAsFixed(0)} د.ل',
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('اختر طريقة الدفع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _methodTile('بطاقة مصرفية', Icons.credit_card),
            _methodTile('سداد', Icons.account_balance),
            _methodTile('موبي كاش', Icons.phone_android),
            _methodTile('الدفع عند الوصول', Icons.money),
            const SizedBox(height: 20),
            if (method == 'بطاقة مصرفية') ...[
              const Text('بيانات البطاقة',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _cardNumber,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: 'رقم البطاقة',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: Icon(Icons.credit_card, color: kPrimary),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardName,
                decoration: const InputDecoration(
                  labelText: 'اسم حامل البطاقة',
                  prefixIcon: Icon(Icons.person, color: kPrimary),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiry,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvv,
                      obscureText: true,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSoftPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'سيتم توجيهك إلى بوابة $method لإتمام الدفع بأمان.',
                  style: const TextStyle(fontSize: 16),
                ),
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
                    : Text('تأكيد الدفع (${widget.total.toStringAsFixed(0)} د.ل)',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('دفع آمن ومشفّر',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 18 : 15,
                  color: bold ? kAccentDark : Colors.black)),
        ],
      ),
    );
  }

  Widget _methodTile(String title, IconData icon) {
    final sel = method == title;
    return Card(
      elevation: sel ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: sel ? kAccent : Colors.grey.shade300,
            width: sel ? 2 : 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: sel ? kAccentDark : Colors.grey),
        title: Text(title,
            style: TextStyle(
                fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
        trailing: sel
            ? const Icon(Icons.check_circle, color: kAccentDark)
            : null,
        onTap: () => setState(() => method = title),
      ),
    );
  }
}

// ================= شاشة النجاح =================
class SuccessScreen extends StatelessWidget {
  final Hall hall;
  final DateTime date;
  final int guests;
  final double total;
  final String method;

  const SuccessScreen({
    super.key,
    required this.hall,
    required this.date,
    required this.guests,
    required this.total,
    required this.method,
  });

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
              const Text('تم الحجز بنجاح!',
                  style:
                      TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('شكراً لك، سيتم التواصل معك قريباً لتأكيد الحجز.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),
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
                    _row('القاعة', hall.name),
                    _row('التاريخ',
                        '${date.year}/${date.month}/${date.day}'),
                    _row('الضيوف', '$guests'),
                    _row('طريقة الدفع', method),
                    const Divider(),
                    _row('المبلغ المدفوع',
                        '${total.toStringAsFixed(0)} د.ل',
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
                  ),
                  child: const Text('العودة للرئيسية',
                      style:
                          TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: bold ? kAccentDark : Colors.black)),
        ],
      ),
    );
  }
}

// ================= الملف الشخصي =================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: kAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('مستخدم فرح',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text('+218 91 000 0000',
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 30),
          _item(context, Icons.history, 'حجوزاتي السابقة'),
_item(context, Icons.favorite, 'القاعات المفضلة'),
_item(context, Icons.payment, 'طرق الدفع'),
_item(context, Icons.notifications, 'الإشعارات'),
_item(context, Icons.help, 'المساعدة والدعم'),
_item(context, Icons.admin_panel_settings, 'لوحة تحكم المدير'),
_item(context, Icons.info, 'عن التطبيق'),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (title == 'لوحة تحكم المدير') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          );
        }
      },
    );
  }
}
