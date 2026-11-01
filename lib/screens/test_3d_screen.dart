import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Test3DScreen extends StatelessWidget {
  const Test3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Model Test')),
      body: const ModelViewer(
        src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
        alt: 'Astronaut',
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }
}
