import 'package:flutter/material.dart';
import 'shared/colors.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const CustomerApp());
}

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
      home: const CustomerHomeScreen(),
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
  final String clientId;

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

  factory Hall.fromMap(Map<String, dynamic> m) {
    return Hall(
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
}

// ================= الشاشة الرئيسية للزبون =================
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String selectedCity = 'الكل';
  final List<String> cities = ['الكل', 'طرابلس', 'بنغازي', 'مصراتة', 'الزاوية'];
  final _service = FirebaseService();
  List<Hall> halls = [];
  bool loading = true;

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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
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
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _HallCard(hall: filtered[i]),
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
  const _HallCard({required this.hall});

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
          MaterialPageRoute(builder: (_) => _HallDetails(hall: hall)),
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
  const _HallDetails({required this.hall});

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
  final String name;
  final String phone;

  const _PaymentScreen({
    required this.hall,
    required this.date,
    required this.guests,
    required this.name,
    required this.phone,
  });

  @override
  State<_PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<_PaymentScreen> {
  String method = 'بطاقة مصرفية';
  bool processing = false;
  final _service = FirebaseService();

  Future<void> _pay() async {
    setState(() => processing = true);

    final booking = {
      'customerName': widget.name,
      'customerPhone': widget.phone,
      'hallId': widget.hall.id,
      'hallName': widget.hall.name,
      'clientId': widget.hall.clientId,
      'date':
          '${widget.date.year}/${widget.date.month}/${widget.date.day}',
      'guests': widget.guests,
      'total': widget.hall.price,
      'paymentMethod': method,
      'status': 'قيد المراجعة',
    };

    await _service.addBooking(booking);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _SuccessScreen(
          hall: widget.hall,
          date: widget.date,
          guests: widget.guests,
          total: widget.hall.price,
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

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(
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
  }

  Widget _tile(String title, IconData icon) {
    final sel = method == title;
    return Card(
      elevation: sel ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: sel ? kAccent : Colors.grey.shade300, width: sel ? 2 : 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: sel ? kAccentDark : Colors.grey),
        title: Text(title,
            style: TextStyle(
                fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
        trailing:
            sel ? const Icon(Icons.check_circle, color: kAccentDark) : null,
        onTap: () => setState(() => method = title),
      ),
    );
  }
}

// ================= شاشة النجاح =================
class _SuccessScreen extends StatelessWidget {
  final Hall hall;
  final DateTime date;
  final int guests;
  final double total;
  final String method;

  const _SuccessScreen({
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
              const Text('سيتم التواصل معك قريباً لتأكيد الحجز',
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
                    _row('الدفع', method),
                    const Divider(),
                    _row('المبلغ', '${total.toStringAsFixed(0)} د.ل',
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
                    MaterialPageRoute(
                        builder: (_) => const CustomerHomeScreen()),
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

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(
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
  }
}
