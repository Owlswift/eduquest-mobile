import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(0) int registerStep,
    @Default('') String fullName,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String password,
    @Default('Nigeria') String country,
    @Default('') String state,
    @Default('') String institution,
    @Default('') String age,
    @Default(<String>[]) List<String> interests,
    @Default(false) bool isLoading,
    @Default(false) bool isPasswordVisible,
    String? errorMessage,
    String? successMessage,
  }) = _AuthState;
}