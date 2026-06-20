import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/routes/routes.dart';
import '../../controllers/auth_controller.dart';
import '../providers/register_notifier.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _pageController = PageController();

  // Step 1 controllers — kept local so text persists across rebuilds
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showSuccess = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Sync text controllers into provider before advancing
    final n = ref.read(registerProvider.notifier);
    n.setFullName(_nameController.text.trim());
    n.setEmail(_emailController.text.trim());
    n.setPhone(_phoneController.text.trim());
    n.setPassword(_passwordController.text);

    ref.read(registerProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    final step = ref.read(registerProvider).step;
    if (step == 0) {
      context.pop();
    } else {
      ref.read(registerProvider.notifier).previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleRegister() async {
    final formData = ref.read(registerProvider).toJson();
    await ref.read(authControllerProvider.notifier).register(formData);

    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (auth.token != null) {
      setState(() => _showSuccess = true);
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      ref.read(registerProvider.notifier).reset();
      context.go(AppRoutes.postRegistration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registerProvider);
    final auth = ref.watch(authControllerProvider);

    if (_showSuccess) {
      return AppScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const Gap(24),
              Text(
                'Congratulations!',
                style: AppTextStyles.title.copyWith(fontSize: 28),
              ),
              const Gap(12),
              Text(
                'We are setting you up...',
                style: AppTextStyles.body.copyWith(fontSize: 16),
              ),
              const Gap(32),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      body: Column(
        children: [
          // ── Header: back + progress bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.text,
                    ),
                    const Spacer(),
                    Text(
                      'Step ${form.step + 1} of 3',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        margin: EdgeInsets.only(
                          left: i == 0 ? 16 : 3,
                          right: i == 2 ? 0 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: i <= form.step
                              ? AppColors.primary
                              : AppColors.subtitle.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Error banner ─────────────────────────────────────────────────────
          if (auth.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  auth.error!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // ── Steps ────────────────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  onNext: _nextStep,
                ),
                _Step2(onNext: _nextStep),
                _Step3(
                  onSubmit: _handleRegister,
                  loading: auth.loading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1
// ─────────────────────────────────────────────────────────────────────────────

class _Step1 extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback onNext;

  const _Step1({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/auth_register.json',
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const Gap(8),
          Text('Create\nYour Account', style: AppTextStyles.title),
          const Gap(4),
          Text(
            'Step 1 of 3',
            style: AppTextStyles.body.copyWith(fontSize: 13),
          ),
          const Gap(24),

          AppTextField(
            hint: 'Full Name',
            controller: nameController,
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.subtitle),
            onChanged: notifier.setFullName,
          ),
          const Gap(14),

          AppTextField(
            hint: 'Email Address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.subtitle),
            onChanged: notifier.setEmail,
          ),
          const Gap(14),

          // Phone with Nigerian prefix
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            onChanged: notifier.setPhone,
            decoration: InputDecoration(
              hintText: '801 234 5678',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇳🇬', style: TextStyle(fontSize: 20)),
                    const Gap(6),
                    Text(
                      '+234',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 1,
                      height: 20,
                      color: AppColors.subtitle.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(14),

          PasswordField(
            controller: passwordController,
            onChanged: notifier.setPassword,
          ),
          const Gap(12),

          // Live password checklist
          _PasswordChecklist(form: form),

          const Gap(28),

          PrimaryButton(
            text: 'Next Step',
            icon: Icons.arrow_forward_rounded,
            onPressed: form.isStep1Valid ? onNext : null,
          ),
          const Gap(20),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    'Login',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2
// ─────────────────────────────────────────────────────────────────────────────

class _Step2 extends ConsumerWidget {
  final VoidCallback onNext;

  const _Step2({required this.onNext});

  static const _states = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
    'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti',
    'Enugu', 'FCT', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina',
    'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo',
    'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
  ];

  static const _ages = [
    'Under 16', '16–18', '19–22', '23–26', '27–30', '31–35', 'Above 35',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/auth_location.json',
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const Gap(8),
          Text('Step 2 of 3', style: AppTextStyles.title),
          const Gap(24),

          _DropdownField(
            label: 'Country',
            value: form.country,
            items: const ['Nigeria'],
            onChanged: notifier.setCountry,
          ),
          const Gap(14),

          _DropdownField(
            label: 'State',
            value: form.state.isEmpty ? null : form.state,
            hint: 'Select your state',
            items: _states,
            onChanged: notifier.setState,
          ),
          const Gap(14),

          AppTextField(
            hint: 'Institution / School',
            controller: TextEditingController(text: form.institution),
            prefixIcon: const Icon(Icons.school_outlined, color: AppColors.subtitle),
          ),
          const Gap(14),

          _DropdownField(
            label: 'Your Age',
            value: form.age.isEmpty ? null : form.age,
            hint: 'Select your age range',
            items: _ages,
            onChanged: notifier.setAge,
          ),
          const Gap(28),

          PrimaryButton(
            text: 'Next Step',
            icon: Icons.arrow_forward_rounded,
            onPressed: form.isStep2Valid ? onNext : null,
          ),
          const Gap(32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3
// ─────────────────────────────────────────────────────────────────────────────

class _Step3 extends ConsumerWidget {
  final Future<void> Function() onSubmit;
  final bool loading;

  const _Step3({required this.onSubmit, required this.loading});

  static const _exams = [
    ('WAEC', Icons.school_rounded),
    ('NECO', Icons.menu_book_rounded),
    ('JAMB', Icons.assignment_rounded),
    ('UTME', Icons.emoji_events_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/auth_interests.json',
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const Gap(8),
          Text('Select Your\nExams', style: AppTextStyles.title),
          const Gap(4),
          Text(
            'Choose the exams you are interested in',
            style: AppTextStyles.body.copyWith(fontSize: 14),
          ),
          const Gap(24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exams.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final (label, icon) = _exams[index];
              final selected = form.interests.contains(label);

              return GestureDetector(
                onTap: () => notifier.toggleInterest(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.subtitle.withOpacity(0.2),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (selected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.subtitle,
                              size: 28,
                            ),
                            const Gap(6),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Gap(28),

          PrimaryButton(
            text: 'Create Account 🎉',
            loading: loading,
            onPressed: form.isStep3Valid ? onSubmit : null,
          ),
          const Gap(32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordChecklist extends StatelessWidget {
  final RegisterFormState form;

  const _PasswordChecklist({required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CheckItem(label: 'At least 8 characters', met: form.hasMinLength),
        const Gap(4),
        _CheckItem(label: 'Contains a number', met: form.hasNumber),
        const Gap(4),
        _CheckItem(label: 'Contains uppercase letter', met: form.hasUppercase),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool met;

  const _CheckItem({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: met ? AppColors.success : AppColors.subtitle.withOpacity(0.4),
            ),
          ),
          child: met
              ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
              : null,
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: met ? AppColors.success : AppColors.subtitle,
            fontWeight: met ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hint;
  final void Function(String) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitle,
          ),
        ),
        const Gap(6),
        DropdownButtonFormField<String>(
          value: value,
          hint: hint != null ? Text(hint!) : null,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: AppColors.subtitle.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: AppColors.subtitle.withOpacity(0.2)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items:
              items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}