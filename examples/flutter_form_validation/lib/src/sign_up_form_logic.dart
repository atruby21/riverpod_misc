import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'inputs.dart';

part 'sign_up_form_logic.freezed.dart';
part 'sign_up_form_logic.g.dart';

@freezed
class SignUpFormState with _$SignUpFormState {
  const factory SignUpFormState({
    @Default(Email.pure()) Email email,
    @Default(Password.pure()) Password password,
    @Default(ConfirmPassword.pure()) ConfirmPassword confirmPassword,
    @Default(FormzStatus.pure) FormzStatus status,
  }) = _SignUpFormState;
}

@riverpod
class SignUpFormLogic extends _$SignUpFormLogic {
  @override
  SignUpFormState build() {
    return const SignUpFormState();
  }

  void updateInput({String? email, String? password, String? confirmPassword}) {
    state = state.copyWith(
      email: email != null ? Email.dirty(email) : state.email,
      password: password != null ? Password.dirty(password) : state.password,
      confirmPassword:
          _updateConfirmPassword(original: password, value: confirmPassword),
    );
    _updateStatus();
  }

  ConfirmPassword _updateConfirmPassword({
    String? original,
    String? value,
  }) {
    if (original != null && value != null) {
      return ConfirmPassword.dirty(
          original: Password.dirty(original), value: value);
    } else if (original != null) {
      return ConfirmPassword.dirty(
          original: Password.dirty(original),
          value: state.confirmPassword.value);
    } else if (value != null) {
      return ConfirmPassword.dirty(value: value, original: state.password);
    } else {
      return const ConfirmPassword.pure();
    }
  }

  void _updateStatus() {
    state = state.copyWith(
      status: Formz.validate([
        state.email,
        state.password,
        state.confirmPassword,
      ]),
    );
  }

  void submit() async {
    state = state.copyWith(
        status: Formz.validate([
      state.email,
      state.password,
      state.confirmPassword,
    ]));
    if (state.status.isValidated) {
      state = state.copyWith(status: FormzStatus.submissionInProgress);
      await Future<void>.delayed(const Duration(seconds: 1));
      state = state.copyWith(status: FormzStatus.submissionSuccess);
    }
  }
}
