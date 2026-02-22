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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('SECURE CODE GEN', style: AppTypography.stepBadge),
        backgroundColor: Colors.black,
        elevation: 0,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: TextField(
                      controller: _promptController,
                      style: GoogleFonts.spaceGrotesk(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., Create a login system with password hashing',
                        hintStyle: GoogleFonts.spaceGrotesk(color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor: const Color(0xFF141414),
                  style: GoogleFonts.spaceGrotesk(color: Colors.white),
                  items: _languages.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedLanguage = val!),
                ),
                const SizedBox(width: 16),
                // Mock Toggle Switch
                Row(
                  children: [
                    Switch(
                      value: _useMock,
                      onChanged: _isLoading ? null : (val) => setState(() => _useMock = val),
                      activeColor: const Color(0xFFE8C1CF),
                    ),
                    Text('Use Mock Data', style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C1CF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _isLoading 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                          const SizedBox(width: 12),
                          Text(_currentStep.isEmpty ? "Working..." : _currentStep, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      )
                    : Text('EXECUTE AGENTS', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(_error!, style: GoogleFonts.spaceGrotesk(color: Colors.redAccent)),
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
            Text('GENERATED CODE', style: AppTypography.stepBadge),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.green),
              ),
              child: Text(
                'SECURITY SCORE: ${result['security_score']}%',
                style: GoogleFonts.spaceGrotesk(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F1F1F)),
          ),
          child: SelectableText(
            result['final_code'] ?? 'No code generated.',
            style: GoogleFonts.firaCode(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 48),
        Text('SECURITY EXPLANATION', style: AppTypography.stepBadge),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F1F1F)),
          ),
          child: MarkdownBody(
            data: result['explanation'] ?? 'No explanation provided.',
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.spaceGrotesk(color: Colors.white70),
              h1: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
              h2: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
              code: GoogleFonts.firaCode(backgroundColor: Colors.black54, color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }
}
