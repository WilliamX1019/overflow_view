import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overflow_view/overflow_view.dart';

import 'limited_time_option_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Avatar {
  const Avatar(this.initials, this.color);
  final String initials;
  final Color color;
}

const List<Avatar> avatars = <Avatar>[
  Avatar('ADddddddddddddddddddddddddddddddddddd', Colors.green),
  Avatar('JGaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', Colors.pink),
  Avatar('DAssss', Colors.blue),
  Avatar('JAaaaa', Colors.black),
  Avatar('CBdddd', Colors.amber),
  Avatar('RRffff', Colors.deepPurple),
  Avatar('JDgggg', Colors.pink),
  Avatar('MBssss', Colors.amberAccent),
  Avatar('AAaaaa', Colors.blueAccent),
  Avatar('BAaaaa', Colors.tealAccent),
  Avatar('CRrrrr', Colors.yellow),
];

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double ratio = 1;
  int maxRun = 2;
  bool isOpen = false;
  List<Widget> allItems = [];
  void _incrementCounter() {
    setState(() {
      // _counter = avatars.length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _counter = avatars.length;

    allItems = List.from(["With Invisi Drawstring", "With Invisi Drawstring4"]).map((e) {
      final isSelected = false;
      final isRecommend = false;
      final isInStock = true;

      Color borderColor = const Color(0xFFDDAF88);
      Color backgroundColor = Colors.white;
      borderColor =  const Color(0xFFDDAF88);
      backgroundColor =  Colors.white;

      return LimitedTimeOptionItem(
        isSelected: isSelected,
        isInStock: isInStock,
        text: e,
        badgeImageUrl: '',
        labelText: "Fit 18-24 In",
        onTap: () {},
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 4,),
                child: OverflowView.wrap(
                  spacing: 8,
                  runSpacing: 12,
                  direction: Axis.horizontal,
                  maxRun: maxRun,
                  children: allItems,
                  builder: (context, remainingItemCount) {
                    print('remainingItemCount: $remainingItemCount');
                    return SizedBox.shrink();
                  },
                ),
              )
              // Text(
              //   "People's names",
              //   style: TextStyle(fontSize: 16),
              // ),
              // SizedBox(height: 16),
              // Container(
              //   width: double.infinity,
              //   padding: EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: Colors.blue.shade50,
              //     border: Border.all(
              //       color: Colors.blue.shade100,
              //       width: 2,
              //     ),
              //     borderRadius: BorderRadius.circular(18),
              //   ),
              //   child: OverflowView.wrap(
              //     runSpacing: 4,
              //     spacing: 4,
              //     maxRun: maxRun,
              //     builder: (context, remainingItemCount) =>
              //         GestureDetector(
              //       child: Chip(
              //         label: Text("+$remainingItemCount"),
              //         backgroundColor: Colors.red,
              //       ),
              //       onTap: () {
              //         setState(() {
              //           maxRun = 100;
              //           isOpen = true;
              //         });
              //       },
              //     ),
              //     children: [
              //       for (int i = 0; i < _counter; i++)
              //         GestureDetector(
              //           onTap: () {
              //             if (isOpen && i == _counter - 1) {
              //               setState(() {
              //                 maxRun = 2;
              //                 isOpen = false;
              //               });
              //             }
              //           },
              //           child: Chip(
              //           label: Text(
              //             avatars[i].initials,
              //             style: TextStyle(
              //               color: Colors.white,
              //             ),
              //           ),
              //           backgroundColor: avatars[i].color,
              //         ),),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
