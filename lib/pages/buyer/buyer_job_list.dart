import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_buyer.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for caching

import 'buyer_create_job_post.dart';
import 'buyer_edit_job_post.dart';
import 'buyer_job_proposal.dart';

class BuyerJobList extends StatefulWidget {
  const BuyerJobList({super.key});

  @override
  _BuyerJobListState createState() => _BuyerJobListState();
}

class _BuyerJobListState extends State<BuyerJobList> {
  final ApiService apiService = ApiService();
  List<dynamic> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobsFromCacheOrFetch(); // Load jobs from cache or API
  }

  Future<void> loadJobsFromCacheOrFetch() async {
    // First, try to load jobs from cache
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('cachedJobs');
    final cachedJobs = prefs.getString('cachedJobs');

    if (cachedJobs != null && cachedJobs.isNotEmpty) {
      // If cache exists, load it
      setState(() {
        jobs = List<dynamic>.from(jsonDecode(cachedJobs)
            as List<dynamic>); // Convert JSON string to list
        isLoading = false;
      });
    } else {
      // If no cache, fetch from API
      fetchJobs();
    }
  }

  Future<void> fetchJobs() async {
    try {
      setState(() => isLoading = true); // Show loading indicator
      final fetchedJobs = await apiService.getJobs(); // Use the new GET method

      setState(() {
        jobs = fetchedJobs;
      });

      // Cache the jobs data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cachedJobs', jsonEncode(jobs)); // Save data as string
    } catch (e) {
      _showErrorSnackbar('Failed to load jobs. Please try again.');
    } finally {
      setState(() => isLoading = false); // Hide loading indicator
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteJob(int jobId) async {
    try {
      await apiService.deleteJob(jobId);
      _showErrorSnackbar('Job deleted successfully');
      fetchJobs(); // Refresh the job list after deleting
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
      ),
      body: isLoading ? _buildSkeletonLoader() : _buildJobList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddJobPostPage()),
          );
          fetchJobs(); // Refresh the job list after adding a new job
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 8, // Shadow
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
            fetchJobs(); // Refresh the job list after editing
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

// Skeleton Card Widget
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      height: 80, // Height for the skeleton loader
    );
  }
}
