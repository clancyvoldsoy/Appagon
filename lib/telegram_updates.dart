import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

late String message;
late String respuesta;
Map<String, String> mapaProvincias = {
  'Holguin': 'elecholguin',
  'Camaguey': 'empresa_electrica',
  'Las Tunas': 'eleclastunas',
  'Santiago de Cuba': 'electricastgo',
  'Villa Clara': 'electrico1895',
  'Matanzas': 'EmpresaElectricaMatanzas',
  'La Habana': 'EmpresaElectricaDeLaHabana',
  'Mayabeque': 'electricamayabeque',
  'Pinar del Rio': 'elecpinar',
  'Guantanamo': 'elecguantanamo',
  'Artemisa': 'EEArtemisa',
  'Ciego de Avila': 'eecav',
  'Granma': 'UNE_EEG',
  'Cienfuegos': 'empresaelectricacienfuegos1'
};

class TelegramMessages {
  String formattedDate;
  String linkWeb;
  bool actualizacion;
  String url;
  String situacion;
  TelegramMessages()
      : formattedDate = '',
        linkWeb = '',
        actualizacion = false,
        url = '',
        situacion = '';
}

Future<String> telegramPrueba(nombre) async {
  String url = 'https://t.me/s/${mapaProvincias[nombre]}';
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      int inicio = response.body
          .indexOf('<section class="tgme_channel_history js-message_history">');
      var parseada = response.body.substring(inicio);
      var respuestaParseada = parse(parseada);
      String situacionSen = respuestaParseada.body!.text;
      // Buscar y reemplazar la palabra views00:00
      RegExp exp = RegExp(
          r'views(\d{2}):(\d{2})'); // Expresión regular para capturar la hora y los minutos
      situacionSen = situacionSen.replaceAllMapped(exp, (match) {
        // Convertir la hora y los minutos a enteros
        int hour = int.parse(match[1]!);
        int minute = int.parse(match[2]!);
        // Crear un objeto DateTime con la hora y los minutos capturados
        DateTime time = DateTime(0, 0, 0, hour, minute);
        // Restar 5 horas usando el método subtract
        time = time.subtract(const Duration(hours: 5));
        // Formatear la hora y los minutos usando el método format
        String newTime = DateFormat('HH:mm').format(time);
        // Devolver la palabra views con la nueva hora
        return 'vistas$newTime';
      });
      RegExp exp1 = RegExp(r'vistas(\d{2}):(\d{2})');

      return situacionSen
          .replaceAll(RegExp(r'\s{5,}'), '')
          .replaceAll('TWeb.init()', "")
          .replaceAllMapped(exp1, (m) => "${m[0]}\n\n")
          .replaceAll('vistas', '')
          .replaceAll('viewsedited', '');
    } else {
      return "Lo sentimos, el sitio no se encuentra disponible en estos momentos";
    }
  } catch (e) {
    return "Verifique su conexion a internet e intente nuevamente";
  }
}
