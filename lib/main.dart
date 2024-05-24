// Importamos los paquetes necesarios

// ignore_for_file: library_private_types_in_public_api, unused_local_variable, await_only_futures, duplicate_ignore

import 'flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'situacion_sen.dart';
import 'telegram_updates.dart';
import 'distribucion_holguin.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final Map<String, List<String>> provincias = {
  'La Habana': ['no disponible'],
  'Pinar del Rio': ['no disponible'],
  'Ciego de Avila': ['no disponible'],
  'Camaguey': ['no disponible'],
  'Granma': ['no disponible'],
  'Artemisa': ['B1', 'B2'],
  'Santiago de Cuba': ['B1', 'B2'],
  'Mayabeque': ['B1', 'B2', 'B3'],
  'Cienfuegos': ['B1', 'B2', 'B3'],
  'Matanzas': ['B1', 'B2', 'B3', 'B4'],
  'Villa Clara': ['B1', 'B2', 'B3', 'B4'],
  'Holguin': ['B1', 'B2', 'B3', 'B4'],
  'Guantanamo': ['B1', 'B2', 'B3', 'B4'],
  'Las Tunas': ['1', '2', '3', '4'],
};
String bloqueSeleccionado = '';
String nombre = 'Holguin';
bool notificacionElectrodomesticos = false;
bool notificacionCargarMovil = false;
LocalNotificationService localNotificationService = LocalNotificationService();

final generacion = ValueNotifier<String>('esperando situacion del SEN ');
actualizarGeneracion() async {
  // Obtener el nuevo valor de alguna fuente, como una API o una base de datos
  String nuevoValor = await SituacionDelSen().senSituation();
  // Asignar el nuevo valor al ValueNotifier
  generacion.value = nuevoValor;
}

class DropDownClase extends StatefulWidget {
  // El mapa de provincias
  final Map<String, List<String>> provincias;

  // El constructor que recibe el mapa como parámetro
  const DropDownClase({super.key, required this.provincias});

  @override
  _DropDownClaseState createState() => _DropDownClaseState();
}

class _DropDownClaseState extends State<DropDownClase> {
  // Los valores seleccionados de cada DropDown
  String provincia = "";
  String bloque = "";

  // El objeto SharedPreferences para guardar y cargar los datos
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    // Inicializar el SharedPreferences
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      // Asignar los valores guardados o usar valores por defecto
      setState(() {
        provincia =
            prefs.getString("provincia") ?? widget.provincias.keys.first;
        nombre = prefs.getString('provincia') ?? widget.provincias.keys.first;
        bloque =
            prefs.getString("bloque") ?? widget.provincias[provincia]!.first;
      });
      bloqueSeleccionado = prefs.getString('bloque') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // El primer DropDown para las provincias
        DropdownButton<String>(
          dropdownColor: Colors.blueGrey, // Fondo del botón en color azul
          style: const TextStyle(color: Colors.white), //
          value: provincia,
          items: widget.provincias.keys
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (value) {
            // Actualizar el valor seleccionado y guardar en el SharedPreferences
            setState(() {
              provincia = value!;
              nombre = provincia;
              bloque = widget.provincias[provincia]!.first;
              prefs.setString("provincia", provincia);
              prefs.setString("bloque", bloque);
            });
          },
        ),
        const Text(
          'Seleccione su bloque',
          style: TextStyle(
            color: Colors.white, // Texto de color blanco
          ),
        ),
        // El segundo DropDown para los bloques que correspondan
        DropdownButton<String>(
          dropdownColor: Colors.blueGrey, // Fondo del botón en color azul
          style: const TextStyle(color: Colors.white), //
          value: bloque,
          items: widget.provincias[provincia]!
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (value) {
            // Actualizar el valor seleccionado y guardar en el SharedPreferences
            setState(() {
              bloque = widget.provincias[provincia]!.first;
              bloque = value!;
              bloqueSeleccionado = bloque;
              prefs.setString("bloque", bloque);
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    // No es necesario cerrar el SharedPreferences
    // prefs.dispose(); // Elimina esta línea
    super.dispose();
  }
}

class SwitchCargarMovil extends StatefulWidget {
  const SwitchCargarMovil({super.key});

  @override
  _SwitchCargarMovilState createState() => _SwitchCargarMovilState();
}

class _SwitchCargarMovilState extends State<SwitchCargarMovil> {
  bool isSwitched = false;

  // Crea una clave para guardar y obtener el valor del switch
  static const switchKey = 'switchValue';

  // Obtiene el valor del switch de las preferencias compartidas
  Future<void> getSwitchValue() async {
    final prefs = await SharedPreferences.getInstance();
    final value = await prefs.getBool(switchKey) ?? false;
    notificacionCargarMovil = value;
    setState(() {
      isSwitched = value;
    });
  }

  // Guarda el valor del switch en las preferencias compartidas
  Future<void> setSwitchValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(switchKey, value);
  }

  @override
  void initState() {
    super.initState();
    // Inicializa el valor del switch al construir el widget
    getSwitchValue();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 37, 36, 36),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 34, 33, 33).withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: const Text('Notificaciones para cargar el móvil ',
            style: TextStyle(color: Colors.white)),
        trailing: Switch(
          value: isSwitched,
          onChanged: (value) async {
            setState(() {
              // Actualiza el valor del switch en el estado y en las preferencias compartidas
              isSwitched = value;
              setSwitchValue(value);
            });
          },
          activeTrackColor: Colors.purpleAccent,
          activeColor: Colors.purple,
        ),
      ),
    );
  }
}

class SwitchElectrodomesticos extends StatefulWidget {
  const SwitchElectrodomesticos({super.key});

  @override
  _SwitchElectrodomesticosState createState() =>
      _SwitchElectrodomesticosState();
}

class _SwitchElectrodomesticosState extends State<SwitchElectrodomesticos> {
  bool isSwitchedElectro = false;

  // Crea una clave para guardar y obtener el valor del switch
  static const switchElectroKey = 'switchElectroValue';

  // Obtiene el valor del switch de las preferencias compartidas
  Future<void> getSwitchElectroValue() async {
    final prefs = await SharedPreferences.getInstance();
    final value = await prefs.getBool(switchElectroKey) ?? false;

    setState(() {
      isSwitchedElectro = value;
      notificacionElectrodomesticos = value;
    });
  }

  // Guarda el valor del switch en las preferencias compartidas
  Future<void> setSwitchElectroValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(switchElectroKey, value);
  }

  @override
  void initState() {
    super.initState();
    // Inicializa el valor del switch al construir el widget
    getSwitchElectroValue();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 37, 36, 36),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 34, 33, 33).withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: const Text('Notificaciones para apagar electrodomésticos',
            style: TextStyle(color: Colors.white)),
        trailing: Switch(
          value: isSwitchedElectro,
          onChanged: (value) async {
            setState(() {
              // Actualiza el valor del switch en el estado y en las preferencias compartidas
              isSwitchedElectro = value;

              setSwitchElectroValue(value);
              // Cambia la variable notificacionCargarMovil por notificacionElectrodomesticos
            });
          },
          activeTrackColor: Colors.purpleAccent,
          activeColor: Colors.purple,
        ),
      ),
    );
  }
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
      return 'Esperando situacion del SEN  ';
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
    // Definimos los colores de la paleta de Material Design
    const Color primaryColor = Color(0xFF6200EE); // Morado
    const Color secondaryColor = Color(0xFF03DAC6); // Turquesa
    const Color backgroundColor = Color(0xFF121212); // Negro
    const Color surfaceColor = Color(0xFF1F1F1F); // Gris oscuro
    const Color onPrimaryColor = Color(0xFFFFFFFF); // Blanco
    const Color onSecondaryColor = Color(0xFF000000); // Negro
    const Color onBackgroundColor = Color(0xFFFFFFFF); // Blanco
    const Color onSurfaceColor = Color(0xFFFFFFFF); // Blanco

    return MaterialApp(
      title: 'Appagon',
      // Creamos nuestro propio tema personalizado con los colores de la paleta
      theme: ThemeData(
        // Aplicamos el tema oscuro de Material Design
        brightness: Brightness.dark,
        // Asignamos los colores de la paleta a los diferentes elementos del tema
        primaryColor: primaryColor,
        hintColor: secondaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: surfaceColor,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          onPrimary: onPrimaryColor,
          onSecondary: onSecondaryColor,
          onSurface: onSurfaceColor,
          onBackground: onBackgroundColor,
        ).copyWith(background: backgroundColor),
      ),
      // Ocultamos la etiqueta de debug
      debugShowCheckedModeBanner: false,
      // Configuramos el soporte de idiomas de la app
      // Definimos las rutas de navegación de la app
      routes: {
        // La ruta inicial es la pantalla de carga
        '/': (context) => const SplashScreen(),
        // La ruta de la pantalla de configuración principal
        '/config': (context) => const ConfigScreen(),
        // Otras rutas que puedas necesitar
        // ...
      },
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
  // Crea una clave para guardar y obtener el valor de isFirstRun
  static const firstRunKey = 'isFirstRun';

  // Obtiene el valor de isFirstRun de las preferencias compartidas
  // ignore: duplicate_ignore, duplicate_ignore
  Future<bool> getFirstRunValue() async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: await_only_futures
    final value = await prefs.getBool(firstRunKey) ?? true;
    return value;
  }

  // Guarda el valor de isFirstRun en las preferencias compartidas
  Future<void> setFirstRunValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(firstRunKey, value);
  }

  // Este método se ejecuta cuando se crea el widget
  @override
  void initState() {
    super.initState();
    // Aquí podemos hacer alguna lógica de inicialización, como cargar datos o verificar el estado de la app
    // Después de un tiempo, pasamos a la pantalla de configuración principal o al main menu según el valor de isFirstRun
    Future.delayed(const Duration(seconds: 3), () async {
      // Obtiene el valor de isFirstRun
      bool isFirstRun = await getFirstRunValue();
      // Si es la primera vez que se ejecuta la app, va a la config screen y cambia el valor de isFirstRun a false

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConfigScreen()),
      );

      // Si no es la primera vez que se ejecuta la app, va al main menu
    });
  }

  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    // Definimos los colores de la paleta de Material Design
    const Color primaryColor = Color(0xFF6200EE); // Morado
    const Color secondaryColor = Color(0xFF03DAC6); // Turquesa
    const Color backgroundColor = Color(0xFF121212); // Negro
    const Color surfaceColor = Color(0xFF1F1F1F); // Gris oscuro
    const Color onPrimaryColor = Color(0xFFFFFFFF); // Blanco
    const Color onSecondaryColor = Color(0xFF000000); // Negro
    const Color onBackgroundColor = Color(0xFFFFFFFF); // Blanco
    const Color onSurfaceColor = Color(0xFFFFFFFF); // Blanco

    return MaterialApp(
      theme: ThemeData(
        // Aplicamos el tema oscuro de Material Design
        brightness: Brightness.dark,
        // Asignamos los colores de la paleta a los diferentes elementos del tema
        primaryColor: primaryColor,
        hintColor: secondaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: surfaceColor,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          onPrimary: onPrimaryColor,
          onSecondary: onSecondaryColor,
          onSurface: onSurfaceColor,
          onBackground: onBackgroundColor,
        ).copyWith(background: backgroundColor),
      ),
      home: Scaffold(
        body: Center(
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
                        color: onBackgroundColor, // Texto de color blanco
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Cargando, por favor, espere.',
                      style: TextStyle(
                        fontFamily: 'Roboto', // Fuente estándar de Flutter
                        fontSize: 25, // Tamaño de fuente más grande
                        color: onBackgroundColor, // Texto de color blanco
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
// Este es el mapa de provincias con sus listas de bloques

// Estas son las variables que guardan los valores seleccionados en cada dropdown

  // Aquí podemos definir algunas variables para guardar los valores de los selectores de elementos
  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    // Definimos los colores de la paleta de Material Design
// Morado
    const Color secondaryColor = Color(0xFF03DAC6); // Turquesa
    const Color backgroundColor = Color(0xFF121212); // Negro
    const Color surfaceColor = Color(0xFF1F1F1F); // Gris oscuro
// Blanco
    const Color onSecondaryColor = Color(0xFF000000); // Negro
    const Color onBackgroundColor = Color(0xFFFFFFFF); // Blanco
    const Color onSurfaceColor = Color(0xFFFFFFFF); // Blanco

    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConfigScreen()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: MaterialApp(
          home: Scaffold(
            // AppBar personalizada sin el botón de retroceso
            appBar: AppBar(
              title: const Text('Configuración principal'),
              automaticallyImplyLeading:
                  false, // Esto desactiva el botón de retroceso
              backgroundColor: backgroundColor, // Fondo de color negro
              foregroundColor: onBackgroundColor, // Texto de color blanco
            ),
            body: Container(
              color: backgroundColor, // Fondo de color negro
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
                              color: onBackgroundColor, // Texto de color blanco
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: DropDownClase(
                              provincias: provincias,
                            ),
                          )
                        ],
                      ),
                    ),

                    const Center(child: SwitchElectrodomesticos()),
                    const Center(
                        child:
                            SwitchCargarMovil()), // Un botón de siguiente que nos lleva al menú principal
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          /////////////////////?HERE IS THE BUTTON!!!!
                          LocalNotificationService().bloqueAfectado(
                              nombre,
                              bloqueSeleccionado,
                              notificacionElectrodomesticos,
                              notificacionCargarMovil);
                          // Mostramos un indicador

                          //de carga mientras se navega a la otra pantalla
                          // ignore: use_build_context_synchronously
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AlertDialog(
                              backgroundColor: surfaceColor,
                              content: Row(
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        secondaryColor),
                                  ),
                                  SizedBox(width: 16.0),
                                  Text(
                                    'Cargando...',
                                    style: TextStyle(color: onSurfaceColor),
                                  ),
                                ],
                              ),
                            ),
                          );

                          actualizarGeneracion();
                          // Después de un tiempo, pasamos a la otra pantalla
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainMenu()),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: onSecondaryColor,
                          backgroundColor:
                              secondaryColor, // Texto del botón en color negro
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 8.0, // Efecto de elevación y sombra
                        ),
                        child: const Text('Siguiente'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    // Aquí llamamos al método _read() para obtener el valor del shared_preferences
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
    // Usamos el mismo tema personalizado que el otro código
    final ThemeData theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: Card(
            // Usamos el color de la superficie del tema
            color: theme.colorScheme.surface,
            // Usamos un margen de 8 píxeles
            margin: const EdgeInsets.all(8),
            // Usamos un relleno de 16 píxeles
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.text,
                // Usamos el estilo de texto del cuerpo del tema
                style: theme.textTheme.bodyLarge,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// Asignar la clave al Scaffold

  // Este método construye el widget
  @override
  Widget build(BuildContext context) {
    // Definimos los colores de la paleta de Material Design
    const Color primaryColor = Color(0xFF6200EE); // Morado
    const Color secondaryColor = Color(0xFF03DAC6); // Turquesa
    const Color backgroundColor = Color(0xFF121212); // Negro
    const Color surfaceColor = Color(0xFF1F1F1F); // Gris oscuro
    const Color onPrimaryColor = Color(0xFFFFFFFF); // Blanco
    const Color onSecondaryColor = Color(0xFF000000); // Negro
    const Color onBackgroundColor = Color(0xFFFFFFFF); // Blanco
    const Color onSurfaceColor = Color(0xFFFFFFFF); // Blanco

    // ignore: deprecated_member_use
    return WillPopScope(
      // Usa el widget WillPopScope para interceptar el gesto de ir atrás
      onWillPop: () async {
        // Usa el método push para mostrar la pantalla principal
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainMenu()),
        );
        return false; // Devuelve false para evitar que se ejecute el pop por defecto
      },
      child: MaterialApp(
        // Aplicar el mismo tema personalizado que el otro código
        theme: ThemeData(
          // Aplicamos el tema oscuro de Material Design
          brightness: Brightness.dark,
          // Asignamos los colores de la paleta a los diferentes elementos del tema
          primaryColor: primaryColor,
          hintColor: secondaryColor,
          scaffoldBackgroundColor: backgroundColor,
          cardColor: surfaceColor,
          colorScheme: const ColorScheme.dark(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            onPrimary: onPrimaryColor,
            onSecondary: onSecondaryColor,
            onSurface: onSurfaceColor,
            onBackground: onBackgroundColor,
          ).copyWith(background: backgroundColor),
        ),
        home: Scaffold(
          key: _scaffoldKey,
          // AppBar personalizada con el botón para invocar el menú desplegable
          appBar: AppBar(
            // El botón para invocar el menú desplegable

            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),

            backgroundColor: backgroundColor, // Fondo de color negro
            foregroundColor: onBackgroundColor, // Texto de color blanco
          ),
          body: Container(
            color: backgroundColor, // Fondo de color negro
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: generacion,
                    builder: (context, value, child) {
                      // Devolver el widget de texto con el valor actual de generacion
                      return CustomTextWidget(text: value);
                    },
                  ),
                  Image.asset('assets/images/image.png'),
                  // Un widget de texto con el nombre y la descripción de la aplicación
                  Text(
                    'Appagon',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: onBackgroundColor,
                        ),
                  ),
                  Text(
                    'Una aplicación para monitorear la situación energética de Cuba $bloqueSeleccionado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onBackgroundColor,
                        ),
                  )
                ],
              ),
            ),
          ),
          // Un menú desplegable desde la izquierda
          drawer: Drawer(
            // El contenido del menú desplegable
            child: ListView(
              // Eliminar el relleno superior
              padding: EdgeInsets.zero,
              children: [
                // Un encabezado con el logo y el nombre de la aplicación
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: surfaceColor,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Appagon',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: onSurfaceColor,
                            ),
                      ),
                    ],
                  ),
                ),
                // Un elemento de lista con el icono y el texto de la opción 'Situación del SEN para el día de hoy'
                ListTile(
                  leading: const Icon(Icons.power),
                  title: const Text('Situación del SEN para el día de hoy'),
                  onTap: () {
                    // Cerrar el menú desplegable
                    Navigator.pop(context);
                    // Navegar a la ruta correspondiente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SenScreen()),
                    );
                  },
                ),
                // Un elemento de lista con el icono y el texto de la opción 'Actualización de último minuto'
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('Actualización de último minuto'),
                  onTap: () {
                    // Cerrar el menú desplegable
                    Navigator.pop(context);
                    // Navegar a la ruta correspondiente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TelegramScrapper()),
                    );
                  },
                ),
                // Un elemento de lista con el icono y el texto de la opción 'Distribución para hoy'
                ListTile(
                  leading: const Icon(Icons.pie_chart),
                  title: const Text('Distribución para hoy'),
                  onTap: () {
                    // Cerrar el menú desplegable
                    Navigator.pop(context);
                    // Navegar a la ruta correspondiente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DistributionScreen()),
                    );
                  },
                ),
                // Un elemento de lista con el icono y el texto de la opción 'Configuración'
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  onTap: () {
                    // Cerrar el menú desplegable
                    Navigator.pop(context);
                    // Navegar a la ruta correspondiente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConfigScreen()),
                    );
                  },
                ),
                // Un elemento de lista con el icono y el texto de la opción 'Info'
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Info'),
                  onTap: () {
                    // Cerrar el menú desplegable
                    Navigator.pop(context);
                    // Navegar a la ruta correspondiente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InfoScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Definimos una clase para la pantalla de Situación del SEN
class SenScreen extends StatefulWidget {
  const SenScreen({super.key});

  @override
  _SenScreenState createState() => _SenScreenState();
}

class _SenScreenState extends State<SenScreen> {
  final dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    dataManager.initPrefs();
  }

  // Esta función devuelve un Future que se resuelve con los datos actualizados
  Future<String> updateData() async {
    await dataManager.updateData();
    return dataManager.data!;
  }

  // Este widget construye un widget basado en el resultado de la actualización de datos
  Widget buildFutureCard() {
    return FutureBuilder<String>(
      // Pasamos la función que devuelve el Future
      future: updateData(),
      // Indicamos el valor inicial que se muestra mientras se espera el resultado
      initialData: null, // o una cadena vacía ''
      // Indicamos el widget que se muestra cuando se obtiene el resultado
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        // Si el estado de la conexión es esperando, mostramos el indicador de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        }
        // Si el resultado tiene datos, construimos el widget Card
        else if (snapshot.hasData) {
          return buildCard(snapshot.data!);
        }
        // Si el resultado tiene un error, mostramos un mensaje de error
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // Si el resultado está vacío, mostramos un widget vacío
        else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  // Este widget construye un widget Card con el texto dado
  Widget buildCard(String data) {
    return Card(
      // Usamos el color de la superficie del tema
      color: Theme.of(context).colorScheme.surface,
      // Usamos un relleno de 16 píxeles
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Usamos el widget Builder para crear un contexto descendiente
        child: Builder(
          builder: (BuildContext context) {
            // Aquí podemos usar el tema heredado sin problemas
            return Text(
              data,
              // Usamos el estilo de texto del cuerpo del tema
              style: Theme.of(context).textTheme.bodyLarge,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el mismo tema personalizado que el otro código
    final ThemeData theme = Theme.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: MaterialApp(
            theme: theme,
            home: Scaffold(
              appBar: AppBar(
                // Usamos el color de fondo del tema
                backgroundColor: theme.colorScheme.background,
                // Usamos el color de texto del tema
                foregroundColor: theme.colorScheme.onBackground,
                title: const Text('Situación del SEN'),
                leading: IconButton(
                  // Usa el leading para mostrar el botón de ir atrás
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Usa el método popUntil para volver a la ruta '/main'
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                    );
                  },
                ),
              ),
              body: Container(
                  // Usamos el color de fondo del tema
                  color: theme.colorScheme.background,
                  // Usamos el widget RefreshIndicator para mostrar una animación de refresco
                  child: RefreshIndicator(
                    // Pasamos la función que devuelve el Future
                    onRefresh: updateData,
                    // Pasamos el widget que se muestra en el centro de la pantalla
                    child: Center(child: buildFutureCard()),
                  )),
            )));
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
    // Usamos el mismo tema personalizado que el otro código
    final ThemeData theme = Theme.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: Scaffold(
          appBar: AppBar(
            // Usamos el color de fondo del tema
            backgroundColor: theme.colorScheme.background,
            // Usamos el color de texto del tema
            foregroundColor: theme.colorScheme.onBackground,
            title: const Text('Distribución para hoy'),
            leading: IconButton(
              // Usa el leading para mostrar el botón de ir atrás
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Usa el método popUntil para volver a la ruta '/main'
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenu()),
                );
              },
            ),
            actions: const [
              // Un botón de ir atrás que nos devuelve al menú principal
            ],
          ),
          body: Container(
            // Usamos el color de fondo del tema
            color: theme.colorScheme.background,
            // Aquí usamos un widget Column para mostrar la card con la distribución para hoy y el botón de buscar fecha
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Aquí usamos un widget Card para envolver el texto con la información de la distribución para hoy
                Card(
                  // Usamos el color de la superficie del tema
                  color: theme.colorScheme.surface,
                  // Usamos un relleno de 16 píxeles
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // Usamos el widget Center para centrar el texto dentro de la tarjeta
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
                      // Indicamos el idioma español
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
                          // ignore: deprecated_member_use
                          return WillPopScope(
                              // Usa el widget WillPopScope para interceptar el gesto de ir atrás
                              onWillPop: () async {
                                // Usa el método push para mostrar la pantalla principal
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainMenu()),
                                );
                                return false; // Devuelve false para evitar que se ejecute el pop por defecto
                              },
                              child: Scaffold(
                                  appBar: AppBar(
                                    // Usamos el color de fondo del tema
                                    backgroundColor:
                                        theme.colorScheme.background,
                                    // Usamos el color de texto del tema
                                    foregroundColor:
                                        theme.colorScheme.onBackground,
                                    title: const Text(
                                        'Distribución de fecha seleccionada'),
                                    leading: IconButton(
                                      // Usa el leading para mostrar el botón de ir atrás
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () {
                                        // Usa el método popUntil para volver a la ruta '/main'
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MainMenu()),
                                        );
                                      },
                                    ),
                                    actions: const [
                                      // Un botón de ir atrás que nos devuelve al menú principal
                                    ],
                                  ),
                                  body: Container(
                                      // Usamos el color de fondo del tema
                                      color: theme.colorScheme.background,
                                      // Aquí usamos un widget Column para mostrar la card con la distribución para el mes
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Aquí usamos un widget Card para envolver el texto con la información de la distribución para el mes
                                            Card(
                                              // Usamos el color de la superficie del tema
                                              color: theme.colorScheme.surface,
                                              // Usamos un relleno de 16 píxeles
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                // Aquí usamos el widget SingleChildScrollView para hacer que el texto sea deslizable
                                                child: SingleChildScrollView(
                                                  // Indicamos la dirección del desplazamiento
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  // Aquí usamos el widget Center para centrar el texto dentro de la tarjeta
                                                  child: Center(
                                                    child:
                                                        Text(distributionMonth),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]))));
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ));
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
    // Define una paleta de colores personalizada
    const primaryColor = Color(0xFF6200EE);
    const secondaryColor = Color(0xFF03DAC6);
    const surfaceColor = Color(0xFF121212);
    const backgroundColor = Color(0xFF121212);

    // Define un tema de material design basado en la paleta de colores
    final theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      hintColor: secondaryColor,
    );

    // Usa el tema para construir la pantalla
    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Acerca de',
                  style: TextStyle(color: Colors.white)),
              leading: IconButton(
                // Usa el leading para mostrar el botón de ir atrás
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Usa el método popUntil para volver a la ruta '/main'
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainMenu()),
                  );
                },
              ),
            ),
            body: Container(
              color: backgroundColor,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Card(
                    color: surfaceColor,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'La aplicación Appagon tiene como objetivo informar a los usuarios\n sobre la disponibilidad de generación eléctrica en Cuba, basándose en los valores publicados por la Empresa Eléctrica de Cuba y siguiendo sus distribuciones.\n Sin embargo, tenga en cuenta que la disponibilidad de generación eléctrica puede cambiar en cualquier momento debido a factores imprevistos. La aplicación no se responsabiliza de los cambios de última hora en la disponibilidad de generación eléctrica. La información proporcionada por la aplicación se proporciona “tal cual” y sin garantía de ningún tipo, expresa o implícita.\n La aplicación no se hace responsable de ningún daño directo, indirecto, incidental, especial o consecuente que surja del uso de la información proporcionada por la aplicación.\n\nLa app extrae la información de la situación del SEN desde el canal oficial de Telegram de Holguín: t/me./s/elecholguin\n\nLa informacion de las provincias se obtiene desde los canales oficiales de Telegram, dichos canales son:\n Holguin :t.me/s/elecholguin \n Camaguey :t.me/s/empresa_electrica \n Las Tunas :t.me/s/eleclastunas \n Santiago de Cuba :t.me/s/electricastgo \nVilla Clara :t.me/s/electrico1895 \nMatanzas :t.me/s/EmpresaElectricaMatanzas \n La Habana :t.me/s/EmpresaElectricaDeLaHabana\nMayabeque :t.me/s/electricamayabeque\nPinar del Rio :t.me/s/elecpinar\nGuantanamo :t.me/s/elecguantanamo\nArtemisa :t.me/s/EEArtemisa\nCiego de Avila :t.me/s/eecav\nGranma :t.me/s/UNE_EEG \nCienfuegos :t.me/s/empresaelectricacienfuegos1',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '\n\n\n\n\n\n\n                Desarrollado por: Carlos Enrique Tomé Rodríguez',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class TelegramScrapper extends StatefulWidget {
  const TelegramScrapper({super.key});

  @override
  _TelegramScrapperState createState() => _TelegramScrapperState();
}

class _TelegramScrapperState extends State<TelegramScrapper> {
  // Esta función devuelve un Future que se resuelve con los datos actualizados
  Future<String> updateData() async {
    var newUrl = await telegramPrueba(nombre);
    return newUrl;
  }

  // Este widget construye un widget basado en el resultado de la actualización de datos
  Widget buildFutureCard() {
    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: FutureBuilder<String>(
          // Pasamos la función que devuelve el Future
          future: updateData(),
          // Indicamos el valor inicial que se muestra mientras se espera el resultado
          initialData: null, // o una cadena vacía ''
          // Indicamos el widget que se muestra cuando se obtiene el resultado
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            // Si el estado de la conexión es esperando, mostramos el indicador de carga
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            }
            // Si el resultado tiene datos, construimos el widget Card
            else if (snapshot.hasData) {
              return buildCard(snapshot.data!);
            }
            // Si el resultado tiene un error, mostramos un mensaje de error
            else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            // Si el resultado está vacío, mostramos un widget vacío
            else {
              return const SizedBox.shrink();
            }
          },
        ));
  }

  // Este widget construye un widget Card con el texto dado
  Widget buildCard(String data) {
    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: Card(
          // Usamos el color de la superficie del tema
          color: Theme.of(context).colorScheme.surface,
          // Usamos un relleno de 16 píxeles
          child: Padding(
            padding: const EdgeInsets.all(16),
            // Usamos el widget SingleChildScrollView para crear un área de desplazamiento vertical
            child: SingleChildScrollView(
              // Indicamos la dirección del desplazamiento
              scrollDirection: Axis.vertical,
              // Usamos el widget Builder para crear un contexto descendiente
              child: Builder(
                builder: (BuildContext context) {
                  // Aquí podemos usar el tema heredado sin problemas
                  return Text(
                    data,
                    // Usamos el estilo de texto del cuerpo del tema
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                },
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el mismo tema personalizado que el otro código
    final ThemeData theme = Theme.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
        // Usa el widget WillPopScope para interceptar el gesto de ir atrás
        onWillPop: () async {
          // Usa el método push para mostrar la pantalla principal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenu()),
          );
          return false; // Devuelve false para evitar que se ejecute el pop por defecto
        },
        child: MaterialApp(
            theme: theme,
            home: Scaffold(
              appBar: AppBar(
                // Usamos el color de fondo del tema
                backgroundColor: theme.colorScheme.background,
                // Usamos el color de texto del tema
                foregroundColor: theme.colorScheme.onBackground,
                title: const Text('Actualización en tiempo real'),
                leading: IconButton(
                  // Usa el leading para mostrar el botón de ir atrás
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Usa el método popUntil para volver a la ruta '/main'
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                    );
                  },
                ),
              ),
              body: Container(
                  // Usamos el color de fondo del tema
                  color: theme.colorScheme.background,
                  child: Center(child: buildFutureCard())),
            )));
  }
}

// El punto de entrada de la app
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  LocalNotificationService().setup();

  runApp(const AppagonApp());
}
