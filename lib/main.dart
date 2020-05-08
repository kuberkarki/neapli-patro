
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'helpers/patro_helper.dart';
import 'patro/patro.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define the default font family.
        // fontFamily: 'Georgia',
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
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
  int _counter = 0;
  NepaliDateTime gorkhaEarthQuake;
  //  NepaliDateTime currentTime = NepaliDateTime.now();
  NepaliDateTime currentTime = NepaliDateTime.now();
  var date2 = NepaliDateFormat.EEEE();

  final NepaliDateTime first =NepaliDateTime(2075,5);
    final NepaliDateTime last = NepaliDateTime(2077,3);

  final NepaliCalendarController _nepaliCalendarController = NepaliCalendarController();
// print(currentTime.toIso8601String());
  // print(currentTime.toIso8601String()); //2076-02-01T11:25:46.490980

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
      ),
      body: Column(
        children: [
          Container(
            // width: MediaQuery.of(context).size.width/20,
            color: Colors.deepOrange,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(NepaliDateFormat.LLLL().format(currentTime) + ', ',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text(
                      NepaliDateFormat.y().format(currentTime),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                Text(NepaliDateFormat.d().format(currentTime),
                    style: TextStyle(fontSize: 36, color: Colors.white)),
                Text(date2.format(currentTime),
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
          Container(
              //  width: 300,
              // _getDayHeaders()
              child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CleanNepaliCalendar(
              controller: _nepaliCalendarController,
              onHeaderLongPressed: (date) {
                print("header long pressed $date");
              },
              onHeaderTapped: (date) {
                print("header tapped $date");
              },
              calendarStyle: CalendarStyle(
                selectedColor: Colors.deepOrange,
                dayStyle: TextStyle(fontWeight: FontWeight.bold),
                todayStyle: TextStyle(
                  fontSize: 20.0,
                ),
                todayColor: Colors.orange.shade400,
                highlightSelected: true,
                renderDaysOfWeek: true,
                highlightToday: true,
              ),
              headerStyle: HeaderStyle(
                centerHeaderTitle: false,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange,fontSize: 20.0),
              ),
              initialDate: NepaliDateTime.now(),
              // firstDate: first,
              // lastDate: last,
              language: Language.nepali,
              onDaySelected: (day){
                print(day.toString());
              },
              
            ),
          ],
        ),
      ),
    ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

