import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/seller/seller_create_gig.dart';
import 'package:work_zone/pages/seller/seller_edit_gig.dart';
import 'package:work_zone/widgets/colors.dart';
import '../../service/api_service.dart';
import '../../widgets/bottom_navigation_bar_seller.dart';

class SellerManageGig extends StatefulWidget {
  @override
  _SellerManageGigState createState() => _SellerManageGigState();
}

class _SellerManageGigState extends State<SellerManageGig> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> gigs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGigs();
  }

  Future<void> _loadGigs() async {
    try {
      final fetchedGigs = await _apiService.getGigsForUser();
      setState(() {
        gigs = fetchedGigs;

        isLoading = false;
        errorMessage = null;
      });

    } catch (e) {
      print('Error loading gigs: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load gigs. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Gig'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => SellerCreateGig());
            },
            child: Text('Create a new Gig'),
            style: ElevatedButton.styleFrom(
              backgroundColor: lime300,
              foregroundColor: white,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: gigs.length,
        itemBuilder: (context, index) {
          return _buildGigCard(gigs[index]);
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBarSeller(currentIndex: 2),
    );
  }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    final imageUrl = gig['gig_img'] != null
        ? '${_apiService.baseUrlImg}${gig['gig_img']}'
        : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';
    final profileImageUrl = gig['user_profile_pic'] != null
        ? '${_apiService.baseUrlImg}${gig['user_profile_pic']}'
        : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pkr ${gig['basic_price'] ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  gig['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: gig['user_profile_pic'] != null
                          ? NetworkImage(_apiService.baseUrlImg + gig['user_profile_pic'])
                          : AssetImage('lib/assets/img/others/1.png') as ImageProvider,
                      radius: 12,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${gig['user_fname'] ?? ''} ${gig['user_lname'] ?? ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle edit gig action
                        Get.to(()=> SellerEditGig(gigId: gig['id']));
                      },
                      child: Text('Edit Gig'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle delete gig action
                        _showDeleteConfirmationDialog(gig['id']);
                      },
                      child: Text('Delete Gig'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
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
                Text('Are you sure you want to delete this job?'),
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
                _deleteJob(gigId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteJob(int gigId) async {
    try {
      await _apiService.deleteGig(gigId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gig deleted successfully')),
      );
      _loadGigs(); // Refresh the job list after deleting
    } catch (e) {
      print('Error deleting job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete job. Please try again.')),
      );
    }
  }
}