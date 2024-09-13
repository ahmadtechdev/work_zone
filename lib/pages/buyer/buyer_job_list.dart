import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_buyer.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_zone/widgets/snackbar.dart';

import 'buyer_create_job_post.dart';
import 'buyer_edit_job_post.dart';
import 'buyer_job_proposal.dart';

class BuyerJobList extends StatefulWidget {
  const BuyerJobList({super.key});

  @override
  _BuyerJobListState createState() => _BuyerJobListState();
}

class _BuyerJobListState extends State<BuyerJobList>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  List<dynamic> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobsFromCacheOrFetch(); // Load jobs from cache or API
  }

  Future<void> loadJobsFromCacheOrFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJobs = prefs.getString('cachedJobs');

    if (cachedJobs != null && cachedJobs.isNotEmpty) {
      setState(() {
        jobs = List<dynamic>.from(jsonDecode(cachedJobs));
        isLoading = false;
      });
    } else {
      fetchJobs();
    }
  }

  Future<void> fetchJobs() async {
    try {
      setState(() => isLoading = true);
      final fetchedJobs = await apiService.get("get-jobs");

      print(fetchedJobs);
      setState(() {
        jobs = fetchedJobs['jobs'] as List<dynamic>;
      });
      print(jobs);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedJobs', jsonEncode(jobs));
    } catch (e) {
      _showErrorSnackbar('Failed to load jobs. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    CustomSnackBar(
      message: message,
      backgroundColor: Colors.red,
    ).show(context);
  }

  Future<void> _deleteJob(int jobId) async {
    try {
      await apiService.deleteJob(jobId);
      _showErrorSnackbar('Job deleted successfully');
      fetchJobs();
    } catch (e) {
      _showErrorSnackbar('Failed to delete job. Please try again.');
    }
  }

  Future<void> _showDeleteConfirmationDialog(int jobId) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to delete this job? This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJob(jobId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Posts'),
        backgroundColor: primary.withOpacity(0.2),
      ),
      body: isLoading ? _buildSkeletonLoader() : _buildJobList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddJobPostPage()),
          );
          fetchJobs();
        },
        backgroundColor: primary,
        foregroundColor: white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBarBuyer(currentIndex: 2),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ShimmerCard(),
        );
      },
    );
  }

  Widget _buildJobList() {
    return jobs.isEmpty
        ? const Center(child: Text('No jobs found'))
        : RefreshIndicator(
            onRefresh: fetchJobs,
            child: ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return _buildJobCard(context, jobs[index]);
              },
            ),
          );
  }

  Widget _buildJobCard(BuildContext context, dynamic job) {
    final imageUrl = job['gig_img'] != null
        ? '${apiService.baseUrlImg}${job['gig_img']}'
        : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';

    print("${apiService.baseUrlImg}${job['gig_img']}");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primary, // Set your desired border color
                      width: 2.0, // Set the border width
                    ),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rs: ${job['budget'] ?? 0}",
                      style: TextStyle(
                        color: dark400.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${job['category'] ?? 'No Category'}',
                      style: TextStyle(
                        color: dark400.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proposals: ${job['proposals_count'] ?? '0'}',
                      style: TextStyle(
                        color: dark400.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${job['status'] ?? 'No Status'}',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildActionButtons(context, job),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic job) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyerJobEditPage(jobId: job['id']),
              ),
            );
            fetchJobs();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmationDialog(job['id']);
          },
        ),
        if (job['status'] == 'In Progress')
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () {},
          )
        else
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerJobProposal(jobId: job['id']),
                ),
              );
            },
          ),
      ],
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      height: 80,
    );
  }
}
