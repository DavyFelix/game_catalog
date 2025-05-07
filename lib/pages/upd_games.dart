import 'package:flutter/material.dart';

class UpdateProgressPage extends StatefulWidget {
  final double initialProgress;
  final Function(double) onUpdate;

  const UpdateProgressPage({
    super.key,
    required this.initialProgress,
    required this.onUpdate,
  });

  @override
  State<UpdateProgressPage> createState() => _UpdateProgressPageState();
}

class _UpdateProgressPageState extends State<UpdateProgressPage> {
  late double progress;

  @override
  void initState() {
    super.initState();
    progress = widget.initialProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atualizar Progresso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Progresso Atual: ${progress.toStringAsFixed(1)}%'),
            Slider(
              value: progress,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: '${progress.toStringAsFixed(1)}%',
              onChanged: (value) => setState(() => progress = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(progress);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
