import 'package:flutter/material.dart';

class SellerProjects extends StatefulWidget {
  @override
  _SellerProjectsState createState() => _SellerProjectsState();
}

class _SellerProjectsState extends State<SellerProjects> {
  final List<Map<String, dynamic>> projects = [
    {
      'projectName': 'ABC',
      'amount': 1000.00,
      'revisions': 3,
      'status': 'Pending',
      'days': 1,
      'image': 'lib/assets/img/others/1.png', // Add this line
    },{
      'projectName': 'ABC',
      'amount': 1000.00,
      'revisions': 3,
      'status': 'Pending',
      'days': 1,
      'image': 'lib/assets/img/others/1.png', // Add this line
    },{
      'projectName': 'ABC',
      'amount': 1000.00,
      'revisions': 3,
      'status': 'Pending',
      'days': 1,
      'image': 'lib/assets/img/others/1.png', // Add this line
    },
    // Add more projects as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Handle create new gig action
            },
            child: Text('Create a New Gig'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         SizedBox(height: 16,),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(projects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'lib/assets/img/others/1.png', // Replace with actual image path
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['projectName'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pkr ${project['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Revisions', project['revisions'].toString()),
                _buildInfoItem('Status', project['status'], _getStatusColor(project['status'])),
                _buildInfoItem('Days', project['days'].toString()),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Handle edit action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.visibility, color: Colors.green),
                  onPressed: () {
                    // Handle view action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoItem(String label, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor ?? Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.black87;
    }
  }
}