import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../widgets/colors.dart';

class SellerProfileSettings extends StatefulWidget {
  @override
  _SellerProfileSettingsState createState() => _SellerProfileSettingsState();
}

class _SellerProfileSettingsState extends State<SellerProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _majorController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _skillController = TextEditingController();

  String? _selectedSpeciality;
  String? _selectedGender;
  List<String> _selectedLanguages = [];
  quill.QuillController _descriptionController = quill.QuillController.basic();
  List<String> _skills = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildSectionTitle('Profile Info'),
                SizedBox(height: 16),
                _buildNameFields(),
                SizedBox(height: 16),
                _buildEmailSpecialityFields(),
                _buildDescriptionField(),
                SizedBox(height: 16),
                _buildPhoneGenderFields(),
                SizedBox(height: 16),
                _buildLanguageProfilePictureFields(),
                SizedBox(height: 24),
                _buildSectionTitle('Highest Education Info'),
                SizedBox(height: 16),
                _buildEducationFields(),
                SizedBox(height: 24),
                _buildSectionTitle('Skills'),
                SizedBox(height: 16),
                _buildSkillsField(),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.green[100],
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNameFields() {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(labelText: 'First Name *',border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: InputDecoration(labelText: 'Last Name *',border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }


  Widget _buildEmailSpecialityFields() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email Address *', border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSpeciality,
          decoration: InputDecoration(labelText: 'Speciality *', border: const OutlineInputBorder(),),
          items: ['Web Development', 'Mobile App Development', 'UI/UX Design']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedSpeciality = newValue;
            });
          },
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPhoneGenderFields() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: 'Phone no *', border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(labelText: 'Gender *',border: const OutlineInputBorder(),),
          items: ['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildLanguageProfilePictureFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Language',border: const OutlineInputBorder(),),
          items: ['English', 'Urdu', 'Arabic'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null && !_selectedLanguages.contains(newValue)) {
              setState(() {
                _selectedLanguages.add(newValue);
              });
            }
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Choose Profile Picture'),
        ),
      ],
    );
  }

  Widget _buildEducationFields() {
    return Column(
      children: [
        TextFormField(
          controller: _institutionController,
          decoration: InputDecoration(labelText: 'Institution *',border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _degreeController,
          decoration: InputDecoration(labelText: 'Degree *',border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _majorController,
          decoration: InputDecoration(labelText: 'Major *',border: const OutlineInputBorder(),),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Start Date *',border: const OutlineInputBorder(),),
                onTap: () => _selectDate(context, _startDateController),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(labelText: 'End Date *',border: const OutlineInputBorder(),),
                onTap: () => _selectDate(context, _endDateController),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsField() {
    return Column(
      children: [
        TextFormField(
          controller: _skillController,
          decoration: InputDecoration(
            labelText: 'Skills',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _addSkill,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: _skills.map((skill) => Chip(
            label: Text(skill),
            onDeleted: () => _removeSkill(skill),
          )).toList(),
        ),
      ],
    );
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
      });
    }
  }

  void _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement form submission logic
      print('Form is valid. Submitting...');
    }
  }
}