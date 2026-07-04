import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/routes/app_router.dart';

/// Single login screen that supports both User and Admin login modes.
/// Toggle between modes using the tab bar at the top of the form.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final TabController _tabController;

  bool _obscurePassword = true;

  /// true  → Admin Login tab is active
  /// false → User Login tab is active
  bool get _isAdminMode => _tabController.index == 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Get.find<AuthController>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final bool success = _isAdminMode
        ? await auth.adminLogin(email: email, password: password)
        : await auth.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      Get.offAllNamed(
        auth.user?.isAdmin == true ? AppRoutes.admin : AppRoutes.home,
      );
      return;
    }

    if (!success) {
      Get.snackbar(
        "Login Failed",
        auth.errorMessage.isNotEmpty
            ? auth.errorMessage
            : "Invalid credentials",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Icon ──────────────────────────────────────────
                      Icon(
                        _isAdminMode
                            ? Icons.admin_panel_settings
                            : Icons.location_on,
                        color: _isAdminMode ? Colors.deepPurple : Colors.blue,
                        size: 70,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Live Tracking System",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── User / Admin Tab ──────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: _isAdminMode
                                ? Colors.deepPurple
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade700,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: "User Login"),
                            Tab(text: "Admin Login"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Email ─────────────────────────────────────────
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your email";
                          }
                          final emailRegex = RegExp(
                            r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Password ──────────────────────────────────────
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── Submit Button ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: GetBuilder<AuthController>(
                          builder: (auth) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAdminMode
                                  ? Colors.deepPurple
                                  : Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: auth.isLoading ? null : _submit,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isAdminMode ? "ADMIN LOGIN" : "LOGIN",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ),

                      // ── Register link (User mode only) ────────────────
                      if (!_isAdminMode) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.register);
                              },
                              child: const Text("Register"),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
