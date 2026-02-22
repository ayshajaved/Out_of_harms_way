import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/backend_providers.dart';

class CodeGeneratorScreen extends ConsumerStatefulWidget {
  const CodeGeneratorScreen({super.key});

  @override
  ConsumerState<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends ConsumerState<CodeGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<String> _languages = ["python", "javascript", "java", "go", "rust"];
  String _selectedLanguage = "python";
  bool _isLoading = false;
  bool _useMock = false; // Toggle for mock data
  String _currentStep = "";
  Map<String, dynamic>? _result;
  String? _error;

  void _generate() {
    if (_promptController.text.length < 10) {
      setState(() => _error = "Prompt must be at least 10 characters.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _currentStep = "Connecting securely to AI Engine...";
    });

    try {
      final authService = ref.read(authServiceProvider);
      final backendService = ref.read(backendServiceProvider);
      
      backendService.generateCodeStream(
        prompt: _promptController.text,
        language: _selectedLanguage,
        userId: authService.currentUser?.uid ?? "anonymous_user",
        useMock: _useMock, // Pass the mock flag dynamically
      ).listen(
        (event) {
          if (!mounted) return;
          
          if (event['step'] == 'error') {
            setState(() {
              _error = event['error'] ?? "Stream connection failed";
              _isLoading = false;
              _currentStep = "";
            });
          } else if (event['step'] == 'complete') {
            setState(() {
              _result = event['result'];
              _isLoading = false;
              _currentStep = "";
            });
          } else {
             // Handle intermediate steps (e.g., 'initialization', 'generation')
            setState(() {
              _currentStep = event['status'] ?? "Processing...";
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = error.toString();
              _isLoading = false;
              _currentStep = "";
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _currentStep = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.outerBg,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Text('SECURE CODE GEN', style: AppTypography.stepBadge),
          ],
        ),
        backgroundColor: AppColors.outerBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 20),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'what should we build securely?',
              style: AppTypography.heroTitle(context).copyWith(fontSize: 28),
            ),
            const SizedBox(height: 24),
            
            // Input Controls
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                    ),
                    child: TextField(
                      controller: _promptController,
                      style: GoogleFonts.spaceGrotesk(color: AppColors.textMain),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.terminal, color: AppColors.textMuted),
                        hintText: 'e.g., Create a login system with password hashing',
                        hintStyle: GoogleFonts.spaceGrotesk(color: AppColors.textMuted.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      maxLines: 4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.innerBg,
                    border: Border.all(color: AppColors.surfaceBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(Icons.code, color: AppColors.accent, size: 16),
                      dropdownColor: AppColors.innerBg,
                      style: GoogleFonts.spaceGrotesk(color: AppColors.textMain, fontWeight: FontWeight.bold),
                      items: _languages.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(" ${value.toUpperCase()}"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedLanguage = val!),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Mock Toggle Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _useMock ? AppColors.accent.withOpacity(0.1) : AppColors.innerBg,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _useMock ? AppColors.accent : AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.science, color: _useMock ? AppColors.accent : AppColors.textMuted, size: 16),
                      const SizedBox(width: 8),
                      Text('Mock Mode', style: GoogleFonts.spaceGrotesk(
                        color: _useMock ? AppColors.accent : AppColors.textMuted, 
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      )),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 24,
                        child: Switch(
                          value: _useMock,
                          onChanged: _isLoading ? null : (val) => setState(() => _useMock = val),
                          activeColor: AppColors.accent,
                          activeTrackColor: AppColors.accent.withOpacity(0.3),
                          inactiveThumbColor: AppColors.textMuted,
                          inactiveTrackColor: AppColors.surfaceLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimaryBg,
                    foregroundColor: AppColors.btnPrimaryText,
                    elevation: _isLoading ? 0 : 4,
                    shadowColor: AppColors.accent.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _isLoading 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.btnPrimaryText)),
                          const SizedBox(width: 12),
                          Text(_currentStep.isEmpty ? "Working..." : _currentStep, style: AppTypography.buttonText),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 18),
                          const SizedBox(width: 12),
                          Text('EXECUTE AGENTS', style: AppTypography.buttonText),
                        ],
                      ),
                ),
              ],
            ),
            
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: GoogleFonts.spaceGrotesk(color: AppColors.error))),
                  ],
                ),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 48),
              _ResultDisplay(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultDisplay extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ResultDisplay({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Text('GENERATED CODE', style: AppTypography.stepBadge.copyWith(color: AppColors.success)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppColors.success, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'SECURITY SCORE: ${result['security_score']}%',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.outerBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder, width: 2),
          ),
          child: SelectableText(
            result['final_code'] ?? 'No code generated.',
            style: GoogleFonts.firaCode(color: AppColors.textMain, fontSize: 15, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            const Icon(Icons.lightbulb, color: AppColors.accent, size: 24),
            const SizedBox(width: 12),
            Text('SECURITY EXPLANATION', style: AppTypography.stepBadge),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.02),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ]
          ),
          child: MarkdownBody(
            data: result['explanation'] ?? 'No explanation provided.',
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.spaceGrotesk(color: AppColors.textMuted, fontSize: 16, height: 1.6),
              h1: GoogleFonts.spaceGrotesk(color: AppColors.textMain, fontWeight: FontWeight.bold),
              h2: GoogleFonts.spaceGrotesk(color: AppColors.textMain, fontWeight: FontWeight.bold),
              code: GoogleFonts.firaCode(backgroundColor: AppColors.outerBg, color: AppColors.success, fontSize: 14),
              codeblockDecoration: BoxDecoration(
                color: AppColors.outerBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder)
              ),
            ),
          ),
        ),
      ],
    );
  }
}
