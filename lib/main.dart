// Importamos los paquetes necesarios

// ignore_for_file: library_private_types_in_public_api

import 'flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'situacion_sen.dart';
import 'telegram_updates.dart';
import 'distribucion_holguin.dart';

late String nombre;
LocalNotificationService localNotificationService = LocalNotificationService();

final generacion = ValueNotifier<String>('esperando situacion del SEN');
actualizarGeneracion() async {
  // Obtener el nuevo valor de alguna fuente, como una API o una base de datos
  String nuevoValor = await SituacionDelSen().senSituation();
  // Asignar el nuevo valor al ValueNotifier
  generacion.value = nuevoValor;
}

// Usar un ValueListenableBuilder para mostrar el valor de generacion en un widget de texto

class DataManager {
  static final DataManager _singleton = DataManager._internal();

  factory DataManager() {
    return _singleton;
  }

  DataManager._internal();

  SharedPreferences? prefs;
  String? data;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    data = prefs?.getString('senData');
  }

  Future<String> _getSenData() async {
    try {
      final response = await SituacionDelSen().getResponse();
      return response;
    } catch (e) {
      return 'Esperando situacion del SEN ';
    }
  }

  updateData() async {
    String newData = await _getSenData();
    prefs?.setString('senData', newData);
    data = newData;
  }
}

// Definimos una clase para la app

class AppagonApp extends StatelessWidget {
  const AppagonApp({super.key});

  // Este widget es la raíz de la app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appagon',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const SplashScreen(), // La pantalla de carga de la app
    );
  }
}

// Definimos una clase para la pantalla de carga
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  // Este widget es la pantalla de carga de la app
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Definimos el estado de la pantalla de carga
class _SplashScreenState extends State<SplashScreen> {
  // Este método se ejecuta cuando se crea el widget
  @override
  void initState() {
    super.initState();
    // Aquí podemos hacer alguna lógica de inicialización, como cargar datos o verificar el estado de la app
    // Después de un tiempo, pasamos a la pantalla de configuración principal
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConfigScreen()),
      );
    });
  }

  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.black, // Fondo de color negro
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Appagón',
                        style: TextStyle(
                          fontFamily: 'Roboto', // Fuente estándar de Flutter
                          fontSize: 60, // Tamaño de fuente más grande
                          fontWeight: FontWeight.bold, // Fuente en negrita
                          color: Colors.white, // Texto de color blanco
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Cargando, por favor, espere.',
                        style: TextStyle(
                          fontFamily: 'Roboto', // Fuente estándar de Flutter
                          fontSize: 25, // Tamaño de fuente más grande
                          color: Colors.white, // Texto de color blanco
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: FractionalOffset.topCenter,
                    child: Image.asset(
                        'assets/images/splash.png'), // Asegúrate de tener esta imagen en tu carpeta de assets
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Definimos una clase para la pantalla de configuración principal
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  // Este widget es la pantalla de configuración principal de la app
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

// Definimos el estado de la pantalla de configuración principal
class _ConfigScreenState extends State<ConfigScreen> {
  String elemento1 = 'Holguin';
  // Aquí podemos definir algunas variables para guardar los valores de los selectores de elementos
  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // AppBar personalizada sin el botón de retroceso
        appBar: AppBar(
          title: const Text('Configuración principal'),
          automaticallyImplyLeading:
              false, // Esto desactiva el botón de retroceso
          backgroundColor: Colors.black, // Fondo de color negro
          foregroundColor: Colors.white, // Texto de color blanco
        ),
        body: Container(
          color: Colors.black, // Fondo de color negro
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                          'assets/images/splash.png'), // Asegúrate de tener esta imagen en tu carpeta de assets
                      const Text(
                        'Seleccione su provincia',
                        style: TextStyle(
                          color: Colors.white, // Texto de color blanco
                        ),
                      ),
                      // Un selector de elementos para el elemento 1
                      DropdownButton<String>(
                        dropdownColor:
                            Colors.blueGrey, // Fondo del botón en color azul
                        style: const TextStyle(
                            color: Colors
                                .white), // Texto del botón en color blanco
                        value: elemento1,
                        onChanged: (String? newValue) {
                          setState(() {
                            elemento1 = newValue!;
                          });
                        },
                        items: <String>[
                          'Pinar del Rio',
                          'La Habana',
                          'Artemisa',
                          'Mayabeque',
                          'Matanzas',
                          'Villa Clara',
                          'Ciego de Avila',
                          'Cienfuegos',
                          'Camaguey',
                          'Las Tunas',
                          'Holguin',
                          'Granma',
                          'Santiago de Cuba',
                          'Guantanamo'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                              onTap: () async {
                                elemento1 = value.toString();
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString('nombre', elemento1);
                              });
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Un botón de siguiente que nos lleva al menú principal
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      nombre = prefs.getString('nombre') ?? 'Holguin';
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainMenu()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          Colors.blueGrey, // Texto del botón en color blanco
                    ),
                    child: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Aquí asignamos el valor de elemento1 al valor guardado o a 'Holguin' si es nulo
      elemento1 = prefs.getString('nombre') ?? 'Holguin';
    });
  }

  @override
  void initState() {
    super.initState();
    // Aquí llamamos al método _read() para obtener el valor del shared_preferences
    _read();
  }
}

class CustomTextWidget extends StatefulWidget {
  final String text;
  const CustomTextWidget({super.key, required this.text});

  @override
  _CustomTextWidgetState createState() => _CustomTextWidgetState();
}

class _CustomTextWidgetState extends State<CustomTextWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: Card(
            color: const Color.fromARGB(255, 31, 31, 31),
            margin: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Definimos una clase para el menú principal
class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  // Este widget es el menú principal de la app
  // ignore: duplicate_ignore
  @override
  _MainMenuState createState() => _MainMenuState();
}

// Definimos el estado del menú principal
class _MainMenuState extends State<MainMenu> {
  // Aquí podemos definir algunas variables para guardar el estado de la app, como el mensaje de reserva o déficit

  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      // AppBar personalizada sin el botón de retroceso
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Esto desactiva el botón de retroceso
        backgroundColor: Colors.black, // Fondo de color negro
        foregroundColor: Colors.white, // Texto de color blanco
      ),
      body: Container(
        color: Colors.black, // Fondo de color negro
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: generacion,
                builder: (context, value, child) {
                  // Devolver el widget de texto con el valor actual de generacion
                  return CustomTextWidget(text: value);
                },
              ),
              Image.asset('assets/images/image.png'),
              // Un botón principal que se llama Situación del SEN
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SenScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.blueGrey, // Texto del botón en color blanco
                ),
                child: const Text('Situación del SEN para el dia de hoy'),
              ),
              // Un botón que se llama Actualización de último minuto
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TelegramScrapper()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.blueGrey, // Texto del botón en color blanco
                ),
                child: const Text('Actualización de último minuto'),
              ),
              // Un botón que se llama Distribución para el mes
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DistributionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.blueGrey, // Texto del botón en color blanco
                ),
                child: const Text('Distribución para hoy'),
              ),
              // Un botón que se llama Configuración
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConfigScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.blueGrey, // Texto del botón en color blanco
                ),
                child: const Text('Configuración'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InfoScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.blueGrey, // Texto del botón en color blanco
                ),
                child: const Text('Info'),
              ),
            ],
          ),
        ),
      ),
      // Un botón de ayuda en la esquina
    ));
  }
}

// Definimos una clase para la pantalla de Situación del SEN
class SenScreen extends StatefulWidget {
  const SenScreen({super.key});

  @override
  _SenScreenState createState() => _SenScreenState();
}

class _SenScreenState extends State<SenScreen> {
  late Widget senCard;
  final dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    dataManager.initPrefs();
    if (dataManager.data != null) {
      senCard = buildCard(dataManager.data!);
    } else {
      updateData();
    }
  }

  updateData() async {
    setState(() {
      senCard = const CircularProgressIndicator();
    });
    await dataManager.updateData();
    setState(() {
      senCard = buildCard(dataManager.data!);
    });
  }

  Widget buildCard(String data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Situación del SEN'),
        actions: [
          IconButton(
            onPressed: updateData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(color: Colors.black, child: Center(child: senCard)),
    );
  }
}

// Definimos una clase para la pantalla de Actualización de último minuto////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Definimos una clase para la pantalla de Distribución para el mes/
class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  // Este widget es la pantalla de Distribución para el mes
  @override
  _DistributionScreenState createState() => _DistributionScreenState();
}

// Definimos el estado de la pantalla de Distribución para el mes
class _DistributionScreenState extends State<DistributionScreen> {
  // Aquí podemos definir algunas variables para guardar la información de la distribución para hoy y para el mes
  late String distributionToday;
  late String distributionMonth;

  // Aquí podemos definir una variable para guardar la fecha seleccionada por el usuario
  late DateTime selectedDate;

  // Este método se ejecuta cuando se crea el estado del widget
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    // Aquí podemos asignar el resultado de las funciones rotacionDiaria() y planMensual() a las variables distributionToday y distributionMonth, respectivamente
    distributionToday = rotacionDiaria(nombre);
    distributionMonth = planMensual(nombre, selectedDate);
    // Aquí podemos asignar la fecha actual a la variable selectedDate
  }

  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Distribución'),
        actions: const [
          // Un botón de ir atrás que nos devuelve al menú principal
        ],
      ),
      body: Container(
        color: Colors.black,
        // Aquí usamos un widget Column para mostrar la card con la distribución para hoy y el botón de buscar fecha
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aquí usamos un widget Card para envolver el texto con la información de la distribución para hoy
            Card(
              color: Colors.white,

              // Aquí usamos un widget Padding para agregar un espacio entre el texto y los bordes de la tarjeta
              child: Padding(
                padding: const EdgeInsets.all(16),
                // Aquí usamos un widget Center para centrar el texto dentro de la tarjeta
                child: Center(
                  child: Text(distributionToday),
                ),
              ),
            ),
            // Aquí usamos un widget ElevatedButton para mostrar el botón de buscar fecha
            ElevatedButton(
              // Aquí usamos un widget Text para mostrar el texto del botón
              child: const Text('Buscar fecha'),
              // Aquí definimos la acción que se ejecuta al presionar el botón
              onPressed: () async {
                // Aquí usamos un widget DatePicker para mostrar el buscador de fechas y obtener la fecha seleccionada por el usuario
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2025),
                );
                // Aquí verificamos si el usuario ha seleccionado una fecha válida
                if (pickedDate != null && pickedDate != selectedDate) {
                  // Aquí actualizamos el estado del widget con la nueva fecha seleccionada
                  setState(() {
                    selectedDate = pickedDate;
                    // Aquí podemos asignar el resultado de la función planMensual() con la nueva fecha a la variable distributionMonth
                    distributionMonth = planMensual(nombre, selectedDate);
                  });
                  // Aquí usamos un widget showDialog para mostrar una card con la información de la distribución para el mes
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Scaffold(
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            title: const Text('Distribución'),
                            actions: const [
                              // Un botón de ir atrás que nos devuelve al menú principal
                            ],
                          ),
                          body: Container(
                              color: Colors.black,
                              // Aquí usamos un widget Column para mostrar la card con la distribución para hoy y el botón de buscar fecha
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Aquí usamos un widget Card para envolver el texto con la información de la distribución para hoy
                                    Card(
                                      color: Colors.white,

                                      // Aquí usamos un widget Padding para agregar un espacio entre el texto y los bordes de la tarjeta
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        // Aquí usamos un widget Center para centrar el texto dentro de la tarjeta
                                        child: Center(
                                          child: Text(distributionMonth),
                                        ),
                                      ),
                                    )
                                  ])));
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Definimos una clase para la pantalla de Configuración

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acerca de',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              color: Color.fromARGB(255, 31, 31, 31),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'La aplicación Appagon tiene como objetivo informar a los usuarios\n sobre la disponibilidad de generación eléctrica en Cuba, basándose en los valores publicados por la Empresa Eléctrica de Cuba y siguiendo sus distribuciones.\n Sin embargo, tenga en cuenta que la disponibilidad de generación eléctrica puede cambiar en cualquier momento debido a factores imprevistos. La aplicación no se responsabiliza de los cambios de última hora en la disponibilidad de generación eléctrica. La información proporcionada por la aplicación se proporciona “tal cual” y sin garantía de ningún tipo, expresa o implícita.\n La aplicación no se hace responsable de ningún daño directo, indirecto, incidental, especial o consecuente que surja del uso de la información proporcionada por la aplicación.',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                            Desarrollado por: Carlos Enrique Tome Rodriguez',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TelegramScrapper extends StatefulWidget {
  const TelegramScrapper({super.key});

  @override
  _TelegramScrapperState createState() => _TelegramScrapperState();
}

class _TelegramScrapperState extends State<TelegramScrapper> {
  String respuesta = '';
  String url = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Actualización en tiempo real',
            textAlign: TextAlign.left,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                var newUrl = await telegramPrueba(nombre);
                setState(() {
                  url = newUrl;
                });
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder<String>(
          future: telegramPrueba(nombre),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color:
                        const Color.fromARGB(255, 31, 31, 31).withOpacity(0.5),
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

// El punto de entrada de la app
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localNotificationService.setup();
  runApp(const AppagonApp());
  await actualizarGeneracion();
}
