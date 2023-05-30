import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/models/auth_exception.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/widgets/background_image_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In To Your Account',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              else
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: 160,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: IconButton(
                          icon: Image.asset('assets/images/google_logo.png'),
                          tooltip: 'Sign In with Google',
                          onPressed: () async => await _asyncWithCatch(
                            _authService.signInWithGoogle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: IconButton(
                          icon: Image.asset('assets/images/apple_logo.png'),
                          tooltip: 'Sign In with Apple',
                          onPressed: () async => await _asyncWithCatch(
                            _authService.signInWithApple,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      height: 42,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink.image(
                          image: const AssetImage(
                              'assets/images/guest_account.png'),
                          fit: BoxFit.fitWidth,
                          // width: 200,
                          // height: 120.0,
                          child: InkWell(
                            onTap: () async => await _asyncWithCatch(
                              _authService.signInAnonymously,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _asyncWithCatch(Future<void> Function() authFunction) async {
    setState(() => _isLoading = true);

    try {
      await authFunction();
    } on AuthException catch (e) {
      final snackBar = SnackBar(content: Text(e.code));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
