import 'package:flutter/material.dart';



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text("Robert Radio"),
          leading: Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 10, right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 15,
              child: Icon(
                Icons.arrow_back,
                color: Colors.brown,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 10, right: 10),
              child: Icon(
                Icons.favorite_border,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 10, right: 10),
                child: Container(
                  color: Colors.amber,
                  child: Image.asset(
                    'assets/images/heart_image.png', 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  color: Colors.amber,
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.brown,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(width: 0),
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.brown,
                          size: 35,
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(width: 0),
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.red,
                          size: 35,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.brown,
                          size: 35,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.brown,
                          size: 35,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Center(
                  child: Text(
                    'Socialize the Pet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.amber,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                SizedBox(height: 5,),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0),
                                  height: 1,
                                  width: 300,
                                  color: Colors.black12,
                                ),
                                // First container
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/heart_image.png'),
                                        radius: 15,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Now",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "\$2.00",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                     
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Diet and Play time",
                                              style: TextStyle(
                                                fontSize: 12, 
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text("ily I Love You baby",
                                              style: TextStyle(
                                                fontSize: 12, 
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.videocam, color: Colors.brown),
                                      SizedBox(width: 10),
                                      Icon(Icons.more_vert, color: Colors.brown),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0),
                                  height: 1,
                                  width: 300,
                                  color: Colors.black12,
                                ),
                                // Second container
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/heart_image.png'),
                                        radius: 15,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Now",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "\$3.00",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(width: 10),
                                      // Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Column(
                                          children: [
                                            Text("Train your pet",
                                              style: TextStyle(
                                                fontSize: 12, // Adjust the font size here
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            Text("ily I Love You baby",
                                              style: TextStyle(
                                                fontSize: 12, // Adjust the font size here
                                              ),),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.mic, color: Colors.brown),
                                      SizedBox(width: 10),
                                      Icon(Icons.more_vert, color: Colors.brown),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0),
                                  height: 1,
                                  width: 300,
                                  color: Colors.black12,
                                ),
                                // Third container
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/heart_image.png'),
                                        radius: 15,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.play_circle_fill_rounded,
                                            color: Colors.red,
                                          size: 25,),
                                        ],
                                      ),
                                      // SizedBox(width: 10),
                                      // Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Socialize the Pet",
                                              style: TextStyle(
                                                fontSize: 12, // Adjust the font size here
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            Text("ily I Love You baby",
                                              style: TextStyle(
                                                fontSize: 12, // Adjust the font size here
                                              ),),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.videocam, color: Colors.brown),
                                      SizedBox(width: 10),
                                      Icon(Icons.more_vert, color: Colors.brown),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0),
                                  height: 1,
                                  width: 300,
                                  color: Colors.black12,
                                ),
                                // Fourth container
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/heart_image.png'),
                                        radius: 15,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Now",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "\$5.00",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(width: 10),
                                      // Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text("Love and care of Pet",
                                              style: TextStyle(
                                                fontSize: 12, // Adjust the font size here
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            Text("ily I Love You baby", style: TextStyle(
                                              fontSize: 12, // Adjust the font size here
                                            ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.mic, color: Colors.brown),
                                      SizedBox(width: 10),
                                      Icon(Icons.more_vert, color: Colors.brown),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      
      ),
    );
  }
}