import 'package:flutter/material.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'influencer_data.dart';

class AllInfluencers extends StatefulWidget {
  @override
  _AllInfluencersState createState() => _AllInfluencersState();
}

class _AllInfluencersState extends State<AllInfluencers> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _influencers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInfluencers();
  }

  Future<void> _fetchInfluencers() async {
    try {
      final data = await _apiService.get('all-influencers');
      setState(() {
        _influencers = List<Map<String, dynamic>>.from(data['influencers']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching influencers: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Influencers', style: TextStyle(color: white)),
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInfluencers,
        child: _isLoading
            ? _buildSkeletonLoader()
            : AnimationLimiter(
          child: ListView.builder(
            itemCount: _influencers.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildInfluencerCard(_influencers[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfluencerCard(Map<String, dynamic> influencer) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: primary.withOpacity(0.1),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(
                    (influencer['profile_picture'] != null && influencer['profile_picture'].isNotEmpty)
                        ? '${_apiService.baseUrlImg}${influencer['profile_picture']}'
                        : '${_apiService.baseUrlImg}users/default.png',
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${influencer['fname']} ${influencer['lname']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  influencer['speciality'] ?? 'Influencer',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: primary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${influencer['city']}, ${influencer['country']}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.language, color: primary, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        influencer['language'] ?? 'Not specified',
                        style: TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InfluencerProfile(influencerId: influencer['id']),
                      ),
                    );
                  },
                  child: Text('View Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}