import 'package:flutter/material.dart';
import 'package:health_app/Services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _hscController = TextEditingController();
  final _linkedPatientEmailController = TextEditingController();

  String selectedRole = 'patient'; // what the dropdown shows
    String effectiveRole = 'patient'; // what gets sent to backend
    bool isLinking = false;
  bool isLoading = false;
  String? error;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userInfo = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _secondNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'hsc_number': _hscController.text.trim().isEmpty
            ? null
            : _hscController.text.trim(),
        'linked_patient_email': _linkedPatientEmailController.text.trim(),
        'role_id': selectedRole == 'patient' ? 1 : 2,
        'access_type_id': 1,
      };
      await _userService.registerUser(userInfo);
      if (!mounted) return;
      Navigator.pop(context);
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (!optional && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('First Name', _firstNameController),
              _buildTextField('Last Name', _secondNameController),
              _buildTextField(
                'Email',
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField('Password', _passwordController, obscure: true),
              _buildTextField(
                'Birthday (YYYY-MM-DD)',
                _birthdayController,
                keyboardType: TextInputType.datetime,
              ),
              _buildTextField(
                'HSC Number (Optional)',
                _hscController,
                keyboardType: TextInputType.number,
                optional: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'I am a...'),
                items: const [
                  DropdownMenuItem(value: 'patient', child: Text('Patient')),
                  DropdownMenuItem(value: 'carer', child: Text('Carer/Family')),
                ],
                onChanged: (value) async {
                  setState(() => selectedRole = value!);

                  if (value == 'carer') {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Carer Role'),
                        content: const Text(
                          'Are you:\n\n'
                          '1. Caring for someone who does NOT use the app (be the Admin)?\n'
                          '2. Linking to an existing patient account (Carer only)?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'admin'),
                            child: const Text('I am the Admin'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'linked'),
                            child: const Text('I am Linking'),
                          ),
                        ],
                      ),
                    );

                    if (result == 'admin') {
                      setState(() {
                        selectedRole =
                            'carer'; // show "Carer/Family" in dropdown
                        effectiveRole = 'patient'; // backend sees as patient
                        isLinking = false; // no email needed
                      });
                    } else if (result == 'linked') {
                      setState(() {
                        effectiveRole = 'carer';
                        isLinking = true; // require patient email
                      });
                    }
                  } else {
                    setState(() {
                      effectiveRole = 'patient';
                      isLinking = false;
                    });
                  }
                },
              ),

              if (isLinking)
                _buildTextField(
                  "Patient's Email (link account)",
                  _linkedPatientEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),

              const SizedBox(height: 16),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),

              ElevatedButton(
                onPressed: isLoading ? null : register,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
