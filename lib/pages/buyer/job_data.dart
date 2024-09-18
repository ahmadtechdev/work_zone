import 'package:flutter/material.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class JobDetailsPage extends StatefulWidget {
  final int jobId;

  const JobDetailsPage({Key? key, required this.jobId}) : super(key: key);

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _jobData = {};
  Map<String, dynamic> _authorData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobData();
  }

  Future<void> _fetchJobData() async {
    try {
      final data = await _apiService.get('show-job/${widget.jobId}');
      setState(() {
        _jobData = data['job'];
        _authorData = data['aurthor'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching job data: $e');
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
          SliverToBoxAdapter(child: _buildJobDetails()),
          SliverToBoxAdapter(child: _buildAuthorCard()),
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
            Container(height: 200, color: Colors.white),
            SizedBox(height: 20),
            Container(height: 150, color: Colors.white),
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
        title: Text(_jobData['title'] ?? 'Job Details'),
        background: CachedNetworkImage(
          imageUrl: '${_apiService.baseUrlImg}${_jobData['gig_img']}',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300]),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildJobDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Category', _jobData['category']),
          _buildInfoRow('Duration', _jobData['jobDuration']),
          _buildInfoRow('Type', _jobData['jobType']),
          _buildInfoRow('Budget', '\$${_jobData['budget']} - \$${_jobData['maxbudget']}'),
          _buildInfoRow('Status', _jobData['status']),
          _buildInfoRow('Posted', _jobData['formatted_created_at']),
          SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_jobData['description'] ?? 'No description available.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About the Client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _authorData['profile_picture'] != null
                      ? CachedNetworkImageProvider(
                    '${_apiService.baseUrlImg}${_authorData['profile_picture']}',
                  )
                      : null,
                  child: _authorData['profile_picture'] == null
                      ? Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_authorData['fname']} ${_authorData['lname']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Member since ${_formatDate(_authorData['created_at'])}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAuthorInfoItem(Icons.location_on, _authorData['country'] ?? 'N/A'),
                _buildAuthorInfoItem(Icons.work, '${_authorData['jobsCount']} jobs posted'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add functionality to contact the client
              },
              child: Text('Contact Client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: primary),
        SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString);
    return DateFormat('MMMM yyyy').format(date);
  }
}