import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductForm extends StatefulWidget {
  final Map<String, dynamic>? product;
  const ProductForm({super.key, this.product});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController imageCtrl;
  late TextEditingController descCtrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameCtrl = TextEditingController(text: p?['product_name'] ?? '');
    priceCtrl = TextEditingController(
      text: p?['product_price']?.toString() ?? '',
    );
    imageCtrl = TextEditingController(text: p?['product_image'] ?? '');
    descCtrl = TextEditingController(text: p?['product_description'] ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'product_name': nameCtrl.text.trim(),
      'product_description': descCtrl.text.trim(),
      'product_price': priceCtrl.text.trim(),
      'product_image': imageCtrl.text.trim(),
    };

    setState(() => loading = true);

    bool ok;
    if (widget.product == null) {
      ok = await ApiService.addProduct(data);
    } else {
      data['product_id'] = widget.product!['product_id'];
      ok = await ApiService.editProduct(data);
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
          widget.product == null ? 'Nuevo producto' : 'Editar producto',
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
              TextFormField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: 'URL Imagen'),
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
