import 'package:flutter/material.dart';
import 'package:test_telegram_modal_animation/widgets/draggable_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Головний екран')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder:
                  (_) => const DraggableModal(
                    url: 'https://www.w3schools.com/html/html_forms.asp',
                  ),
            );
          },
          child: const Text('Відкрити модальне вікно'),
        ),
      ),
    );
  }
}
