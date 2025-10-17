import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryForm extends StatefulWidget {
  final Map<String, dynamic>? category; // null → nueva, no null → editar
  const CategoryForm({super.key, this.category});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  String stateValue = 'Activa';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(
      text: widget.category?['category_name'] ?? '',
    );
    stateValue = (widget.category?['category_state'] ?? 'Activa').toString();
    if (stateValue.isEmpty) stateValue = 'Activa';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'category_name': nameCtrl.text.trim(),
      'category_state': stateValue,
    };

    setState(() => loading = true);

    bool ok;
    if (widget.category == null) {
      ok = await ApiService.addCategory(data);
    } else {
      data['category_id'] = widget.category!['category_id'];
      ok = await ApiService.editCategory(data);
    }

    if (!mounted) return;
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Guardado correctamente' : 'Error al guardar'),
      ),
    );
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Nueva categoría' : 'Editar categoría',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: stateValue,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'Activa', child: Text('Activa')),
                  DropdownMenuItem(value: 'Inactiva', child: Text('Inactiva')),
                ],
                onChanged: (v) => setState(() => stateValue = v ?? 'Activa'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: loading ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(loading ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
