import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';

class Palavrapasse extends StatefulWidget {
  //
  final String title;

  const Palavrapasse({super.key, required this.title});

  @override
  State<Palavrapasse> createState() => _PalavrapasseState();
}

class _PalavrapasseState extends State<Palavrapasse> {
  int currentPageIndex = 3; // Definições

  late TextEditingController
  _currentPasswordController; // Controlador para o campo de palavra-passe atual
  late TextEditingController
  _newPasswordController; // Controlador para o campo de nova palavra-passe
  late TextEditingController
  _confirmPasswordController; // Controlador para o campo de confirmação da nova palavra-passe
  final ApiService _apiService =
      ApiService(); // Instância do serviço de API para chamadas de rede
  final DatabaseHelper _dbHelper =
      DatabaseHelper(); // Instância do helper de banco de dados para acessar dados locais

  bool _isLoading = false;
  bool _showCurrentPassword =
      false; // Variável para controlar a visibilidade da palavra-passe atual
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController =
        TextEditingController(); // Inicializar os controladores de texto para os campos de palavra-passe
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController
        .dispose(); // Liberar os recursos dos controladores de texto quando a tela for descartada
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<String?> _getUserEmail() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'utilizadores',
    ); // Consultar a tabela de utilizadores para obter o email do usuário logado
    if (result.isNotEmpty) {
      return result.first['email'];
    }
    return null;
  }

  void _showErrorDialog(String message) {
    // Função para exibir um erro com uma mensagem
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
    // Função para exibir uma mensagem de sucesso
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
                // Limpar campos após confirmar
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
    // Função para alterar a palavra-passe do usuário
    final currentPassword = _currentPasswordController.text
        .trim(); // Obter o valor da palavra-passe atual do campo de texto
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
      // Obter o email do usuário logado para enviar na requisição de alteração de palavra-passe
      final userEmail = await _getUserEmail();
      if (userEmail == null) {
        _showErrorDialog(
          'Erro: Utilizador não encontrado. Por favor, faça login novamente.',
        );
        setState(() => _isLoading = false);
        return;
      }

      final result = await _apiService.changePassword(
        // Enviar a requisição de alteração de palavra-passe para a API
        userEmail,
        currentPassword,
        newPassword,
      );

      if (result['success'] == true) {
        if (result['offline'] == true) {
          // Operação offline
          _showSuccessDialog(
            'Sem internet. A alteração será sincronizada automaticamente quando houver conexão.',
          );
        } else {
          // Operação online bem-sucedida
          _showSuccessDialog('Palavra-passe alterada com sucesso!');
        }

        // Tentar sincronizar operações pendentes em background
        _apiService.sincronizarOperacoesPendentes().catchError((e) {
          debugPrint("Erro ao sincronizar operações pendentes: $e");
        });
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
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/definicoes'),
        ),
        title: const Text(
          'Alterar Palavra-passe',
          style: TextStyle(color: Colors.white),
        ),
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
                    _showCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(
                      () => _showCurrentPassword = !_showCurrentPassword,
                    );
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
              controller:
                  _confirmPasswordController, // Campo para confirmar a nova palavra-passe
              obscureText:
                  !_showConfirmPassword, // Controla a visibilidade do texto para o campo de confirmação
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword // Ícone de olho para mostrar a palavra-passe nova
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(
                      () => _showConfirmPassword =
                          !_showConfirmPassword, // Alterna a visibilidade do campo de confirmação
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : _changePassword, // Altera a palavra-passe
                style: OutlinedButton.styleFrom(
                  // Estilo do botão de alteração de palavra-passe
                  side: const BorderSide(color: Color(0xFF907041), width: 1.2),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF907041),
                          ),
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
        backgroundColor: Colors.white,
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
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Definições',
          ),
        ],
      ),
    );
  }
}
