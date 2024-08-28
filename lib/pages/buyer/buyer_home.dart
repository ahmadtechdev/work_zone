import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/widgets/bottom_navigation_bar.dart';
import 'package:work_zone/widgets/colors.dart';

class BuyerHome extends StatefulWidget {
  @override
  _BuyerHomeState createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {


  @override
  Widget build(BuildContext context) {
    // Get the passed arguments
    final userData = Get.arguments;
// Ensure userData is not null and has the required keys
    final userName = userData != null
        ? (userData['fname'] ?? '') + ' ' + (userData['lname'] ?? '')
        : 'Unknown User';
    final userAddress = userData != null
        ? userData['address'] ?? 'No Address Provided'
        : 'No Address Provided';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('lib/assets/img/others/1.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName),
                Text('I\'m a Client', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(),
              SizedBox(height: 20),
              GetMatchedCard(),
              SizedBox(height: 20),
              CategorySection(),
              SizedBox(height: 20),
              PopularServicesSection(),
              SizedBox(height: 20),
              TopSellersSection(),
              SizedBox(height: 20),
              RecentViewedSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search services...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}

class GetMatchedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get Matched\nWith Sellers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Post a Request'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
            Image.network('https://images.pexels.com/photos/26347939/pexels-photo-26347939/free-photo-of-silhouette-of-man-near-brooms-at-brooms-seller.jpeg?auto=compress&cs=tinysrgb&w=600', width: 100, height: 100),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Graphics Design', 'icon': Icons.brush},
    {'name': 'Video Editing', 'icon': Icons.videocam},
    {'name': 'Digital Marketing', 'icon': Icons.shop},
    {'name': 'Business', 'icon': Icons.business_center},
    {'name': 'Business', 'icon': Icons.business_center},
    {'name': 'Business', 'icon': Icons.business_center},
    {'name': 'Business', 'icon': Icons.business_center},
    // Add more categories as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('View All')),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: lime300,
                      child: Icon(categories[index]['icon'], color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(categories[index]['name'], style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PopularServicesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('View All')),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 230, // Increased height to give more space
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return ServiceCard(
                title: 'Mobile UI UX design or app design',
                rating: 5.0,
                reviewCount: 520,
                price: 30,
                sellerName: 'William Liam',
                sellerLevel: 1,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final double rating;
  final int reviewCount;
  final int price;
  final String sellerName;
  final int sellerLevel;

  ServiceCard({
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.sellerName,
    required this.sellerLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1613909207039-6b173b755cc1?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8dWklMjB1eCUyMGRlc2lnbmVyfGVufDB8fDB8fHww',
              height: 100,
              width: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Ensures text doesn't overflow
                    maxLines: 2,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      SizedBox(width: 4),
                      Text('$rating ($reviewCount)'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Price: \$$price'),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/128/1999/1999625.png'),
                        radius: 10,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '$sellerName - Level $sellerLevel',
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
}

class TopSellersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Sellers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('View All')),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return SellerCard(
                name: 'William Liam',
                rating: 5.0,
                reviewCount: 520,
                level: 2,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SellerCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final int level;

  SellerCard({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://cdn-icons-gif.flaticon.com/11186/11186790.gif'),
              radius: 40,
            ),
            SizedBox(height: 5),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 16),
                Text('$rating ($reviewCount review)'),
              ],
            ),
            Text('Seller Level - $level'),
          ],
        ),
      ),
    );
  }
}

class RecentViewedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Viewed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('View All')),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return ServiceCard(
                title: 'Modern unique business logo design',
                rating: 5.0,
                reviewCount: 520,
                price: 30,
                sellerName: 'William Liam',
                sellerLevel: 1,
              );
            },
          ),
        ),
      ],
    );
  }
}