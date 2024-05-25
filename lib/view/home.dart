import 'package:flutter/material.dart';
import 'package:responsi/model/kopi_model.dart';
import 'package:responsi/service/api_data_source.dart';
import 'package:responsi/view/logout.dart';
import 'package:responsi/view/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<JenisKopi>> _futureJenisKopi;
  List<JenisKopi>? _jenisKopiList;
  List<JenisKopi>? _filteredJenisKopiList;
  List<JenisKopi> _favoriteKopiList = [];
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureJenisKopi = ApiDataSource().loadJenisKopi();
    _futureJenisKopi.then((list) {
      setState(() {
        _jenisKopiList = list;
        _filteredJenisKopiList = list;
      });
    });
    _searchController.addListener(_filterKopiList);
  }

  void _filterKopiList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJenisKopiList = _jenisKopiList?.where((kopi) {
        return kopi.name?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  void _toggleFavorite(JenisKopi kopi) {
    setState(() {
      // kopi.toggleFavorite();
      if (kopi.isFavorite) {
        _favoriteKopiList.add(kopi);
      } else {
        _favoriteKopiList.remove(kopi);
      }
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        // Home - already on this page
        break;
      case 1:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => FavoritePage(favorites: _favoriteKopiList)),
        // );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LogoutPage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text('Coffee Types'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search coffee types...',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<JenisKopi>>(
        future: _futureJenisKopi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No coffee types found.'));
          } else {
            return ListView.builder(
              itemCount: _filteredJenisKopiList?.length ?? 0,
              itemBuilder: (context, index) {
                JenisKopi kopi = _filteredJenisKopiList![index];
                return ListTile(
                  leading: kopi.imageUrl != null
                      ? Image.network(kopi.imageUrl!)
                      : Icon(Icons.local_cafe),
                  title: Text(kopi.name ?? ''),
                  subtitle: Text(kopi.region ?? ''),
                  trailing: IconButton(
                    icon: Icon(
                      kopi.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: kopi.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      _toggleFavorite(kopi);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoffeeDetailPage(kopi: kopi),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.brown,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
            backgroundColor: Colors.brown,
          ),
        ],
      ),
    );
  }
}

class CoffeeDetailPage extends StatelessWidget {
  final JenisKopi kopi;

  CoffeeDetailPage({required this.kopi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kopi.name ?? 'Coffee Detail'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kopi.imageUrl != null
                ? Image.network(kopi.imageUrl!)
                : Icon(Icons.local_cafe, size: 100),
            SizedBox(height: 15),
            Text(
              kopi.name ?? 'Unknown Coffee',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(kopi.description ?? 'No description available'),
            SizedBox(height: 8),
            Text('Region: ${kopi.region ?? 'Unknown'}'),
            Text('Price: \$${kopi.price?.toStringAsFixed(2) ?? 'N/A'}'),
            Text('Weight: ${kopi.weight?.toString() ?? 'N/A'} grams'),
            Text('Roast Level: ${kopi.roastLevel?.toString() ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Flavor Profile: ${kopi.flavorProfile?.join(', ') ?? 'N/A'}'),
            Text('Grind Options: ${kopi.grindOption?.join(', ') ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
