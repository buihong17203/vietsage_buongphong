import 'package:flutter/material.dart';
import '../../drawable/drawables.dart';
import '../values/colors.dart';
import '../values/strings.dart';

class ActivityLoginLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLoginPressed;

  const ActivityLoginLayout({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.isLoading,
    this.errorMessage,
    required this.onTogglePasswordVisibility,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Cụm Logo & Tiêu đề được đẩy cao lên và căn giữa
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AppDrawables.appLogo(size: 72),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'VIETSAGE',
                          style: TextStyle(
                            color: ResColors.brand,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          ResStrings.appName,
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Login Card nằm chính xác ở trung tâm màn hình
                        Container(
                          width: double.infinity,
                          decoration: AppDrawables.bgCard,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                ResStrings.loginTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: ResColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Email Input
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(fontSize: 15, color: ResColors.textDark),
                                decoration: InputDecoration(
                                  hintText: ResStrings.emailHint,
                                  prefixIcon: const Icon(Icons.email_outlined, color: ResColors.brand),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password Input
                              TextField(
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => onLoginPressed(),
                                style: const TextStyle(fontSize: 15, color: ResColors.textDark),
                                decoration: InputDecoration(
                                  hintText: ResStrings.passwordHint,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: ResColors.brand),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: ResColors.textMuted,
                                    ),
                                    onPressed: onTogglePasswordVisibility,
                                  ),
                                ),
                              ),

                              // Error Banner
                              if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFCA5A5)),
                                  ),
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 22),

                              // Login Button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : onLoginPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ResColors.brand,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              ResStrings.loggingInBtn,
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          ResStrings.loginBtn,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
