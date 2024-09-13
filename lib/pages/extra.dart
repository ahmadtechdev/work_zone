// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
// import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
//
// import '../../service/api_service.dart';
// import '../../widgets/colors.dart';
// import '../../widgets/snackbar.dart'; // Assuming CustomSnackBar is here
//
// class AddJobPostPage extends StatefulWidget {
//   @override
//   _AddJobPostPageState createState() => _AddJobPostPageState();
// }
//
// class _AddJobPostPageState extends State<AddJobPostPage>
//     with SingleTickerProviderStateMixin {
//   final ApiService apiService = ApiService();
//   final jobTitleController = TextEditingController();
//   String _selectedJobDuration = "01 week";
//   String _selectedJobType = "Fixed Price";
//   String _selectedCategory = "web-development";
//   final QuillController _descriptionController = QuillController.basic();
//   final minBudgetController = TextEditingController();
//   final maxBudgetController = TextEditingController();
//   List<File> _selectedImages = [];
//
//   final _formKey = GlobalKey<FormState>();
//   late AnimationController _animationController;
//   late Animation<double> _fadeInAnimation;
//
//   final List<Map<String, String>> categories = [
//     {"value": "", "label": "Select a Category"},
//     {"value": "web-development", "label": "Web Development"},
//     {"value": "android", "label": "Android Development"},
//     {"value": "ios", "label": "iOS Development"},
//     {"value": "software-development", "label": "Software Development"},
//     {"value": "graphic-design", "label": "Graphic Design"},
//     {"value": "ui-ux-design", "label": "UI/UX Design"},
//     {"value": "marketing", "label": "Marketing"},
//     {"value": "seo", "label": "SEO"},
//     {"value": "content-writing", "label": "Content Writing"},
//     {"value": "copywriting", "label": "Copywriting"},
//     {"value": "social-media-management", "label": "Social Media Management"},
//     {"value": "video-editing", "label": "Video Editing"},
//     {"value": "animation", "label": "Animation"},
//     {"value": "photography", "label": "Photography"},
//     {"value": "data-entry", "label": "Data Entry"},
//     {"value": "virtual-assistant", "label": "Virtual Assistant"},
//     {"value": "customer-service", "label": "Customer Service"},
//     {"value": "translation", "label": "Translation"},
//     {"value": "transcription", "label": "Transcription"},
//     {"value": "legal-services", "label": "Legal Services"},
//     {"value": "finance-accounting", "label": "Finance & Accounting"},
//     {"value": "human-resources", "label": "Human Resources"},
//     {"value": "project-management", "label": "Project Management"},
//     {"value": "business-consulting", "label": "Business Consulting"},
//     {"value": "sales", "label": "Sales"},
//     {"value": "ecommerce", "label": "E-commerce"},
//     {"value": "product-management", "label": "Product Management"},
//     {"value": "devops", "label": "DevOps"},
//     {"value": "cloud-computing", "label": "Cloud Computing"},
//     {"value": "cybersecurity", "label": "Cybersecurity"},
//     {"value": "blockchain", "label": "Blockchain"},
//     {"value": "ai-ml", "label": "AI & Machine Learning"},
//     {"value": "data-science", "label": "Data Science"},
//     {"value": "database-management", "label": "Database Management"},
//     {"value": "network-administration", "label": "Network Administration"},
//     {"value": "hardware-support", "label": "Hardware Support"},
//     {"value": "qa-testing", "label": "QA Testing"},
//     {"value": "game-development", "label": "Game Development"},
//     {"value": "mobile-app-development", "label": "Mobile App Development"},
//     {"value": "cloud-services", "label": "Cloud Services"},
//     {"value": "consulting", "label": "Consulting"},
//     {"value": "others", "label": "Others"},
//   ];
//
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeInAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     jobTitleController.dispose();
//     _descriptionController.dispose();
//     minBudgetController.dispose();
//     maxBudgetController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Post a Job'),
//         backgroundColor: primary,
//       ),
//       body: FadeTransition(
//         opacity: _fadeInAnimation,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 _buildHeader('Job Info'),
//                 _buildTextField(
//                   controller: jobTitleController,
//                   label: 'Job Title',
//                   validator: (value) {
//                     if (value!.isEmpty) return "Please enter Job Title";
//                     if (value.length < 3) return 'Title must be more than 2 characters';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDropdownField(
//                   'Category',
//                   _selectedCategory,
//                   categories.map((c) => c['value']!).toList(),
//                       (newValue) => setState(() {
//                     _selectedCategory = newValue!;
//                   }),
//                   categories.map((c) => c['label']!).toList(),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDropdownField(
//                   'Job Duration',
//                   _selectedJobDuration,
//                   ["01 week", "03 Days", "05 Days", "07 Days", "10 Days"],
//                       (newValue) => setState(() {
//                     _selectedJobDuration = newValue!;
//                   }),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDropdownField(
//                   'Job Type',
//                   _selectedJobType,
//                   ['Fixed Price', "Urgent"],
//                       (newValue) => setState(() {
//                     _selectedJobType = newValue!;
//                   }),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildHeader('Description'),
//                 _buildDescriptionEditor(),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   controller: minBudgetController,
//                   label: 'Min Budget',
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value!.isEmpty) return "Please enter Min Budget";
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(
//                   controller: maxBudgetController,
//                   label: 'Max Budget',
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value!.isEmpty) return "Please enter Max Budget";
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 _buildHeader('Upload Images'),
//                 _buildImagePicker(),
//                 _buildSelectedImagesPreview(), // Display selected images
//                 const SizedBox(height: 24),
//                 _buildSubmitButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dark400),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: dark200),
//         border: const OutlineInputBorder(),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: primary),
//         ),
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//     );
//   }
//
//   Widget _buildDescriptionEditor() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         Container(
//           height: 300,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Column(
//             children: [
//               // Toolbar
//               QuillSimpleToolbar(
//                 controller: _descriptionController,
//                 configurations: QuillSimpleToolbarConfigurations(
//                   toolbarIconAlignment: WrapAlignment.start,
//                   multiRowsDisplay: false, // Single row toolbar
//                   showDividers: false,
//                   showBoldButton: true,
//                   showItalicButton: true,
//                   showUnderLineButton: true,
//                   showColorButton: true,
//                   showBackgroundColorButton: true,
//                   showClearFormat: true,
//                   showAlignmentButtons: true,
//                   showLeftAlignment: true,
//                   showCenterAlignment: true,
//                   showRightAlignment: true,
//                   showJustifyAlignment: true,
//                   showHeaderStyle: true,
//                   showListNumbers: true,
//                   showListBullets: true,
//                   showUndo: true,
//                 ),
//               ),
//               // Editor
//               Expanded(
//                 child: QuillEditor.basic(
//                   controller: _descriptionController,
//                   configurations: const QuillEditorConfigurations(
//                     scrollable: true,
//                     autoFocus: false,
//                     placeholder: 'Enter job description...',
//                     padding: EdgeInsets.all(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildImagePicker() {
//     return OutlinedButton(
//       onPressed: _pickImages,
//       style: OutlinedButton.styleFrom(
//         side: BorderSide(color: primary),
//       ),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.upload_file, color: primary),
//           SizedBox(width: 8),
//           Text('Upload File & Image', style: TextStyle(color: primary)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectedImagesPreview() {
//     return _selectedImages.isNotEmpty
//         ? Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: _selectedImages
//             .map((image) => Stack(
//           alignment: Alignment.topRight,
//           children: [
//             Image.file(
//               image,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//             IconButton(
//               icon: Icon(Icons.cancel, color: secondary),
//               onPressed: () {
//                 setState(() {
//                   _selectedImages.remove(image);
//                 });
//               },
//             ),
//           ],
//         ))
//             .toList(),
//       ),
//     )
//         : const SizedBox.shrink();
//   }
//
//   Widget _buildSubmitButton() {
//     return ElevatedButton(
//       onPressed: _submitJobPost,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primary, // Your brand primary color
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: const Text('Post', style: TextStyle(color: white, fontSize: 18)),
//     );
//   }
//
//   Future<void> _pickImages() async {
//     final ImagePicker _picker = ImagePicker();
//     final List<XFile>? images = await _picker.pickMultiImage();
//
//     if (images != null) {
//       setState(() {
//         _selectedImages = images.map((image) => File(image.path)).toList();
//       });
//     }
//   }
//
//   Future<void> _submitJobPost() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final delta = _descriptionController.document.toDelta();
//         final converter = QuillDeltaToHtmlConverter(
//           delta.toJson(),
//           ConverterOptions.forEmail(),
//         );
//         final htmlContent = converter.convert();
//
//         var request = http.MultipartRequest('POST', Uri.parse('${apiService.baseUrl}store-job'));
//
//         // Add text fields
//         request.fields['title'] = jobTitleController.text;
//         request.fields['category'] = _selectedCategory;
//         request.fields['jobDuration'] = _selectedJobDuration;
//         request.fields['jobType'] = _selectedJobType;
//         request.fields['description'] = htmlContent;
//         request.fields['budget'] = minBudgetController.text;
//         request.fields['maxbudget'] = maxBudgetController.text;
//
//         // Add image file
//         if (_selectedImages.isNotEmpty) {
//           var file = await http.MultipartFile.fromPath(
//               'gig_img',
//               _selectedImages[0].path,
//               filename: path.basename(_selectedImages[0].path)
//           );
//           request.files.add(file);
//         }
//
//         // Add authorization header
//         var prefs = await SharedPreferences.getInstance();
//         var token = prefs.getString('token') ?? '';
//         request.headers['Authorization'] = 'Bearer $token';
//
//         // Send the request
//         var streamedResponse = await request.send();
//         var response = await http.Response.fromStream(streamedResponse);
//
//         if (response.statusCode == 200) {
//           var result = jsonDecode(response.body);
//           if (result['status'] == 'success') {
//             CustomSnackBar(
//               message: 'Job posted successfully',
//               backgroundColor: Colors.green,
//             ).show(context);
//             Navigator.of(context).pop();
//           } else {
//             CustomSnackBar(
//               message: 'An error occurred: ',
//               backgroundColor: Colors.red,
//             ).show(context);
//           }
//         } else {
//           throw Exception('Failed to post job: ${response.body}');
//         }
//       } catch (e) {
//         CustomSnackBar(
//           message: 'An error occurred: $e',
//           backgroundColor: Colors.red,
//         ).show(context);
//       }
//     }
//   }
//
//   Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged, [List<String>? displayOptions]) {
//     return InputDecorator(
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           onChanged: onChanged,
//           items: options.asMap().entries.map<DropdownMenuItem<String>>((entry) {
//             int idx = entry.key;
//             String option = entry.value;
//             return DropdownMenuItem<String>(
//               value: option,
//               child: Text(displayOptions != null ? displayOptions[idx] : option),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
// }
