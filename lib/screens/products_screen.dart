import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'product_form.dart';
import '../widgets/ui_helpers.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool loading = true;
  String? error;
  List<dynamic> items = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      items = await ApiService.getProducts();
    } catch (e) {
      error = 'Error al cargar productos: $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Seguro que deseas eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ApiService.deleteProduct(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Producto eliminado' : 'Error al eliminar')),
    );
    if (ok) load();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = () {
      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (error != null) {
        return Center(child: Text(error!));
      }
      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              HintBanner(
                message:
                    '💡 Toca un producto para editarlo o eliminarlo.\nUsa el botón + para agregar nuevos productos.',
              ),
              SizedBox(height: 12),
              Center(child: Text('No hay productos')),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: load,
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = items[i];
            final id = p['product_id'] ?? 0;
            final name = (p['product_name'] ?? '').toString();
            final price = (p['product_price'] ?? '').toString();
            final image = (p['product_image'] ?? '').toString();

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? const Icon(Icons.image_not_supported)
                    : null,
              ),
              title: Text(name),
              subtitle: Text('\$ $price'),
              onTap: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductForm(product: p)),
                );
                if (refresh == true) load();
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
                onPressed: () => _delete(id),
              ),
            );
          },
        ),
      );
    }();

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductForm()),
          );
          if (refresh == true) load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
