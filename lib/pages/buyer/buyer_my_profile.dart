import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'dart:convert';
import '../../service/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BuyerMyProfile extends StatefulWidget {
  const BuyerMyProfile({super.key});

  @override
  State<BuyerMyProfile> createState() => _BuyerMyProfileState();
}

class _BuyerMyProfileState extends State<BuyerMyProfile> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final QuillController _descriptionController = QuillController.basic();

  int? _selectedGender = 0; // Initialize with a valid value, 0 for Male
  String _selectedLanguage = 'English';
  File? _profilePicture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getUserProfile();
      print(response);
      setState(() {
        _firstNameController.text = response['user']['fname'] ?? '';
        _lastNameController.text = response['user']['lname'] ?? '';
        _emailController.text = response['user']['email'] ?? '';
        _phoneController.text = response['user']['phone'] ?? '';
        _selectedGender = response['user']['gender'] ?? 0;
        _selectedLanguage = response['user']['language'] ?? '';
        _descriptionController.document = Document.fromJson(
            jsonDecode(response['user']['description'] ?? '{}'));
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load profile: $e')),
      // );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final delta = _descriptionController.document.toDelta();
        final converter = QuillDeltaToHtmlConverter(
          delta.toJson(),
          ConverterOptions.forEmail(),
        );
        final htmlContent = converter.convert();
        final profileData = {
          'fname': _firstNameController.text,
          'lname': _lastNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'gender': _selectedGender,
          'language': _selectedLanguage,
          'description':htmlContent,
        };
        print(profileData);

        final response =
            await _apiService.updateUserProfile(profileData, _profilePicture);
        print(response);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          throw Exception(response['message']);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profilePicture = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile Info',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your first name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                          labelText: 'Last Name', border: OutlineInputBorder()),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your last name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder()),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                          labelText: 'Phone no', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          QuillSimpleToolbar(
                            controller: _descriptionController,
                            configurations:
                                const QuillSimpleToolbarConfigurations(
                              toolbarIconAlignment: WrapAlignment.start,
                              multiRowsDisplay: false,
                              showDividers: false,
                              showFontFamily: false,
                              showFontSize: false,
                              showBoldButton: true,
                              showItalicButton: true,
                              showUnderLineButton: true,
                              showStrikeThrough: false,
                              showInlineCode: false,
                              showColorButton: true,
                              showBackgroundColorButton: true,
                              showClearFormat: true,
                              showAlignmentButtons: true,
                              showLeftAlignment: true,
                              showCenterAlignment: true,
                              showRightAlignment: true,
                              showJustifyAlignment: true,
                              showHeaderStyle: true,
                              showListNumbers: true,
                              showListBullets: true,
                              showListCheck: false,
                              showCodeBlock: false,
                              showQuote: false,
                              showIndent: false,
                              showLink: false,
                              showUndo: true,
                              showRedo: false,
                            ),
                          ),
                          Expanded(
                            child: QuillEditor.basic(
                              controller: _descriptionController,
                              configurations: const QuillEditorConfigurations(
                                scrollable: true,
                                autoFocus: false,
                                placeholder: 'Enter job description...',
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGenderDropdown(
                      'Gender',
                      _selectedGender,
                      [0, 1], // 0 for Male, 1 for Female
                      (int? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _selectedLanguage,
                      decoration: const InputDecoration(
                          labelText: 'Language', border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Choose Profile Picture'),
                    ),
                    if (_profilePicture != null)
                      Image.file(_profilePicture!, height: 100, width: 100),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Save Now'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGenderDropdown(
      String label, int? value, List<int> options, Function(int?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          // Optional: to make sure the dropdown uses the full width
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<int>>((int option) {
            return DropdownMenuItem<int>(
              value: option,
              child: Text(option == 0 ? "Male" : "Female"),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
