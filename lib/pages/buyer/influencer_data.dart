import 'package:flutter/material.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class InfluencerProfile extends StatefulWidget {
  final int influencerId;

  const InfluencerProfile({Key? key, required this.influencerId}) : super(key: key);

  @override
  _InfluencerProfileState createState() => _InfluencerProfileState();
}

class _InfluencerProfileState extends State<InfluencerProfile> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _influencerData = {};
  List<Map<String, dynamic>> _gigs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInfluencerData();
  }

  Future<void> _fetchInfluencerData() async {
    try {
      final data = await _apiService.get('show-influencer/${widget.influencerId}');
      setState(() {
        _influencerData = data['influencer'];
        _gigs = List<Map<String, dynamic>>.from(data['gigs']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching influencer data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildSkeletonLoader()
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildInfluencerInfo()),
          SliverToBoxAdapter(child: _buildGigsHeader()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGigCard(_gigs[index]),
              childCount: _gigs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 250, color: Colors.white),
            SizedBox(height: 20),
            Container(height: 100, color: Colors.white),
            SizedBox(height: 20),
            Container(height: 200, color: Colors.white),
            SizedBox(height: 20),
            Container(height: 200, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_influencerData['fname'] + ' ' + _influencerData['lname'], style: TextStyle(backgroundColor:secondary ,color: white),),
        background: CachedNetworkImage(
          imageUrl: '${_apiService.baseUrlImg}${_influencerData['profile_picture']}',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300]),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildInfluencerInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _influencerData['speciality'] ?? 'Influencer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary),
          ),
          SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, '${_influencerData['city']}, ${_influencerData['country']}'),
          _buildInfoRow(Icons.language, _influencerData['language'] ?? 'Not specified'),
          _buildInfoRow(Icons.email, _influencerData['email']),
          _buildInfoRow(Icons.phone, _influencerData['phone']),
          SizedBox(height: 16),
          Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_influencerData['description'] ?? 'No description available.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildGigsHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Gigs',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: '${_apiService.baseUrlImg}${gig['gig_img'].split(',')[0]}',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gig['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  gig['category'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Starting at \$${gig['basic_price']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primary,
                    fontSize: 16,
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