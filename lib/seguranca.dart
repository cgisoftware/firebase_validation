import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_validation/model/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/constants.dart';
import 'dart:async';
import 'dart:io';

class Seguranca {
  final String email;
  final String password;

  Seguranca({this.email, this.password});

  String _codigoAcesso;

  refresh(String aplicativo) async {
    try {
      Dio dio = new Dio();

      Response response =
          await dio.post("https://gateway.cgisoftware.com.br/sessao", data: {
        "usuario": await this.getUsuario(),
        "senha": await this.getSenha(),
        "pacific": await this.getURL(),
        "versao": int.parse(await this.getVersaoMinima()),
        "cliente": await this.getCodigo(),
        "aplicativo": aplicativo
      });

      if (response.data["token"] != null) {
        print(response.data["token"]);
        await this.savePreferences("token", response.data["token"]);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<String> execute() async {
    this._codigoAcesso = await readPreferences("edtCodigo");
    String response = await verify();
    return response;
  }

  Future<String> verify() async {
    String diasAutenticacao = await readPreferences("diasAutenticacao");
    String dtUltimaAutenticacao = await readPreferences("dtUltAutenticacao");
    int iDataAtual = int.tryParse(getData(getDate())[4]);
    int iDataAutenticacao = int.tryParse(dtUltimaAutenticacao);
    int iDias = int.tryParse(diasAutenticacao);

    print(iDias == 0 || iDias == null);

    if (iDias == 0 || iDias == null) {
      return await auth();
    } else {
      if (dtUltimaAutenticacao.trim().length == 0) {
        return await auth();
      } else {
        if (iDataAutenticacao + iDias <= iDataAtual) {
          return await auth();
        } else {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String sVersao = await readPreferences("versao");

          if (sVersao.toLowerCase() == packageInfo.version.toLowerCase()) {
            return '';
          } else {
            await auth();
          }
        }

        return '';
      }
    }
  }

  Future<String> auth() async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.signOut();
      await _auth.signInWithEmailAndPassword(
          email: _codigoAcesso + email, password: password);

      return await permissions();
    } catch (e) {
      return "$string001|${e.toString()}";
    }
  }

  Future<String> permissions() async {
    try {
      DocumentSnapshot snapshot = await Firestore.instance
          .collection("Permissoes")
          .document(this._codigoAcesso)
          .get();

      Firebase firebase = Firebase.fromJson(snapshot.data);
      print(firebase.ativo.toLowerCase());
      // verifica se está ativo
      if (firebase.ativo.toLowerCase() != "sim") {
        return string002;
      }

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      // verifica a validade do app
      List<String> vDtAtual = getData(getDate());
      List<String> vDtValidade = getData(firebase.dtValidade);
      if (int.tryParse(vDtAtual[4]) > int.tryParse(vDtValidade[4])) {
        return string003;
      }

      // black_list
      List<String> vLista = firebase.blackList.split(",");
      for (int i = 0; i <= vLista.length - 1; i++) {
        if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          if (vLista[i].contains(iosInfo.identifierForVendor.toString())) {
            return string004;
          }
        } else {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          if (vLista[i].contains(androidInfo.androidId.toString())) {
            return string004;
          }
        }
      }

      // versao_minima
      if (int.tryParse(packageInfo.buildNumber) < firebase.versaoMinima) {
        return string005;
      }

      String sUsuario = await readPreferences("edtUsuario");
      String sSenha = await readPreferences("edtSenha");
      String sServico = await readPreferences("edtServico");

      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        Firestore.instance
            .collection("Permissoes")
            .document(this._codigoAcesso)
            .collection("Devices")
            .document(iosInfo.identifierForVendor.toString())
            .setData({
          "identifierForVendor": iosInfo.identifierForVendor.toString(),
          "model": iosInfo.model.toString(),
          "localizedModel": iosInfo.localizedModel.toString(),
          "name": iosInfo.name.toString(),
          "systemName": iosInfo.systemName.toString(),
          "systemVersion": iosInfo.systemVersion.toString(),
          "versao_aplicativo": packageInfo.version.toString(),
          "versao_code": packageInfo.buildNumber.toString(),
          "dt_acesso": getDate(),
          "erp_codigo_acesso": this._codigoAcesso.toString(),
          "erp_usuario_cgi": sUsuario,
          "erp_senha_cgi": sSenha,
          "erp_servico": sServico
        });
      } else {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        Firestore.instance
            .collection("Permissoes")
            .document(this._codigoAcesso)
            .collection("Devices")
            .document(androidInfo.androidId.toString())
            .setData({
          "androidId": androidInfo.androidId.toString(),
          "device": androidInfo.device.toString(),
          "model": androidInfo.model.toString(),
          "version": androidInfo.version.toString(),
          "board": androidInfo.board.toString(),
          "bootloader": androidInfo.bootloader.toString(),
          "display": androidInfo.display.toString(),
          "fingerprint": androidInfo.fingerprint.toString(),
          "hardware": androidInfo.hardware.toString(),
          "brand": androidInfo.brand.toString(),
          "host": androidInfo.host.toString(),
          "id": androidInfo.id.toString(),
          "manufacturer": androidInfo.manufacturer.toString(),
          "product": androidInfo.product.toString(),
          "type": androidInfo.type.toString(),
          "versao_aplicativo": packageInfo.version.toString(),
          "versao_code": packageInfo.buildNumber.toString(),
          "dt_acesso": getDate(),
          "erp_codigo_acesso": this._codigoAcesso.toString(),
          "erp_usuario_cgi": sUsuario,
          "erp_senha_cgi": sSenha,
          "erp_servico": sServico
        });
      }

      await savePreferences(
          "diasAutenticacao", firebase.diasAutenticacao.toString());
      await savePreferences("edtServico", firebase.enderecoPacific);
      await savePreferences("dtUltAutenticacao", getData(getDate())[4]);
      await savePreferences("versao", packageInfo.version);
      await savePreferences("numDevices", firebase.numDevices.toString());
      await savePreferences(
          "numDevicesVendedor", firebase.numDevicesVendedor.toString());

      await savePreferences("versao_minima", firebase.versaoMinima.toString());
      return '';
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> getBuildVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return {'b': packageInfo.buildNumber.toString(), 'v': packageInfo.version};
  }

  Future<int> getNumDevices() async {
    int numDevices = int.parse(await readPreferences('numDevices'));
    return numDevices;
  }

  Future<int> getNumDevicesVendedor() async {
    int numDevices = int.parse(await readPreferences('numDevicesVendedor'));
    return numDevices;
  }

  Future getCodigo() async {
    var cod = await readPreferences('edtCodigo');
    return cod;
  }

  Future getSenha() async {
    var senha = await readPreferences('edtSenha');
    return senha;
  }

  Future getURL() async {
    var url = await readPreferences('edtServico');
    return url;
  }

  Future getUsuario() async {
    var usuario = await readPreferences('edtUsuario');
    return usuario;
  }

  Future getMotorista() async {
    var motorista = await readPreferences('edtMotorista');
    return motorista;
  }

  Future getPlaca() async {
    var placa = await readPreferences('edtPlaca');
    return placa;
  }

  Future getToken() async {
    var token = await readPreferences('token');
    return token;
  }

  Future getVersaoMinima() async {
    var token = await readPreferences('versao_minima');
    return token;
  }

  Future<Null> savePreferences(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  Future<String> readPreferences(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String sRetorno = sharedPreferences.getString(key);

    if (sRetorno == null)
      return "";
    else
      return sRetorno;
  }

  String getDate() {
    return new DateFormat("dd/MM/yyyy").format(new DateTime.now());
  }

  String getDateTime() {
    return new DateFormat("dd/MM/yyyy HH:mm:ss").format(new DateTime.now());
  }

  List<String> getData(String data) {
    List<String> vRetorno = new List(9);
    int iDia = 0;
    int iMes = 0;
    int iAno = 0;
    String sAno = "";
    String sMes = "";
    String sDia = "";

    if (data.trim().length != 0) {
      iDia = int.tryParse(data.split("/")[0]);
      iMes = int.tryParse(data.split("/")[1]);
      iAno = int.tryParse(data.split("/")[2]);

      sDia = data.split("/")[0];
      sMes = data.split("/")[1];
      sAno = data.split("/")[2];
    }

    vRetorno[0] = data;
    vRetorno[1] = iDia.toString();
    vRetorno[2] = iMes.toString();
    vRetorno[3] = iAno.toString();
    vRetorno[4] = sAno + sMes + sDia;
    vRetorno[5] = sMes + "/" + sAno;
    vRetorno[6] = sDia;
    vRetorno[7] = sMes;
    vRetorno[8] = sAno;

    return vRetorno;
  }

  show(r, context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Aviso!"),
          content: Text(r),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
