import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_validation/app/page/politica.dart';
import 'package:firebase_validation/seguranca.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const CPF = '###.###.###-##';
const CNPJ = '###.###.###/####-##';

class ConfigPage extends StatefulWidget {
  final bool motorista;
  final bool cpf;
  final bool placa;
  final bool filled;
  final Color appBarColor;
  final Color appBarTextColor;
  final bool gateway;
  final String aplicativo;
  ConfigPage(
      {this.motorista = false,
      this.placa = false,
      this.filled = false,
      this.cpf = false,
      this.appBarColor = Colors.transparent,
      this.appBarTextColor = Colors.white,
      this.gateway = false,
      this.aplicativo = ""});
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  Seguranca s = new Seguranca(email: "@cgi.com.br", password: "Mariana23");

  TextEditingController _edtCodigoText = TextEditingController();
  TextEditingController _edtUsuarioText = TextEditingController();
  TextEditingController _edtSenhaText = TextEditingController();
  TextEditingController _edtServicoText = TextEditingController();
  TextEditingController _edtMotoristaText = TextEditingController();
  TextEditingController _edtPlacaText = TextEditingController();

  FocusNode _edtCodigoFocus = FocusNode();
  FocusNode _edtUsuarioFocus = FocusNode();
  FocusNode _edtSenhaFocus = FocusNode();
  FocusNode _edtServicoFocus = FocusNode();
  FocusNode _edtMotoristaFocus = FocusNode();
  FocusNode _edtPlacaFocus = FocusNode();

  bool _isLoading = false;
  Map<String, dynamic> _version = {};

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final maskFormatter = new MaskTextInputFormatter(mask: CPF);

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    setValues();
  }

  setValues() async {
    this._edtUsuarioText.text = await _redPreferences("edtUsuario");
    this._edtCodigoText.text = await _redPreferences("edtCodigo");
    this._edtSenhaText.text = await _redPreferences("edtSenha");
    this._edtServicoText.text = await _redPreferences("edtServico");
    if (this.widget.motorista) {
      this._edtMotoristaText.text = await _redPreferences("edtMotorista");
    }
    if (this.widget.placa) {
      this._edtPlacaText.text = await _redPreferences("edtPlaca");
    }

    _version = await s.getBuildVersion();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: !_isLoading,
          backgroundColor: widget.appBarColor,
          title: Text(
            "Configurações",
            style: TextStyle(color: widget.appBarTextColor),
          ),
          iconTheme: IconThemeData(color: widget.appBarTextColor),
          actions: <Widget>[
            !_isLoading
                ? IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      _grava();
                    })
                : Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Center(
                        child: SizedBox(
                            height: 25.0,
                            width: 25.0,
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                              backgroundColor: Colors.white,
                            )))),
          ],
        ),
        body: Container(
            padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 20),
            child: Form(
              key: _formKey,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 100,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Informe o código de acesso';
                                      }
                                      return null;
                                    },
                                    focusNode: _edtCodigoFocus,
                                    controller: _edtCodigoText,
                                    decoration: InputDecoration(
                                        labelText: "Código de Acesso",
                                        filled: this.widget.filled),
                                    keyboardType: TextInputType.text)),
                            this.widget.motorista
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: TextFormField(
                                        validator: (val) {
                                          if (val.isEmpty) {
                                            return 'Informe o código do motorista';
                                          }
                                          return null;
                                        },
                                        focusNode: _edtMotoristaFocus,
                                        controller: _edtMotoristaText,
                                        decoration: InputDecoration(
                                            labelText: "Código do Motorista",
                                            filled: this.widget.filled),
                                        keyboardType: TextInputType.number))
                                : Container(),
                            this.widget.cpf
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: TextFormField(
                                      validator: (val) {
                                        if (val.isEmpty) {
                                          return 'Informe o CPF';
                                        }

                                        return null;
                                      },
                                      focusNode: _edtUsuarioFocus,
                                      controller: _edtUsuarioText,
                                      decoration: InputDecoration(
                                          labelText: "CPF",
                                          filled: this.widget.filled),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        maskFormatter
                                      ],
                                    ))
                                : Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: TextFormField(
                                        validator: (val) {
                                          if (val.isEmpty) {
                                            return 'Informe o usuário';
                                          }
                                          return null;
                                        },
                                        focusNode: _edtUsuarioFocus,
                                        controller: _edtUsuarioText,
                                        decoration: InputDecoration(
                                            labelText: "Usuário",
                                            filled: this.widget.filled),
                                        keyboardType: TextInputType.text)),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                    validator: (val) {
                                      if (val.isEmpty) {
                                        return 'Informe a senha';
                                      }
                                      return null;
                                    },
                                    focusNode: _edtSenhaFocus,
                                    controller: _edtSenhaText,
                                    decoration: InputDecoration(
                                        labelText: "Senha",
                                        filled: this.widget.filled),
                                    keyboardType: TextInputType.text,
                                    obscureText: true)),
                            this.widget.placa
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: TextFormField(
                                        validator: (val) {
                                          if (val.isEmpty) {
                                            return 'Informe a placa do veiculo';
                                          }
                                          return null;
                                        },
                                        focusNode: _edtPlacaFocus,
                                        controller: _edtPlacaText,
                                        decoration: InputDecoration(
                                            labelText: "Placa do veículo",
                                            filled: this.widget.filled),
                                        keyboardType: TextInputType.text))
                                : Container(),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: TextFormField(
                                    enabled: false,
                                    focusNode: _edtServicoFocus,
                                    controller: _edtServicoText,
                                    decoration: InputDecoration(
                                        labelText: "Serviço",
                                        filled: this.widget.filled),
                                    keyboardType: TextInputType.url)),
                            Container(
                                padding: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    _version != null
                                        ? Text(
                                            "Versão atual do aplicativo: ${_version['v']}")
                                        : Container(),
                                    _version != null
                                        ? Text(
                                            "Versão atual do build: ${_version['b']}")
                                        : Container(),
                                  ],
                                )),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              height: 50,
                              width: double.infinity,
                              child: RaisedButton(
                                  child: Text(
                                    "Política de Privacidade",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PoliticaPage()));
                                  }),
                            ),
                          ],
                        ),
                      )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            _launchSocial('fb://profile/338379049642068',
                                'https://www.facebook.com/CGISoftware');
                          },
                          child: Icon(
                            FontAwesomeIcons.facebook,
                            color: Color(0xff3A5997),
                            size: 40,
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              _launchSocial(
                                  'https://www.instagram.com/cgisoftware/',
                                  'https://www.instagram.com/cgisoftware/');
                            },
                            child: Icon(
                              FontAwesomeIcons.instagram,
                              color: Color(0xff3E729A),
                              size: 40,
                            )),
                        InkWell(
                            onTap: () {
                              _launchSocial(
                                  'linkedin://company/cgisoftware/about/',
                                  'https://www.linkedin.com/company/cgisoftware/about/');
                            },
                            child: Icon(
                              FontAwesomeIcons.linkedin,
                              color: Color(0xff027BB6),
                              size: 40,
                            )),
                        InkWell(
                            onTap: () {
                              _launchSocial(
                                  'twitter://user?screen_name=CgiSoftware',
                                  'https://twitter.com/CgiSoftware');
                            },
                            child: Center(
                              child: Icon(
                                FontAwesomeIcons.twitter,
                                color: Color(0xff2995E8),
                                size: 40,
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  void _launchSocial(String url, String fallbackUrl) async {
    // Don't use canLaunch because of fbProtocolUrl (fb://)
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      print(e);
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  Future<Null> _savePreferences(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  Future<String> _redPreferences(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String sRetorno = sharedPreferences.getString(key);

    if (sRetorno == null)
      return "";
    else
      return sRetorno;
  }

  void _grava() async {
    if (_formKey.currentState.validate()) {
      this._isLoading = true;
      setState(() {});
      await _savePreferences("edtCodigo", this._edtCodigoText.text);
      await _savePreferences("edtUsuario", this._edtUsuarioText.text);
      await _savePreferences("edtSenha", this._edtSenhaText.text);
      await _savePreferences("edtServico", this._edtServicoText.text);
      await _savePreferences("edtMotorista", this._edtMotoristaText.text);
      await _savePreferences("edtPlaca", this._edtPlacaText.text);
      var r = await s.execute();
      print(r);
      if (r != "") {
        s.show(r, context);
        this._isLoading = false;
        setState(() {});
      } else {
        this._edtServicoText.text = await _redPreferences("edtServico");
        if (widget.gateway) {
          try {
            Dio dio = new Dio();

            Response response = await dio
                .post("https://gateway.cgisoftware.com.br/sessao", data: {
              "usuario": this._edtUsuarioText.text,
              "senha": this._edtSenhaText.text,
              "pacific": this._edtServicoText.text,
              "versao": int.parse(await _redPreferences("versao_minima")),
              "cliente": this._edtCodigoText.text,
              "aplicativo": widget.aplicativo
            });

            if (response.data["token"] != null) {
              print(response.data["token"]);
              await _savePreferences("token", response.data["token"]);

              this._isLoading = false;
              setState(() {});

              final snackBar = SnackBar(
                content: Text('Configurações salvar com sucesso!'),
                // action: SnackBarAction(
                //   label: 'OK',
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
              );

              _scaffoldKey.currentState.showSnackBar(snackBar);
              await Future.delayed(new Duration(milliseconds: 2000));
              Navigator.pop(context);
            }
          } catch (e) {
            s.show(e.toString(), context);
          }
        } else {
          this._isLoading = false;
          setState(() {});

          final snackBar = SnackBar(
            content: Text('Configurações salvar com sucesso!'),
            // action: SnackBarAction(
            //   label: 'OK',
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
          );

          _scaffoldKey.currentState.showSnackBar(snackBar);
          await Future.delayed(new Duration(milliseconds: 2000));
          Navigator.pop(context);
        }
      }
    }
    // Navigator.of(context).pop(true);
  }
}
