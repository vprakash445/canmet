import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../utils/strings.dart';
import '../utils/providers.dart';
import '../utils/module_data.dart';

class ModuleDetailScreen extends StatelessWidget {
  final ModuleData module;
  const ModuleDetailScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.lang;
    final tasks = context.watch<TaskProvider>();
    final taskList = module.tasks(l);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: module.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: module.color,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 50,
                  20,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(module.name(l),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(module.sub(l),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _KeyMessageCard(module: module, l: l),
                const SizedBox(height: 14),
                ...module.sections.map(
                    (sec) => _SectionCard(section: sec, color: module.color, l: l)),
                const SizedBox(height: 4),
                _DailyReminderCard(module: module, l: l),
                const SizedBox(height: 14),
                _TaskCard(module: module, l: l, taskList: taskList, tasks: tasks),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Key message ─────────────────────────────────────────────────────────────

class _KeyMessageCard extends StatelessWidget {
  final ModuleData module;
  final String l;
  const _KeyMessageCard({required this.module, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: module.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: module.color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: module.color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(module.keyMsg(l),
                style: TextStyle(
                    fontSize: 13,
                    color: module.color,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─── Section card with optional infographic image ─────────────────────────────

class _SectionCard extends StatefulWidget {
  final ModuleSection section;
  final Color color;
  final String l;
  const _SectionCard({required this.section, required this.color, required this.l});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.section.imagePath != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tap header ───────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.section.title(widget.l),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable content ────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Infographic image — shown FIRST, full width
                if (hasImage) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: widget.color.withOpacity(0.15))),
                    ),
                    child: ClipRRect(
                      child: Image.asset(
                        widget.section.imagePath!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => Container(
                          height: 60,
                          color: widget.color.withOpacity(0.05),
                          child: Center(
                            child: Icon(Icons.image_outlined,
                                color: widget.color.withOpacity(0.3), size: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: widget.color.withOpacity(0.12)),
                ],

                // Text body below image
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    hasImage ? 14 : 28, 10, 14, 14),
                  child: Text(
                    widget.section.body(widget.l),
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Daily reminder ───────────────────────────────────────────────────────────

class _DailyReminderCard extends StatelessWidget {
  final ModuleData module;
  final String l;
  const _DailyReminderCard({required this.module, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📱', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l == 'hi' ? 'दैनिक याद' : 'Daily Reminder',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 3),
                Text(module.dailyReminder(l),
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF78350F),
                        height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tasks card ───────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final ModuleData module;
  final String l;
  final List<String> taskList;
  final TaskProvider tasks;

  const _TaskCard({
    required this.module,
    required this.l,
    required this.taskList,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final completed = tasks.completedCount(module.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 8),
            child: Row(
              children: [
                Text(AppStrings.t('todays_tasks', l),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: module.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('$completed/${taskList.length}',
                      style: TextStyle(
                          fontSize: 11,
                          color: module.color,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          ...List.generate(taskList.length, (i) {
            final done = tasks.isTaskDone(module.id, i);
            return _TaskItem(
              text: taskList[i],
              isDone: done,
              color: module.color,
              onToggle: () =>
                  context.read<TaskProvider>().toggleTask(module.id, i),
              isLast: i == taskList.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String text;
  final bool isDone;
  final Color color;
  final VoidCallback onToggle;
  final bool isLast;

  const _TaskItem({
    required this.text,
    required this.isDone,
    required this.color,
    required this.onToggle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDone ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: isDone ? color : Colors.grey.shade400,
                        width: 1.5),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDone
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 48, color: AppColors.cardBorder),
      ],
    );
  }
}
