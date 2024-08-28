// import 'package:flutter/material.dart';
// import 'package:work_zone/widgets/bottom_navigation_bar.dart';
// import 'package:work_zone/widgets/colors.dart';
// import 'package:work_zone/service/api_service.dart';
// import 'package:intl/intl.dart';
//
// import 'buyer_create_job_post.dart';
// import 'buyer_edit_job_post.dart';
//
// class JobPostPage extends StatefulWidget {
//   @override
//   _JobPostPageState createState() => _JobPostPageState();
// }
//
// class _JobPostPageState extends State<JobPostPage> {
//   final ApiService apiService = ApiService();
//   List<dynamic> jobs = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchJobs();
//   }
//
//   Future<void> fetchJobs() async {
//     try {
//       final fetchedJobs = await apiService.getJobs();
//       setState(() {
//         jobs = fetchedJobs;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching jobs: $e');
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load jobs. Please try again.')),
//       );
//     }
//   }
//
//   Future<void> _deleteJob(int jobId) async {
//     try {
//       await apiService.deleteJob(jobId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Job deleted successfully')),
//       );
//       fetchJobs(); // Refresh the job list after deleting
//     } catch (e) {
//       print('Error deleting job: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete job. Please try again.')),
//       );
//     }
//   }
//
//   Future<void> _showDeleteConfirmationDialog(int jobId) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Are you sure you want to delete this job?'),
//                 Text('This action cannot be undone.'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Delete'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _deleteJob(jobId);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('Job Posts'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//         onRefresh: fetchJobs,
//         child: jobs.isEmpty
//             ? Center(child: Text('No jobs found'))
//             : ListView.builder(
//           itemCount: jobs.length,
//           itemBuilder: (context, index) {
//             return _buildJobCard(context, jobs[index]);
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddJobPostPage()),
//           );
//           fetchJobs(); // Refresh the job list after adding a new job
//         },
//         child: Icon(Icons.add),
//         backgroundColor: lime300,
//         foregroundColor: white,
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
//     );
//   }
//
//   Widget _buildJobCard(BuildContext context, dynamic job) {
//     final imageUrl = job['gig_img'] != null
//         ? '${apiService.baseUrlImg}${job['gig_img']}'
//         : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';
//     print(imageUrl);
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   imageUrl,
//                   width: 100,
//                   height: 180,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     width: 80,
//                     height: 80,
//                     color: Colors.grey[200],
//                     child: Icon(Icons.image, color: Colors.grey[400]),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ... (keep existing job details)
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () async {
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => BuyerJobEditPage(jobId: job['id']),
//                               ),
//                             );
//                             fetchJobs();
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             _showDeleteConfirmationDialog(job['id']);
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.visibility),
//                           onPressed: () {
//                             // Handle eye action
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(String? dateString) {
//     if (dateString == null) return 'No Date';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('yyyy-MM-dd').format(date);
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }
// }