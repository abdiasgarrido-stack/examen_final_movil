import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'provider_form.dart';
import '../widgets/ui_helpers.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});
  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  bool loading = true;
  String? error;
  List<dynamic> items = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      items = await ApiService.getProviders();
    } catch (e) {
      error = 'Error al cargar proveedores: $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: const Text('¿Seguro que deseas eliminar este proveedor?'),
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

    final ok = await ApiService.deleteProvider(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Proveedor eliminado' : 'Error al eliminar')),
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
    Widget content;

    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = Center(child: Text(error!));
    } else {
      content = RefreshIndicator(
        onRefresh: load,
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: (items.isEmpty ? 1 : items.length + 1),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            // Encabezado (banner)
            if (i == 0) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: HintBanner(
                  message:
                      '💡 Toca un proveedor para editarlo o eliminarlo.\nUsa el botón + para crear un nuevo proveedor.',
                ),
              );
            }

            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No hay proveedores')),
              );
            }

            final p = items[i - 1];
            final id = p['provider_id'] ?? 0;
            final name = (p['provider_name'] ?? '').toString();
            final phone = (p['provider_phone'] ?? '').toString();
            final email = (p['provider_email'] ?? '').toString();

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.store)),
              title: Text(name),
              subtitle: Text('Tel: $phone\nEmail: $email'),
              onTap: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProviderForm(provider: p)),
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
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProviderForm()),
          );
          if (refresh == true) load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
