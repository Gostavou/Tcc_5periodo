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

// Ainda falta uma parte essencial mas simples, que é o usuario colocar seu saldo, que eu deixei inicialmente travado em 5 mil pra fazer testes
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  String? _currency;

  File? _imageFile;
  Uint8List? _imageFileWeb;
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _loading ? null : _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Insira um nome' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _currency,
                  decoration: const InputDecoration(
                    labelText: 'Moeda',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'BRL', child: Text('Real (R\$)')),
                    DropdownMenuItem(value: 'USD', child: Text('Dólar (US\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
                  ],
                  onChanged:
                      _loading ? null : (v) => setState(() => _currency = v),
                  validator: (v) => v == null ? 'Selecione uma moeda' : null,
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
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
                              if (_imageFile != null || _imageFileWeb != null) {
                                photoUrl = await _uploadImage(uid);
                              }

                              final error = await authProvider.updateProfile(
                                uid: uid,
                                name: _nameCtrl.text.trim(),
                                photoUrl: photoUrl,
                                currency: _currency!,
                              );

                              if (error == null) {
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
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Salvar Perfil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
