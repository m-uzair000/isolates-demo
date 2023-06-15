import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolates Demo')),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: const Text('Run Task Without Isolate'),
                onPressed: () => withOutIsolate(5000000000)),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
            const SizedBox(height: 50),
            ElevatedButton(
                child: const Text('Run Task With Isolate'),
                onPressed: () => isolate()),
            const SizedBox(height: 50),
            ElevatedButton(
                child: const Text('Run Task With Compute'),
                onPressed: () => computeIsolate()),
          ],
        ),
      ),
    );
  }

  isolate() async {
    final ReceivePort receivePort = ReceivePort();
    try {
      await Isolate.spawn(withIsolate, [receivePort.sendPort, 5000000000]);
    } on Object {
      debugPrint('Failed');
      receivePort.close();
    }

    /// first way to listen
    final response = await receivePort.first;
    print('Isolate: $response');

    /// Second way to listen
    // receivePort.listen((message) {
    //   print('Response: $message');
    // });
  }

  withIsolate(List<dynamic> args) {
    SendPort resultPort = args[0];
    int value = 0;
    for (var i = 0; i < args[1]; i++) {
      value += i;
    }
    Isolate.exit(resultPort, value);
  }

  withOutIsolate(int count) {
    int value = 0;
    for (var i = 0; i < count; i++) {
      value += i;
    }
    print('Without Isolate: $value');
  }

  computeIsolate() async {
    int returnValue = 0;
    try {
      returnValue = await compute(withCompute, 5000000000);
    } on Object {
      debugPrint('Failed');
    }
    print("Compute: $returnValue");
  }

  int withCompute(int args) {
    int value = 0;
    for (var i = 0; i < args; i++) {
      value += i;
    }
    return value;
  }
}
