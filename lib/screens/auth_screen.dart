import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../core/theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _error;
  String? _message;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    final auth = ref.read(authServiceProvider);

    try {
      if (_isLogin) {
        await auth.signInWithEmail(_email, _password);
        // Navigation handled by router based on auth state change
      } else {
        await auth.signUpWithEmail(_email, _password);
        setState(() {
          _message = "Sign up successful! Please check your email to confirm your account.";
        });
        // If auto-login happens, router will redirect. If email confirm needed, message shows.
      }
    } catch (e) {
      setState(() {
        _error = e.toString().contains('Exception:') 
            ? e.toString().split('Exception: ')[1] 
            : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'AI English Tutor',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your personalized path to fluency',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Card
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 24),

                      // Email
                      const Text('EMAIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'hello@example.com',
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[900],
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                        onSaved: (value) => _email = value!,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: '••••••••',
                           filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[900],
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        obscureText: true,
                        validator: (value) => value == null || value.length < 6 ? 'Password must be 6+ chars' : null,
                        onSaved: (value) => _password = value!,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                        ),
                        
                      if (_message != null)
                         Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(_message!, style: const TextStyle(color: AppTheme.success, fontSize: 13)),
                        ),
                        
                       if (_error != null || _message != null) const SizedBox(height: 16),

                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppTheme.primary,
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             elevation: 4,
                             shadowColor: AppTheme.primary.withOpacity(0.3),
                           ),
                          child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isLogin ? 'Sign In' : 'Sign Up', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                             _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In",
                             style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
