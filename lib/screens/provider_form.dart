import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProviderForm extends StatefulWidget {
  final Map<String, dynamic>? provider;
  const ProviderForm({super.key, this.provider});

  @override
  State<ProviderForm> createState() => _ProviderFormState();
}

class _ProviderFormState extends State<ProviderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(
      text: widget.provider?['provider_name'] ?? '',
    );
    phoneCtrl = TextEditingController(
      text: widget.provider?['provider_phone'] ?? '',
    );
    emailCtrl = TextEditingController(
      text: widget.provider?['provider_email'] ?? '',
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'provider_name': nameCtrl.text.trim(),
      'provider_phone': phoneCtrl.text.trim(),
      'provider_email': emailCtrl.text.trim(),
    };

    setState(() => loading = true);

    bool ok;
    if (widget.provider == null) {
      ok = await ApiService.addProvider(data);
    } else {
      data['provider_id'] = widget.provider!['provider_id'];
      ok = await ApiService.editProvider(data);
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
          widget.provider == null ? 'Nuevo proveedor' : 'Editar proveedor',
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
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
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
