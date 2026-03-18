import 'package:flutter/material.dart';

class Allepisode extends StatefulWidget {
  final String imagePath;

  const Allepisode({Key? key, required this.imagePath}) : super(key: key);

  @override
  _AllepisodeState createState() => _AllepisodeState();
}

class _AllepisodeState extends State<Allepisode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.share, color: Colors.white, size: 28),
                    onPressed: () {
                      // Implement share functionality
                    },
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: -60,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 43,
                      backgroundImage: AssetImage(widget.imagePath),
                    ),
                  ),
                ),
                Positioned(
                  left: 120,
                  bottom: -80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "The Honest Bunch",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Nedu",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
                      ),
                      Text(
                        "1.2m listeners   240 Episodes",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "A Nigerian podcast hosted by FK Abudu and Jola Ayeye, covering relatable millennial experiences, pop culture, and societal issues.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("FOLLOW", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.bookmark_border, color: Colors.black, size: 40),
                        onPressed: () {
                          // Implement save functionality
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Episodes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "All Episodes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildEpisodeTile("Ep 102", "To be or not to be internally focused", "54 min", "Oct 17, 2021"),
                  _buildEpisodeTile("Ep 101", "What ways should you follow to find happiness?", "36 min", "Oct 11, 2021"),
                  _buildEpisodeTile("Ep 100", "What is true happiness and when does it occur?", "45 min", "Oct 8, 2021"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeTile(String epNumber, String title, String duration, String date) {
    return Card(
      elevation: 4,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                epNumber,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$duration   |   $date",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: Colors.green, size: 36),
          ],
        ),
      ),
    );
  }
}
