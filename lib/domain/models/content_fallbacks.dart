// ─── Content Fallbacks ────────────────────────────────────────────
// What the app shows when the server can't be reached: the same help
// questions, Premium list and occasions the admin starts with (App content).
import 'package:domease/domain/models/content.dart';

const fallbackFaqs = [
  Faq(
    question: 'How is the meal plan made?',
    answer:
        'DomEase plans 35 meals a week from your answers: who lives with you, how many eat at home and any dietary needs. '
        'Amounts scale to your household. Tap Swap week on Meals for fresh ideas.',
  ),
  Faq(
    question: 'Can I add my own cleaning zones?',
    answer:
        'Yes. On Clean, tap Add a zone. Pick a ready made one like Compound, Laundry or Animals, or type a name of your own. '
        'Use the three dots on a zone to rename it, move it, give it to someone or remove it.',
  ),
  Faq(
    question: 'How do I share DomEase with the people I live with?',
    answer:
        'Household sharing comes with Premium. Open You, then your household, and share the invite code. '
        'They sign in and choose Join a home.',
  ),
  Faq(
    question: 'How do I pay for Premium?',
    answer: 'With MTN Mobile Money or Airtel Money, monthly or yearly. DomEase never sees or stores your mobile money PIN.',
  ),
  Faq(
    question: 'How do I change my currency?',
    answer: 'Open You, then Settings, then Currency. Prices, the shopping list and the converter all follow it.',
  ),
  Faq(
    question: 'Is the diabetic and PCOS guidance medical advice?',
    answer: 'No. It is general guidance only. Speak to a doctor or dietitian about your own needs.',
  ),
  Faq(
    question: 'How do I delete my account?',
    answer: 'Open You, then your profile, then Delete account. Your account and the home you set up are deleted for good.',
  ),
];

const fallbackPremiumFeatures = [
  PremiumFeatureInfo(
    id: 'houseHelp',
    title: 'House Help',
    description: 'Vetting questionnaire and guides',
  ),
  PremiumFeatureInfo(
    id: 'payroll',
    title: 'House help pay',
    description: 'Salary, advances and days off, with a payslip to send on WhatsApp',
  ),
  PremiumFeatureInfo(
    id: 'sharing',
    title: 'Household sharing',
    description: 'Everyone at home on one plan, one list',
  ),
  PremiumFeatureInfo(
    id: 'allergies',
    title: 'Allergy profiles',
    description: 'For each person, with warnings on recipes',
  ),
  PremiumFeatureInfo(
    id: 'occasions',
    title: 'Occasion menus',
    description: 'Birthday, Christmas, Easter and Eid',
  ),
  PremiumFeatureInfo(
    id: 'healthyPastry',
    title: 'Healthier pastry swaps',
    description: 'Lighter versions of the pastries you love',
  ),
  PremiumFeatureInfo(
    id: 'dietary',
    title: 'Diabetic and PCOS ideas',
    description: 'Meal ideas with the dietary disclaimer',
  ),
  PremiumFeatureInfo(
    id: 'favourites',
    title: 'Favourite meals',
    description: 'Keep the dishes your home asks for',
  ),
  PremiumFeatureInfo(
    id: 'trends',
    title: 'Eating trends',
    description: 'What your home eats most, and how varied the week is',
  ),
  PremiumFeatureInfo(
    id: 'budget',
    title: 'Budget insights',
    description: 'A monthly food budget, and what each market trip really cost',
  ),
  PremiumFeatureInfo(
    id: 'autoPlan',
    title: 'Automatic weekly planning',
    description: 'Next week planned every Sunday',
    comingSoon: true,
  ),
  PremiumFeatureInfo(
    id: 'adFree',
    title: 'No ads',
    description: 'Every screen, ad free',
  ),
];

const fallbackOccasions = [
  Occasion(id: 'birthday', name: 'Birthday'),
  Occasion(id: 'christmas', name: 'Christmas'),
  Occasion(id: 'easter', name: 'Easter'),
  Occasion(id: 'eid', name: 'Eid'),
];
