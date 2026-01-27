import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';

class Palavrapasse extends StatefulWidget {
  final String title;

  const Palavrapasse({super.key, required this.title});

  @override
  State<Palavrapasse> createState() => _PalavrapasseState();
}

class _PalavrapasseState extends State<Palavrapasse> {
  int currentPageIndex = 3; // Definições
  
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<String?> _getUserEmail() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query('utilizadores');
    if (result.isNotEmpty) {
      return result.first['email'];
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Limpar campos após sucesso
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validações
    if (currentPassword.isEmpty) {
      _showErrorDialog('Por favor, insira a palavra-passe atual');
      return;
    }
    if (newPassword.isEmpty) {
      _showErrorDialog('Por favor, insira a nova palavra-passe');
      return;
    }
    if (confirmPassword.isEmpty) {
      _showErrorDialog('Por favor, confirme a nova palavra-passe');
      return;
    }
    if (newPassword.length < 3) {
      _showErrorDialog('A nova palavra-passe deve ter pelo menos 3 caracteres');
      return;
    }
    if (newPassword != confirmPassword) {
      _showErrorDialog('A nova palavra-passe e a confirmação não coincidem');
      return;
    }
    if (currentPassword == newPassword) {
      _showErrorDialog('A nova palavra-passe não pode ser igual à atual');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userEmail = await _getUserEmail();
      if (userEmail == null) {
        _showErrorDialog('Erro: Utilizador não encontrado. Por favor, faça login novamente.');
        setState(() => _isLoading = false);
        return;
      }

      final success = await _apiService.changePassword(
        userEmail,
        currentPassword,
        newPassword,
      );

      if (success) {
        _showSuccessDialog('Palavra-passe alterada com sucesso!');
      }
    } catch (e) {
      _showErrorDialog('Erro ao alterar a palavra-passe: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white), // título branco
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(
            '/definicoes',
          ), // vai diretamente para a rota /definicoes
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Palavra-passe atual",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: !_showCurrentPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showCurrentPassword = !_showCurrentPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Palavra-passe nova",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showNewPassword = !_showNewPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Confirmar palavra-passe nova",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showConfirmPassword = !_showConfirmPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF907041),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF907041)),
                            ),
                          )
                        : const Text(
                            "Continuar",
                            style: TextStyle(
                              color: Color(0xFF907041),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() => currentPageIndex = index);

          switch (index) {
            case 0:
              context.go('/inicio');
              break;
            case 1:
              context.go('/calendario');
              break;
            case 2:
              context.go('/notificacoes');
              break;
            case 3:
              context.go('/definicoes');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendário'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notificações'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Definições'),
        ],
      ),
    );
  }
}