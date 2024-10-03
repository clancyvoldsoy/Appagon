import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

late String message;
late String respuesta;

class SituacionDelSen {
  String returnValue;
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
        returnValue = '',
        situacion = '';

  getResponse() async {
    await initializeDateFormatting('es', null);
    DateTime hoy = DateTime.now(); //FECHA
    String formattedDate =
        DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(hoy);
    String url = 'https://t.me/s/EmpresaElectricaDeLaHabana';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
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
            returnValue =
                "Parte del SEN para el hoy, $scrapping\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
            return "Parte del SEN para el hoy, $scrapping\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
          } else {
            returnValue =
                "Parte del SEN para el hoy, $scrapping\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
            return "Parte del SEN para el hoy, $scrapping\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
          }
        } else {
          return 'No se ha actualizado el parte del SEN para el dia de hoy';
        }
      } else {
        await initializeDateFormatting('es', null);
        DateTime hoy = DateTime.now(); //FECHA
        String dia = DateFormat('dd', 'es').format(hoy);
        String mes = DateFormat('MMMM', 'es').format(hoy);
        String year = DateFormat('yyyy', 'es').format(hoy);
        String linkWeb = formattedDate.replaceAll('-', '-de-');
        String url =
            'https://www.minem.gob.cu/es/noticias/situacion-del-sistema-electrico-para-el-06-de-septiembre-de-2024';

        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          if (response.body.contains('{title:"Situaci\\u00f3n del SEN')) {
            int inicio =
                response.body.indexOf(' /><meta name="abstract" content="');
            int fin =
                response.body.indexOf('/><meta name="robots" content="follow,');
            var scrapping = response.body.substring(inicio, fin);
            String situacion =
                scrapping.replaceAll(' /><meta name="abstract" content="', '');
            String respuesta = situacion;
            String encabezado =
                'Parte del SEN para el ${linkWeb.replaceAll('-', ' ')}:\n';
            if (respuesta.contains('disponibilidad')) {
              RegExp exp = RegExp(
                  r'una disponibilidad de (\d+) MW|una demanda máxima de (\d+) MW');
              Iterable<Match> matches = exp.allMatches(situacion);
              List<int> intNumbers = [];
              for (Match match in matches) {
                String? number = match.group(1) ?? match.group(2);
                intNumbers.add(int.parse(number!));
              }

              this.situacionMW = intNumbers.first - intNumbers.last;
              String message = this.situacionMW.toString();
              if (situacionMW < 0) {
                returnValue =
                    "Parte del SEN para el hoy, $scrapping\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
                return "Parte del SEN para el hoy, $scrapping\n \nSe estima una un deficit de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\nHay Probabilidades de Afectacion";
              } else {
                returnValue =
                    "Parte del SEN para el hoy, $scrapping\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
                return "Parte del SEN para el hoy, $scrapping\n \nSe estima una reserva de ${message.toString().replaceAll('-', '')} MW para el dia de hoy\n\nNo Hay Probabilidades de Afectacion";
              }
            } else {
              return 'No se ha actualizado el parte del SEN para el dia de hoy';
            }
          }
        }
      }
    }
  }

  senSituation() async {
    SituacionDelSen situacion = SituacionDelSen();
    String afectacion = await situacion.getResponse();
    String message = situacion.situacionMW.toString();
    if (message == '0') {
      return 'esperando situacion del SEN';
    }
    if (afectacion.contains('una afectación de')) {
      RegExp exp = RegExp(r'una afectación de (\d{1,4}) MW');
      Iterable<Match> matches = exp.allMatches(afectacion);
      for (final m in matches) {
        return 'Se pronostica ${(m[0])} para el dia de hoy';
      }
    } else {
      if (message.contains('-')) {
        return 'Appagon:\nSe estima un deficit de ${message.replaceAll('-', '')} MW para el dia de hoy';
      } else {
        return 'Appagon:\nSe estima una reserva de $message MW para el dia de hoy';
      }
    }
  }
}
