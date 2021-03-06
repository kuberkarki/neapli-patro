import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'helpers/patro_helper.dart';
import 'patro/patro.dart';
import "package:http/http.dart" as http;

void main() {
  Patro(Language.nepali);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: NepaliUnicode.convert('nepaalI Paatro'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define the default font family.
        // fontFamily: 'Georgia',
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(
            fontSize: 16.0,
          ),
          caption: TextStyle(
              fontSize: 18.0, color: Colors.white),
        ),
      ),
      home: MyHomePage(title: NepaliUnicode.convert('nepaalI Paatro')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  //  NepaliDateTime currentTime = NepaliDateTime.now();
  NepaliDateTime currentTime = NepaliDateTime.now();
  var date2 = NepaliDateFormat.EEEE();

  final NepaliDateTime first = NepaliDateTime(2075, 5);
  final NepaliDateTime last = NepaliDateTime(2077, 3);

  final NepaliCalendarController _nepaliCalendarController =
      NepaliCalendarController();
// print(currentTime.toIso8601String());
  // print(currentTime.toIso8601String()); //2076-02-01T11:25:46.490980

  List holidays;
  // fetchHolidays() async {
  //   http.Response response = await http.get(
  //       'https://raw.githubusercontent.com/kuberkarki/2077/master/db.json');

  //   setState(() {
  //     holidays = json.decode(response.body);
  //     print(holidays);
  //   });
  // }
  loadJson() async {
  String data = await rootBundle.loadString('assets/json/db.json');
  
  setState(() {
      holidays = json.decode(data);
      print(holidays);
    });
  print(holidays);
}

  @override
  void initState()  {
    // fetchHolidays();
    loadJson();
    super.initState();
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        bottomOpacity: 0.0,
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.deepOrange,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left:20),
                    width: 110,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                NepaliDateFormat.LLLL().format(currentTime) +
                                    ', ',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white)),
                            Text(
                              NepaliDateFormat.y().format(currentTime),
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ],
                        ),
                        Text(NepaliDateFormat.d().format(currentTime),
                            style:
                                TextStyle(fontSize: 34, color: Colors.white)),
                        Text(date2.format(currentTime),
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            PatroNepaliCalendar(
                              controller: _nepaliCalendarController,
                              onHeaderLongPressed: (date) {
                                print("header long pressed $date");
                              },
                              onHeaderTapped: (date) {
                                print("header tapped $date");
                              },
                              calendarStyle: CalendarStyle(
                                selectedColor: Colors.green[800],
                                dayStyle: TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                todayStyle: TextStyle(
                                  fontSize: 18.0,
                                ),
                                todayColor: Colors.grey[400],
                                highlightSelected: true,
                                renderDaysOfWeek: true,
                                highlightToday: true,
                              ),
                              headerStyle: HeaderStyle(
                                centerHeaderTitle: true,
                                titleTextStyle: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18.0),
                              ),
                              initialDate: NepaliDateTime.now(),
                              // firstDate: first,
                              // lastDate: last,
                              language: Language.nepali,
                              onDaySelected: (day) {
                                print(day.toString());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: holidays!=null ? getHolidays(holidays) : Container(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{},
        tooltip: 'Help',
        child: Icon(Icons.help),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget getHolidays(List holidays) {
    return ListView.builder(
      itemBuilder: (context, index) {
        NepaliDateTime date = NepaliDateTime.parse(holidays[index]['date']);
        String moment = NepaliMoment.fromBS(date);
        // NepaliDateFormat.yMMMMEEEEd().format(date);
        if (moment.contains('पहिले')) {

          // setState(() {
            // holidays.removeAt(index);
          // });
          return Container();
        }
        return Card(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: <Widget>[
                Container(
                  // width: 200,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        holidays[index]['description'],
                        style: TextStyle(
                             color: Colors.red),
                      ),
                      Text(
                        NepaliDateFormat.yMMMMEEEEd().format(date),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        moment,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
        );
      },
      itemCount: holidays == null ? 0 : holidays.length,
    );
  }
}
