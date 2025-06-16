import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/auth_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _balanceCtrl = TextEditingController();
  String? _currency;

  File? _imageFile;
  Uint8List? _imageFileWeb;
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currency = 'BRL';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageFileWeb = bytes;
            _imageFile = null;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
            _imageFileWeb = null;
          });
        }
      }
    } catch (_) {
      setState(() {
        _error = 'Erro ao selecionar imagem';
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('user_photos/$uid.jpg');
      UploadTask uploadTask;

      if (kIsWeb && _imageFileWeb != null) {
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        uploadTask = ref.putData(_imageFileWeb!, metadata);
      } else if (_imageFile != null) {
        uploadTask = ref.putFile(_imageFile!);
      } else {
        return null;
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final uid = authProvider.currentUser?.uid;

    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider? avatarImage;
    if (kIsWeb && _imageFileWeb != null) {
      avatarImage = MemoryImage(_imageFileWeb!);
    } else if (_imageFile != null) {
      avatarImage = FileImage(_imageFile!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Complete seu Perfil',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 74, 119, 241),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Informações do Perfil',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(0xFFE9ECFF),
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? const Icon(Icons.person,
                                      size: 50, color: Color(0xFF4361EE))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _loading ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 80, 147, 235),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.grey[600]),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          style: TextStyle(color: Colors.grey[800]),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Insira um nome'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: InputDecoration(
                            labelText: 'Moeda Principal',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            prefixIcon: Icon(Icons.currency_exchange_outlined,
                                color: Colors.grey[600]),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          dropdownColor: Colors.white,
                          style: TextStyle(color: Colors.grey[800]),
                          items: currencyProvider.supportedCurrencies
                              .map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency['code'],
                              child: Row(
                                children: [
                                  Text(
                                    currency['flag'] ?? '',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                      '${currency['name']} (${currency['code']})'),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currency = newValue;
                            });
                          },
                          validator: (v) =>
                              v == null ? 'Selecione uma moeda' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _balanceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Saldo Inicial',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            prefixIcon: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.grey[600]),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          style: TextStyle(color: Colors.grey[800]),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Insira seu saldo inicial';
                            final value = double.tryParse(v);
                            if (value == null) return 'Valor inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_error != null) const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _loading = true;
                                        _error = null;
                                      });

                                      String? photoUrl;
                                      if (_imageFile != null ||
                                          _imageFileWeb != null) {
                                        photoUrl = await _uploadImage(uid);
                                      }

                                      final error =
                                          await authProvider.updateProfile(
                                        uid: uid,
                                        name: _nameCtrl.text.trim(),
                                        photoUrl: photoUrl,
                                        currency: _currency!,
                                        initialBalance:
                                            double.parse(_balanceCtrl.text),
                                      );

                                      if (error == null) {
                                        currencyProvider
                                            .setCurrency(_currency!);
                                        await userProvider.loadUserData();

                                        if (!mounted) return;

                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/dashboard',
                                          (route) => false,
                                        );
                                      } else if (mounted) {
                                        setState(() {
                                          _error = error;
                                          _loading = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 80, 147, 235),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor:
                                  const Color.fromARGB(255, 80, 147, 235),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Salvar Perfil',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Complete seu perfil para começar a usar o aplicativo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
