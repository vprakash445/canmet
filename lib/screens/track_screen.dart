import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../utils/providers.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _fastingCtrl = TextEditingController();
  final _postMealCtrl = TextEditingController();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _stressCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();

  bool _saved = false;
  bool _loadingPrev = true;

  @override
  void initState() {
    super.initState();
    _loadTodaysLog();
  }

  @override
  void dispose() {
    _fastingCtrl.dispose();
    _postMealCtrl.dispose();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _stressCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  String get _todayKey {
    final now = DateTime.now();
    return 'log_${now.year}_${now.month}_${now.day}';
  }

  Future<void> _loadTodaysLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todayKey);
    if (raw != null) {
      final parts = raw.split('|');
      if (parts.length == 8) {
        _fastingCtrl.text = parts[0];
        _postMealCtrl.text = parts[1];
        _sysCtrl.text = parts[2];
        _diaCtrl.text = parts[3];
        _weightCtrl.text = parts[4];
        _waistCtrl.text = parts[5];
        _stressCtrl.text = parts[6];
        _sleepCtrl.text = parts[7];
      }
    }
    if (mounted) setState(() => _loadingPrev = false);
  }

  Future<void> _saveLog() async {
    final prefs = await SharedPreferences.getInstance();
    final data = [
      _fastingCtrl.text,
      _postMealCtrl.text,
      _sysCtrl.text,
      _diaCtrl.text,
      _weightCtrl.text,
      _waistCtrl.text,
      _stressCtrl.text,
      _sleepCtrl.text,
    ].join('|');
    await prefs.setString(_todayKey, data);

    if (!mounted) return;
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LanguageProvider>().lang;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppStrings.t('track_title', l)),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                AppStrings.t('track_sub', l),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
      body: _loadingPrev
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  // ── Blood glucose ────────────────────────────────────
                  _LogSection(
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFFE24B4A),
                    title: AppStrings.t('blood_glucose', l),
                    fields: [
                      _LogRow(
                          label: AppStrings.t('fasting', l),
                          ctrl: _fastingCtrl,
                          unit: 'mg/dL'),
                      _LogRow(
                          label: AppStrings.t('post_meal', l),
                          ctrl: _postMealCtrl,
                          unit: 'mg/dL'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Blood pressure ───────────────────────────────────
                  _LogSection(
                    icon: Icons.monitor_heart_outlined,
                    color: const Color(0xFF185FA5),
                    title: AppStrings.t('blood_pressure', l),
                    fields: [
                      _LogRow(
                          label: AppStrings.t('systolic', l),
                          ctrl: _sysCtrl,
                          unit: 'mmHg'),
                      _LogRow(
                          label: AppStrings.t('diastolic', l),
                          ctrl: _diaCtrl,
                          unit: 'mmHg'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Weight & waist ───────────────────────────────────
                  _LogSection(
                    icon: Icons.monitor_weight_outlined,
                    color: const Color(0xFF1D9E75),
                    title: AppStrings.t('weight_waist', l),
                    fields: [
                      _LogRow(
                          label: AppStrings.t('weight', l),
                          ctrl: _weightCtrl,
                          unit: 'kg'),
                      _LogRow(
                          label: AppStrings.t('waist', l),
                          ctrl: _waistCtrl,
                          unit: 'cm'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Stress & sleep ───────────────────────────────────
                  _LogSection(
                    icon: Icons.bedtime_outlined,
                    color: AppColors.warning,
                    title: AppStrings.t('stress_sleep', l),
                    fields: [
                      _LogRow(
                          label: AppStrings.t('stress_score', l),
                          ctrl: _stressCtrl,
                          unit: '0–10'),
                      _LogRow(
                          label: AppStrings.t('sleep_hours', l),
                          ctrl: _sleepCtrl,
                          unit: 'hrs'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Warning card ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.t('warning_card', l),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F1D1D),
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Save button ──────────────────────────────────────
                  ElevatedButton.icon(
                    onPressed: _saveLog,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(AppStrings.t('save_log', l)),
                  ),

                  // ── Success banner ───────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _saved
                        ? Container(
                            key: const ValueKey('saved'),
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.t('saved_ok', l),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Log section card ─────────────────────────────────────────────────────────

class _LogSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<_LogRow> fields;

  const _LogSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        children: [
          // Section header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
              border: Border(
                  bottom: BorderSide(color: color.withOpacity(0.15))),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Fields
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Column(children: fields),
          ),
        ],
      ),
    );
  }
}

// ─── Log row (label + input) ──────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String unit;

  const _LogRow({
    required this.label,
    required this.ctrl,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: unit,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 9),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
