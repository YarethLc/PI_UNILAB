import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE9EDEF),
        border: Border(top: BorderSide(color: Color(0xFFD4DADC))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;
          final logo = Image.asset(
            'assets/images/logo_ciencia_verde.jpeg',
            width: isNarrow ? 92 : 112,
            height: isNarrow ? 92 : 112,
            fit: BoxFit.contain,
            semanticLabel: 'Logo del Centro Internacional de Ciencias',
          );
          const information = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'INFORMACIÓN',
                style: TextStyle(
                  color: Color(0xFF183D35),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              SizedBox(height: 10),
              _ContactLine(
                icon: Icons.location_on_outlined,
                text:
                    'Carrera 27 A No. 48 -144 Kilómetro 1 Salida Sur, Tuluá - Valle del Cauca - Colombia.',
              ),
              SizedBox(height: 6),
              _ContactLine(
                icon: Icons.markunread_mailbox_outlined,
                text: 'Código Postal: 763022',
              ),
              SizedBox(height: 6),
              _ContactLine(
                icon: Icons.email_outlined,
                text: 'igsclac@gmail.com',
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                logo,
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: information,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              logo,
              const SizedBox(width: 24),
              const Expanded(child: information),
            ],
          );
        },
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF385B54)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF3F4A48),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
