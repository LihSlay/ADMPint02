import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermosCondicoesPage extends StatefulWidget {
  const TermosCondicoesPage({super.key});

  @override
  State<TermosCondicoesPage> createState() => _TermosPageState();
}

class _TermosPageState extends State<TermosCondicoesPage> {
  bool aceitou = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF907041),
                  Color(0xFF97774D),
                  Color(0xFFA68A69),
                ],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/iniciar_sessao',
                    (route) => false,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Termos e condições",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: RichText(
                textAlign: TextAlign.justify,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.black,
                  ),
                  children: [
                    // ---------- Ponto 1 ----------
                    TextSpan(
                      text:
                          "1. Identificação do responsável pelo tratamento\n",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text:
                          "CLINIMOLELOS, LDA, sociedade comercial por quotas, com o NIPC nº508353424 e com sede na Rua Dr. Adriano Figueiredo, nº 158, Pedra da Vista, 3460 Tondela. "
                          "Contato do EPD (Encarregado da Proteção de Dados) xxxxx@xxxxx\n\n",
                    ),

                    // ---------- Ponto 2 ----------
                    TextSpan(
                      text:
                          "2. Informação, consentimento e finalidade do tratamento\n",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text:
                          "A Lei da Proteção de Dados Pessoais e o Regulamento Geral de Proteção de Dados asseguram a proteção das pessoas singulares relativamente ao tratamento de dados pessoais. \n"
                          "Mediante a aceitação da presente Política de Privacidade e/ou Termos e Condições o utilizador presta o seu consentimento informado, expresso, livre e inequívoco para que os dados pessoais fornecidos sejam incluídos num ficheiro da responsabilidade da CLINIMOLELOS, cujo tratamento nos termos do RGPD cumpre as medidas de segurança técnicas e organizativas adequadas. \n"

                          "Os dados presentes nesta base são unicamente os dados prestados pelos próprios, progenitores em caso de menores, maiores acompanhados ou cuidadores informais, na altura do seu registo, sendo tratados apenas para a criação do histórico clínico do utente.\n"
                          
                          "Em caso algum será solicitada informação sobre convicções filosóficas ou políticas, filiação partidária ou sindical, fé religiosa, vida privada e origem racial. Os dados recolhidos não serão cedidos a outras pessoas ou outras entidades, sem o consentimento prévio do titular dos dados. \n\n",
                    ),

                    // ---------- Ponto 3 ----------
                    TextSpan(
                      text: "3. Medidas de segurança\n",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text:
                          "A CLINIMOLELOS, declara que implementou e continuará a implementar as medidas de segurança de natureza técnica e organizativa necessárias para garantir a segurança dos dados de carácter pessoal e clínico que lhe sejam fornecidos visando evitar a sua alteração, perda, tratamento e/ou acesso não autorizado, tendo em conta o estado atual da tecnologia, a natureza dos dados armazenados e os riscos a que estão expostos bem como garante a confidencialidade dos mesmos.\n\n",
                    ),

                    // ---------- Ponto 4 ----------
                    TextSpan(
                      text: "4. Exercício dos direitos\n",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text:
                          "O titular dos dados pessoais ou os representantes legais podem exercer a todo o tempo, os seus direitos de acesso, retificação, apagamento, limitação, oposição e portabilidade.\n\n",
                    ),

                    // ---------- Ponto 5 ----------
                    TextSpan(
                      text: "5. Prazo de conservação\n",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text:
                          "A clínica apenas trata os dados pessaois durante o período que se revele necessário ao cumprimento da sua finalidade (criação de histórico de saúde do utente), sem prejuízo dos dados serem conservados por um período superior, por exigências legais.\n\n",
                    ),

                    // ---------- Ponto 6 ----------
                    TextSpan(
                      text: "6. Autoridade de controlo\n",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text:
                          "Nos termos legais, o titular dos dados tem o direito de apresentar uma reclamação em matéria de proteção de dados pessoais à autoridade de controlo competente, a Comissão Nacional de Proteção de Dados (CNPD).\n\n",
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => aceitou = !aceitou),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: aceitou ? const Color(0xFFF1EFEA) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 2,
                            color: aceitou
                                ? const Color(0xFFB49B6D)
                                : Colors.black54,
                          ),
                        ),
                        child: aceitou
                            ? const Center(
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFFB49B6D),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Eu confirmo que li e aceito os termos e condições.",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: aceitou ? () => context.go('/inicio') : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          aceitou ? Colors.white : Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: aceitou ? 3 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Continuar",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
