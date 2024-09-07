import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_zone/pages/buyer/buyer_job_list.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
    fetchProposals();
  }

  Future<void> fetchProposals() async {
    try {
      setState(() => isLoading = true);
      final response = await apiService.get('get-jobs-proposals/${widget.jobId}');
      setState(() {
        proposals = response['proposals'] ?? [];
        isLoading = false;
      });
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : proposals.isEmpty
          ? const Center(child: Text('No proposals found'))
          : ListView.builder(
        itemCount: proposals.length,
        itemBuilder: (context, index) {
          final proposal = proposals[index];
          return ProposalCard(proposal: proposal);
        },
      ),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (proposal['status'] == 'Rejected') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot view details of a rejected proposal.'),
                backgroundColor: Colors.red,
              ),
            );
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
                    backgroundImage: NetworkImage(apiService.baseUrlImg + (proposal['profile_picture'] ?? 'https://via.placeholder.com/150')),
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
              _buildInfoRow('Amount', '\$${proposal['amount'] ?? 'N/A'}'),
              _buildInfoRow('Revisions', proposal['revision'] ?? 'N/A'),
              _buildInfoRow('Time', proposal['time'] ?? 'N/A'),
            ],
          ),
        ),
      )
      ,
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

        // Get the directory to download files (Downloads folder)
        Directory? downloadsDir = await getExternalStorageDirectory();
        String newPath = "";

        // Setting the Downloads folder path
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

        // Ensure the directory exists
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Define the file path in the Downloads directory
        final filePath = "${downloadsDir.path}/${url.split('/').last}";

        // Download the file and save it to the device
        await dio.download(url, filePath);

        // Show success message using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download complete: ${url.split('/').last}"),
            duration: Duration(seconds: 3),
          ),
        );

      } catch (e) {
        print("Error downloading file: $e");
      }
    }
  }



  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      print("Permission denied");
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    print(apiService.baseUrlImg+proposal['file_path']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(apiService.baseUrlImg+proposal['profile_picture'] ?? 'https://via.placeholder.com/150'),
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
                      Text(
                        proposal['details'] ?? 'No details provided',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      if (proposal['file_path'] != null)

                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_download),
                          label: const Text('Download File'),
                          style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: white),
                          onPressed: () => _downloadFile(context,apiService.baseUrlImg+proposal['file_path']),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.message),
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
                              // Replace `id` with the actual proposal ID you want to update
                              String id = proposal['id'].toString(); // Example: '1725706582'
                              String endpoint = 'update-proposal/$id';

                              // Define the body of the request
                              Map<String, dynamic> body = {
                                "status": "Accepted",
                              };

                              try {
                                // Hit the API using the post function
                                final response = await apiService.post(endpoint, body);

                                if(response["success"]){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response["message"].toString()),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  Get.off(()=> BuyerJobList());
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response["message"].toString()),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }

                                // Show success message using ScaffoldMessenger

                              } catch (e) {
                                // Show error message using ScaffoldMessenger
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
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
                              // Replace `id` with the actual proposal ID you want to update
                              String id = proposal['id'].toString(); // Example: '1725706582'
                              String endpoint = 'update-proposal/$id';

                              // Define the body of the request
                              Map<String, dynamic> body = {
                                "status": "Rejected",
                              };

                              try {
                                // Hit the API using the post function
                                final response = await apiService.post(endpoint, body);

                                if(response["success"]){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response["message"].toString()),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  Get.off(()=> BuyerJobList());
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response["message"].toString()),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }

                                // Show success message using ScaffoldMessenger

                              } catch (e) {
                                // Show error message using ScaffoldMessenger
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
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