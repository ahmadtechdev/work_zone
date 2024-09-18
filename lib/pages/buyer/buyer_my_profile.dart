import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:work_zone/widgets/colors.dart';
import '../../service/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart'; // For skeleton loader
import 'package:flutter_animate/flutter_animate.dart';

import '../../widgets/snackbar.dart'; // For animations

class BuyerMyProfile extends StatefulWidget {
  const BuyerMyProfile({super.key});

  @override
  State<BuyerMyProfile> createState() => _BuyerMyProfileState();
}

class _BuyerMyProfileState extends State<BuyerMyProfile> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late QuillController _descriptionController = QuillController.basic();

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
      final response = await _apiService.get('user-profile');
      // var document = Document.fromHtml(response['user']['description']);
      // _descriptionController = QuillController(
      //   document: document,
      //   selection: const TextSelection.collapsed(offset: 0),
      // );
      setState(() {
        _firstNameController.text = response['user']['fname'] ?? '';
        _lastNameController.text = response['user']['lname'] ?? '';
        _emailController.text = response['user']['email'] ?? '';
        _phoneController.text = response['user']['phone'] ?? '';
        _selectedGender = response['user']['gender'] ?? 0;
        _selectedLanguage = response['user']['language'] ?? '';
        final document = Document.fromHtml(response['user']['description']);
        _descriptionController = QuillController(
          document: document,
          selection: TextSelection.collapsed(offset: 0),
        );
      });
    } catch (e) {
      // Handle error
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
          'description': htmlContent,
        };

        final response =
        await _apiService.updateUserProfile(profileData, _profilePicture);
        if (response['status'] == 'success') {
          CustomSnackBar(
            message: 'Profile updated successfully',
            backgroundColor: Colors.green,
          ).show(context);
        } else {
          throw Exception(response['message']);
        }
      } catch (e) {
        CustomSnackBar(
          message: 'Failed to update profile: $e',
          backgroundColor: Colors.red,
        ).show(context);
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Profile Info', theme),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _firstNameController,
                label: 'First Name',
                validator: (value) => value!.isEmpty
                    ? 'Please enter your first name'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _lastNameController,
                label: 'Last Name',
                validator: (value) =>
                value!.isEmpty ? 'Please enter your last name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email Address',
                validator: (value) =>
                value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _phoneController,
                label: 'Phone no',
                validator: (value) => value!.isEmpty
                    ? 'Please enter your phone number'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Description', theme),
              const SizedBox(height: 8),
              _buildDescriptionField(),
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
              _buildTextFormField(
                initialValue: _selectedLanguage,
                label: 'Language',
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(

                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondary,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
                child: const Text('Choose Profile Picture'),
              ),
              if (_profilePicture != null)
                Image.file(_profilePicture!, height: 100, width: 100),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(

                    backgroundColor: primary,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  ),
                  child: const Text('Save Now'),
                ).animate().fadeIn().scale(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmer(height: 20),
          const SizedBox(height: 16),
          _buildShimmer(height: 50),
          const SizedBox(height: 16),
          _buildShimmer(height: 50),
          const SizedBox(height: 16),
          _buildShimmer(height: 50),
          const SizedBox(height: 16),
          _buildShimmer(height: 300),
        ],
      ),
    );
  }

  Widget _buildShimmer({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color:primary,
      ),
    );
  }

  Widget _buildTextFormField({
    TextEditingController? controller,
    required String label,
    String? Function(String?)? validator,
    String? initialValue,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: _descriptionController,
            configurations: const QuillSimpleToolbarConfigurations(
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
    );
  }

  Widget _buildGenderDropdown(
      String label, int? value, List<int> options, Function(int?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
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