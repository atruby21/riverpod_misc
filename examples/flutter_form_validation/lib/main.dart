import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formz/formz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/sign_up_form_logic.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SignUpFormState>(signUpFormLogicProvider, (prev, next) {
      if (next.status.isSubmissionSuccess) {
        showDialog(
            context: context, builder: (context) => const SuccessDialog());
      }
    });
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: const [
            EmailTextField(),
            PasswordTextField(),
            ConfirmPasswordTextField(),
            SubmitButton(),
          ],
        ),
      )),
    );
  }
}

class EmailTextField extends HookConsumerWidget {
  const EmailTextField({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('EmailTextField rebuild');
    final notifier = ref.watch(signUpFormLogicProvider.notifier);

    final isValid =
        ref.watch(signUpFormLogicProvider.select((value) => value.email.valid));

    final focusNode = useFocusNode();

    final canShowError = useHasUnfocused(focusNode);

    return TextFormField(
      focusNode: focusNode,
      onChanged: (value) => notifier.updateInput(email: value),
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: canShowError
            ? isValid
                ? null
                : 'Please ensure the email entered is valid'
            : null,
      ),
    );
  }
}

class PasswordTextField extends HookConsumerWidget {
  const PasswordTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('PasswordTextField rebuild');
    final notifier = ref.watch(signUpFormLogicProvider.notifier);

    final isValid = ref
        .watch(signUpFormLogicProvider.select((value) => value.password.valid));

    final focusNode = useFocusNode();

    final canShowError = useHasUnfocused(focusNode);

    return TextFormField(
      focusNode: focusNode,
      onChanged: (value) => notifier.updateInput(password: value),
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: canShowError
            ? isValid
                ? null
                : 'Password must be at least 8 characters and contain at least one letter and number'
            : null,
      ),
    );
  }
}

class ConfirmPasswordTextField extends HookConsumerWidget {
  const ConfirmPasswordTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ConfirmPasswordTextField rebuild');
    final notifier = ref.watch(signUpFormLogicProvider.notifier);

    final isValid = ref.watch(
        signUpFormLogicProvider.select((value) => value.confirmPassword.valid));

    // included to rebuild if the password changes
    ref.watch(signUpFormLogicProvider.select((value) => value.password.value));

    final focusNode = useFocusNode();

    final canShowError = useHasUnfocused(focusNode);

    return TextFormField(
      focusNode: focusNode,
      onChanged: (value) => notifier.updateInput(confirmPassword: value),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        errorText: canShowError
            ? isValid
                ? null
                : 'Please match passwords'
            : null,
      ),
    );
  }
}

class SubmitButton extends HookConsumerWidget {
  const SubmitButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(signUpFormLogicProvider.notifier);

    final status =
        ref.watch(signUpFormLogicProvider.select((value) => value.status));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: status.isValidated ? Colors.blue : Colors.grey,
        ),
        onPressed: status.isValidated ? () => notifier.submit() : null,
        child: const Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Success'),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

bool useHasUnfocused(FocusNode node) {
  final hasUnfocused = useState(false);

  useEffect(
    () {
      void listener() {
        print('node has focus: ${node.hasFocus}');
        // change isFocused only if the node is not focused
        if (!node.hasFocus) {
          print('node does not have focus');
          hasUnfocused.value = true;
        }
      }

      node.addListener(listener);
      return () => node.removeListener(listener);
    },
    [node],
  );

  return hasUnfocused.value;
}
