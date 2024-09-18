import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/buyer/all_gigs.dart';
import 'package:work_zone/pages/buyer/all_influencers.dart';
import 'package:work_zone/pages/buyer/all_jobs.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_buyer.dart';
import 'package:work_zone/widgets/colors.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../service/api_service.dart';

class BuyerHome extends StatefulWidget {
  @override
  _BuyerHomeState createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _homeData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final data = await _apiService.get('home');
      setState(() {
        _homeData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching home data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _homeData['user'] ?? {};
    final userName = user['name'] ?? 'Unknown User';
    final userRole = user['role'] ?? 'buyer';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                (user['profile_picture'] != null &&
                        user['profile_picture'].isNotEmpty)
                    ? '${_apiService.baseUrlImg}${user['profile_picture']}'
                    : '${_apiService.baseUrlImg}jobs/1726650879.png',
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(color: white)),
                Text('I\'m a ${userRole}',
                    style:
                        TextStyle(fontSize: 12, color: white.withOpacity(0.8))),
              ],
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.notifications_outlined, color: white),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : RefreshIndicator(
              onRefresh: _fetchHomeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildGetMatchedCard(),
                      const SizedBox(height: 20),
                      _buildCategorySection(),
                      const SizedBox(height: 20),
                      _buildPopularGigsSection(),
                      const SizedBox(height: 20),
                      _buildTopInfluencersSection(),
                      const SizedBox(height: 20),
                      _buildRecentJobsSection(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar:
          const CustomBottomNavigationBarBuyer(currentIndex: 0),
    );
  }

  // ... (keep other methods like _buildSkeletonLoader, _buildSearchBar, and _buildGetMatchedCard the same)
  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 50, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 100, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 100, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 200, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 150, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 200, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search services...',
        prefixIcon: const Icon(Icons.search, color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildGetMatchedCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get Matched\nWith Sellers',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Post a Request',
                          style: TextStyle(color: primary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset('lib/assets/img/others/1.png',
                  width: 100, height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    List<String> categories = (_homeData['categories'] as List<dynamic>?)
            ?.map((item) => item as String)
            .toList() ??
        [];
    List<IconData> categoryIcons = [
      Icons.search,
      Icons.article,
      Icons.branding_watermark,
      Icons.videocam,
      Icons.public,
      Icons.trending_up,
      Icons.language,
      Icons.shopping_cart,
      Icons.campaign,
      Icons.emoji_people,
      Icons.batch_prediction,
      Icons.email,
      Icons.podcasts,
      Icons.gavel,
      Icons.person
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: primary,
                      child: Icon(categoryIcons[index % categoryIcons.length],
                          color: white, size: 30),
                    ),
                    const SizedBox(height: 5),
                    Text(categories[index],
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularGigsSection() {
    List<Map<String, dynamic>> gigs =
        List<Map<String, dynamic>>.from(_homeData['gigs'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Popular Gigs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
                onPressed: () {
                  Get.to(()=> AllGigs());
                },
                child:
                    const Text('View All', style: TextStyle(color: primary))),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 280, // Increased height to accommodate the new content
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gigs.length,
            itemBuilder: (context, index) => _buildGigCard(gigs[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        width: 220, // Increased width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: CachedNetworkImage(
                imageUrl: (gig['gig_img'] != null && gig['gig_img'].isNotEmpty)
                    ? '${_apiService.baseUrlImg}${gig['gig_img'].split(',')[0]}'
                    : '${_apiService.baseUrlImg}jobs/1726650879.png',

                height: 140,
                // Increased height
                width: 220,
                // Increased width
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gig['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                          '${gig['averageRating']} (${gig['reviewCount']} reviews)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Starting at \$${gig['basic_price']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: CachedNetworkImageProvider(
                          (gig['gig_owner_image'] != null && gig['gig_owner_image'].isNotEmpty)
                              ? '${_apiService.baseUrlImg}${gig['gig_owner_image']}'
                              : '${_apiService.baseUrlImg}jobs/1726650879.png',
                        ),

                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          gig['gig_owner_name'] ?? 'Unknown Seller',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (keep _buildTopInfluencersSection the same)
  Widget _buildTopInfluencersSection() {
    List<Map<String, dynamic>> influencers =
        List<Map<String, dynamic>>.from(_homeData['influencers'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Top Influencers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
                onPressed: () {
                  Get.to(()=> AllInfluencers());
                },
                child:
                    const Text('View All', style: TextStyle(color: primary))),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: influencers.length,
            itemBuilder: (context, index) =>
                _buildInfluencerCard(influencers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfluencerCard(Map<String, dynamic> influencer) {
    String image = "";
    if (influencer['profile_picture'] != null &&
        influencer['profile_picture'].isNotEmpty) {
      image = _apiService.baseUrlImg + influencer['profile_picture'];
    } else {
      image = "http://10.10.0.100:500/gigs/1726647309.png";
    }
    return Card(
      margin: const EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(
                (influencer['profile_picture'] != null && influencer['profile_picture'].isNotEmpty)
                    ? '${_apiService.baseUrlImg}${influencer['profile_picture']}'
                    : '${_apiService.baseUrlImg}jobs/1726650879.png',
              ),

            ),
            const SizedBox(height: 8),
            Text('${influencer['fname']} ${influencer['lname']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            Text(influencer['speciality'] ?? 'Influencer',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobsSection() {
    List<Map<String, dynamic>> jobs =
        List<Map<String, dynamic>>.from(_homeData['jobs'] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Top Jobs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
                onPressed: () {
                  Get.to(()=> AllJobs());
                },
                child:
                    const Text('View All', style: TextStyle(color: primary))),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) => _buildJobCard(jobs[index]),
        ),
      ],
    );
  }
  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: (job['gig_img'] != null && job['gig_img'].isNotEmpty)
                  ? '${_apiService.baseUrlImg}${job['gig_img']}'
                  : '${_apiService.baseUrlImg}jobs/1726650879.png',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  job['category'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      job['jobDuration'],
                      style: TextStyle(
                        color: white, // Using white color for text
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Decreased font size
                      ),
                    ),
                    backgroundColor: secondary.withOpacity(0.8), // Using secondary color with opacity for background
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjusted padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      side: BorderSide(color: dark200, width: 1), // Optional: border to enhance the look
                    ),
                  ),
                  Chip(
                    label: Text(
                      job['jobType'],
                      style: TextStyle(
                        color: white, // Using white color for text
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Decreased font size
                      ),
                    ),
                    backgroundColor: secondary.withOpacity(0.8), // Using secondary color with opacity for background
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjusted padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      side: BorderSide(color: dark200, width: 1), // Optional: border to enhance the look
                    ),
                  ),
                ],
              ),



                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget: ${job['budget']} - ${job['maxbudget']}',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Add action for applying to the job
                      },
                      child: const Text('Apply'),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        (job['job_owner_image'] != null && job['job_owner_image'].isNotEmpty)
                            ? '${_apiService.baseUrlImg}${job['job_owner_image']}'
                            : '${_apiService.baseUrlImg}jobs/1726650879.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['job_owner_name'] ?? 'Unknown Client',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Posted ${_getTimeAgo(job['created_at'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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

  String _getTimeAgo(String dateString) {
    DateTime date = DateTime.parse(dateString);
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
