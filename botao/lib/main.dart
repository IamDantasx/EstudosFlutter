import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visualizador de Imagem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ImagemPage(),
    );
  }
}

class ImagemPage extends StatefulWidget {
  const ImagemPage({super.key});

  @override
  State<ImagemPage> createState() => _ImagemPageState();
}

class _ImagemPageState extends State<ImagemPage> {
  // Controla o texto digitado no campo
  final TextEditingController _controller = TextEditingController();

  // URL que está sendo exibida no momento (null = nada exibido ainda)
  String? _urlExibida;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mostrarImagem() {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o endereço de uma imagem.')),
      );
      return;
    }

    setState(() {
      _urlExibida = url;
    });

    // Fecha o teclado
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador de Imagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _mostrarImagem(),
              decoration: const InputDecoration(
                labelText: 'URL da imagem',
                hintText: 'https://exemplo.com/imagem.png',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _mostrarImagem,
              icon: const Icon(Icons.image),
              label: const Text('Mostrar imagem'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: _urlExibida == null
                    ? const Text(
                        'Nenhuma imagem carregada.',
                        style: TextStyle(color: Colors.grey),
                      )
                    : Image.network(
                        _urlExibida!,
                        fit: BoxFit.contain,
                        // Indicador de carregamento enquanto a imagem baixa
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          );
                        },
                        // Mensagem caso a URL seja inválida ou falhe
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Não foi possível carregar a imagem.'),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
