import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const SmileKidsApp());
}

class SmileKidsApp extends StatelessWidget {
  const SmileKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smile Kids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.bg,
        fontFamily: 'Arial',
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: LoginUsersPage(),
      ),
    );
  }
}

class AppColor {
  static const bg = Color(0xFF0B0906);
  static const top = Color(0xFF0F0C07);
  static const card = Color(0xFF18150F);
  static const card2 = Color(0xFF242017);
  static const dark = Color(0xFF100E09);
  static const border = Color(0xFF332B18);
  static const gold = Color(0xFFFFC12B);
  static const goldDark = Color(0xFF493707);
  static const muted = Color(0xFFB7AA8A);
  static const green = Color(0xFF4BC46A);
  static const red = Color(0xFFE85050);
}

enum UserRole { admin, management, staff }

class AppUser {
  final String name;
  final String password;
  final String job;
  final UserRole role;
  final IconData icon;

  const AppUser({
    required this.name,
    required this.password,
    required this.job,
    required this.role,
    required this.icon,
  });
}

const List<AppUser> appUsers = [
  AppUser(
    name: 'أدمن',
    password: '19921996',
    job: 'مسؤول النظام',
    role: UserRole.admin,
    icon: Icons.admin_panel_settings_rounded,
  ),
  AppUser(
    name: 'إدارة',
    password: '19921996',
    job: 'مشرف',
    role: UserRole.management,
    icon: Icons.supervisor_account_rounded,
  ),
  AppUser(
    name: 'نجلاء',
    password: '2000',
    job: 'موظف تسجيل',
    role: UserRole.staff,
    icon: Icons.person_rounded,
  ),
  AppUser(
    name: 'شهد',
    password: '2002',
    job: 'موظف تسجيل',
    role: UserRole.staff,
    icon: Icons.person_rounded,
  ),
];

class KidSession {
  final int id;
  final String childName;
  final int childrenCount;
  final String note;
  final String createdBy;
  final DateTime startTime;

  DateTime endTime;
  int totalMoney;
  bool ended;
  bool alarmDone;

  KidSession({
    required this.id,
    required this.childName,
    required this.childrenCount,
    required this.note,
    required this.createdBy,
    required this.startTime,
    required this.endTime,
    required this.totalMoney,
    this.ended = false,
    this.alarmDone = false,
  });

  Duration get remaining {
    final diff = endTime.difference(DateTime.now());
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  bool get isExpired {
    return !ended && remaining == Duration.zero;
  }

  int get totalMinutes {
    final minutes = endTime.difference(startTime).inMinutes;
    if (minutes <= 0) return 1;
    return minutes;
  }

  double get progress {
    final totalSeconds = endTime.difference(startTime).inSeconds;
    if (totalSeconds <= 0) return 0;

    final remainingSeconds = remaining.inSeconds;
    return (remainingSeconds / totalSeconds).clamp(0.0, 1.0).toDouble();
  }
}

final List<KidSession> allSessions = [];

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/* =========================
   LOGIN PAGE
========================= */

class LoginUsersPage extends StatelessWidget {
  const LoginUsersPage({super.key});

  void openPasswordDialog(BuildContext context, AppUser user) {
    final passwordController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) {
              void login() {
                final password = passwordController.text.trim();

                if (password == user.password) {
                  Navigator.pop(dialogContext);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: HomePage(user: user),
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    errorText = 'كلمة المرور غير صحيحة';
                  });
                }
              }

              return AlertDialog(
                backgroundColor: AppColor.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppColor.border),
                ),
                title: Text(
                  'دخول ${user.name}',
                  style: const TextStyle(
                    color: AppColor.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => login(),
                      decoration: InputDecoration(
                        hintText: 'ادخل كلمة المرور',
                        hintStyle: const TextStyle(color: AppColor.muted),
                        filled: true,
                        fillColor: AppColor.dark,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColor.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColor.gold,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
          IconButton(icon: const Icon(Icons.filter_alt), onPressed: toggleFilter),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: AppColor.muted),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'دخول',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.35, -0.35),
            radius: 1.25,
            colors: [
              Color(0xFF2A2108),
              AppColor.bg,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 14),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    color: AppColor.goldDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColor.gold,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'سمايل كيدز',
                  style: TextStyle(
                    color: AppColor.gold,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اختر المستخدم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'اضغط على اسم المستخدم وادخل كلمة المرور',
                  style: TextStyle(
                    color: AppColor.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: GridView.builder(
                    itemCount: appUsers.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.02,
                    ),
                    itemBuilder: (context, index) {
                      final user = appUsers[index];

                      return GestureDetector(
                        onTap: () => openPasswordDialog(context, user),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.card.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColor.border,
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: AppColor.goldDark,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  user.icon,
                                  color: AppColor.gold,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.job,
                                style: const TextStyle(
                                  color: AppColor.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: AppColor.gold,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'نظام داخلي لمتابعة وتشغيل الكيدز إيريا',
                      style: TextStyle(
                        color: AppColor.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   HOME PAGE
========================= */

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===== ADDED FEATURES (SAFE PATCH) =====
  bool showLast3Days = false;
  String? lastPlayedSessionId;

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginUsersPage(),
      ),
    );
  }

  void toggleFilter() {
    setState(() {
      showLast3Days = !showLast3Days;
    });
  }

  void playAlertOnce(String id) {
    if (lastPlayedSessionId == id) return;
    lastPlayedSessionId = id;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  bool isLast3Days(DateTime date) {
    return date.isAfter(DateTime.now().subtract(const Duration(days: 3)));
  }

  Timer? timer;
  bool alarmDialogOpen = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {});
      checkExpiredSessions();
    });
    // FIREBASE SYNC
    FirebaseFirestore.instance.collection('sessions').snapshots().listen((snapshot) {
      allSessions.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        allSessions.add(KidSession(
          id: data['id'] ?? 0,
          childName: data['childName'] ?? '',
          childrenCount: data['childrenCount'] ?? 1,
          note: data['note'] ?? '',
          createdBy: data['createdBy'] ?? '',
          startTime: DateTime.parse(data['startTime']),
          endTime: DateTime.parse(data['endTime']),
          totalMoney: data['totalMoney'] ?? 0,
          ended: data['ended'] ?? false,
        ));
      }

      if (mounted) setState(() {});
    });

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  int get activeChildren {
    return allSessions
        .where((session) => !session.ended)
        .fold(0, (sum, session) => sum + session.childrenCount);
  }

  int get activeGroups {
    return allSessions.where((session) => !session.ended).length;
  }

  int get totalMoney {
    return allSessions.fold(0, (sum, session) => sum + session.totalMoney);
  }

  List<KidSession> get activeSessions {
    return allSessions.where((session) => !session.ended).toList();
  }

  List<KidSession> get historySessions {
    return allSessions;
  }

  Future<void> playAlarmSound() async {
    for (int i = 0; i < 4; i++) {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 650));
    }
  }

  void checkExpiredSessions() {
    final expired = allSessions.where((session) {
      return session.isExpired && !session.alarmDone;
    }).toList();

    if (expired.isEmpty) return;

    for (final session in expired) {
      session.alarmDone = true;
    }

    playAlarmSound();

    if (!alarmDialogOpen) {
      showAlarmDialog(expired.first);
    }
  }

  void showAlarmDialog(KidSession session) {
    alarmDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.78),
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColor.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColor.gold),
            ),
            title: const Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColor.gold),
                SizedBox(width: 8),
                Text(
                  'انتهى الوقت',
                  style: TextStyle(
                    color: AppColor.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            content: Text(
              'وقت ${session.childName} خلص.\nاختار تعمل إيه دلوقتي؟',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
          IconButton(icon: const Icon(Icons.filter_alt), onPressed: toggleFilter),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    session.endTime =
                        session.endTime.add(const Duration(minutes: 30));
                    session.totalMoney += 30 * session.childrenCount;
                    session.alarmDone = false;
                  });

                  Navigator.pop(dialogContext);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColor.border),
                ),
                child: const Text('زيادة 30 دقيقة'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    session.ended = true;
                  });

                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.green,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'إنهاء',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      alarmDialogOpen = false;
    });
  }

  void goBackToUsers() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Directionality(
          textDirection: TextDirection.rtl,
          child: LoginUsersPage(),
        ),
      ),
    );
  }

  void refreshPage() {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث البيانات')),
    );
  }

  void openHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.dark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: 420,
              child: Column(
                children: [
                  const Text(
                    'سجل اليوم',
                    style: TextStyle(
                      color: AppColor.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: historySessions.isEmpty
                        ? const Center(
                            child: Text(
                              'لا يوجد سجلات بعد',
                              style: TextStyle(color: AppColor.muted),
                            ),
                          )
                        : ListView.builder(
                            itemCount: historySessions.length,
                            itemBuilder: (context, index) {
                              final s = historySessions[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColor.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColor.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      s.ended
                                          ? Icons.check_circle_rounded
                                          : Icons.timer_rounded,
                                      color: s.ended
                                          ? AppColor.green
                                          : AppColor.gold,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '${s.childName} • ${s.childrenCount} طفل • ${s.totalMoney} جنيه • ${s.createdBy}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void openRegisterDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.74),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: RegisterDialog(
            user: widget.user,
            orderNumber: allSessions.length + 1,
            onSave: (session) {
              setState(() {
                allSessions.add(session);
              });
            },
          ),
        );
      },
    );
  }

  void endSession(KidSession session) {
    setState(() {
      session.ended = true;
    });
  }

  void addTime(KidSession session) {
    setState(() {
      session.endTime = session.endTime.add(const Duration(minutes: 30));
      session.totalMoney += 30 * session.childrenCount;
      session.alarmDone = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة 30 دقيقة لـ ${session.childName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSessions = activeSessions.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColor.bg,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.45, -0.2),
              radius: 1.15,
              colors: [
                Color(0xFF2A2108),
                AppColor.bg,
              ],
            ),
          ),
          child: Column(
            children: [
              TopBar(
                user: widget.user,
                activeChildren: activeChildren,
                activeGroups: activeGroups,
                totalMoney: totalMoney,
                onBack: goBackToUsers,
                onRefresh: refreshPage,
                onHistory: openHistory,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                  child: hasSessions
                      ? Column(
                          children: [
                            ActiveSessionsHeader(count: activeSessions.length),
                            const SizedBox(height: 12),
                            ActiveSessionsList(
                              sessions: activeSessions,
                              onEnd: endSession,
                              onAddTime: addTime,
                            ),
                            const SizedBox(height: 24),
                            GoldButton(
                              text: 'تسجيل جديد',
                              icon: Icons.add_rounded,
                              width: 190,
                              height: 54,
                              onTap: openRegisterDialog,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            MainCard(onRegister: openRegisterDialog),
                            const SizedBox(height: 24),
                            GoldButton(
                              text: 'تسجيل جديد',
                              icon: Icons.add_rounded,
                              width: 190,
                              height: 54,
                              onTap: openRegisterDialog,
                            ),
                          ],
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

/* =========================
   TOP BAR
========================= */

class TopBar extends StatelessWidget {
  final AppUser user;
  final int activeChildren;
  final int activeGroups;
  final int totalMoney;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onHistory;

  const TopBar({
    super.key,
    required this.user,
    required this.activeChildren,
    required this.activeGroups,
    required this.totalMoney,
    required this.onBack,
    required this.onRefresh,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: AppColor.top,
        border: Border(
          bottom: BorderSide(color: AppColor.border),
        ),
      ),
      child: Row(
        children: [
          SmallLiveChip(value: '$activeGroups'),
          const SizedBox(width: 8),
          TopCircleButton(
            icon: Icons.history_rounded,
            onTap: onHistory,
          ),
          const SizedBox(width: 8),
          TopCircleButton(
            icon: Icons.refresh_rounded,
            onTap: onRefresh,
          ),
          const SizedBox(width: 8),
          SmallCounter(
            value: '$totalMoney',
            label: 'جنيه',
            active: true,
          ),
          const SizedBox(width: 7),
          SmallCounter(
            value: '$activeChildren',
            label: 'أطفال',
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'سمايل كيدز',
                style: TextStyle(
                  color: AppColor.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'مرحباً ${user.name}',
                style: const TextStyle(
                  color: AppColor.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColor.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF302303),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class SmallLiveChip extends StatelessWidget {
  final String value;

  const SmallLiveChip({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.card.withOpacity(0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.person_rounded, color: AppColor.muted, size: 14),
          const SizedBox(width: 5),
          const Icon(Icons.sensors_rounded, color: AppColor.muted, size: 14),
        ],
      ),
    );
  }
}

class TopCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const TopCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: AppColor.card2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.border),
        ),
        child: Icon(icon, color: AppColor.gold, size: 20),
      ),
    );
  }
}

class SmallCounter extends StatelessWidget {
  final String value;
  final String label;
  final bool active;

  const SmallCounter({
    super.key,
    required this.value,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 45,
      decoration: BoxDecoration(
        color: active ? AppColor.goldDark : AppColor.card2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? AppColor.gold : AppColor.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColor.gold : AppColor.muted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   MAIN CARD + ACTIVE CARDS
========================= */

class MainCard extends StatelessWidget {
  final VoidCallback onRegister;

  const MainCard({
    super.key,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: AppColor.card.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: AppColor.goldDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColor.gold,
              size: 42,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'يوم جديد',
            style: TextStyle(
              color: AppColor.gold,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بتسجيل أول دخول',
            style: TextStyle(
              color: AppColor.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          GoldButton(
            text: 'تسجيل',
            icon: Icons.add_rounded,
            onTap: onRegister,
          ),
        ],
      ),
    );
  }
}

class ActiveSessionsHeader extends StatelessWidget {
  final int count;

  const ActiveSessionsHeader({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.alarm_on_rounded,
            color: AppColor.gold,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            'داخل المنطقة ($count)',
            style: const TextStyle(
              color: AppColor.gold,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveSessionsList extends StatelessWidget {
  final List<KidSession> sessions;
  final void Function(KidSession session) onEnd;
  final void Function(KidSession session) onAddTime;

  const ActiveSessionsList({
    super.key,
    required this.sessions,
    required this.onEnd,
    required this.onAddTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sessions.map((session) {
        return ActiveSessionCard(
          session: session,
          onEnd: () => onEnd(session),
          onAddTime: () => onAddTime(session),
        );
      }).toList(),
    );
  }
}

class ActiveSessionCard extends StatelessWidget {
  final KidSession session;
  final VoidCallback onEnd;
  final VoidCallback onAddTime;

  const ActiveSessionCard({
    super.key,
    required this.session,
    required this.onEnd,
    required this.onAddTime,
  });

  @override
  Widget build(BuildContext context) {
    final remainingText = formatDuration(session.remaining);
    final progress = session.progress;
    final expired = session.isExpired;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.card.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: expired ? AppColor.red : AppColor.gold.withOpacity(0.55),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.42),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: expired ? AppColor.red : AppColor.gold,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'رقم',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${session.id}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 5,
                      children: [
                        TinyBadge(
                          text: '${session.childrenCount} طفل',
                          icon: Icons.groups_2_rounded,
                        ),
                        Text(
                          '${session.totalMinutes} د • ${session.totalMoney} ج',
                          style: const TextStyle(
                            color: AppColor.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    remainingText,
                    style: TextStyle(
                      color: expired ? AppColor.red : AppColor.gold,
                      fontSize: 25,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expired ? 'انتهى' : 'متبقي',
                    style: TextStyle(
                      color: expired ? AppColor.red : AppColor.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (session.note.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                session.note,
                style: const TextStyle(
                  color: AppColor.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 7,
              width: double.infinity,
              color: AppColor.dark,
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerRight,
                child: Container(
                  color: expired ? AppColor.red : AppColor.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DarkActionButton(
                  text: 'زيادة وقت',
                  icon: Icons.add_rounded,
                  onTap: onAddTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GreenActionButton(
                  text: 'إنهاء',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: onEnd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TinyBadge extends StatelessWidget {
  final String text;
  final IconData icon;

  const TinyBadge({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.goldDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.gold, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColor.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class DarkActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const DarkActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 19),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.border),
          backgroundColor: AppColor.dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class GreenActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const GreenActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black, size: 19),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.green,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final double width;
  final double height;

  const GoldButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.width = 150,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.gold,
          elevation: 8,
          shadowColor: AppColor.gold.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

/* =========================
   REGISTER DIALOG
========================= */

class RegisterDialog extends StatefulWidget {
  final AppUser user;
  final int orderNumber;
  final void Function(KidSession session) onSave;

  const RegisterDialog({
    super.key,
    required this.user,
    required this.orderNumber,
    required this.onSave,
  });

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final nameController = TextEditingController();
  final noteController = TextEditingController();

  int childrenCount = 1;
  int minutes = 60;
  int pricePerChild = 60;

  int get totalMoney => childrenCount * pricePerChild;

  void chooseHour() {
    setState(() {
      minutes = 60;
      pricePerChild = 60;
    });
  }

  void chooseHalfHour() {
    setState(() {
      minutes = 30;
      pricePerChild = 30;
    });
  }

  void saveSession() {
    final childName = nameController.text.trim();

    if (childName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اسم الطفل أو المجموعة')),
      );
      return;
    }

    final now = DateTime.now();

    final session = KidSession(
      id: DateTime.now().millisecondsSinceEpoch,
      childName: childName,
      childrenCount: childrenCount,
      note: noteController.text.trim(),
      createdBy: widget.user.name,
      startTime: now,
      endTime: now.add(Duration(minutes: minutes)),
      totalMoney: totalMoney,
    );

    FirebaseFirestore.instance.collection('sessions').add({
      'id': session.id,
      'childName': session.childName,
      'childrenCount': session.childrenCount,
      'note': session.note,
      'createdBy': session.createdBy,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime.toIso8601String(),
      'totalMoney': session.totalMoney,
      'ended': session.ended,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 470),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: AppColor.dark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColor.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.65),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColor.muted,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'تسجيل جديد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColor.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '#${widget.orderNumber}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const FieldLabel(
                  text: 'الاسم (طفل أو مجموعة)',
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 7),
                AppInput(
                  controller: nameController,
                  hint: 'مثلاً: يوسف ومنى',
                  height: 45,
                ),
                const SizedBox(height: 14),
                const FieldLabel(
                  text: 'عدد الأطفال',
                  icon: Icons.groups_2_rounded,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleControlButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        setState(() {
                          if (childrenCount < 20) childrenCount++;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColor.card,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColor.gold.withOpacity(0.55),
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          '$childrenCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleControlButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        setState(() {
                          if (childrenCount > 1) childrenCount--;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [1, 2, 3, 4, 5].map((number) {
                    final selected = childrenCount == number;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              childrenCount = number;
                            });
                          },
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  selected ? AppColor.gold : AppColor.card2,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              '$number',
                              style: TextStyle(
                                color: selected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المدة والسعر (للطفل الواحد)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: PlanCard(
                        title: 'نص ساعة',
                        subtitle: '30د - 30ج',
                        selected: minutes == 30,
                        onTap: chooseHalfHour,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PlanCard(
                        title: 'ساعة',
                        subtitle: '60د - 60ج',
                        selected: minutes == 60,
                        onTap: chooseHour,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ValueBox(
                        label: 'دقيقة',
                        value: '$minutes',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ValueBox(
                        label: 'إجمالي جنيه',
                        value: '$totalMoney',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const FieldLabel(
                  text: 'علامة / ملاحظة',
                  icon: Icons.edit_note_rounded,
                ),
                const SizedBox(height: 7),
                AppInput(
                  controller: noteController,
                  hint: 'مثلاً: تيشيرت أحمر، الأم بره',
                  height: 72,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColor.border),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: saveSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.gold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'تسجيل',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   SMALL WIDGETS
========================= */

class FieldLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const FieldLabel({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.gold, size: 16),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double height;
  final int maxLines;

  const AppInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.height,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColor.muted,
            fontSize: 13,
          ),
          filled: true,
          fillColor: AppColor.bg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColor.gold.withOpacity(0.45),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColor.gold,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircleControlButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColor.card2,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A2108) : AppColor.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColor.gold : AppColor.border,
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColor.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ValueBox extends StatelessWidget {
  final String label;
  final String value;

  const ValueBox({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColor.muted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.border),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}