import 'package:flutter/material.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GigDetail extends StatefulWidget {
  final int gigId;

  const GigDetail({Key? key, required this.gigId}) : super(key: key);

  @override
  _GigDetailState createState() => _GigDetailState();
}

class _GigDetailState extends State<GigDetail> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _gigData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGigDetails();
  }

  Future<void> _fetchGigDetails() async {
    try {
      final data = await _apiService.get('show-gig/${widget.gigId}');
      setState(() {
        _gigData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching gig details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildGigInfo(),
                    _buildRatingSection(),
                    _buildReviewsSection(),
                    _buildAuthorInfo(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        // title: Text(_gigData?['gig']['title'] ?? 'Gig Details'),
        background: CachedNetworkImage(
          imageUrl: _apiService.baseUrlImg+_gigData?['gig']['gig_img'].split(',').first ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGigInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _gigData?['gig']['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${_gigData?['gig']['category'] ?? ''}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              _gigData?['gig']['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildPricingTiers(),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTiers() {
    return Column(
      children: [
        _buildPricingTier('Basic', _gigData?['gig']['basic_price'], _gigData?['gig']['basic_description']),
        _buildPricingTier('Standard', _gigData?['gig']['standard_price'], _gigData?['gig']['standard_description']),
        _buildPricingTier('Premium', _gigData?['gig']['premium_price'], _gigData?['gig']['premium_description']),
      ],
    );
  }

  Widget _buildPricingTier(String tier, String? price, String? description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('$tier: \$${price ?? ''}'),
        subtitle: Text(description ?? ''),
      ),
    );
  }

  Widget _buildRatingSection() {
    final averageRating = _gigData?['averageRating'] ?? 0;
    final reviewCount = _gigData?['reviewCount'] ?? 0;
    final starRatingsCount = _gigData?['starRatingsCount'] ?? {};

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text('$reviewCount reviews'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildRatingBar(5, starRatingsCount['5'] ?? 0, reviewCount),
                    _buildRatingBar(4, starRatingsCount['4'] ?? 0, reviewCount),
                    _buildRatingBar(3, starRatingsCount['3'] ?? 0, reviewCount),
                    _buildRatingBar(2, starRatingsCount['2'] ?? 0, reviewCount),
                    _buildRatingBar(1, starRatingsCount['1'] ?? 0, reviewCount),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    return Row(
      children: [
        Text('$stars'),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 8,
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
        const SizedBox(width: 8),
        Text('($count)'),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _gigData?['reviews'] ?? [];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                review['star_rating'],
                                    (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['review'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: CachedNetworkImageProvider(
                                    (review['review_buyer_image'] != null && review['review_buyer_image'].isNotEmpty)
                                        ? '${_apiService.baseUrlImg}${review['review_buyer_image']}'
                                        : '${_apiService.baseUrlImg}jobs/1726650879.png',
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['review_buyer_name'] ?? 'Unknown Seller',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    final author = _gigData?['aurthor'];
    if (author == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About the Seller',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(_apiService.baseUrlImg+author['profile_picture'] ?? ''),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${author['fname']} ${author['lname']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(author['speciality'] ?? ''),
                      Text('${author['city']}, ${author['country']}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(author['description'] ?? ''),
          ],
        ),
      ),
    );
  }
}