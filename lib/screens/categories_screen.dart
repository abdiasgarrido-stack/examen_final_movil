import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'category_form.dart';
import '../widgets/ui_helpers.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool loading = true;
  String? error;
  List<dynamic> items = [];

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      items = await ApiService.getCategories();
    } catch (e) {
      error = 'Error al cargar categorías: $e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: const Text('¿Seguro que deseas eliminar esta categoría?'),
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

    final ok = await ApiService.deleteCategory(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Categoría eliminada' : 'Error al eliminar')),
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
            if (i == 0) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: HintBanner(
                  message:
                      '💡 Toca una categoría para editarla o eliminarla.\nUsa el botón + para agregar nuevas categorías.',
                ),
              );
            }

            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No hay categorías')),
              );
            }

            final c = items[i - 1];
            final id = c['category_id'] ?? 0;
            final name = (c['category_name'] ?? '').toString();
            final state = (c['category_state'] ?? '').toString();

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.folder)),
              title: Text(name),
              subtitle: Text(state.isEmpty ? '—' : state),
              onTap: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CategoryForm(category: c)),
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
      appBar: AppBar(title: const Text('Categorías')),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryForm()),
          );
          if (refresh == true) load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
