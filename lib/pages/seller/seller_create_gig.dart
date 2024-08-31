import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'dart:io';

import '../../service/api_service.dart';
import '../../widgets/colors.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'seller_manage_gig.dart';

class SellerCreateGig extends StatefulWidget {
  const SellerCreateGig({Key? key}) : super(key: key);

  @override
  _SellerCreateGigState createState() => _SellerCreateGigState();
}

class _SellerCreateGigState extends State<SellerCreateGig> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  final ApiService apiService = ApiService();

  // Controllers for text fields
  final _titleController = TextEditingController();
  String _selectedCategory = "web-development";
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
    {"value": "android", "label": "Android Development"},
    {"value": "ios", "label": "iOS Development"},
    {"value": "software-development", "label": "Software Development"},
    {"value": "graphic-design", "label": "Graphic Design"},
    {"value": "ui-ux-design", "label": "UI/UX Design"},
    {"value": "marketing", "label": "Marketing"},
    {"value": "seo", "label": "SEO"},
    {"value": "content-writing", "label": "Content Writing"},
    {"value": "copywriting", "label": "Copywriting"},
    {"value": "social-media-management", "label": "Social Media Management"},
    {"value": "video-editing", "label": "Video Editing"},
    {"value": "animation", "label": "Animation"},
    {"value": "photography", "label": "Photography"},
    {"value": "data-entry", "label": "Data Entry"},
    {"value": "virtual-assistant", "label": "Virtual Assistant"},
    {"value": "customer-service", "label": "Customer Service"},
    {"value": "translation", "label": "Translation"},
    {"value": "transcription", "label": "Transcription"},
    {"value": "legal-services", "label": "Legal Services"},
    {"value": "finance-accounting", "label": "Finance & Accounting"},
    {"value": "human-resources", "label": "Human Resources"},
    {"value": "project-management", "label": "Project Management"},
    {"value": "business-consulting", "label": "Business Consulting"},
    {"value": "sales", "label": "Sales"},
    {"value": "ecommerce", "label": "E-commerce"},
    {"value": "product-management", "label": "Product Management"},
    {"value": "devops", "label": "DevOps"},
    {"value": "cloud-computing", "label": "Cloud Computing"},
    {"value": "cybersecurity", "label": "Cybersecurity"},
    {"value": "blockchain", "label": "Blockchain"},
    {"value": "ai-ml", "label": "AI & Machine Learning"},
    {"value": "data-science", "label": "Data Science"},
    {"value": "database-management", "label": "Database Management"},
    {"value": "network-administration", "label": "Network Administration"},
    {"value": "hardware-support", "label": "Hardware Support"},
    {"value": "qa-testing", "label": "QA Testing"},
    {"value": "game-development", "label": "Game Development"},
    {"value": "mobile-app-development", "label": "Mobile App Development"},
    {"value": "cloud-services", "label": "Cloud Services"},
    {"value": "consulting", "label": "Consulting"},
    {"value": "others", "label": "Others"},
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = QuillController.basic();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
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
        title: Text('Create a Gig'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        child: Image.file(_images[index], width: 100, height: 100, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),

              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitJobPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lime300,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Post'),
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

  Future<void> _submitJobPost() async {
    if (_formKey.currentState!.validate()) {
      try {
        final delta = _descriptionController.document.toDelta();
        final converter = QuillDeltaToHtmlConverter(
          delta.toJson(),
          ConverterOptions.forEmail(),
        );
        final htmlContent = converter.convert();

        var request = http.MultipartRequest('POST', Uri.parse('${apiService.baseUrl}store-gig'));

        // Add text fields
        request.fields['title'] = _titleController.text;
        request.fields['category'] = _selectedCategory;
        request.fields['description'] = htmlContent;
        request.fields['basic_description'] = _basicDescriptionController.text;
        request.fields['basic_delivery_time'] = _basicDeliveryTime!;
        request.fields['basic_revision'] = _basicRevision!;
        request.fields['basic_price'] = _basicPriceController.text;
        request.fields['standard_description'] = _standardDescriptionController.text;
        request.fields['standard_delivery_time'] = _standardDeliveryTime!;
        request.fields['standard_revision'] = _standardRevision!;
        request.fields['standard_price'] = _premiumPriceController.text;
        request.fields['premium_description'] = _premiumDescriptionController.text;
        request.fields['premium_delivery_time'] = _premiumDeliveryTime!;
        request.fields['premium_revision'] = _premiumRevision!;
        request.fields['premium_price'] = _premiumPriceController.text;


        // Add image file
        if (_images.isNotEmpty) {
          var file = await http.MultipartFile.fromPath(
              'gig_img',
              _images[0].path,
              filename: path.basename(_images[0].path)
          );
          request.files.add(file);
        }

        // Add authorization header
        var prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('token') ?? '';
        request.headers['Authorization'] = 'Bearer $token';

        // Send the request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        print(response);
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          // print('Failed to post job: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result['message']}')),
          );
         Get.off(()=> SellerManageGig());
        } else {
          var result = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post: ${result['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
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