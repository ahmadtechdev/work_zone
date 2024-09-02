import 'package:flutter/material.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../service/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class BuyerJobEditPage extends StatefulWidget {
  final int jobId;

  BuyerJobEditPage({required this.jobId});

  @override
  _BuyerJobEditPageState createState() => _BuyerJobEditPageState();
}

class _BuyerJobEditPageState extends State<BuyerJobEditPage> {
  final ApiService _apiService = ApiService();
  final jobTitleController = TextEditingController();
  String _selectedJobDuration = "01 week";
  String _selectedJobType = "Fixed Price";
  String _selectedCategory = "web-development";
  late QuillController _descriptionController = QuillController.basic();
  final budgetController = TextEditingController();
  List<File> _selectedImages = [];
  String? _currentGigImg;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

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
    _loadJobData();
  }

  Future<void> _loadJobData() async {
    try {
      final jobData = await _apiService.getJob(widget.jobId);
      setState(() {
        jobTitleController.text = jobData['job']['title'];
        _selectedCategory = jobData['job']['category'];
        _selectedJobDuration = jobData['job']['jobDuration'];
        _selectedJobType = jobData['job']['jobType'];

        // Convert HTML to Quill Delta
        final document = Document.fromHtml(jobData['job']['description']);
        _descriptionController = QuillController(
          document: document,
          selection: TextSelection.collapsed(offset: 0),
        );

        budgetController.text = jobData['job']['budget'].toString();
        _currentGigImg = jobData['job']['gig_img'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading job data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load job data. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Job Post'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Job Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                controller: jobTitleController,
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Job Title";
                  } else if (value.length < 3) {
                    return 'Name must be more than 2 characters';
                  }
                  return null;
                },
              ),
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
              _buildDropdownField('Job Duration', _selectedJobDuration,
                  ["01 week", "03 Days", "05 Days", "07 Days", "10 Days"], (String? newValue) {
                    setState(() {
                      _selectedJobDuration = newValue!;
                    });
                  }),
              SizedBox(height: 16),
              _buildDropdownField('Job Type', _selectedJobType, ['Fixed Price', "Urgent"], (String? newValue) {
                setState(() {
                  _selectedJobType = newValue!;
                });
              }),
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
              SizedBox(height: 16),
              TextFormField(
                controller: budgetController,
                decoration: InputDecoration(
                  labelText: 'Budget',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Budget";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Upload Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: _pickImages,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Upload File & Image'),
                  ],
                ),
              ),
              if (_currentGigImg != null || _selectedImages.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_currentGigImg != null)
                        _buildImageWidget(_currentGigImg!, isNetwork: true),
                      ..._selectedImages.map((image) => _buildImageWidget(image.path)),
                    ],
                  ),
                ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lime300,
                  foregroundColor: white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Update Job Post'),
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

  Widget _buildImageWidget(String imagePath, {bool isNetwork = false}) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: isNetwork
              ? Image.network('${_apiService.baseUrlImg}$imagePath', width: 80, height: 80, fit: BoxFit.cover)
              : Image.file(File(imagePath), width: 80, height: 80, fit: BoxFit.cover),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              if (isNetwork) {
                _currentGigImg = null;
              } else {
                _selectedImages.removeWhere((image) => image.path == imagePath);
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _updateJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        final delta = _descriptionController.document.toDelta();
        final converter = QuillDeltaToHtmlConverter(
          delta.toJson(),
          ConverterOptions.forEmail(),
        );
        final htmlContent = converter.convert();

        var request = http.MultipartRequest('POST', Uri.parse('${_apiService.baseUrl}edit-job/${widget.jobId}'));

        // Add text fields
        request.fields['title'] = jobTitleController.text;
        request.fields['category'] = _selectedCategory;
        request.fields['jobDuration'] = _selectedJobDuration;
        request.fields['jobType'] = _selectedJobType;
        request.fields['description'] = htmlContent;
        request.fields['budget'] = budgetController.text;

        // Add image file
        if (_selectedImages.isNotEmpty) {
          var file = await http.MultipartFile.fromPath(
              'gig_img',
              _selectedImages[0].path,
              filename: path.basename(_selectedImages[0].path)
          );
          request.files.add(file);
        } else if (_currentGigImg == null) {
          request.fields['remove_gig_img'] = 'true';
        }

        // Add authorization header
        var prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('token') ?? '';
        request.headers['Authorization'] = 'Bearer $token';

        // Send the request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (result['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Job updated successfully')),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update job: ${result['message']}')),
            );
          }
        } else {
          throw Exception('Failed to update job: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
        print(e);
      }
    }
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    _descriptionController.dispose();
    budgetController.dispose();
    super.dispose();
  }
}