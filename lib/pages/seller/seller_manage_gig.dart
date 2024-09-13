import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // For skeleton loader
import 'package:work_zone/pages/seller/seller_create_gig.dart';
import 'package:work_zone/pages/seller/seller_edit_gig.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import '../../widgets/bottom_navigation_bar_seller.dart';
import '../../widgets/snackbar.dart'; // CustomSnackBar class

class SellerManageGig extends StatefulWidget {
  @override
  _SellerManageGigState createState() => _SellerManageGigState();
}

class _SellerManageGigState extends State<SellerManageGig>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> gigs = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadGigs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadGigs({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cachedGigs = prefs.getString('cachedGigs');
      if (cachedGigs != null) {
        setState(() {
          gigs = List<Map<String, dynamic>>.from(json.decode(cachedGigs));
          isLoading = false;
          errorMessage = null;
        });
        return;
      }
    }
    try {
      final response = await _apiService.get("all-gigs-foruser");
      setState(() {
        gigs = List<Map<String, dynamic>>.from(response['gigs']);
        isLoading = false;
        errorMessage = null;
      });
      prefs.setString('cachedGigs', json.encode(gigs));
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load gigs. Please try again later.';
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadGigs(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Gigs'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? _buildSkeletonLoader()
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : _buildGigList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => SellerCreateGig());
        },
        backgroundColor: primary,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBarSeller(currentIndex: 2),
    );
  }

  Widget _buildGigList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: gigs.length,
        itemBuilder: (context, index) {
          return _buildGigCard(gigs[index]);
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.all(16),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Widget _buildGigCard(Map<String, dynamic> gig) {
  //   final String? gigImg = gig['gig_img'];
  //   final List<String> images = gigImg != null ? gigImg.split(',') : [];
  //   final String imageUrl = images.isNotEmpty
  //       ? '${_apiService.baseUrlImg}${images[0]}' // First image
  //       : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png'; // Placeholder
  //
  //   final profileImageUrl = gig['user_profile_pic'] != null
  //       ? '${_apiService.baseUrlImg}${gig['user_profile_pic']}'
  //       : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';
  //
  //   return AnimatedContainer(
  //     duration: Duration(milliseconds: 300),
  //     margin: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(blurRadius: 4, color: Colors.grey.shade300, spreadRadius: 1)
  //       ],
  //       color: white,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         ClipRRect(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
  //           child: Image.network(
  //             imageUrl,
  //             height: 180,
  //             width: double.infinity,
  //             fit: BoxFit.cover,
  //             errorBuilder: (context, error, stackTrace) => Container(
  //               color: Colors.grey[200],
  //               child: Icon(Icons.image, color: Colors.grey[400]),
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Pkr ${gig['basic_price'] ?? 'N/A'}',
  //                 style: TextStyle(
  //                   color: primary,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Text(
  //                 gig['title'] ?? 'No Title',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: dark400,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Row(
  //                 children: [
  //                   CircleAvatar(
  //                     backgroundImage: NetworkImage(profileImageUrl),
  //                     radius: 15,
  //                     backgroundColor: Colors.grey[200],
  //                   ),
  //                   SizedBox(width: 8),
  //                   Text(
  //                     '${gig['user_fname'] ?? ''} ${gig['user_lname'] ?? ''}',
  //                     style: TextStyle(fontSize: 16, color: dark300),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 16),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       Get.to(() => SellerEditGig(gigId: gig['id']));
  //                     },
  //                     child: Text('Edit Gig'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: blue300,
  //                       foregroundColor: white,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       _showDeleteConfirmationDialog(gig['id']);
  //                     },
  //                     child: Text('Delete Gig'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: secondary,
  //                       foregroundColor: white,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    final String? gigImg = gig['gig_img'];
    final List<String> images = gigImg != null ? gigImg.split(',') : [];
    final String? imageUrl = images.isNotEmpty
        ? '${_apiService.baseUrlImg}${images[0]}'
        : null;

    final profileImageUrl = gig['user_profile_pic'] != null
        ? '${_apiService.baseUrlImg}${gig['user_profile_pic']}'
        : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.grey.withOpacity(0.2), spreadRadius: 2)
        ],
        color: white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              ),
              // Positioned(
              //   top: 10,
              //   right: 10,
              //   child: CircleAvatar(
              //     backgroundImage: NetworkImage(profileImageUrl),
              //     radius: 20,
              //     backgroundColor: Colors.white,
              //   ),
              // ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gig['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dark400,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Pkr ${gig['basic_price'] ?? 'N/A'}',
                  style: TextStyle(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      radius: 15,
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${gig['user_fname'] ?? ''} ${gig['user_lname'] ?? ''}',
                        style: TextStyle(fontSize: 16, color: dark300),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.to(() => SellerEditGig(gigId: gig['id']));
                      },
                      icon: Icon(Icons.edit),
                      color: blue300,
                      tooltip: 'Edit Gig',
                      splashRadius: 24.0,
                    ),
                    IconButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(gig['id']);
                      },
                      icon: Icon(Icons.delete),
                      color: secondary,
                      tooltip: 'Delete Gig',
                      splashRadius: 24.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(
        Icons.image,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }


  Future<void> _showDeleteConfirmationDialog(int gigId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this gig?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGig(gigId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGig(int gigId) async {
    try {
      await _apiService.deleteGig(gigId);
      CustomSnackBar(
        message: 'Gig deleted successfully',
        backgroundColor: Colors.green,
      ).show(context);
      _loadGigs(); // Refresh the gig list
    } catch (e) {
      CustomSnackBar(
        message: 'Failed to delete gig. Please try again.',
        backgroundColor: Colors.red,
      ).show(context);
    }
  }
}
