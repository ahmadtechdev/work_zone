// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
// import '../../service/api_service.dart';
// import '../../widgets/colors.dart';
// import 'seller_create_gig.dart';
// import 'seller_manage_gig.dart';
//
// class SellerEditGig extends StatefulWidget {
//   final int gigId;
//
//   const SellerEditGig({super.key, required this.gigId});
//
//   @override
//   _SellerEditGigState createState() => _SellerEditGigState();
// }
//
// class _SellerEditGigState extends State<SellerEditGig> {
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();
//   final List<File> _images = [];
//   final ApiService apiService = ApiService();
//
//   // Controllers
//   final TextEditingController _titleController = TextEditingController();
//   late QuillController _descriptionController;
//   String _selectedCategory = "";
//
//   // Pricing package controllers
//   final Map<String, PackageControllers> _packageControllers = {
//     'Basic': PackageControllers(),
//     'Standard': PackageControllers(),
//     'Premium': PackageControllers(),
//   };
//
//   // Categories structure
//   final List<CategoryGroup> categories = [
//     // SEO and SEM
//     CategoryGroup(
//       name: "1. SEO and SEM",
//       items: [
//         "SEO Experts",
//         "Search Engine Marketing (SEM) Specialists",
//         "SEO Auditors",
//         "Link Building Specialists",
//         "Local SEO Experts",
//         "Keyword Research Analysts",
//       ],
//     ),
//     // Content Creation
//     CategoryGroup(
//       name: "2. Content Creation",
//       items: [
//         "Content Writers",
//         "Copywriters",
//         "Social Media Content Creators",
//         "Blog Writers",
//         "Scriptwriters for Video Content",
//         "Product Description Writers",
//         "Email Marketers",
//         "Social Media Graphic Designers",
//         "Infographic Designers",
//         "Presentation Designers (PowerPoint, etc.)",
//         "Digital Illustrators",
//       ],
//     ),
//     // Graphic Design and Branding
//     CategoryGroup(
//       name: "3. Graphic Design and Branding",
//       items: [
//         "Branding and Logo Designers",
//         "Motion Graphic Designers",
//         "Infographic Designers",
//         "Graphic Designers for social media posts, thumbnails, and other visual content",
//         "Brand Consultants",
//         "Rebranding Specialists",
//         "Brand Voice Experts",
//       ],
//     ),
//     // Video and Photography
//     CategoryGroup(
//       name: "4. Video and Photography",
//       items: [
//         "Video Editors",
//         "Videographers",
//         "Motion Graphics Artists",
//         "Animators (2D, 3D)",
//         "Camera Crew for Events/Productions",
//         "YouTube Video Editors",
//         "Product Photographers",
//       ],
//     ),
//     // Social Media Management
//     CategoryGroup(
//       name: "5. Social Media Management",
//       items: [
//         "Social Media Managers",
//         "Facebook/Instagram Ad Specialists",
//         "Social Media Strategists",
//         "Influencer Marketing Managers",
//         "Community Managers",
//         "LinkedIn Marketing Experts",
//         "Pinterest Marketing Specialists",
//         "Content Creators for social media platforms",
//         "Growth Hackers",
//         "Conversion Rate Optimization (CRO) Specialists for social media pages",
//       ],
//     ),
//     // Digital Marketing
//     CategoryGroup(
//       name: "6. Digital Marketing",
//       items: [
//         "PPC (Pay-Per-Click) Specialists",
//         "Google Ads Experts",
//         "Social Media Ads Specialists",
//         "Display Advertising Experts",
//         "Affiliate Marketing Managers",
//         "Digital Marketing Strategists",
//       ],
//     ),
//     // Web Development and Design (Marketing-Focused)
//     CategoryGroup(
//       name: "7. Web Development and Design (Marketing-Focused)",
//       items: [
//         "Landing Page Designers",
//         "Conversion Rate Optimization (CRO) Specialists",
//         "Web Developers (WordPress, Shopify, etc.)",
//         "UX/UI Designers",
//         "Email Template Designers",
//         "Web Designers for influencer branding sites or landing pages",
//       ],
//     ),
//     // E-commerce Marketing
//     CategoryGroup(
//       name: "8. E-commerce Marketing",
//       items: [
//         "E-commerce SEO Experts",
//         "Shopify Marketing Specialists",
//         "Amazon Marketing Experts",
//         "Product Listing Optimization Specialists",
//         "E-commerce Developers (Shopify, WooCommerce, etc.)",
//         "Product Launch Specialists for influencers selling merchandise",
//       ],
//     ),
//     // Analytics and Data
//     CategoryGroup(
//       name: "9. Analytics and Data",
//       items: [
//         "Marketing Data Analysts",
//         "Google Analytics Specialists",
//         "Conversion Tracking Experts",
//         "Marketing Automation Experts (HubSpot, Marketo, etc.)",
//         "CRM (Customer Relationship Management) Specialists",
//         "Social Media Analytics Specialists",
//       ],
//     ),
//     // Public Relations (PR)
//     CategoryGroup(
//       name: "10. Public Relations (PR)",
//       items: [
//         "PR Consultants",
//         "Media Relations Specialists",
//         "Crisis Management Experts",
//         "Press Release Writers",
//         "Event Promotion Specialists",
//       ],
//     ),
//     // Brand Strategy and Consulting
//     CategoryGroup(
//       name: "11. Brand Strategy and Consulting",
//       items: [
//         "Brand Consultants",
//         "Rebranding Specialists",
//         "Brand Voice Experts",
//       ],
//     ),
//     // Email and Newsletter Marketing
//     CategoryGroup(
//       name: "12. Email and Newsletter Marketing",
//       items: [
//         "Email Marketing Specialists",
//         "Newsletter Writers/Designers",
//         "Email Automation Specialists (Mailchimp, Klaviyo, etc.)",
//       ],
//     ),
//     // Podcast and Audio Production
//     CategoryGroup(
//       name: "13. Podcast and Audio Production",
//       items: [
//         "Podcast Editors",
//         "Sound Engineers",
//         "Voiceover Artists for narrations or intros",
//       ],
//     ),
//     // Legal and Compliance
//     CategoryGroup(
//       name: "14. Legal and Compliance",
//       items: [
//         "Legal Consultants for reviewing contracts and agreements",
//         "Copyright Specialists for protecting influencer content and intellectual property",
//       ],
//     ),
//     // Virtual Assistance
//     CategoryGroup(
//       name: "15. Virtual Assistance",
//       items: [
//         "Influencer Virtual Assistants for managing schedules, collaborations, and campaigns",
//         "Customer Service Specialists to handle influencer-related queries or product support",
//       ],
//     ),
//   ];
//
//   List<String> deliveryTimeOptions = [
//     'Select Delivery Time',
//     '1 Day',
//     '2 Days',
//     '3 Days',
//     '4 Days',
//     '5 Days',
//     '6 Days',
//     '7 Days',
//     '10 Days',
//     '15 Days',
//     '20 Days',
//     '30 Days',
//     '45 Days',
//     '60 Days',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadGigData();
//     _descriptionController = QuillController.basic();
//   }
//
//   Future<void> _loadGigData() async {
//     try {
//       final gigData = await apiService.getGig(widget.gigId);
//       setState(() {
//         _titleController.text = gigData['gig']['title'];
//         _selectedCategory = gigData['gig']['category'];
//
//         _packageControllers['Basic']!.description.text = gigData['gig']['basic_description'];
//         _packageControllers['Basic']!.deliveryTime.value = gigData['gig']['basic_delivery_time'];
//         _packageControllers['Basic']!.revision.value = gigData['gig']['basic_revision'];
//         _packageControllers['Basic']!.price.text = gigData['gig']['basic_price'].toString();
//
//         _packageControllers['Standard']!.description.text = gigData['gig']['standard_description'];
//         _packageControllers['Standard']!.deliveryTime.value = gigData['gig']['standard_delivery_time'];
//         _packageControllers['Standard']!.revision.value = gigData['gig']['standard_revision'];
//         _packageControllers['Standard']!.price.text = gigData['gig']['standard_price'].toString();
//
//         _packageControllers['Premium']!.description.text = gigData['gig']['premium_description'];
//         _packageControllers['Premium']!.deliveryTime.value = gigData['gig']['premium_delivery_time'];
//         _packageControllers['Premium']!.revision.value = gigData['gig']['premium_revision'];
//         _packageControllers['Premium']!.price.text = gigData['gig']['premium_price'].toString();
//
//         final document = Document.fromHtml(gigData['gig']['description']);
//         _descriptionController = QuillController(
//           document: document,
//           selection: const TextSelection.collapsed(offset: 0),
//         );
//
//         if (gigData['gig']['gig_img'] != null) {
//           _images.add(File('${apiService.baseUrlImg}${gigData['gig']['gig_img']}'));
//         }
//       });
//     } catch (e) {
//       print('Error loading gig data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to load gig data. Please try again.')),
//       );
//     }
//   }
//
//
//   Future<void> _updateGig() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final delta = _descriptionController.document.toDelta();
//         final converter = QuillDeltaToHtmlConverter(
//           delta.toJson(),
//           ConverterOptions.forEmail(),
//         );
//         final htmlContent = converter.convert();
//
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('${apiService.baseUrl}update-gig/${widget.gigId}'),
//         );
//
//         _addTextFields(request, htmlContent);
//         await _addImages(request);
//         await _addAuthorizationHeader(request);
//
//         var streamedResponse = await request.send();
//         var response = await http.Response.fromStream(streamedResponse);
//
//         _handleResponse(response);
//       } catch (e) {
//         _showErrorSnackBar('An error occurred: $e');
//       }
//     }
//   }
//
//   void _addTextFields(http.MultipartRequest request, String htmlContent) {
//     request.fields['title'] = _titleController.text;
//     request.fields['category'] = _selectedCategory;
//     request.fields['description'] = htmlContent;
//
//     for (var entry in _packageControllers.entries) {
//       var package = entry.key.toLowerCase();
//       var controllers = entry.value;
//       request.fields['${package}_description'] = controllers.description.text;
//       request.fields['${package}_delivery_time'] = controllers.deliveryTime.value ?? '';
//       request.fields['${package}_revision'] = controllers.revision.value ?? '';
//       request.fields['${package}_price'] = controllers.price.text;
//     }
//   }
//
//   Future<void> _addImages(http.MultipartRequest request) async {
//     for (var image in _images) {
//       if (image is File) {
//         var file = await http.MultipartFile.fromPath(
//           'gig_img[]',
//           image.path,
//           filename: path.basename(image.path),
//         );
//         request.files.add(file);
//       } else if (image is String) {
//         request.fields['existing_images[]'] = image;
//       }
//     }
//   }
//
//   Future<void> _addAuthorizationHeader(http.MultipartRequest request) async {
//     var prefs = await SharedPreferences.getInstance();
//     var token = prefs.getString('token') ?? '';
//     request.headers['Authorization'] = 'Bearer $token';
//   }
//
//   void _handleResponse(http.Response response) {
//     var result = jsonDecode(response.body);
//     if (response.statusCode == 200) {
//       _showSuccessSnackBar(result['message']);
//       Get.off(() => SellerManageGig());
//     } else {
//       _showErrorSnackBar('Failed to update: ${result['message']}');
//     }
//   }
//
//   void _showSuccessSnackBar(String message) {
//     CustomSnackBar(
//       message: message,
//       backgroundColor: Colors.green,
//     ).show(context);
//   }
//
//   void _showErrorSnackBar(String message) {
//     CustomSnackBar(
//       message: message,
//       backgroundColor: Colors.red,
//     ).show(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Gig'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSectionTitle('Gig Info'),
//               _buildTextField('Title', _titleController),
//               _buildCategoryDropdown(),
//               _buildDescriptionField(),
//               _buildSectionTitle('Pricing Packages'),
//               ..._packageControllers.entries.map((entry) =>
//                   _buildPricingPackageCard(entry.key, entry.value)
//               ),
//               _buildSectionTitle('Upload Gig Images'),
//               _buildImageUploader(),
//               const SizedBox(height: 24),
//               _buildSubmitButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//     );
//   }
//
//   Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         validator: (value) => value?.isEmpty ?? true ? 'Please enter $label' : null,
//       ),
//     );
//   }
//
//   Widget _buildCategoryDropdown() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           return DropdownButtonHideUnderline(
//             child: DropdownButtonFormField<String>(
//               value: _selectedCategory.isEmpty ? null : _selectedCategory,
//               decoration: InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//               ),
//               items: _buildDropdownItems(),
//               onChanged: (String? newValue) {
//                 if (newValue != null && !newValue.startsWith('__GROUP__')) {
//                   setState(() => _selectedCategory = newValue);
//                 }
//               },
//               validator: (value) => value == null ? 'Please select a category' : null,
//               isDense: true,
//               isExpanded: true,
//               icon: const Icon(Icons.arrow_drop_down),
//               iconSize: 24,
//               elevation: 16,
//               style: const TextStyle(color: Colors.black, fontSize: 16),
//               dropdownColor: Colors.white,
//               menuMaxHeight: MediaQuery.sizeOf(context).height/1.75,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   List<DropdownMenuItem<String>> _buildDropdownItems() {
//     List<DropdownMenuItem<String>> items = [];
//     for (var group in categories) {
//       items.add(DropdownMenuItem<String>(
//         value: '__GROUP__${group.name}',
//         enabled: false,
//         child: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
//       ));
//       items.addAll(group.items.map((item) => DropdownMenuItem<String>(
//         value: item,
//         child: Padding(
//           padding: const EdgeInsets.only(left: 16.0),
//           child: Text(item, overflow: TextOverflow.ellipsis),
//         ),
//       )));
//     }
//     return items;
//   }
//
//   Widget _buildDescriptionField() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Container(
//             height: 300,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Column(
//               children: [
//                 QuillSimpleToolbar(
//                   controller: _descriptionController,
//                   configurations: const QuillSimpleToolbarConfigurations(
//                     toolbarIconAlignment: WrapAlignment.start,
//                     multiRowsDisplay: false,
//                     showDividers: false,
//                     showFontFamily: false,
//                     showFontSize: false,
//                     showBoldButton: true,
//                     showItalicButton: true,
//                     showUnderLineButton: true,
//                     showStrikeThrough: false,
//                     showInlineCode: false,
//                     showColorButton: true,
//                     showBackgroundColorButton: true,
//                     showClearFormat: true,
//                     showAlignmentButtons: true,
//                     showLeftAlignment: true,
//                     showCenterAlignment: true,
//                     showRightAlignment: true,
//                     showJustifyAlignment: true,
//                     showHeaderStyle: true,
//                     showListNumbers: true,
//                     showListBullets: true,
//                     showListCheck: false,
//                     showCodeBlock: false,
//                     showQuote: false,
//                     showIndent: false,
//                     showLink: false,
//                     showUndo: true,
//                     showRedo: false,
//                   ),
//                 ),
//                 Expanded(
//                   child: QuillEditor.basic(
//                     controller: _descriptionController,
//                     configurations: const QuillEditorConfigurations(
//                       scrollable: true,
//                       autoFocus: false,
//                       placeholder: 'Enter job description...',
//                       padding: EdgeInsets.all(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPricingPackageCard(String title, PackageControllers controllers) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _buildTextField('Description', controllers.description, maxLines: 3),
//             _buildDropdown(
//                 'Delivery Time', controllers.deliveryTime, deliveryTimeOptions),
//             _buildDropdown('Revision', controllers.revision, [
//               '1',
//               '2',
//               '3',
//               '4',
//               '5',
//               '6',
//               '7',
//               '8',
//               '9',
//               '10',
//               'Unlimited'
//             ]),
//             _buildTextField('Price', controllers.price),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdown(String label, ValueNotifier<String?> valueNotifier, List<String> items) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: ValueListenableBuilder<String?>(
//         valueListenable: valueNotifier,
//         builder: (context, value, child) {
//           return DropdownButtonFormField<String>(
//             value: value,
//             decoration: InputDecoration(
//               labelText: label,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             items: items.map((String item) {
//               return DropdownMenuItem<String>(value: item, child: Text(item));
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 valueNotifier.value = newValue;
//               }
//             },
//             validator: (value) => value == null ? 'Please select $label' : null,
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildImageUploader() {
//     return Column(
//       children: [
//         OutlinedButton(
//           onPressed: _pickImages,
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.upload_file),
//               SizedBox(width: 8),
//               Text('Upload File & Image'),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         if (_images.isNotEmpty)
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _images.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8.0),
//                   child: Stack(
//                     children: [
//                       _images[index] is File
//                           ? Image.file(_images[index] as File, width: 100, height: 100, fit: BoxFit.cover)
//                           : CachedNetworkImage(
//                         imageUrl: _images[index],
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => const CircularProgressIndicator(),
//                         errorWidget: (context, url, error) => const Icon(Icons.error),
//                       ),
//                       Positioned(
//                         top: 0,
//                         right: 0,
//                         child: GestureDetector(
//                           onTap: () => _removeImage(index),
//                           child: Container(
//                             padding: const EdgeInsets.all(2),
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Icon(Icons.close, color: Colors.white, size: 16),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _updateGig,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primary,
//           foregroundColor: white,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//         child: const Text('Update'),
//       ),
//     );
//   }
//   Future<void> _pickImages() async {
//     final List<XFile>? images = await _picker.pickMultiImage();
//
//     if (images != null && images.isNotEmpty) {
//       setState(() {
//         _images.addAll(images.map((image) => File(image.path)));
//       });
//     }
//   }
//   void _removeImage(int index) {
//     setState(() {
//       _images.removeAt(index);
//     });
//   }
// }