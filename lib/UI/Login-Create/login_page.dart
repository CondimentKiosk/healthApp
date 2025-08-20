import 'package:flutter/material.dart';
import 'package:health_app/Services/globalAPIClient.dart';
import 'package:health_app/access_rights.dart';
import 'package:health_app/main.dart';
import '../../Services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final loginData = await UserService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      ApiClient.currentUserId = loginData['user_id'];
      ApiClient.currentPatientId = loginData['patient_id'];

      await AccessRights.load(ApiClient.currentUserId.toString(), ApiClient.currentPatientId.toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: "Health Hub for ${ApiClient.currentUserId}",
            userId: ApiClient.currentUserId,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: navigateToRegister,
                child: const Text('Create an Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
