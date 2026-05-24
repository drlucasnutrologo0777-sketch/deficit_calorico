import '/pagina_cadastro/pagina_cadastro_widget.dart';
import 'package:flutter/material.dart';

/// Rota dedicada do build 114 — reutiliza o formulário de perfil em modo edição.
class EditarPerfilWidget extends StatelessWidget {
  const EditarPerfilWidget({super.key});

  static String routeName = 'editarPerfil';
  static String routePath = '/editarPerfil';

  @override
  Widget build(BuildContext context) => const PaginaCadastroWidget();
}
