import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../../service/api_service.dart';
import '../../widgets/colors.dart';

class SellerEditGig extends StatefulWidget {
  final int gigId;

  SellerEditGig({required this.gigId});

  @override
  _SellerEditGigState createState() => _SellerEditGigState();
}

class _SellerEditGigState extends State<SellerEditGig> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  final ApiService apiService = ApiService();

  // Controllers for text fields
  final _titleController = TextEditingController();
  String _selectedCategory = "";
  late QuillController _descriptionController;

  // Controllers for pricing packages
  final _basicDescriptionController = TextEditingController();
  final _standardDescriptionController = TextEditingController();
  final _premiumDescriptionController = TextEditingController();

  final _basicPriceController = TextEditingController();
  final _standardPriceController = TextEditingController();
  final _premiumPriceController = TextEditingController();

  String? _basicDeliveryTime;
  String? _standardDeliveryTime;
  String? _premiumDeliveryTime;

  String? _basicRevision;
  String? _standardRevision;
  String? _premiumRevision;

  final List<Map<String, String>> categories = [
    {"value": "", "label": "Select a Category"},
    {"value": "web-development", "label": "Web Development"},
    // Add other categories here
  ];

  @override
  void initState() {
    super.initState();
    _loadGigData();
    _descriptionController = QuillController.basic();
  }

  Future<void> _loadGigData() async {
    try {
      final gigData = await apiService.getGig(widget.gigId);
      setState(() {
        _titleController.text = gigData['gig']['title'];
        _selectedCategory = gigData['gig']['category'];
        _basicDescriptionController.text = gigData['gig']['basic_description'];
        _basicDeliveryTime = gigData['gig']['basic_delivery_time'];
        _basicRevision = gigData['gig']['basic_revision'];
        _basicPriceController.text = gigData['gig']['basic_price'].toString();

        _standardDescriptionController.text = gigData['gig']['standard_description'];
        _standardDeliveryTime = gigData['gig']['standard_delivery_time'];
        _standardRevision = gigData['gig']['standard_revision'];
        _standardPriceController.text = gigData['gig']['standard_price'].toString();

        _premiumDescriptionController.text = gigData['gig']['premium_description'];
        _premiumDeliveryTime = gigData['gig']['premium_delivery_time'];
        _premiumRevision = gigData['gig']['premium_revision'];
        _premiumPriceController.text = gigData['gig']['premium_price'].toString();

        // Convert HTML to Quill Delta
        final document = Document.fromHtml(gigData['gig']['description']);
        _descriptionController = QuillController(
          document: document,
          selection: TextSelection.collapsed(offset: 0),
        );

        if (gigData['gig']['gig_img'] != null) {
          _images.add(File('${apiService.baseUrlImg}${gigData['gig']['gig_img']}'));
        }
      });
    } catch (e) {
      print('Error loading gig data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load gig data. Please try again.')),
      );
    }
  }

  Future<void> _updateGig() async {
    if (_formKey.currentState!.validate()) {
      try {
        final delta = _descriptionController.document.toDelta();
        final converter = QuillDeltaToHtmlConverter(
          delta.toJson(),
          ConverterOptions.forEmail(),
        );
        final htmlContent = converter.convert();

        final gigData = {
          'title': _titleController.text,
          'category': _selectedCategory,
          'description': htmlContent,
          'basic_description': _basicDescriptionController.text,
          'basic_delivery_time': _basicDeliveryTime!,
          'basic_revision': _basicRevision!,
          'basic_price': _basicPriceController.text,
          'standard_description': _standardDescriptionController.text,
          'standard_delivery_time': _standardDeliveryTime!,
          'standard_revision': _standardRevision!,
          'standard_price': _standardPriceController.text,
          'premium_description': _premiumDescriptionController.text,
          'premium_delivery_time': _premiumDeliveryTime!,
          'premium_revision': _premiumRevision!,
          'premium_price': _premiumPriceController.text,
          'gig_img': _images.isNotEmpty ? _images[0] : null,
        };

        print(widget.gigId);
        print(gigData);
        final result = await apiService.gigUpdate(widget.gigId, gigData);
        print(result);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gig updated successfully')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update gig: ${result['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
        print(e);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPricingPackageCard(String title, TextEditingController descriptionController,
      TextEditingController priceController, String? deliveryTime, String? revision,
      Function(String?) onDeliveryTimeChanged, Function(String?) onRevisionChanged) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildTextField('Description', descriptionController, maxLines: 3),
            _buildDropdown('Delivery Time', deliveryTime, ['1 day', '3 days', '7 days'], onDeliveryTimeChanged),
            _buildDropdown('Revision', revision, ['1 time', '2 times', '3 times'], onRevisionChanged),
            _buildTextField('Price', priceController),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Gig'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gig Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildTextField('Title', _titleController),
              SizedBox(height: 16),
              _buildDropdownField(
                'Category',
                _selectedCategory,
                categories.map((c) => c["value"]!).toList(),
                    (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                categories.map((c) => c["label"]!).toList(),
              ),
              SizedBox(height: 16),
              Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
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
                      configurations: QuillSimpleToolbarConfigurations(
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
              SizedBox(height: 24),

              Text('Pricing Packages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildPricingPackageCard(
                'Basic',
                _basicDescriptionController,
                _basicPriceController,
                _basicDeliveryTime,
                _basicRevision,
                    (value) => setState(() => _basicDeliveryTime = value),
                    (value) => setState(() => _basicRevision = value),
              ),
              _buildPricingPackageCard(
                'Standard',
                _standardDescriptionController,
                _standardPriceController,
                _standardDeliveryTime,
                _standardRevision,
                    (value) => setState(() => _standardDeliveryTime = value),
                    (value) => setState(() => _standardRevision = value),
              ),
              _buildPricingPackageCard(
                'Premium',
                _premiumDescriptionController,
                _premiumPriceController,
                _premiumDeliveryTime,
                _premiumRevision,
                    (value) => setState(() => _premiumDeliveryTime = value),
                    (value) => setState(() => _premiumRevision = value),
              ),

              SizedBox(height: 24),
              Text('Upload Gig Images', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: _pickImage,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Upload File & Image'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              if (_images.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(_images[index], width: 100, height: 100, fit:BoxFit.cover),
                      );
                    },
                  ),
                ),

              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateGig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lime300,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Update Gig'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged, [List<String>? displayOptions]) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: options.asMap().entries.map<DropdownMenuItem<String>>((entry) {
            int idx = entry.key;
            String option = entry.value;
            return DropdownMenuItem<String>(
              value: option,
              child: Text(displayOptions != null ? displayOptions[idx] : option),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _basicDescriptionController.dispose();
    _standardDescriptionController.dispose();
    _premiumDescriptionController.dispose();
    _basicPriceController.dispose();
    _standardPriceController.dispose();
    _premiumPriceController.dispose();
    super.dispose();
  }
}