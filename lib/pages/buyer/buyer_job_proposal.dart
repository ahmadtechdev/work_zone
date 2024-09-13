import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:work_zone/pages/buyer/buyer_job_list.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';

import '../../widgets/snackbar.dart';


class BuyerJobProposal extends StatefulWidget {
  final int jobId;

  const BuyerJobProposal({Key? key, required this.jobId}) : super(key: key);

  @override
  State<BuyerJobProposal> createState() => _BuyerJobProposalState();
}

class _BuyerJobProposalState extends State<BuyerJobProposal> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  List<dynamic> proposals = [];

  @override
  void initState() {
    super.initState();
    _loadCachedProposals();
    fetchProposals(refresh: false);
  }

  // Load cached proposals from SharedPreferences
  Future<void> _loadCachedProposals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('proposals_${widget.jobId}');
    if (cachedData != null) {
      setState(() {
        proposals = List<Map<String, dynamic>>.from(proposals);
        isLoading = false;
      });
    }
  }

  // Fetch proposals from API
  Future<void> fetchProposals({bool refresh = true}) async {
    setState(() => isLoading = refresh);
    try {
      final response = await apiService.get('get-jobs-proposals/${widget.jobId}');
      setState(() {
        proposals = response['proposals'] ?? [];
        isLoading = false;
      });

      // Cache the proposals
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('proposals_${widget.jobId}', response['proposals'].toString());
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Proposals'),
        elevation: 0,
        backgroundColor: primary,
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchProposals(refresh: true),
        child: isLoading
            ? _buildSkeletonLoader()
            : proposals.isEmpty
            ? const Center(
          child: Text('No proposals found', style: TextStyle(fontSize: 18)),
        )
            : ListView.builder(
          itemCount: proposals.length,
          itemBuilder: (context, index) {
            final proposal = proposals[index];
            return ProposalCard(proposal: proposal);
          },
        ),
      ),
    );
  }

  // Skeleton loader for loading state
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: dark100,
          highlightColor: offWhite,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundColor: dark200),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 16, color: dark200),
                            const SizedBox(height: 8),
                            Container(height: 12, color: dark200),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 16, color: dark200),
                  const SizedBox(height: 8),
                  Container(height: 16, color: dark200),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProposalCard extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final ApiService apiService = ApiService();
  ProposalCard({Key? key, required this.proposal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (proposal['status'] == 'Rejected') {
            CustomSnackBar(
              message: 'Cannot view details of a rejected proposal.',
              backgroundColor: Colors.red,
            ).show(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProposalDetailPage(proposal: proposal),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: proposal['profile_picture'] != null
                        ? NetworkImage(apiService.baseUrlImg + proposal['profile_picture'])
                        : const AssetImage('lib/assets/img/others/1.png') as ImageProvider,
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller: ${proposal['fname'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${proposal['status'] ?? 'N/A'}',
                          style: TextStyle(
                            color: proposal['status'] == 'Pending'
                                ? Colors.orange
                                : proposal['status'] == 'Rejected'
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Image section for proposal file
              if (proposal['file_path'] != null)
                Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(apiService.baseUrlImg + proposal['file_path']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              _buildInfoRow('Amount', '\$${proposal['amount'] ?? 'N/A'}'),
              _buildInfoRow('Revisions', proposal['revision'] ?? 'N/A'),
              _buildInfoRow('Time', proposal['time'] ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class ProposalDetailPage extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final ApiService apiService = ApiService();
  ProposalDetailPage({Key? key, required this.proposal}) : super(key: key);

  Future<void> _downloadFile(BuildContext context, String url) async {
    if (await _requestPermissions()) {
      try {
        final dio = Dio();
        Directory? downloadsDir = await getExternalStorageDirectory();

        // Define file path
        String newPath = "";
        List<String> paths = downloadsDir!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        downloadsDir = Directory(newPath);

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final filePath = "${downloadsDir.path}/${url.split('/').last}";
        await dio.download(url, filePath);

        CustomSnackBar(
          message: "Download complete: ${url.split('/').last}",
          backgroundColor: Colors.green,
        ).show(context);
      } catch (e) {
        CustomSnackBar(message: 'Error downloading file: $e', backgroundColor: Colors.red).show(context);
      }
    }
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
        elevation: 0,
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: proposal['profile_picture'] != null
                                ? NetworkImage(apiService.baseUrlImg + proposal['profile_picture'])
                                : const AssetImage('lib/assets/img/others/1.png') as ImageProvider,
                            radius: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seller: ${proposal['fname'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${proposal['status'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: proposal['status'] == 'Pending' ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Amount', '\$${proposal['amount'] ?? 'N/A'}'),
                      _buildInfoRow('Revisions', proposal['revision'] ?? 'N/A'),
                      _buildInfoRow('Time', proposal['time'] ?? 'N/A'),
                      const SizedBox(height: 16),
                      Text(
                        'Details:',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(proposal['details'] ?? 'No details provided', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      // Image section for proposal file
                      if (proposal['file_path'] != null)
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(apiService.baseUrlImg + proposal['file_path']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.message, color: primary),
                            onPressed: () {
                              // TODO: Implement message functionality
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              String id = proposal['id'].toString();
                              String endpoint = 'update-proposal/$id';
                              Map<String, dynamic> body = {"status": "Accepted"};

                              try {
                                final response = await apiService.post(endpoint, body);
                                if (response["success"]) {
                                  CustomSnackBar(
                                    message: response["message"],
                                    backgroundColor: Colors.green,
                                  ).show(context);
                                  Get.off(() => BuyerJobList());
                                } else {
                                  CustomSnackBar(
                                    message: response["message"],
                                    backgroundColor: Colors.red,
                                  ).show(context);
                                }
                              } catch (e) {
                                CustomSnackBar(
                                  message: 'Error: $e',
                                  backgroundColor: Colors.red,
                                ).show(context);
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              String id = proposal['id'].toString();
                              String endpoint = 'update-proposal/$id';
                              Map<String, dynamic> body = {"status": "Rejected"};

                              try {
                                final response = await apiService.post(endpoint, body);
                                if (response["success"]) {
                                  CustomSnackBar(
                                    message: response["message"],
                                    backgroundColor: Colors.green,
                                  ).show(context);
                                  Get.off(() => BuyerJobList());
                                } else {
                                  CustomSnackBar(
                                    message: response["message"],
                                    backgroundColor: Colors.red,
                                  ).show(context);
                                }
                              } catch (e) {
                                CustomSnackBar(
                                  message: 'Error: $e',
                                  backgroundColor: Colors.red,
                                ).show(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}