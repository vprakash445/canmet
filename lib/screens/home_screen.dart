import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../utils/providers.dart';
import '../utils/module_data.dart';
import 'module_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(String l) {
    final h = DateTime.now().hour;
    if (h < 12) return AppStrings.t('good_morning', l);
    if (h < 17) return AppStrings.t('good_afternoon', l);
    return AppStrings.t('good_evening', l);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final user = context.watch<UserProvider>();
    final tasks = context.watch<TaskProvider>();
    final l = lang.lang;

    // Count modules with at least 1 task done
    final modulesDone =
        allModules.where((m) => tasks.completedCount(m.id) > 0).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Sticky App Bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HomeHeader(
                greeting: _greeting(l),
                name: user.name,
                day: user.treatmentDay,
                lang: lang,
                l: l,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats row ───────────────────────────────────────────
                Row(
                  children: [
                    _StatCard(
                      label: AppStrings.t('adherence', l),
                      value: '85%',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: AppStrings.t('modules_done', l),
                      value: '$modulesDone/7',
                      color: const Color(0xFF7F77DD),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: AppStrings.t('day_streak', l),
                      value: '${user.treatmentDay}🔥',
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Today's message ─────────────────────────────────────
                _SectionTitle(AppStrings.t('todays_message', l)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                  ),
                  child: Text(
                    AppStrings.t('daily_tip', l),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Modules heading ─────────────────────────────────────
                _SectionTitle(AppStrings.t('your_modules', l)),
                const SizedBox(height: 10),

                // ── Modules grid ────────────────────────────────────────
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allModules.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (ctx, i) => _ModuleCard(
                    module: allModules[i],
                    l: l,
                    completedTasks: tasks.completedCount(allModules[i].id),
                    totalTasks: allModules[i].tasks(l).length,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header inside SliverAppBar ───────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final int day;
  final LanguageProvider lang;
  final String l;

  const _HomeHeader({
    required this.greeting,
    required this.name,
    required this.day,
    required this.lang,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $name 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${AppStrings.t('treatment_day', l)} $day  •  ${AppStrings.t('keep_it_up', l)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Language toggle
              GestureDetector(
                onTap: lang.toggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.45)),
                  ),
                  child: Text(
                    l == 'en' ? 'हिंदी' : 'EN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Module card ──────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final ModuleData module;
  final String l;
  final int completedTasks;
  final int totalTasks;

  const _ModuleCard({
    required this.module,
    required this.l,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModuleDetailScreen(module: module),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: module.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(module.icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                if (completedTasks > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: module.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$completedTasks/$totalTasks',
                      style: TextStyle(
                        fontSize: 10,
                        color: module.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              module.name(l),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              module.sub(l),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                backgroundColor: module.color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(module.color),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
