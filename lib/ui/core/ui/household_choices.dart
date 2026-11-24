// ─── Household Choices ────────────────────────────────────────────
// Every question about the home, in the order onboarding asks it. Shared by
// onboarding and by Edit my answers, so both always offer the same choices.
import 'package:domease/domain/models/household.dart';

class Choice {
  const Choice(this.id, this.emoji, this.label, {this.premium = false});

  final String id;
  final String emoji;
  final String label;

  /// Shown, but locked until Premium (FR-ON-4).
  final bool premium;
}

/// A heading with one highlighted word: before, highlight, after.
typedef Heading = (String, String, String);

const whoHeading = ('Who lives in your ', 'home', '?');
final whoChoices = [
  const (HouseholdType.bachelor, '🧍'),
  const (HouseholdType.couple, '💑'),
  const (HouseholdType.family, '👨‍👩‍👧'),
  const (HouseholdType.singleParent, '🤱'),
];

const sizeHeading = ('How many people ', 'eat', ' at home?');

const moodHeading = ('First off, how has running the ', 'house', ' felt lately?');
const moodChoices = [
  Choice('on_top', '🔥', "I'm on top of it, I want fresh ideas"),
  Choice('samey', '🙂', "It's fine, but a bit samey"),
  Choice('rut', '😐', "I'm stuck in a rut"),
  Choice('chore', '😩', 'Honestly, it feels like a chore'),
  Choice('behind', '🙃', "I'm barely keeping up"),
];

const goalsHeading = ('What would make your ', 'week', ' easier?');
const goalChoices = [
  Choice('plan_ahead', '📋', 'Meals planned ahead'),
  Choice('share_cleaning', '🧹', 'Cleaning shared fairly'),
  Choice('one_list', '🛒', 'One shopping list for everyone'),
  Choice('spend_less', '💸', 'Spending less at the market'),
  Choice('less_waste', '♻️', 'Less food wasted'),
  Choice('healthier', '💚', 'Healthier food'),
];

const mealsHeading = ('Which meals do you want ', 'help', ' with?');
const mealChoices = [
  Choice('breakfast', '🥣', 'Breakfasts before the school run'),
  Choice('lunch', '🍛', 'Lunches'),
  Choice('dinner', '🍲', 'Weeknight dinners'),
  Choice('snack', '🥭', 'School snacks and packed lunches'),
  Choice('pastry', '🥐', 'Baking and pastries'),
];

const currencyHeading = ('Where do you ', 'shop', '?');
const currencyChoices = [
  Choice('UGX', '🇺🇬', 'Uganda · Shillings'),
  Choice('KES', '🇰🇪', 'Kenya · Shillings'),
  Choice('TZS', '🇹🇿', 'Tanzania · Shillings'),
  Choice('GHS', '🇬🇭', 'Ghana · Cedi'),
  Choice('NGN', '🇳🇬', 'Nigeria · Naira'),
  Choice('ZAR', '🇿🇦', 'South Africa · Rand'),
  Choice('USD', '🇺🇸', 'United States · Dollar'),
  Choice('GBP', '🇬🇧', 'United Kingdom · Pound'),
  Choice('EUR', '🇪🇺', 'Europe · Euro'),
  Choice('INR', '🇮🇳', 'India · Rupee'),
  Choice('CAD', '🇨🇦', 'Canada · Dollar'),
  Choice('AUD', '🇦🇺', 'Australia · Dollar'),
];

const dietHeading = ('Any ', 'dietary', ' needs at home?');
const dietChoices = [
  Choice('none', '🍽️', 'No, we eat everything'),
  Choice('veg', '🥬', 'More vegetables, less meat'),
  Choice('diabetic', '🩺', 'Diabetic friendly ideas', premium: true),
  Choice('pcos', '🌸', 'PCOS friendly ideas', premium: true),
];

const readyHeading = ('Your ', 'home', ' is ready');
const premiumHeading = ('Get the ', 'whole', ' of DomEase');
