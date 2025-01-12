import 'package:flutter/material.dart';

class EK_DrawerPage extends StatelessWidget {
  const EK_DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      child: Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(231, 255, 203, 112)),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(
                    255, 255, 223, 141), // Background color of the DrawerHeader
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30, // Radius of the avatar
                    backgroundImage: AssetImage(
                        'assets/logo.png'), // Replace with your image asset
                  ),
                  const SizedBox(width: 16), // Space between avatar and text
                  Text(
                    'EK AppZone',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                "EK App Zone is a forward-thinking digital solution company  in Sri Lanka, dedicated to delivering innovative app solutions. Our expertise lies in creating cutting-edge applications that cater to the evolving needs of businesses and individuals. We combine technology with creativity to offer products that enhance efficiency, connectivity, and user experience.",
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: screenWidth * 0.03),
              ),
              onTap: () {
                // Handle item 1 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Ekappzone@gmail.com'),
              onTap: () {
                // Handle item 2 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('+94782694957'),
              onTap: () {
                // Handle item 2 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text("Nuwaraeliya,Srilanka"),
              onTap: () {
                // Handle item 2 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            // Add more ListTile items as needed
          ],
        ),
      ),
    );
  }
}
