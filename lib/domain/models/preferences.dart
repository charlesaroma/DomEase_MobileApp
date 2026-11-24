// ─── Preferences ──────────────────────────────────────────────────
// Choices that belong to this phone rather than the household: how the app
// looks and which reminders it may send.

enum Appearance {
  system('Match my phone'),
  light('Light'),
  dark('Dark');

  const Appearance(this.label);
  final String label;
}

class Preferences {
  const Preferences({
    this.appearance = Appearance.system,
    this.remindTasks = true,
    this.remindLowStock = true,
    this.weeklyPlan = true,
  });

  final Appearance appearance;

  /// Cleaning tasks due today (PRD 4.3, push reminders).
  final bool remindTasks;

  /// Supplies marked low that are still not bought.
  final bool remindLowStock;

  /// The new week's meal plan, on Sunday evening.
  final bool weeklyPlan;

  Preferences copyWith({Appearance? appearance, bool? remindTasks, bool? remindLowStock, bool? weeklyPlan}) => Preferences(
        appearance: appearance ?? this.appearance,
        remindTasks: remindTasks ?? this.remindTasks,
        remindLowStock: remindLowStock ?? this.remindLowStock,
        weeklyPlan: weeklyPlan ?? this.weeklyPlan,
      );
}
