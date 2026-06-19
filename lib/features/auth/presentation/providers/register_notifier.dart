import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterFormState {
  final int step;

  // Step 1
  final String fullName;
  final String email;
  final String phone;
  final String password;

  // Step 2
  final String country;
  final String state;
  final String institution;
  final String age;

  // Step 3
  final List<String> interests;

  const RegisterFormState({
    this.step = 0,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.country = 'Nigeria',
    this.state = '',
    this.institution = '',
    this.age = '',
    this.interests = const [],
  });

  RegisterFormState copyWith({
    int? step,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? country,
    String? state,
    String? institution,
    String? age,
    List<String>? interests,
  }) {
    return RegisterFormState(
      step: step ?? this.step,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      country: country ?? this.country,
      state: state ?? this.state,
      institution: institution ?? this.institution,
      age: age ?? this.age,
      interests: interests ?? this.interests,
    );
  }

  // Validation
  bool get isStep1Valid =>
      fullName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      password.length >= 8;

  bool get isStep2Valid => country.isNotEmpty && state.isNotEmpty;

  bool get isStep3Valid => interests.isNotEmpty;

  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': '+234$phone',
        'password': password,
        'country': country,
        'state': state,
        'institution': institution,
        'age': age,
        'interests': interests,
      };
}

class RegisterNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void nextStep() {
    if (state.step < 2) state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPhone(String v) => state = state.copyWith(phone: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setCountry(String v) => state = state.copyWith(country: v);
  void setState(String v) => state = state.copyWith(state: v);
  void setInstitution(String v) => state = state.copyWith(institution: v);
  void setAge(String v) => state = state.copyWith(age: v);

  void toggleInterest(String interest) {
    final current = List<String>.from(state.interests);
    current.contains(interest) ? current.remove(interest) : current.add(interest);
    state = state.copyWith(interests: current);
  }

  void reset() => state = const RegisterFormState();
}

final registerProvider = NotifierProvider<RegisterNotifier, RegisterFormState>(
  RegisterNotifier.new,
);