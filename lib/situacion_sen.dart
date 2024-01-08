import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

late String message;
late String respuesta;

class SituacionDelSen {
  int situacionMW;
  String linkWeb;
  bool actualizacion;
  String url;
  String situacion;
  SituacionDelSen()
      : situacionMW = 0,
        linkWeb = '',
        actualizacion = false,
        url = '',
        situacion = '';

  getResponse() async {
    await initializeDateFormatting('es', null);
    DateTime hoy = DateTime.now(); //FECHA
    String formattedDate =
        DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(hoy);
    String url = 'https://t.me/s/elecholguin';

    var response = await http.get(Uri.parse(url));
    var respuestaParseada = parse(response.body);
    String situacionSen = respuestaParseada.body!.text;
    if (situacionSen.contains(formattedDate)) {
      int inicio = situacionSen.indexOf(formattedDate);
      int fin = situacionSen.indexOf('MINEM', inicio + formattedDate.length);
      var parseado = situacionSen.substring(inicio, fin + 'MINEM'.length);
      var scrapping =
          parseado.replaceAll('👉', '').replaceAll(RegExp(r'\s{2,}'), ' ');
      if (scrapping.contains(formattedDate)) {
        RegExp exp = RegExp(
            r'una disponibilidad de (\d+) MW|una demanda máxima de (\d+) MW');
        Iterable<Match> matches = exp.allMatches(scrapping);
        List<int> intNumbers = [];
        for (Match match in matches) {
          String? number = match.group(1) ?? match.group(2);
          intNumbers.add(int.parse(number!));
        }
        this.situacionMW = intNumbers.first - intNumbers.last;
        String message = this.situacionMW.toString();
        if (situacionMW < 0) {
          return "Parte del SEN para el hoy, $scrapping\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
        } else {
          return "Parte del SEN para el hoy, $scrapping\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
        }
      } else {
        return 'No se ha actualizado el parte del SEN para el dia de hoy';
      }
    }
  }

  senSituation() async {
    SituacionDelSen situacion = SituacionDelSen();
    await situacion.getResponse();
    String message = situacion.situacionMW.toString();
    if (message == '0') {
      return 'esperando situacion del SEN';
    }
    if (message.contains('-')) {
      return 'Appagon:\nSe estima un deficit de ${message.replaceAll('-', '')} MW para el dia de hoy';
    } else {
      return 'Appagon:\nSe estima una reserva de $message MW para el dia de hoy';
    }
  }
}
