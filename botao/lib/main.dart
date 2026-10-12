import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria de Imagens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const GaleriaPage(),
    );
  }
}

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final TextEditingController _controller = TextEditingController();

  // Agora guardamos TODAS as URLs adicionadas, não só uma
  final List<String> _urls = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adicionarImagem() {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      _mostrarAviso('Digite o endereço de uma imagem.');
      return;
    }

    setState(() {
      _urls.add(url); // adiciona no fim da lista; as antigas continuam
    });

    _controller.clear(); // limpa o campo para a próxima URL
    FocusScope.of(context).unfocus();
  }

  void _removerImagem(int index) {
    setState(() {
      _urls.removeAt(index);
    });
  }

  Future<void> _limparTudo() async {
    // Pede confirmação antes de apagar tudo
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar todas as imagens?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      setState(() {
        _urls.clear();
      });
    }
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeria (${_urls.length})'),
        actions: [
          IconButton(
            tooltip: 'Apagar todas',
            icon: const Icon(Icons.delete_sweep),
            // Botão desabilitado (null) quando não há imagens
            onPressed: _urls.isEmpty ? null : _limparTudo,
          ),
        ],
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
              onSubmitted: (_) => _adicionarImagem(),
              decoration: const InputDecoration(
                labelText: 'URL da imagem',
                hintText: 'https://exemplo.com/imagem.png',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _adicionarImagem,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Adicionar imagem'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _urls.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma imagem adicionada.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      itemCount: _urls.length,
                      // Cada célula tem no máximo 200px de largura,
                      // então o número de colunas se ajusta à tela
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return _CardImagem(
                          url: _urls[index],
                          onRemover: () => _removerImagem(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget separado para cada imagem do grid, deixando o build principal mais limpo
class _CardImagem extends StatelessWidget {
  final String url;
  final VoidCallback onRemover;

  const _CardImagem({required this.url, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // faz a imagem respeitar as bordas arredondadas
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('Falha ao carregar', textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          ),
          // Botão de apagar no canto superior direito de cada imagem
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              tooltip: 'Remover',
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemover,
            ),
          ),
        ],
      ),
    );
  }
}
